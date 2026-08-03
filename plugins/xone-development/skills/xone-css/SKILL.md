---
name: xone-css
description: Estilos CSS en XOne. Usar al crear o modificar default.css y variantes, clases CSS, selectores coll/prop/prop:TYPE/group/frame, unidades p y %, colores #AARRGGBB, herencia con extends o @extend, variables :root/var(), calc(), @import, animaciones, temas light/dark o estilos dinámicos por campo.
---

# XOne CSS

Sistema de estilos propietario, con sintaxis parecida a CSS web pero atributos propios. Antes de editar, lee el `default.css` del proyecto y respeta sus convenciones de nombres de clase.

**No afirmes nada sobre un atributo o función que no esté en las referencias de esta skill.** Si algo no aparece, dilo y pide el dato en vez de deducirlo.

## Archivos

`default.css` en la raíz del proyecto es obligatorio y es el único que se declara en `app.xml`: `<style url="default.css" encoding="UTF-8" />`. Las variantes se cargan automáticamente por convención de nombre.

Si el atributo `compatibility-mode` del nodo `<app>` vale `true`, **el CSS se ignora por completo** — compruébalo antes de diagnosticar cualquier estilo que «no se aplica».

> El corpus documenta los nombres de variante de dos formas: con guion bajo (`default_night.css`, `default_ios.css`) y con punto (`default.night.css`, `default.ios.css`). Comprueba en el proyecto qué convención está en uso; no asumas una.

## Cascada

De menor a mayor prioridad: `default.css` → plataforma → orientación → tema → condiciones combinadas → **atributos inline en XML** (máxima prioridad). Lo más específico gana atributo por atributo, no bloque por bloque.

## Selectores

Solo estos: `coll`, `prop`, `prop:TYPE` (`prop:T`, `prop:N`, `prop:B`, `prop:NC`, `prop:Z`, `prop:IMG`, `prop:D`…), `group`, `frame` y `.clase`. Las clases se asignan con `class="..."` en el XML.

## Unidades

- `p` para dimensiones absolutas, `%` relativo al contenedor.
- Sin unidad: `fontsize`, `border-corner-radius`, `border-width`, `labelwidth`, `lines`, `visible`, `gallery-columns`, `img-width`, `img-height`.
- Prohibidas: `px`, `em`, `rem`, `vw`, `vh`, `vmin`, `vmax`.

## Colores

`#RRGGBB` o ARGB `#AARRGGBB`. **El alpha va primero**, al contrario que el `#RRGGBBAA` de CSS web.

## Herencia

Dos mecanismos equivalentes: el atributo `extends: .claseBase;` y la at-rule `@extend selector;`. Diferencia relevante: `@extend` detecta ciclos en tiempo de parseo (auto-referencia, 2 vías y N vías) y admite referencias adelantadas; `extends:` no detecta ciclos automáticamente. En un proyecto que ya usa `extends:`, mantén `extends:` por consistencia.

## Funciones del parser

**Sí soportadas:** comentarios `/* */` y `//`; `@import "ruta";` (solo al inicio del archivo); variables CSS en `:root` o locales de bloque, con `var(--nombre)` y `var(--nombre, fallback)`; `calc()` con `+ - * /`, paréntesis y `-` unario sobre números puros; `!important`; `!default`; selectores múltiples `a, b, c { }`.

**No soportadas:** `min()`, `max()`, `clamp()`, `@media`, pseudo-clases (`:hover`, `:focus`, `:active`, `:nth-child`), pseudo-elementos (`::before`, `::after`), selectores de atributo (`[data-attr]`), combinadores (`>`, `+`, `~`, descendiente), `transition`, `transform`, Flexbox, CSS Grid, `box-shadow`, `text-shadow` y gradientes.

Para sombras usa `elevation` y `shadow-color`. No hay abreviados `margin` ni `padding`: usa `tmargin`, `bmargin`, `lmargin`, `rmargin` y sus equivalentes `*padding`.

## Estilos dinámicos

No existe selector condicional puro. Dos vías: tokens `##FLD_CAMPO##` en el valor (funcionan en CSS y en atributos inline XML) y cambio de clase desde JavaScript en tiempo de ejecución.

## Anti-patrones

| Incorrecto | Correcto |
|---|---|
| `font-size: 14px` | `fontsize: 14` |
| `bg-color: #FFF` | `bgcolor: #FFFFFF` |
| `#00000080` (alpha al final) | `#80000000` (ARGB) |
| `margin: 10p` | `tmargin: 10p; bmargin: 10p; …` |
| `div.header { }` | `.header { }` |
| Duplicar atributos entre clases | `extends: .base;` y sobrescribir |
| `display: none` | `visible` (bitmask) |
| `box-shadow` | `elevation` + `shadow-color` |

## Referencias

Lee el fichero que corresponda antes de responder sobre atributos concretos, valores admitidos o ejemplos.

| Para… | Lee |
|---|---|
| Selectores en detalle, unidades, paletas y formatos de color | [references/selectores-unidades-colores.md](references/selectores-unidades-colores.md) |
| Atributos por categoría con ejemplos largos (dimensiones, márgenes, padding, fuentes, texto, fondo, bordes, sombras, visibilidad, Material) y el sistema `extends` completo | [references/propiedades-y-herencia.md](references/propiedades-y-herencia.md) |
| Tablas compactas de atributos por categoría, incluidas etiquetas, checkbox/toggles, imágenes e iconos, atributos de `coll`, machine learning y la tabla de transparencia alpha | [references/atributos-por-categoria.md](references/atributos-por-categoria.md) |
| `##FLD_CAMPO##`, cascada de dispositivo, `strict-mode`, animaciones y tokens, gráficos, calendario y mapa | [references/dinamicos-cascada-y-componentes.md](references/dinamicos-cascada-y-componentes.md) |
| Patrones Material (header/body/footer, botones, inputs, tarjetas, FAB, toolbar, item de lista), temas light/dark y un `default.css` + `colors.css` completos y comentados | [references/patrones-material-y-temas.md](references/patrones-material-y-temas.md) |
| Buenas prácticas, anti-patrones, checklist de validación y detalle de las funciones del parser (`@import`, variables, `calc()`, `!important`, `!default`, `@extend`, modo estricto) | [references/buenas-practicas-y-parser.md](references/buenas-practicas-y-parser.md) |

Si un estilo no se aplica, empieza por `compatibility-mode`; el resto de síntomas está en la skill `xone-debugging`.
