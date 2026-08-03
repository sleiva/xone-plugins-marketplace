# XOne CSS: troubleshooting

| CSS web / síntoma | Corrección XOne |
|---|---|
| `font-size: 14px` | `fontsize: 14` |
| `background-color: #fff` | `bgcolor: #FFFFFF` |
| `margin-top: 10px` | `tmargin: 10p` |
| `border-radius: 8px` | `border-corner-radius: 8` |
| `display: none` | `visible: 0` |
| `overflow: scroll` | `scroll: true` |
| alpha al final | alpha al inicio: `#AARRGGBB` |
| `font-weight: bold` | `fontbold: true` |
| `box-shadow` | `elevation` y `shadow-color` |
| Gradientes/Flexbox/media queries | No están soportados |

Si no se aplica CSS, comprueba que el archivo sea `default.css` en la raíz y esté referenciado desde `app.xml`; revisa nombre exacto de clase, `compatibility-mode` (si es `true` ignora CSS), unidades y atributos inline que puedan sobrescribirlo. Para imágenes verifica `icons/`/`files/`, formato PNG en producción y rutas `##APP##\\icons\\...`.
