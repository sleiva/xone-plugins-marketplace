# XOne Debugging: troubleshooting detallado

## Pantalla vacía o sin datos

Comprueba, en este orden: `loadAll()` del content; `visible` (`7` para edición/lista/contents o `4` para contents); `unlock` antes de cargar; `ui.refresh` tras modificar; filtro `##FLD_CAMPO##`; coincidencia exacta entre `contents` del prop y `name` del nodo; y existencia de `<contents name="..." src="...">`. Una colección sin `objname`/`updateobj`, `.xne` no procesado o nombre distinto no genera tabla.

## Botones y eventos

Un botón necesita visibilidad de edición y no debe estar cubierto por un frame flotante. `method="miNodo"` no basta: usa `method="ExecuteNode(miNodo)"`. Los eventos son case-sensitive. `refresh="false"` puede ocultar el cambio; usa temporalmente `refresh="true"`. Para un campo `T`, `onchange` ocurre al perder foco; `ontextchanged` sirve para tiempo real. El atributo acepta `Refresh`, `refresh(campo1,campo2)` y `ExecuteNode(miNodo)`, no `onchange="true"`.

## Refresh y contexto

`ui.refresh("MAP_CAMPO")` debe usar el `name` exacto. En callbacks, conserva el objeto y obtén la vista asociada:

```javascript
var contexto = self;
$http.get(url, request, function(sData) {
    var vista = ui.getView(contexto);
    if (vista) {
        contexto.MAP_RESULTADO = sData;
        vista.refresh("MAP_RESULTADO");
    }
});
```

## Colecciones, SQL y persistencia

Si `count()` es cero tras `loadAll`, revisa SQL, `##PREF##`, filtro y tabla. Para limpiar un filtro: `coll.setFilter(""); coll.loadAll();`. Colecciones externas requieren `startBrowse`/`endBrowse`. Regenera con `python3 -m xone_db_generator mi_proyecto --overwrite`. Para modificar, garantiza el cierre:

```javascript
try {
    coll.unlock();
    var obj = coll.createObject();
    coll.addItem(obj);
    obj.save();
} finally { coll.lock(); }
```

Los campos `MAP_` no se guardan en BD. Para `-8100`, completa props `mandatory="true"`. Para `-11888`, no lo trates como fallo cuando el mensaje sea `##EXIT##` o `##EXITAPP##`.

## CSS, imágenes y GPS

CSS sin efecto: revisa `default.css`, `compatibility-mode`, clase exacta, atributos inline y unidades `p`/`%` (no `px`, `em`, `rem`). Imagen ausente: verifica `icons/`/`files/`, PNG de producción, ruta `##APP##\\icons\\...` y valor no vacío. GPS: inicia `ui.startGps`, pide permiso y comprueba `STATUS`; un emulador sin GPS requiere mock o dispositivo real.

## Réplica y rendimiento

Para réplica revisa internet, URL, timeout, cola y configuración de `Empresas`. Usa `recyclerview` para listas largas, carga perezosa, filtros por `##FLD_CAMPO##`, refresh específico y colas de réplica saneadas.

## Tabla por capa

| Capa | Síntoma | Causa frecuente |
|---|---|---|
| XML/UI | Pantalla vacía | `loadAll` o `visible` incorrecto |
| XML/UI | Elemento invisible | bitmask `visible` |
| XML/UI | Botón mudo | `method` sin `ExecuteNode` |
| Eventos | Nada ocurre | nombre exacto o `refresh=false` |
| JS | `self` null | callback asíncrono |
| Datos | Colección vacía | `##PREF##`, filtro o BD |
| Datos | `-8100` | obligatorio vacío |
| Persistencia | `MAP_` perdido | campo transitorio |
| Estilos | CSS sin efecto | unidades o inline |
