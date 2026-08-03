# XOne CSS: referencia

## Selectores y atributos

`coll` admite `notab`, `show-toolbar`, `bgcolor`, `cell-bgcolor`, `cell-tpadding`, `cell-bpadding`, `show-selected-item` y `selected-item-start-index`. `prop` admite fuente, etiqueta, texto y color. Por tipo se usan `prop:B`, `prop:IMG`, `prop:NC`, `prop:T`, `prop:N`, `prop:Z` y otros tipos XML.

Una base habitual define `coll { notab: true; show-toolbar: false; bgcolor: #FFFFFF; cell-bgcolor: #F2F2F2; cell-tpadding: 2p; cell-bpadding: 2p; show-selected-item: false; selected-item-start-index: -1; }` y `prop { fontname: Roboto-Regular.ttf; fontsize: 14; labelbox: false; label-wrap: true; text-border: false; forecolor: #212121; }`. Para inputs Material usa `text-border: true` con `text-border-left/right/top: false`, `text-border-bottom: true`, `text-border-color`.

Dimensiones: `width`, `height`, `tmargin`, `bmargin`, `lmargin`, `rmargin`, `tpadding`, `bpadding`, `lpadding`, `rpadding`. Fuentes: `fontname`, `fontsize`, `fontbold`, `fontitalic`, `text-fontsize`, `labelfontsize`, `labelfont-bold`, `textfont-bold`. Texto: `forecolor`, estados disabled/focus, `text-align`, `align`, `lines`, `fixed-lines`, `locked`, `mask`. Fondo: `bgcolor`, `bgcolor-disabled`, `bgcolor-focus`, `text-bgcolor`, `text-bgcolor-focus`, `text-bgcolor-disabled`, `imgbk`.

Bordes: `text-border` y lados, `text-border-color`, `text-border-width`, `border`, `border-width`, `border-color`, `border-corner-radius` y esquinas, `border-top`, `border-bottom`, `framebox`, `grid-framebox`, `grid-text-border`. Sombras: `elevation`, `shadow-color`; no `box-shadow`/`text-shadow`.

Otros: `newline`, `scroll`, `fixed`/`orientation`, `floating`/`top`/`left`, `ripple-effect`, `undo-button`, `apply-css`, `zoom-controls`, `img`, `imgsel`, `img-width`, `img-height`. Tabs: `tab-visible`, `tab-height`, `tab-fontsize`, `tab-bgcolor`, `tab-forecolor`, `tab-selected-forecolor`, `tab-indicator-color`.

La visibilidad es una bitmask: `0` oculto, `1` edición, `2` lista, `3` edición+lista, `4` contents, `5` edición+contents, `6` lista+contents, `7` todos. Los frames fijos usan `fixed: true`, `orientation: top|bottom`, `width` y `height`; un layout habitual separa `.frameHeader`, `.frameBody { scroll: true; }` y `.frameFooter`.

## Herencia y cascada

Una clase hija hereda con `extends: .base;`; también puede heredar de `prop`, `prop:B`, `prop:T`, etc. La hija sobrescribe atributos heredados. La prioridad es: `default.css`, variante de plataforma, variante de orientación, variante de tema y atributos inline XML. Variantes convencionales: `default_ios.css`, `default_portrait.css`, `default_night.css`, `default_day.css`, `default_landscape.css`, `default_wear.css`.

## Animaciones

Usa `animation-in`, `animation-out`, `animation-in-delay`, `animation-out-delay`. Tokens: `##RIGHT_IN##`, `##RIGHT_OUT##`, `##LEFT_IN##`, `##LEFT_OUT##`, `##PUSH_IN##`, `##PUSH_OUT##`, `##PUSH_DOWN_IN##`, `##PUSH_DOWN_OUT##`, `##ALPHA_IN##`, `##ALPHA_OUT##`, `##ZOOM_IN##`, `##ZOOM_OUT##`, `##ROTATE3D_IN##`, `##ROTATE3D_OUT##`. Úsalos en transiciones de pantalla, no en elementos de lista.
