# XOne JavaScript — Métodos nativos de la vista (Android/iOS)

Contenido: el mecanismo · qué contrato hay · regla de admisión · métodos confirmados · cómo se envuelve

---

## El mecanismo

`ui.getView(self)` devuelve la **ventana** del objeto actual. Indexarla por nombre devuelve un
frame o un control, igual que `getControl`:

```javascript
let window = ui.getView(self);   // ventana
let frame  = window["mi_frame"]; // frame
let ctrl   = window["MAP_MI_PROP"];  // control (equivale a getControl("MAP_MI_PROP"))
```

Esos tres objetos son **envoltorios sobre la vista nativa** de la plataforma: `View` en Android,
`UIView` en iOS. XOne expone su propia API sobre ellos —`exit`, `refresh`, `bind`, `getControl`,
`setBottomSheetState`, `setStatusBarColor`, `scrollToTop`, `startChronometer`,
`setCircularReveal`…—, y ésa es la que documentan los demás ficheros de esta carpeta.

**Lo que no es API de XOne cae directo a la vista nativa.** Este fichero es el sitio donde se
anota eso, y solo eso.

## Qué contrato hay: ninguno

Los métodos de esta página **no son API de XOne**. No están soportados, no hay compromiso de
compatibilidad, pueden comportarse distinto en Android y en iOS, y pueden cambiar o desaparecer
entre versiones sin aviso. Quien los use asume eso.

Por eso no aparecen en [métodos de los controles](metodos-de-los-controles.md), que documenta lo
que XOne sí garantiza por cada tipo de control.

## Regla de admisión

> **Una entrada entra en la tabla solo si se ha confirmado funcionando, anotando en qué
> plataforma. Lo no confirmado no se escribe.**

No es burocracia: esta página es, por definición, la que documenta lo que XOne no garantiza. Si
además se llena de métodos plausibles pero no comprobados, deja de valer para nada. Una lista
corta y cierta es útil; una larga y verosímil es un pasivo.

Esta página **no enumera la API de vistas de Android ni de iOS**. Esa lista no pertenece a este
repositorio.

## Métodos confirmados

| Método | Sobre | Qué hace | Confirmado en |
|---|---|---|---|
| `setBlur(n)` | frame o control | Desenfoque. `0` = sin efecto; valores mayores, más desenfoque | Android · iOS |
| `setSaturation(n)` | frame o control | Saturación. `0` = escala de grises; valores mayores, más saturación | Android · iOS |

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
