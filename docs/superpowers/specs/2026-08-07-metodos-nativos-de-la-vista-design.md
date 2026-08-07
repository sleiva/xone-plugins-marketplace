# Métodos nativos de la vista — diseño

**Fecha:** 2026-08-07 · **Estado:** aprobado, pendiente de implementar · **Versión objetivo:** `1.3.0`

## De dónde sale

El 2026-08-07 se corrigió un anti-patrón falso en `xone-development` (v1.2.1). Decía que
`setBlur`/`setSaturation` son «funciones que implementa el proyecto, no están en `ui`». No lo
son: las expone la **vista nativa** de Android/iOS que hay bajo el frame, y llegan al JS por el
objeto que devuelve la ventana. El proyecto solo escribe el envoltorio (`doBlurEffect`).

El daño no fue la imprecisión. Al enunciarse solo en negativo y sin dar la forma correcta, la
fila hacía que **una búsqueda por `setBlur` se leyera como «no existe»** — y eso fabricó un
falso negativo que llegó a proponerse como justificación para una skill nueva
(`SKILLS_NEEDED.md` §3, consecuencia 1).

La lección: el corpus no tenía dónde decir que existe una capa nativa debajo. Este documento
diseña ese sitio.

## Problema

Dos cosas distintas viven hoy sin separar:

1. **Lo que XOne expone** sobre la ventana y los controles —`exit`, `refresh`, `bind`,
   `getControl`, `setBottomSheetState`, `setStatusBarColor`, `scrollToTop`, `startChronometer`,
   `setCircularReveal`…—. Está documentado, repartido por `references/javascript/`.
2. **Lo que expone la vista nativa** por debajo, alcanzable por los mismos objetos. No está
   documentado en ninguna parte, y el único caso conocido (`setBlur`/`setSaturation`) solo
   aparecía como una negación dentro de una tabla de anti-patrones.

**Todo lo documentado como API es de XOne.** Ésa es la regla que ordena el corpus, y se
mantiene: este diseño no reclasifica nada de lo existente. Añade el sitio donde vive lo otro.

## Decisión

**Fichero propio:** `references/javascript/metodos-nativos-de-la-vista.md`.

Descartadas:

- **Sección en `metodos-de-los-controles.md`** — ese fichero existe para decir qué expone XOne
  por cada tipo de control. Meter ahí lo nativo difumina justo la frontera que se quiere marcar.
- **Sección en `ui-navegacion-mensajes-y-vista.md`** (donde hoy vive `setBlur`) — ese fichero va
  de `ui`: navegación y mensajes. La lista quedaría tan poco encontrable como estaba, que es el
  fallo original.

El criterio decisivo es la encontrabilidad: un fichero cuyo nombre y contenido son «métodos
nativos de la vista» hace que `grep setBlur` aterrice en una página que **explica**, en vez de
en una celda que niega.

## Estructura del fichero

1. **El mecanismo.** `ui.getView(self)` devuelve la ventana; indexarla (`window["frmX"]`) o
   `getControl("X")` devuelven frames y controles. Esos objetos son envoltorios sobre la vista
   nativa —`View` en Android, `UIView` en iOS—. XOne expone su API sobre ellos; lo que no es de
   XOne cae directo a la vista nativa.
2. **Qué contrato hay: ninguno.** No es API de XOne, no está soportada, puede diferir entre
   Android e iOS y cambiar entre versiones sin aviso. Quien la use asume eso.
3. **Regla de admisión**, escrita en el propio fichero para que no se pierda:
   > Una entrada entra solo si se ha confirmado funcionando, anotando en qué plataforma.
   > Lo no confirmado no se escribe.
4. **La lista.** Tabla: método · sobre qué objeto · qué hace · plataforma confirmada · ejemplo.
5. **Cómo se envuelve.** El patrón `doBlurEffect`: por qué se escribe un envoltorio en
   `functions.js` en lugar de llamar suelto —resuelve `ui.getView` una vez y comprueba el null—.

## Contenido inicial

Dos entradas, ambas confirmadas en **Android e iOS**:

| Método | Sobre | Qué hace |
|---|---|---|
| `setBlur(n)` | frame o control | Desenfoque. `0` = sin efecto; valores mayores, más desenfoque |
| `setSaturation(n)` | frame o control | Saturación. `0` = escala de grises; valores mayores, más saturación |

Con el ejemplo que ya existe en el corpus: los envoltorios `doBlurEffect`/`doSaturationEffect` y
el patrón de slider (`<prop viewmode="slider" min="0" max="32">` más el `<onchange>`).

## Enganches

- **Índice de `SKILL.md`:** una línea junto a las otras 17 de `javascript/`.
- **Fila de anti-patrones de `setBlur`:** pasa a apuntar al fichero en vez de explicarlo entero
  en una celda.
- **`metodos-de-los-controles.md` §8 (Frames):** puntero — «además de éstos, la vista nativa
  expone otros; ver …». Así quien busca métodos de frame encuentra la frontera.

## Qué NO hace

- **No enumera la API de vistas de Android/iOS.** No es una lista que pertenezca a este
  repositorio, y no hay fuente de verdad para ella aquí.
- **No reclasifica lo ya documentado.** Todo lo documentado como API es de XOne; no hay nada
  que etiquetar.

## Criterios de aceptación

- [ ] Existe `references/javascript/metodos-nativos-de-la-vista.md` con las cinco partes.
- [ ] La regla de admisión está escrita dentro del fichero.
- [ ] Las dos entradas constan como confirmadas en Android e iOS.
- [ ] `grep -r setBlur` sobre el corpus devuelve el fichero nuevo, y lo que devuelve explica qué
      es y cómo se llama, no solo qué no es.
- [ ] Los tres enganches están puestos.
- [ ] `CHANGELOG.md` tiene entrada `1.3.0` en «Añadido», y la versión sube en
      `.claude-plugin/marketplace.json` y `plugins/xone-development/.claude-plugin/plugin.json`.
