# XML/UI Referencia Completa de XOne — Índice

Esta referencia esta dividida en 5 sub-archivos por área temática. Carga **solo el sub-archivo que necesites** para generar código concreto — reduce el contexto a procesar de ~3,650 lineas a ~610-900 por sub-archivo.

## Reglas generales de naming (aplican a coll/group/frame/prop)

> 1. **`name` es case-sensitive.** `name="MiNombre"` y `name="minombre"` son nombres **distintos** para XOne. Aplica también a TODAS las referencias cruzadas: `self.X`, `mapcol`, `linkedto`, `inherits`, `<field name="...">`, `getControl("...")`, `ui.openEditView("...")`, `appData.getCollection("...")`, etc.
> 2. **El `id` de `<group>` es obligatorio y único en la coll.** Dos `<group id="1">` en la misma `<coll>` producen comportamiento indefinido. Convencion: `id="1"`, `id="2"`, ... normales; `id="999"` HEADER fijo (`class="groupfixed_header"`) y `id="0"` FOOTER fijo (`class="groupfixed_footer"`).
> 3. **Unicidad de `name` en la coll.** No puede repetirse el `name` de ningun nodo dentro de una `<coll>`, aunque estén en `<group>` o `<frame>` distintos.

## Índice de sub-archivos

| Sub-archivo | Contenido | Cuando usar |
|-------------|-----------|-------------|
| **[a - Estructura: archivos, coll, frame, group](xone-xml-ui-a-estructura.md)** | §1 estructura `.xne`, declaración XML, jerarquía, convencion `MAP_`. §2 nodo `<coll>` (atributos, herencia `inherits`, composición `<include-layout>`). §5 nodo `<frame>` (flotantes, bottom sheet, animaciones). §6 nodo `<group>` (tabs, drawer, navegación). | Diseño de la jerarquía de una pantalla, configuración de la coll, layout entre grupos y frames, headers/footers fijos, drawers. |
| **[b - Nodo prop y tipos](xone-xml-ui-b-prop-tipos.md)** | §3 nodo `<prop>` entero: todos los atributos por categoría (dimensiones, layout, label, visuales, borde, comportamiento, tooltip, eventos inline, mapeo, IMG, B, X, NC, DR). §4 tabla autoritativa de tipos validos (T, TN, N, D, DT, TT, B, L, TL (alias legacy), X, IMG, PH, VD, DR, NC, Z, WEB, AT, THTML, O) y viewmodes. | Crear cualquier campo o control en una pantalla. Es el sub-archivo más consultado. |
| **[c - Contents, asfilter, eventos, visibilidad, macros](xone-xml-ui-c-contents-eventos.md)** | §7 nodo `<contents>` (lista embebida, kanban, coverflow, stepper, OTP, markdown). §7b `<asfilter>`. §8 event handlers detallados (`create`, `before-edit`, `load`, `onchange`, `selecteditem`, `onback`, `update`, `insert`, `delete`, custom). §9 visibilidad bitmask. §10 macros completas (sistema, fecha, app, dispositivo, `##FLD_X##`, coll, animación). | Disenar listas embebidas, filtros dinámicos, handlers de eventos, macros parametricas en SQL. |
| **[d - Patrones de pantalla, mappings, colecciones adicionales](xone-xml-ui-d-patrones-mappings.md)** | §11 8 patrones completos (menú, login con huella, RecyclerView, formulario, dashboard, mapa, calendario, drawer). §12 estructura obligatoria `mappings.xne`. §13 convención de colecciones adicionales en `.xne` separados. | Plantillas listas para copiar y adaptar. Configurar `mappings.xne` y entender qué va en cada `.xne`. |
| **[e - Mapas, GPS y errores](xone-xml-ui-e-mapas-errores.md)** | §15 API completa de mapas (atributos del prop type=Z viewmode=mapview, API JS del control, GPS, GpsTools). §14 17 errores comunes a evitar (CSS web, `##PREF##`, tipos invalidos, `objname`, APIs web, `progid`, encoding, `mappings.xne`, etc.). | Implementar mapas con marcadores/rutas. Validar código antes de entregar al usuario. |

## Referencia rápida — atajos

| Quiero... | Sub-archivo + sección |
|-----------|----------------------|
| Crear una coll de datos | [a §2](xone-xml-ui-a-estructura.md#2-nodo-coll---referencia-completa) |
| Headers/footers fijos | [a §6 (drawer + groupfixed)](xone-xml-ui-a-estructura.md#6-nodo-group---referencia-completa) |
| Bottom Sheet | [a §5 (Bottom Sheet)](xone-xml-ui-a-estructura.md#atributos-de-bottom-sheet) |
| `inherits` herencia | [a §2 (`inherits`)](xone-xml-ui-a-estructura.md#herencia-entre-colecciones-con-inherits) |
| `<include-layout>` composición | [a §2 (`<include-layout>`)](xone-xml-ui-a-estructura.md#composicion-xml-con-include-layout) |
| Tabla completa de tipos prop | [b §4](xone-xml-ui-b-prop-tipos.md#4-tipos-de-propiedades-type---tabla-completa) |
| Combo / selector | [b §3 (mapeo)](xone-xml-ui-b-prop-tipos.md#atributos-de-mapeo-de-datos-comboslookups) |
| Firma / dibujo (DR) | [b §3 (`type="DR"`)](xone-xml-ui-b-prop-tipos.md#atributos-para-dibujofirma-typedr) |
| Lista / Kanban / Coverflow / Stepper / OTP / Markdown | [c §7 (viewmodes)](xone-xml-ui-c-contents-eventos.md#viewmodes-disponibles-para-contents) |
| `<asfilter>` barra de busqueda | [c §7b](xone-xml-ui-c-contents-eventos.md#7b-nodo-asfilter---filtros-de-busqueda) |
| Handlers de eventos | [c §8](xone-xml-ui-c-contents-eventos.md#8-event-handlers-detallados) |
| Bitmask de visibilidad | [c §9](xone-xml-ui-c-contents-eventos.md#9-sistema-de-visibilidad) |
| Macros del sistema | [c §10](xone-xml-ui-c-contents-eventos.md#10-macros-del-sistema) |
| `setMacro`/`getMacro` | [c §10 (Macros de coll)](xone-xml-ui-c-contents-eventos.md#macros-de-coleccion--nodo-xml-macro--setmacrogetmacro) |
| Plantilla login con huella | [d §11 Patron 2](xone-xml-ui-d-patrones-mappings.md#patron-2-login-con-huella-dactilar) |
| Plantilla RecyclerView | [d §11 Patron 3](xone-xml-ui-d-patrones-mappings.md#patron-3-lista-con-recyclerview) |
| Plantilla dashboard | [d §11 Patron 5](xone-xml-ui-d-patrones-mappings.md#patron-5-dashboard-con-tabs-y-graficos) |
| Plantilla drawer | [d §11 Patron 8](xone-xml-ui-d-patrones-mappings.md#patron-8-drawer-lateral) |
| `mappings.xne` campos mínimos | [d §12](xone-xml-ui-d-patrones-mappings.md#12-mappingsxne---estructura-obligatoria) |
| Mapa con marcadores | [e §15.1-15.2](xone-xml-ui-e-mapas-errores.md#15-mapas-atributos-eventos-y-api-javascript) |
| `ui.startGps` con callbacks | [e §15.3](xone-xml-ui-e-mapas-errores.md#153-gps-uistartgps-uistopgps-y-checkgpsstatus) |
| `GpsTools` (distancias, geocoding) | [e §15.4](xone-xml-ui-e-mapas-errores.md#154-gpstools-api-de-utilidades-gps) |
| Errores comunes a evitar | [e §14](xone-xml-ui-e-mapas-errores.md#14-errores-comunes-a-evitar) |

---

*Índice generado a partir del documento original. Cada sub-archivo es autocontenido y puede leerse sin necesidad de los demas.*
