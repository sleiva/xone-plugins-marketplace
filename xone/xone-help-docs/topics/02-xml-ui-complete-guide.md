# Guía Completa de XML/UI en XOne — Índice

Esta guía esta dividida en 4 sub-archivos por área temática. Carga **solo el sub-archivo que necesites** para responder a una pregunta concreta — reduce el contexto que el LLM debe procesar de ~4,150 lineas a ~600-1,500 por sub-archivo.

## Reglas generales de naming (aplican a coll/group/frame/prop)

> 1. **`name` es case-sensitive.** `name="MiNombre"` y `name="minombre"` son nombres **distintos**. Aplica también a TODAS las referencias cruzadas: `self.X`, `mapcol`, `linkedto`, `inherits`, `<field name="...">`, `getControl("...")`, `ui.openEditView("...")`, `appData.getCollection("...")`.
> 2. **El `id` de `<group>` es obligatorio y único en la coll.** Dos `<group id="1">` en la misma `<coll>` producen comportamiento indefinido. Convencion: `id="1"`, `id="2"`, ... normales; `id="999"` HEADER fijo y `id="0"` FOOTER fijo.
> 3. **Unicidad de `name` en la coll.** No puede repetirse el `name` de ningun nodo dentro de una `<coll>`, aunque estén en `<group>` o `<frame>` distintos.

## Índice de sub-archivos

| Sub-archivo | Contenido | Cuando usar |
|-------------|-----------|-------------|
| **[02a - Estructura: coll, group, frame](02a-xml-estructura.md)** | §1 Introduccion, jerarquía, encoding. §2 Nodo `<coll>` (atributos, progid, colecciones especiales vs datos, ID/ROWID, prefijos `MAP_`/`@`/`%`/`$`). §3 Nodo `<group>` (tabs, fixed, drawer, floating). §4 Nodo `<frame>` (dimensiones, align, margenes, newline, bordes, scroll, anidamiento, bottom sheet). | Diseño de la jerarquía de una pantalla, configuración de la coll, layout entre grupos y frames, headers/footers fijos. |
| **[02b - Nodo prop y tipos](02b-xml-prop-tipos.md)** | §5 entero — Nodo `<prop>`: tabla completa de tipos (T, L, TL (alias legacy), THTML, N, TN, N2-N6, TN2-TN6, B, NC, D, DT, TT, X, IMG, PH, VD, DR, Z, WEB, AT, O), atributos comunes, `visible`, dimensiones, estilos, comportamiento, bordes, `disablevisible`/`disableedit`, props por tipo (texto, label, número, botón, checkbox, fecha/hora, imagen, foto, video/escaner, mapa, grid, kanban, coverflow, combo, web, slider, stepper, OTP, markdown, password, selector lookup, adjunto, THTML, DR, contextual-search, onchange, updates/formula). | Crear cualquier campo o control en una pantalla. Es el sub-archivo más consultado. |
| **[02c - Contents, macros, patrones de pantalla](02c-xml-contents-patrones.md)** | §6 Nodo `<contents>` (vinculacion con `type="Z"`, maestro-detalle, filtros `##FLD_CAMPO##`, `<asfilter>`). §7 Nodo `<macro>` y macros del sistema (`##PREF##`, `##USERID##`, `##APP##`, `##NOW_TIME##`, animaciones, `setMacro`/`getMacro`). §8 Patrones de pantalla completos (login, menú, lista, detalle, tabs, mapa, chat, dashboard, maestro-detalle, edit-inrow, multi-selección). | Disenar listas embebidas, filtros dinámicos, macros parametricas en SQL y plantillas completas de pantallas reales. |
| **[02d - Layouts avanzados, herencia y best practices](02d-xml-layouts-herencia.md)** | §9 Layouts avanzados (responsive, overlays/modales, sticky, FAB, recyclerview). §10 Herencia entre colecciones con `inherits` y composición con `<include-layout>`. §11 Best practices, anti-patrones, checklist de validación y restricción crítica de unicidad de nombres. | Reutilizar estructura entre varias pantallas, optimizar layouts complejos y validar XML antes de entregar. |

## Referencia rápida — atajos

| Quiero... | Sub-archivo + sección |
|-----------|----------------------|
| Crear una coleccion de datos | [02a §2](02a-xml-estructura.md#2-nodo-coll---colecciones) |
| Crear una pantalla `special="true"` | [02a §2.5](02a-xml-estructura.md#25-colecciones-especiales-vs-colecciones-de-datos) |
| Header/footer fijos | [02a §3.2](02a-xml-estructura.md#32-grupos-fijos-fixed-orientation-topbottom) |
| Drawer lateral | [02a §3.3b](02a-xml-estructura.md#33b-grupos-drawer-panel-lateral-deslizante) |
| Tabs | [02a §3.4](02a-xml-estructura.md#34-grupos-como-pestanas-tabs) |
| Bottom Sheet | [02a §4.5b](02a-xml-estructura.md#45b-bottom-sheet-panel-deslizante-inferior) |
| Tabla de tipos de prop | [02b §5.1](02b-xml-prop-tipos.md#51-tabla-completa-de-tipos) |
| Bitmask de visibilidad | [02b §5.3](02b-xml-prop-tipos.md#53-sistema-de-visibilidad-visible) |
| Combo (selector) | [02b §5.9.13](02b-xml-prop-tipos.md#5913-combo-typet--mapcolmapfld---selector-desplegable) |
| Lista / grid | [02b §5.9.12](02b-xml-prop-tipos.md#5912-gridlista-z) |
| Kanban | [02b §5.9.12c](02b-xml-prop-tipos.md#5912c-tablero-kanban-viewmodekanban) |
| CoverFlow | [02b §5.9.12d](02b-xml-prop-tipos.md#5912d-carrusel-cover-flow-viewmodecoverflow) |
| Mapa | [02b §5.9.11](02b-xml-prop-tipos.md#5911-mapa-typez-viewmodemapview) |
| Stepper numérico | [02b §5.9.17b](02b-xml-prop-tipos.md#5917b-stepper-numerico-viewmodestepper) |
| OTP | [02b §5.9.17c](02b-xml-prop-tipos.md#5917c-otp--entrada-de-codigos-viewmodeotp) |
| Markdown | [02b §5.9.17d](02b-xml-prop-tipos.md#5917d-texto-markdown-viewmodemarkdown) |
| Firma / dibujo (DR) | [02b §5.9.22](02b-xml-prop-tipos.md#5922-dr--firma--dibujo-moderno) |
| Filtros `<asfilter>` | [02c §6.6](02c-xml-contents-patrones.md#66-nodo-asfilter---filtros-de-busqueda-en-listas) |
| Macros del sistema | [02c §7.2](02c-xml-contents-patrones.md#72-macros-del-sistema) |
| `setMacro`/`getMacro` | [02c §7.5](02c-xml-contents-patrones.md#75-macros-de-coleccion--nodo-xml-macro--api-setmacrogetmacro) |
| Plantilla de login | [02c §8.1](02c-xml-contents-patrones.md#81-pantalla-de-login) |
| Maestro-detalle | [02c §8.9](02c-xml-contents-patrones.md#89-patron-maestro-detalle-completo) |
| Edit-inrow | [02c §8.10](02c-xml-contents-patrones.md#810-edicion-en-linea-edit-inrow) |
| Modal flotante | [02d §9.2](02d-xml-layouts-herencia.md#92-overlays-y-modales-flotantes) |
| `inherits` | [02d §10.1](02d-xml-layouts-herencia.md#101-herencia-entre-colecciones-con-inherits) |
| `<include-layout>` | [02d §10.2](02d-xml-layouts-herencia.md#102-composicion-con-include-layout) |
| Checklist XML | [02d §11.3](02d-xml-layouts-herencia.md#113-checklist-de-validacion-xml) |
| Unicidad de nombres | [02d §11.4](02d-xml-layouts-herencia.md#114-restriccion-critica-unicidad-de-nombres-de-nodos) |

---

*Índice generado a partir del topic 02 original. Cada sub-archivo es autocontenido y puede leerse sin necesidad de los demas.*
