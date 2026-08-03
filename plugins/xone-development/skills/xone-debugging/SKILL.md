---
description: Diagnóstico sistemático de errores y rendimiento en aplicaciones XOne. Usar al depurar pantallas vacías, botones que no responden, eventos que no disparan, colecciones sin datos, self null, errores -8100/-11888, problemas de refresh o de persistencia MAP_, o al analizar fallos con xone-simulator.
---

# XOne Debugging

Guía para diagnosticar y corregir errores en aplicaciones XOne de forma sistemática. Antes de tocar código, reproduce y aísla el problema con `xone-simulator`; aplica las causas más probables de la sección correspondiente y verifica con el flujo de validación.

## Proceso de diagnóstico

1. **Reproducir**: ejecuta el proyecto y confirma el síntoma exacto (pantalla vacía, botón mudo, error en consola, dato que no se guarda).
2. **Aislar**: usa `xone-simulator` para localizar la capa afectada (XML/UI, evento JS, colección o persistencia).
3. **Buscar la causa** en la sección específica de abajo, en orden de frecuencia.
4. **Corregir** con el patrón correcto (los snippets de cada sección muestran la versión incorrecta y la correcta).
5. **Verificar**: valida de nuevo y ejecuta el smoke para confirmar que el fallo desaparece y no se rompió otra cosa.

## Herramientas de diagnóstico

El paquete npm `xone-linter` expone el binario `xone-simulator`, ideal para reproducir errores sin dispositivo:

```bash
# Validación completa del proyecto (XML, tipos, referencias, anti-patrones)
xone-simulator validate ./proyecto

# Ejecutar un evento concreto de una coll para reproducir un fallo JS
xone-simulator run ./proyecto --coll MiColl --event before-edit

# Renderizar una coll a HTML para inspeccionar la UI generada
xone-simulator render ./proyecto --coll MiColl

# Smoke completo de todas las colls (vida: exit 1 si hay failures)
xone-simulator smoke ./proyecto
```

Usa `--json` en cualquier comando para salida estructurada parseable, y `--coll X` para acotar el análisis a una sola pantalla. Con `--db-path` se puede apuntar a una copia de una BD real (nunca a la del repo, el simulador puede mutarla).

### Anti-patrones que detecta el validador

- `ANTIPATTERN_LOAD_EVENT` — usar `load` como evento de carga. La carga no se dispara de forma fiable; usa `before-edit`.
- `ANTIPATTERN_MULTIPLE_BEFORE_EDIT` — tener más de un `before-edit` (o un `before-edit` duplicado con otro evento) en la misma coll. Debe existir uno solo.

## Pantalla vacía o sin datos

**Síntoma**: hay datos en BD pero la pantalla aparece sin contenido.

Causas en orden de frecuencia:

1. **Falta `loadAll()`** — los contents no cargan solos:
```javascript
self.getContents("miContent").loadAll();
```
2. **Visibilidad incorrecta** — el campo no es visible en el modo actual (`visible="7"` o `visible="4"`).
3. **Content bloqueado** — desbloquear antes de cargar:
```javascript
self.getContents("miContent").unlock();
self.getContents("miContent").loadAll();
self.getContents("miContent").lock();
```
4. **Falta `ui.refresh()`** — tras modificar datos desde JS, refrescar la vista.
5. **Filtro demasiado restrictivo** en el `<contents>` (verificar `##FLD_CAMPO##` usado en el filtro).
6. **El `<prop type="Z">` no referencia al content correcto**: el `contents="..."` del prop debe coincidir con el `name="..."` del `<contents>`.
7. **Causa estructural**: `<prop name="@miContent" type="Z" contents="miContent"/>` sin `<contents name="miContent" src="MiColeccion"/>` — el content fuente no existe o el nombre no coincide.

## El botón no hace nada

1. **Falta `visible="1"` o `visible="7"`** — el botón no es visible en modo edición.
2. **`method` sin `ExecuteNode`**:
```xml
<!-- Incorrecto -->
<prop name="btn" type="B" method="miNodo"/>
<!-- Correcto -->
<prop name="btn" type="B" method="ExecuteNode(miNodo)"/>
```
3. **Bloqueado por `disableedit`**:
```xml
<prop name="btn" type="B" disableedit="MAP_ESTADO=0"/>
```
4. **Solapamiento** — un frame flotante encima intercepta el toque.

## Evento que no se dispara

1. **Nombre incorrecto** — los nombres de evento son case-sensitive; deben coincidir exactamente con el nodo XML.
2. **`refresh` en falso** — si el evento modifica datos con `refresh="false"`, la UI no se actualiza. Prueba `refresh="true"` para diagnosticar:
```xml
<miEvento refresh="true" show-wait-dialog="false">
```
3. **`method` sin `ExecuteNode`** (ver sección del botón).
4. **Error JS silencioso** — activa temporalmente `show-wait-dialog="true"` para ver el error, o ejecuta el evento con `xone-simulator run`.

## onchange que no dispara

- Para campos `T` (texto), el `onchange` del nodo se dispara al **perder el foco**, no en cada tecla. Para tiempo real usa `ontextchanged`:
```xml
<prop name="campo" type="T" ontextchanged="javascript:miFuncion(e);"/>
```
- El `name` del `<field>` debe coincidir exactamente con el nombre del prop:
```xml
<onchange>
    <field name="MAP_CAMPO">
        <action name="runscript">
            <script language="javascript">/* codigo */</script>
        </action>
    </field>
</onchange>
```
- Como atributo, `onchange` acepta comandos (`Refresh`, `refresh(campo1,campo2)`, `ExecuteNode(miNodo)`) — **no** valores booleanos: `onchange="true"` es incorrecto.

## Refresh que no funciona

1. **Nombre de campo incorrecto** — `ui.refresh("...")` debe usar el nombre exacto del `name` del `<prop>` (ej. `MAP_NOMBRE`, no `nombre`).
2. **En callbacks asíncronos**, obtener la vista con `ui.getView(self)`:
```javascript
var v = ui.getView(self);
if (v) { v.refresh("MAP_CAMPO"); }
```
3. **Contexto `self` perdido** — en callbacks de `$http` o eventos diferidos `self` puede ser null. Guardar la referencia antes:
```javascript
var miObjeto = self;
$http.get(url, request, function(sData) {
    miObjeto.MAP_RESULTADO = sData;
    ui.refresh("MAP_RESULTADO");
});
```

## self es null en callback

Acceder a `self` dentro de un callback de `$http`, GPS o evento diferido da error porque `self` es null/undefined. Guarda la referencia en una variable local antes del callback:

```javascript
var contexto = self;
$http.get(url, request, function(sData) {
    contexto.MAP_DATO = JSON.parse(sData).valor;
    ui.refresh("MAP_DATO");
});
```

## La colección no carga datos

**Síntoma**: `count()` retorna 0 después de `loadAll()`.

1. **SQL incorrecto** — revisar la consulta del atributo `sql` del `<coll>`.
2. **Tabla no existe** — regenerar la base de datos: `python3 -m xone_db_generator mi_proyecto --overwrite`.
3. **Falta prefijo `##PREF##`**:
```xml
<!-- Correcto -->
<coll ... sql="SELECT * FROM ##PREF##MiTabla t1"/>
<!-- Incorrecto -->
<coll ... sql="SELECT * FROM MiTabla t1"/>
```
4. **Filtro demasiado restrictivo** — limpiar con `coll.setFilter("")` y volver a cargar:
```javascript
coll.setFilter("");
coll.loadAll();
```
5. **Colección accedida externamente** requiere startBrowse/endBrowse:
```javascript
var coll = appData.getCollection("MiColeccion");
try {
    coll.startBrowse();
    coll.loadAll();
    var count = coll.count();
} finally {
    coll.endBrowse();
}
```

## Error de tabla no encontrada

**Síntoma**: "no such table" al cargar datos.

La tabla no se generó si:
- La colección no tiene `objname` o `updateobj`.
- El archivo `.xne` no fue procesado por el generador.
- El nombre no coincide (recordar el prefijo `gen_`).

**Solución**: regenerar la BD con `python3 -m xone_db_generator mi_proyecto --overwrite`.

## lock/unlock que falla

Si falla al modificar una colección bloqueada, asegura que `lock()` se ejecuta siempre, incluso ante error:

```javascript
// INCORRECTO - si hay error, nunca se ejecuta lock()
coll.unlock();
var obj = coll.createObject();
coll.addItem(obj);
obj.save();
coll.lock();

// CORRECTO - lock() siempre se ejecuta en finally
try {
    coll.unlock();
    var obj = coll.createObject();
    coll.addItem(obj);
    obj.save();
} finally {
    coll.lock();
}
```

## Campos MAP_ que no se guardan

Los campos con prefijo `MAP_` son **transitorios** (calculados/virtuales). No se persisten en BD; solo existen en memoria mientras el objeto está cargado. Si necesitas persistir el dato, usa un campo sin `MAP_` que tenga columna en la tabla.

## Los estilos no se aplican

1. **Unidades incorrectas** — no usar `px`, `em`, `rem`:
```css
/* Incorrecto */
.miClase { width:200px; }
/* Correcto */
.miClase { width:200p; }
```
2. **Nombre de clase incorrecto** — debe coincidir exactamente.
3. **Atributo inline sobreescribe la clase** — los atributos del XML tienen prioridad sobre el CSS.
4. **Archivo CSS no cargado** — debe llamarse `default.css` y estar en la raíz del proyecto.

## La imagen no se muestra

1. El archivo no existe en `icons/` o `files/`.
2. **Formato incorrecto** — en producción XOne solo soporta PNG.
3. **Ruta incorrecta** — usar `##APP##\icons\` para rutas absolutas:
```xml
<prop name="img" type="IMG" path="##APP##\icons\mi_icono.png"/>
```
4. El campo está vacío — verificar que el valor del campo contiene el nombre del archivo.

## GPS que no funciona

1. **Falta `ui.startGps()`** — iniciar antes de pedir coordenadas.
2. **Permisos no concedidos**:
```javascript
var status = ui.checkGpsStatus();
if (status == 0 || status == 3) {
    ui.askUserForGpsPermission({
        onEnabled: function() { ui.startGps(); },
        onDenied: function() { ui.showToast("Active el GPS"); }
    });
}
```
3. **Emulador sin GPS** — probar en dispositivo físico.

## La réplica falla

Verificar: conexión a internet, URL del servidor, timeout de conexión, datos corruptos en la cola de réplica. Revisar la configuración de réplica en `Empresas` y los logs del dispositivo.

## Errores numéricos del framework

### Error -8100

**Síntoma**: al guardar un objeto se obtiene `-8100`.

**Causa**: campos obligatorios no completados. El framework valida que todos los campos con `mandatory="true"` (o equivalente) tengan valor.

**Solución**: completar todos los campos obligatorios antes de `save()`.

### Error -11888 con ##EXIT##

**Síntoma**: `appData.failWithMessage(-11888, "##EXIT##")` lanza y la pantalla se cierra.

**Explicación**: es el **comportamiento esperado**. `-11888` con mensaje `##EXIT##` es el patrón estándar para cerrar la pantalla actual y volver a la anterior. No es un error real.

```javascript
// Cerrar pantalla actual (comportamiento normal)
appData.failWithMessage(-11888, "##EXIT##");

// Cerrar toda la aplicación
appData.failWithMessage(-11888, "##EXITAPP##");
```

## Rendimiento

- **Listas**: usar `viewmode="recyclerview"` en el `<prop type="Z">` para reciclar vistas y mejorar el scroll en listas largas.
- **Carga perezosa**: no cargar todos los datos en `before-edit` si la pantalla no los necesita; filtrar por `##FLD_CAMPO##` o usar `loadAll()` solo en el content visible.
- **Evitar refresh globales**: refrescar solo los campos afectados con `ui.refresh("MAP_CAMPO")` en lugar de toda la vista.
- **Colas de réplica**: colas crecientes de datos corruptos degradan el arranque; revisar `maintenance` en `Empresas`.

## Errores recurrentes por capa

| Capa | Síntoma típico | Causa raíz más frecuente |
|------|----------------|--------------------------|
| XML/UI | Pantalla vacía | Falta `loadAll()` o `visible` incorrecto |
| XML/UI | Elemento invisible | `visible="0"` o bitmask sin el modo actual |
| XML/UI | Botón mudo | `method` sin `ExecuteNode` |
| Eventos | Nada ocurre al tocar | Nombre de evento case-sensitive o `refresh="false"` |
| JS | `self` null | Acceso a `self` dentro de callback asíncrono |
| Datos | Colección vacía | SQL sin `##PREF##`, filtro restrictivo o tabla sin regenerar |
| Datos | `-8100` al guardar | Campo obligatorio sin valor |
| Persistencia | `MAP_` perdidos | Campo transitorio usado como si fuera persistente |
| Estilos | CSS sin efecto | Unidades `px/em/rem` o atributo inline con prioridad |

## Anti-patrones a evitar

- Usar `load` en lugar de `before-edit` (lo detecta el validador).
- Duplicar `before-edit` en una coll.
- Llamar a `save()` sin try/finally que garantice `lock()`.
- Usar `visible` sin modo (asumir que vale para todos los modos).
- Referenciar contents, campos o colecciones con nombres que no coinciden exactamente.
