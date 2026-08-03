# Tareas pendientes

Lista operativa de trabajo pendiente sobre `xone-plugins-market`. Detalle técnico y contexto en [`docs/ARCHITECTURE.md`](ARCHITECTURE.md) (§13).

## Estado

- [x] **1. Frontmatter `name` en todos los `SKILL.md`**
- [x] **2. Refactor de skills con `references/`**
  - [x] 2.1 `xone-javascript`
  - [x] 2.2 `xone-device`
  - [x] 2.3 `xone-data-integration`
  - [x] 2.4 `xone-css`
  - [x] 2.5 `xone-debugging`
  - [x] 2.6 `xone-xml-ui` (no procede: 157 líneas)
- [ ] **3. Pruebas de activación real**
- [x] **4. Configurar `opencode.json` con `skills.paths`**
- [ ] **5. Versiones de XOne soportadas**
- [ ] **6. Revisores expertos por área**

---

## 1. Frontmatter `name` en todos los `SKILL.md`

**Prioridad:** Alta · **Esfuerzo:** Bajo · **Ref:** ARCHITECTURE.md §3.5

Añadir `name: <skill-name>` al frontmatter de los 9 `SKILL.md`. El valor debe coincidir exactamente con el nombre del directorio y seguir el patrón `^[a-z0-9]+(-[a-z0-9]+)*$`.

**Rationale:** OpenCode exige `name` obligatorio; Claude Code lo trata como opcional. Sin él, OpenCode no carga las skills.

**Skills afectadas (9):**

- [ ] `xone-development/SKILL.md` → `name: xone-development`
- [ ] `xone-xml-ui/SKILL.md` → `name: xone-xml-ui`
- [ ] `xone-javascript/SKILL.md` → `name: xone-javascript`
- [ ] `xone-css/SKILL.md` → `name: xone-css`
- [ ] `xone-data-integration/SKILL.md` → `name: xone-data-integration`
- [ ] `xone-device/SKILL.md` → `name: xone-device`
- [ ] `xone-verification/SKILL.md` → `name: xone-verification`
- [ ] `xone-debugging/SKILL.md` → `name: xone-debugging`
- [ ] `xone-review/SKILL.md` → `name: xone-review`

**Verificación:** `opencode` arranca y lista las 9 skills en el tool `skill`.

---

## 2. Refactor de skills con `references/`

**Prioridad:** Alta/Media · **Esfuerzo:** Medio · **Ref:** ARCHITECTURE.md §10.1

Aplicar el patrón estándar de Agent Skills: mantener `SKILL.md` por debajo de 500 líneas con la guía esencial, reglas y anti-patrones, y mover el material extenso a `references/` con carga perezosa.

**Patrón objetivo por skill:**

```text
<skill-name>/
├── SKILL.md              # <500 líneas — overview, reglas, anti-patrones
└── references/
    ├── api.md            # API detallada
    ├── examples.md       # Snippets extensos
    └── troubleshooting.md # Errores y soluciones
```

**Referenciar desde `SKILL.md`:**

```markdown
## Recursos adicionales
- Para la API completa, ver [references/api.md](references/api.md)
- Para ejemplos extensos, ver [references/examples.md](references/examples.md)
- Para errores y soluciones, ver [references/troubleshooting.md](references/troubleshooting.md)
```

### 2.1. `xone-javascript` — Alta

**Líneas actuales:** 419 · **Objetivo:** ~250-300 en `SKILL.md`

| Queda en `SKILL.md` | Va a `references/` |
|---------------------|---------------------|
| Frontmatter + intro + tabla de objetos globales + eventos del ciclo de vida + acceso básico a `self` + patrones críticos (lock/unlock, startBrowse, contexto `self`, WaitDialog) + reglas de seguridad y rendimiento | `api.md`: listas exhaustivas de métodos de `DataCollection`, `UserInterface`, `AppData`, `SqlManager` |
| | `examples.md`: snippets extensos de `$http`, GPS, contents, cursor SQL, filter/restore |
| | `troubleshooting.md`: tabla de errores comunes y soluciones |

### 2.2. `xone-device` — Alta

**Líneas actuales:** 429 · **Objetivo:** ~250-300 en `SKILL.md`

| Queda en `SKILL.md` | Va a `references/` |
|---------------------|---------------------|
| Frontmatter + intro + permisos + GPS (inicio y lectura) + cámara + firma + buenas prácticas | `api.md`: API completa de `biometricsManager`, `fingerprintManager`, `bluetoothSerial`, `XOnePrinter`, `XOneNFC`, `WebSocket`, `DeviceInfo`, `WifiManager`, `systemSettings`, `GpsTools`, `BarcodeGenerator`, `codeScanner` |
| | `examples.md`: snippets de Bluetooth, NFC/DNIe, WebSocket, selectores de fecha/hora, utilidades de `ui` |
| | `troubleshooting.md`: tabla de errores y diagnóstico |

### 2.3. `xone-data-integration` — Media

**Líneas actuales:** 331 · **Objetivo:** ~200 en `SKILL.md`

| Queda en `SKILL.md` | Va a `references/` |
|---------------------|---------------------|
| Frontmatter + intro + modelo de datos local (`##PREF##`, ROWID) + reglas de SQL seguro + TLS + buenas prácticas | `api.md`: API completa de `SqlManager`, `$http` (verbos, parámetros, future), `OAuth2`, `replica`, `crypto` |
| | `examples.md`: snippets de `$http`, SqlManager, OAuth2, réplica, sys-message, encriptación |
| | `troubleshooting.md`: tabla de errores y diagnóstico |

### 2.4. `xone-css` — Media

**Líneas actuales:** 319 · **Objetivo:** ~200 en `SKILL.md`

| Queda en `SKILL.md` | Va a `references/` |
|---------------------|---------------------|
| Frontmatter + intro + selectores + unidades + colores + herencia + estilos dinámicos + buenas prácticas | `reference.md`: tabla completa de atributos (dimensiones, fuentes, texto, fondo, bordes, sombras, visibilidad, grupos/tabs), cascada de archivos, temas, animaciones |
| | `troubleshooting.md`: tabla de errores CSS web vs XOne |

### 2.5. `xone-debugging` — Media

**Líneas actuales:** 298 · **Objetivo:** ~180 en `SKILL.md`

| Queda en `SKILL.md` | Va a `references/` |
|---------------------|---------------------|
| Frontmatter + intro + proceso de diagnóstico + herramientas + secciones de síntomas más frecuentes (pantalla vacía, botón mudo, self null) | `troubleshooting.md`: tabla de errores recurrentes por capa, secciones detalladas de onchange, refresh, lock/unlock, MAP_, estilos, imagen, GPS, réplica, errores -8100/-11888 |

### 2.6. `xone-xml-ui` — Baja

**Líneas actuales:** 157 · **Decisión:** borderline — revisar tras las anteriores.

Si se decide refactorizar, el candidato a extraer es la lista de tipos válidos y los ejemplos de combo/mapa/contents a `references/examples.md`.

### Skills que no requieren refactor

- `xone-development` (60 líneas)
- `xone-verification` (111 líneas)
- `xone-review` (168 líneas)

**Verificación por skill:** `wc -l SKILL.md` < 500; `opencode` carga la skill y el agente puede `Read` los archivos de `references/`.

---

## 3. Pruebas de activación real

**Prioridad:** Media · **Esfuerzo:** Alto · **Ref:** ARCHITECTURE.md §13.3

Definir 1–2 proyectos XOne mínimos de prueba y un script que valide que, dada una tarea de prueba, el agente invoca la skill correcta sin intervención del usuario.

**Cobertura mínima:**

- [ ] Proyecto XOne de prueba con XML, JS y CSS mínimos
- [ ] Tarea XML → debe invocar `xone-xml-ui`
- [ ] Tarea JavaScript → debe invocar `xone-javascript`
- [ ] Tarea de validación → debe invocar `xone-verification`
- [ ] Script de smoke que ejecute las tareas y reporte qué skill se activó

---

## 4. Configurar `opencode.json` con `skills.paths`

**Prioridad:** Alta · **Esfuerzo:** Bajo · **Ref:** ARCHITECTURE.md §3.4

Actualizar `opencode.json` para apuntar a la fuente canónica sin duplicación:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "skills": {
    "paths": ["./plugins/xone-development/skills"]
  }
}
```

**Verificación:** `opencode` arranca en el repo y lista las 9 skills en el tool `skill`.

---

## 5. Versiones de XOne soportadas

**Prioridad:** Media · **Esfuerzo:** Bajo (decisión) · **Ref:** ARCHITECTURE.md §12

Confirmar las versiones de XOne que se quieren soportar. Condiciona el tono y las reglas de todas las skills. Documentar la decisión en `ARCHITECTURE.md` y `README.md`.

---

## 6. Revisores expertos por área

**Prioridad:** Media · **Esfuerzo:** Bajo (coordinación) · **Ref:** ARCHITECTURE.md §7.2, §12

Confirmar los expertos responsables de cada área y el canal de revisión:

- [ ] Experto de XML/UI XOne
- [ ] Experto de JavaScript y runtime XOne
- [ ] Experto de CSS y diseño responsive XOne
- [ ] Experto de integraciones, seguridad y sincronización
- [ ] Desarrollador que valide la experiencia real con Claude Code y OpenCode

---

## Orden sugerido de ejecución

1. **Tarea 1** (frontmatter `name`) — desbloquea OpenCode, esfuerzo mínimo.
2. **Tarea 4** (`opencode.json` `skills.paths`) — desbloquea OpenCode junto con la 1.
3. **Tarea 2.1 y 2.2** (refactor de `xone-javascript` y `xone-device`) — mayor retorno.
4. **Tarea 2.3–2.5** (resto de refactors) — en paralelo si procede.
5. **Tarea 5** (versiones de XOne) — decisión que estabiliza todas las skills.
6. **Tarea 3** (pruebas de activación) — una vez estabilizadas las skills.
7. **Tarea 6** (revisores expertos) — en paralelo con el resto.
