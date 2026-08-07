# XOne JavaScript — Métodos nativos de la vista (Android/iOS)

Contenido: el mecanismo · qué garantías hay · regla de admisión · efectos y estilo · transformaciones · orden de capas · lecturas · visibilidad y comportamiento · cómo se envuelve · pendiente de confirmar

---

## El mecanismo

`ui.getView(self)` devuelve la **ventana** del objeto actual. Indexarla por nombre devuelve un
frame o un control, igual que `getControl`:

```javascript
let window = ui.getView(self);       // ventana
let frame  = window["mi_frame"];     // frame
let ctrl   = window["MAP_MI_PROP"];  // control (equivale a getControl("MAP_MI_PROP"))
```

Esos tres objetos son **envoltorios sobre la vista nativa** de la plataforma: `View` en Android,
`UIView` en iOS. Los métodos de esta página actúan sobre esa vista, y por eso valen igual para
un frame que para un control: lo que hay debajo es una vista en ambos casos.

La API que XOne garantiza por cada **tipo** de control —campos, listas, mapas, cámara…— es otra
cosa, y vive en [métodos de los controles](metodos-de-los-controles.md).

## Qué garantías hay

Cada método se implementa sobre la vista nativa de cada plataforma, así que **la disponibilidad
y el comportamiento se confirman por plataforma, no en general**. La columna «Confirmado en» de
cada tabla es la que manda, y hay casos que además exigen una versión mínima del sistema —
`setBlur` y `setSaturation` necesitan **iOS 17+**.

Que un método funcione en una plataforma no implica que exista en la otra. Lo que no aparece en
estas tablas no está confirmado en ninguna.

## Regla de admisión

> **Una entrada entra en las tablas solo si se ha confirmado funcionando, anotando en qué
> plataforma. Lo no confirmado no se escribe.**

No es burocracia: si esta página se llena de métodos plausibles pero no comprobados, deja de
valer para nada. Una lista corta y cierta es útil; una larga y verosímil es un pasivo. Lo que
esté a medias va en «pendiente de confirmar», al final, y no se usa.

Esta página **no enumera la API de vistas de Android ni de iOS**. Esa lista no pertenece a este
repositorio.

## Efectos y estilo

| Método | Qué hace | Nativo (iOS) | Confirmado en |
|---|---|---|---|
| `setBlur(radius)` | Desenfoque. `0` = sin efecto; mayor, más desenfoque | `CIGaussianBlur` en `layer.filters` | Android · **iOS 17+** |
| `setSaturation(value)` | Saturación. `0` = grises; `1` = normal; `>1` = saturado | `CIColorControls` en `layer.filters` | Android · **iOS 17+** |
| `setOpacity(0-100)` | Opacidad. `0` = transparente; `100` = opaca | `view.layer.opacity` | iOS |
| `setTintColor(color)` | Color de tinte. Color hex | `view.tintColor` | iOS |
| `setShadow(opacity, radius, offsetX, offsetY, color)` | Sombra. Opacidad `0–1`, radio, desplazamiento y color hex | `view.layer.shadow*` | iOS |

**`setShadow` exige que la capa no recorte la sombra.** Si el contenido lo permite, hay que
dejar `setClipped(false)`; con recorte activo la sombra no se ve.

## Transformaciones

| Método | Qué hace | Nativo (iOS) | Confirmado en |
|---|---|---|---|
| `setScale(sx[, sy])` | Escala. `sy` opcional: si falta, se usa `sx` | `CGAffineTransformScale` | iOS |
| `setRotation(grados)` | Rotación en **grados**, no radianes | `CGAffineTransformRotate` | iOS |
| `setTranslate(dx, dy)` | Desplazamiento, en puntos | `CGAffineTransformTranslate` | iOS |
| `resetTransform()` | Vuelve al estado original | `CGAffineTransformIdentity` | iOS |

**Las transformaciones acumulan.** Se concatenan sobre la transformación actual, no la
reemplazan: llamar dos veces a `setScale(2)` deja la vista a escala 4. Para volver al punto de
partida, `resetTransform()` — no una transformación inversa.

## Orden de capas

| Método | Qué hace | Nativo (iOS) | Confirmado en |
|---|---|---|---|
| `setZIndex(z)` | Posición en el eje Z | `view.layer.zPosition` | iOS |
| `bringToFront()` | Trae al frente dentro de su contenedor | `superview.bringSubviewToFront:` | iOS |
| `sendToBack()` | Manda al fondo dentro de su contenedor | `superview.sendSubviewToBack:` | iOS |

`bringToFront`/`sendToBack` actúan **dentro del contenedor** de la vista, no sobre la pantalla
entera.

## Lecturas

| Método | Devuelve | Confirmado en |
|---|---|---|
| `getFrame()` | `{ x, y, width, height }` | iOS |
| `getPosition()` | `{ x, y }` | iOS |
| `getSize()` | `{ width, height }` | iOS |

## Visibilidad y comportamiento

| Método | Qué hace | Nativo (iOS) | Confirmado en |
|---|---|---|---|
| `setClipped(bool)` | Recorta el contenido al borde de la vista | `view.clipsToBounds` | iOS |
| `setEnabled(bool)` | Habilita o bloquea la interacción | `view.userInteractionEnabled` | iOS |
| `setContentMode(mode)` | Cómo se ajusta el contenido | `view.contentMode` | iOS |

Valores de `setContentMode`: `"scaleToFill"` · `"scaleAspectFit"` · `"scaleAspectFill"` ·
`"center"` · `"top"` · `"bottom"`.

## Cómo se envuelve

No se llaman sueltos: se envuelven en `functions.js`. El envoltorio resuelve la ventana una vez
y comprueba el nulo, que es lo que evita el error cuando el evento salta sin vista montada.

```javascript
// Desenfoque sobre un frame
function doBlurEffect(sFrame, nValue) {
    let window = ui.getView(self);
    if (!window) return;
    window[sFrame].setBlur(nValue);
}

// Saturacion sobre un frame
function doSaturationEffect(sFrame, nValue) {
    let window = ui.getView(self);
    if (!window) return;
    window[sFrame].setSaturation(nValue);
}
```

El patrón típico es un slider que llama al envoltorio desde su `onchange`. El rango del ejemplo
—`min="0" max="32"`— es el del slider, no un límite del método:

```xml
<prop name="MAP_BLUR_SLIDER" type="N"
      updates="MAP_BLUR_SLIDER"
      min="0" max="32"
      viewmode="slider" orientation="horizontal"
      notify-only-when-dropped="false"
      width="800p" height="100p" />
```

```xml
<onchange>
    <field name="MAP_BLUR_SLIDER">
        <action name="runscript">
            <script>
                doBlurEffect("mi_frame", self.MAP_BLUR_SLIDER);
            </script>
        </action>
    </field>
</onchange>
```

**No existe `ui.setBlur` ni `ui.setSaturation`.** Se llaman sobre el frame o el control, nunca
sobre `ui`.

## Pendiente de confirmar

**Nada de esta sección está documentado: no lo uses.** Está aquí para que no se vuelva a
investigar desde cero, y sale cuando se confirme.

| Método | Qué falta por decidir |
|---|---|
| `setCornerRadius(radius)` | Solapa con `setBorder(obj)`, que ya lleva `cornerRadius` dentro y es la API documentada. Falta saber si `setCornerRadius` sigue existiendo aparte o quedó sustituida |
| `setVisible(bool)`, `hide()`, `show()` | Existen, pero el corpus solo los documenta sobre marcadores de mapa y sobre el shimmer, nunca sobre una vista genérica. Si existen a nivel de vista son API de XOne y su sitio es `metodos-de-los-controles.md`, no esta página |

**Android está sin confirmar** en todo lo que no sea `setBlur` y `setSaturation`. Las columnas
«Confirmado en» que hoy dicen solo `iOS` se completan cuando se compruebe el otro lado.
