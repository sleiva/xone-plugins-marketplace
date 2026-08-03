# Consolidación de skills: de nueve puertas a cuatro

Fecha: 2026-08-03 · Estado: aprobado, pendiente de implementar · Versión objetivo: `0.11.0`

## Problema

El plugin distribuye nueve skills: seis de conocimiento (`xone-development`, `xone-xml-ui`, `xone-javascript`, `xone-css`, `xone-data-integration`, `xone-device`) y tres de procedimiento (`xone-project-generator`, `xone-review`, `xone-debugging`). Dos defectos derivan de esa división:

1. **Las tareas llegan cruzadas, la taxonomía está dividida por área.** Modificar una pantalla toca `.xne`, un evento JavaScript y una clase CSS. Con activación automática, el caso a cubrir es el peor: que el agente abra una sola puerta y escriba el resto de memoria, es decir, que invente.
2. **La misma regla vive en tres o cuatro `SKILL.md`.** Los tipos de prop, el bitmask de visibilidad, la opcionalidad de `progid` y la sintaxis JavaScript soportada están escritos varias veces. Ya divergieron dos veces en una sola sesión de trabajo: el bit `8` de visibilidad se corrigió en un sitio y no en otro, y las reglas de sintaxis JS estaban mal del mismo modo en `xone-review` y en la desaparecida `xone-verification`. Ningún check automático detecta dos skills afirmando lo contrario.

`xone-data-integration` y `xone-device`, además, no son dominios: son superficies de API que se invocan desde JavaScript.

## Contexto que fija el diseño

- **Consumidor:** un agente experto en XOne. Un experto no decide qué manual abrir: tiene las reglas en la cabeza y consulta el detalle.
- **Activación:** automática y sin medir. El diseño debe ser seguro en el peor caso.
- **Hosts:** Claude Code, OpenCode y posiblemente Codex. `SKILL.md` es el formato común a los tres; el marketplace, los `commands/`, los hooks y las definiciones de agente **no** son portables. Por tanto las reglas duras tienen que vivir en una skill.

## Decisión

Cuatro skills, según el criterio: **el conocimiento va a referencias bajo una puerta; el procedimiento merece puerta propia, porque cambia cómo trabaja el agente.**

| Skill | Rol | Referencias |
|---|---|---|
| `xone-development` | Puerta de conocimiento: todas las reglas duras y el índice maestro. Absorbe `xml-ui`, `javascript`, `css`, `data-integration` y `device` | 54 ficheros, ~1,0 MB |
| `xone-project-generator` | Procedimiento: generar un proyecto desde cero, 12 fases | 14 ficheros, 273 KB |
| `xone-review` | Procedimiento: validar, smoke y auditar con `xone-simulator` | ninguna |
| `xone-debugging` | Procedimiento: síntoma → hipótesis → comprobación | 2 ficheros, 32 KB |

Se mantiene el nombre `xone-development` en lugar de renombrar a `xone-core`: evita rehacer las instrucciones de instalación y el `plugin.json`, y el nombre sigue siendo cierto.

### Alternativas descartadas

- **Seis puertas** (`development` + `ui` + `runtime` + las tres de procedimiento). Las dos puertas de conocimiento apenas se solapan, pero una tarea que toque pantalla y evento sigue necesitando dos — que es el caso más frecuente.
- **Siete puertas** (mínimo cambio: `data-integration` y `device` como referencias de `javascript`). Conserva intactos los dos defectos.

### Tensión declarada

En [`ANALISIS.md`](../../ANALISIS.md) se marcó como defecto que la `description` de `xone-development` fuera la unión de las demás. En este diseño vuelve a ser amplia, a propósito. La diferencia es real y conviene dejarla escrita para que no se lea como una regresión: en la v0.9.0 esa descripción competía con ocho skills cuyo conocimiento nunca entregaba, y su cuerpo de 61 líneas no derivaba a ningún sitio. Aquí no hay competidoras y la puerta lleva al índice completo.

## Estructura

```text
plugins/xone-development/skills/
├── xone-development/
│   ├── SKILL.md                    # ~250-280 líneas, techo duro 400
│   └── references/
│       ├── fundamentos/   (5)
│       ├── xml-ui/        (18)
│       ├── javascript/    (16)
│       ├── css/           (6)
│       ├── datos/         (5)
│       └── device/        (4)
├── xone-project-generator/
├── xone-review/
└── xone-debugging/
```

## Contenido del `SKILL.md` de conocimiento

Regla de corte: **arriba solo lo que evita una respuesta equivocada sin haber leído nada.**

Arriba:

- Preámbulo: no afirmar nada que no esté en las referencias; declarar la incertidumbre en vez de deducir.
- Reglas transversales: la fuente son los `.xne` (los `.xml` de colecciones son artefactos de XOneStudio), `progid` opcional, encoding coherente, `ID`/`ROWID` los gestiona la plataforma, evento correcto de inicialización, unicidad y case-sensitivity de nombres, prefijo `MAP_`.
- Sintaxis JavaScript soportada: sí / no / existe con implementación custom.
- Tablas canónicas cortas: tipos de prop, visibilidad de 4 bits, ciclo de vida.
- Anti-patrones, todos, agrupados por área: ~70 filas de una línea. Es el contenido con más valor por línea del plugin.
- Índice maestro, agrupado por área, con una fila por referencia.

Abajo: explicaciones, ejemplos largos, listas exhaustivas de métodos y atributos, y las reglas que solo importan estando ya dentro de un área (cascada CSS, detalle de GPS, mecanismos de herencia).

### Invariante

> **Una regla se escribe una vez, en la puerta de conocimiento. Las skills de procedimiento la referencian, no la repiten.**

Consecuencias:

- `xone-review` pierde su lista de 16 anti-patrones y sus reglas por capa. Conserva lo que es suyo: precondiciones del CLI, los cuatro comandos, los códigos del validador, la checklist de entrega, las severidades y el formato de reporte.
- `xone-debugging` conserva la tabla síntoma → causa y deja de repetir las reglas de `load`, `lock`/`unlock` y `MAP_`.

### Índice: decisión de forma

El índice va plano dentro del `SKILL.md`, con una fila por referencia agrupadas por área. Se descartó partirlo en un `README.md` por área (que dejaría arriba 6 líneas en vez de ~60): mete un salto extra antes de la lectura útil, y con activación automática el riesgo es que el agente se detenga en el primer salto y conteste.

## Portabilidad

La carpeta canónica no se mueve ni se duplica. Cada host apunta a ella:

| Host | Mecanismo | Estado |
|---|---|---|
| Claude Code | Marketplace, o `--plugin-dir` en desarrollo | Funciona |
| OpenCode | `skills.paths` en `opencode.json` | Funciona |
| Codex | Espera las skills en `~/.codex/skills/` o `.codex/skills/` | **Sin resolver** |

Para Codex, dos vías sin duplicar contenido: un `AGENTS.md` en la raíz que indique dónde están las skills, o symlinks en `.codex/skills/` hacia la carpeta canónica. Se elige `AGENTS.md` como vía principal —cero duplicación y sin los problemas de symlinks en Windows— y el symlink queda documentado como comodidad opcional. **Copiar las skills queda descartado**: reintroduce el problema de sincronización que se eliminó al borrar `scripts/sync.sh`.

**Límite de conocimiento declarado:** que Codex carga `SKILL.md` desde esas rutas está documentado; que descubra skills siguiendo una instrucción de `AGENTS.md` procede de fuentes de terceros, no de documentación oficial. Debe comprobarse empíricamente antes de afirmarlo en el README. **Si la comprobación falla, la vía principal pasa a ser el symlink** en `.codex/skills/`, y el `AGENTS.md` se queda como documentación para quien lea el repo. La implementación no debe dar por buena la vía de `AGENTS.md` sin ejecutar Codex contra el repo y confirmar que enumera las cuatro skills.

### Regla de capas

**Nada imprescindible puede vivir en la capa específica de un host.** `/xone-validate` es solo de Claude Code y es aceptable porque su contenido existe como flujo dentro de `xone-review`: en OpenCode y Codex no se pierde más que el atajo. Cualquier hook o definición de agente futuros entran bajo la misma regla.

## Migración

1. `git mv` de los 54 ficheros de referencia a `xone-development/references/<área>/`. No hay colisiones de nombre.
2. Fusionar los seis `SKILL.md` de conocimiento en uno, deduplicando cada regla y resolviendo contra el corpus cualquier contradicción restante.
3. Reescribir el índice agrupado por área con las rutas nuevas.
4. Quitar de `xone-review` y `xone-debugging` las reglas que pasan a la puerta de conocimiento, dejando punteros.
5. Borrar las cinco carpetas absorbidas.
6. Actualizar validador, README, `ARCHITECTURE.md` (§4, §10, §13.4), `CHANGELOG.md` y `TODO.md`.
7. Versión `0.11.0`: retirar skills rompe para quien conociera los nombres, y en SemVer 0.x un cambio incompatible sube la minor.

### Red de seguridad del paso 2

La dedupe «a ojo» es exactamente cómo se perdieron 46.000 líneas en la v0.9.0. Antes de borrar los cinco `SKILL.md`, un script de un solo uso extrae de los seis ficheros toda línea que sea viñeta (`- `), fila de tabla (`|`) o punto numerado, normaliza espacios, y comprueba para cada una que su texto aparece en el `SKILL.md` fusionado o en alguna referencia. Lo que no aparezca se lista para decidir explícitamente si se recupera o se descarta. Es un diff mecánico, no una lectura, y no se versiona: vive en el scratchpad como el troceador de la v0.10.0.

### Efecto secundario favorable

Varios punteros entre skills desaparecen al convertirse en rutas internas: el catálogo de eventos (vive en `xml-ui`, lo necesita `javascript`), los códigos `sys-message` (los necesita `data-integration`) y los métodos de los controles (los necesita `device`). Esa clase de puntero era una costura del diseño de nueve puertas.

## Verificación

Cambios en `scripts/validate-skills.sh`:

1. **Recursividad.** Las referencias pasan a estar en subcarpetas; la comprobación de enlaces y de huérfanas debe recorrer `references/**/*.md`. Hoy mira el nivel plano y dejaría de ver nada.
2. **Techo de tamaño propio.** Fallar por encima de 400 líneas en la puerta de conocimiento, más estricto que el límite estándar de 500. Sin check, el presupuesto se incumple.
3. **Guardián del invariante.** Una lista corta de marcadores canónicos declarada como array al principio de `scripts/validate-skills.sh`, junto al resto de la configuración del script: una cadena literal por regla (por ejemplo la cabecera de la tabla de visibilidad, la de tipos de prop, el encabezado de la sección de sintaxis JS y la frase que declara `progid` como opcional). El script cuenta en cuántos `SKILL.md` aparece cada marcador y falla si alguno aparece en más de uno. Es heurístico: detecta duplicación literal, no una paráfrasis. Aun así cubre el fallo real observado.

## Efecto sobre el trabajo pendiente

Este diseño **abarata las pruebas de activación** ([`TODO.md`](../../TODO.md) tarea 6). Con nueve puertas había que medir si el agente elige bien entre seis skills de conocimiento solapadas. Con una, esa pregunta casi desaparece y queda la que de verdad importa: *¿abre las referencias del índice, o contesta solo con las reglas de arriba?* Se mide con muchos menos prompts.

## Criterios de aceptación

- Cuatro skills en `plugins/xone-development/skills/`, y ninguna referencia huérfana ni enlace roto (lo verifica el validador).
- `SKILL.md` de `xone-development` por debajo de 400 líneas.
- Ninguna regla canónica escrita en más de un `SKILL.md`.
- Cada línea de regla de los seis `SKILL.md` originales localizable en el resultado.
- `scripts/validate-skills.sh` y `claude plugin validate` en verde.
- Las skills se enumeran en Claude Code y en OpenCode; para Codex, la vía de descubrimiento queda comprobada o declarada como no verificada.
