# XML/UI Referencia — Mapas, GPS y errores comunes

Sub-archivo de [xone-xml-ui-reference.md](xone-xml-ui-reference.md). Cubre la API completa de mapas (prop type=Z con viewmode=mapview): atributos del prop, API JavaScript del control de mapa, GPS (startGps, stopGps, checkGpsStatus, callbacks), GpsTools (utilidades de geolocalizacion); y los 17 errores más comunes a evitar al generar proyectos XOne.

## Tabla de Contenidos

- [15. Mapas: Atributos, Eventos y API JavaScript](#15-mapas-atributos-eventos-y-api-javascript)
- [14. Errores Comunes a Evitar](#14-errores-comunes-a-evitar)

---

## 15. Mapas: Atributos, Eventos y API JavaScript

XOne soporta dos motores de mapa: **Google Maps** (`viewmode="mapview"`) y **OpenStreetMap** (`viewmode="openstreetmap"`). Ambos comparten la misma API JavaScript salvo excepciones indicadas.

---

### 15.1 Atributos del prop type="Z" para mapas

Todos los atributos se definen directamente en el `<prop type="Z">`.

#### Comunes a mapview y openstreetmap

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `viewmode` | `mapview` / `openstreetmap` | Motor de mapa |
| `contents` | `@NombreContent` | Coleccion de POIs a mostrar |
| `show-user-location` | `true`/`false` | Mostrar marcador de posición del usuario |
| `zoom-to-pois` | `true`/`false` | Ajustar zoom para mostrar todos los POIs al cargar |
| `zoom-to-my-location` | `true`/`false` | Centrar mapa en ubicación del usuario al cargar |
| `map-type` | `normal` / `satellite` / `terrain` / `hybrid` / `none` | Tipo de mapa. También configurable en tiempo de ejecución con `setMapType()` |
| `show-pois` | `true`/`false` | Mostrar los POIs del contents |
| `show-google-buttons` | `true`/`false` | Mostrar botones nativos de Google Maps |
| `clear-lines-on-refresh` | `true`/`false` | Borrar lineas dibujadas al hacer refresh |
| `cluster-markers` | `true`/`false` | Agrupar marcadores cercanos en clusters |
| `follow-location-on-background` | `true`/`false` | Seguir la ubicación del usuario aunque la app este en segundo plano |
| `ignore-geocoding-errors` | `true`/`false` | No lanzar error si falla la geocodificacion de una dirección |
| `zoom-buttons-visibility` | `always` / `never` | Visibilidad de los botones de zoom |
| `min-zoom` | Número | Nivel mínimo de zoom permitido |
| `max-zoom` | Número | Nivel máximo de zoom permitido |
| `encoded-initial-bounds` | String encoded | Limites iniciales del mapa en formato polyline encoded |
| `restrict-map-to-bounds` | `"lat1,lon1,lat2,lon2"` | Restringe el desplazamiento del mapa a unos limites geograficos |
| `show-compass` | `true`/`false` | Mostrar brújula (mapview y openstreetmap) |

#### Atributos exclusivos de mapview (Google Maps)

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `map-features` | Lista separada por comas (`roads`, `transit`, `poi`, `parks`, ...) | Muestra solo las features indicadas y oculta el resto |
| `map-style` | JSON de estilo de Google (en línea) o nombre de fichero de la app | Reestiliza el mapa (recolorear, modo oscuro, ocultar features). Tiene prioridad sobre `map-features`. También en runtime con `setMapStyle()` |
| `traffic-enabled` | `true`/`false` (def. `false`) | Muestra la capa de tráfico. También en runtime con `setTrafficEnabled()` |
| `map-padding` | `"left,top,right,bottom"` (píxeles) | Padding del mapa. También en runtime con `setMapPadding()` |
| `tilt-gestures-enabled` | `true`/`false` (def. `true`) | Permite inclinar el mapa con gestos |
| `scroll-gestures-enabled` | `true`/`false` (def. `true`) | Permite desplazar el mapa con gestos |
| `zoom-gestures-enabled` | `true`/`false` (def. `true`) | Permite hacer zoom con gestos |
| `rotate-gestures-enabled` | `true`/`false` (def. `true`) | Permite rotar el mapa con gestos |
| `indoor-maps-enabled` | `true`/`false` (def. `true`) | Activa los planos de interiores |
| `show-my-location-button` | `true`/`false` (def. `true`) | Botón para centrar en la ubicación del usuario |

#### Eventos del prop mapa (atributos inline)

| Atributo | Descripción | Parámetros del evento |
|----------|-------------|----------------------|
| `onmapclicked` | Click en el mapa (no sobre un marcador) | `e.latitude`, `e.longitude`, `e.target` (nombre del prop) |
| `onmaplongclicked` | Click largo en el mapa | `e.latitude`, `e.longitude`, `e.target` |
| `onmapready` | Mapa inicializado y listo | `e.target` |
| `onmapzoomchanged` | Cambio de nivel de zoom | `e.zoom` (nuevo nivel); `e.bounds` = `Object[]` de 2 elementos `[noreste, suroeste]`. Cada elemento es un objeto location con `latitude`, `longitude`, `altitude`, `accuracy`, `bearing`, `speed`, `time` (los 5 últimos siempre a 0) |
| `onmarkerdragend` | Fin de arrastre de un marcador | `e.latitude`, `e.longitude`, `e.tag`, `e.marker` |
| `ondrop` | Objeto soltado sobre el mapa (drag & drop) | `e.latitude`, `e.longitude`, `e.target` |
| `ondistancemeter` | Evento del medidor de distancia | `e.distance`, `e.location1`, `e.location2` |
| `onstreetviewenabled` | StreetView activado | `e.latitude`, `e.longitude`, `e.target` (coordenadas del punto donde se activó) |
| `onstreetviewunavailable` | StreetView no disponible en la zona | `e.latitude`, `e.longitude`, `e.target` (coordenadas del punto consultado) |
| `onlocationready` | Primera localización GPS obtenida | `e.latitude`, `e.longitude` |
| `onlocationchanged` | Cambio de posición GPS | `e.latitude`, `e.longitude` |

#### Atributos exclusivos de openstreetmap

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `show-minimap` | `true`/`false` | Mostrar minimapa de referencia |
| `show-scale` | `true`/`false` | Mostrar escala del mapa |
| `tile-source` | `usgs_topo` / `usgs_sat` | Fuente alternativa de tiles |
| `storage-path` | Ruta | Ruta para almacenar tiles descargados offline |
| `offline-maps` | `true`/`false` | Activar modo mapas offline |
| `user-location-icon` | `nombre.png` | Icono personalizado para la posición del usuario |
| `direction-arrow-icon` | `nombre.png` | Icono de flecha de dirección |
| `allow-rotate` | `true`/`false` | Permitir rotar el mapa con dos dedos |

#### Ejemplo de declaración completa

```xml
<prop name="MAP_MAPA" type="Z" visible="1"
      viewmode="mapview"
      contents="@PuntosEntrega"
      map-type="normal"
      show-user-location="true"
      zoom-to-pois="true"
      show-pois="true"
      show-google-buttons="true"
      clear-lines-on-refresh="false"
      cluster-markers="true"
      follow-location-on-background="true"
      min-zoom="10" max-zoom="15"
      width="100%" height="70%"
      onmapclicked="onMapClicked(e);"
      onmaplongclicked="onMapLongClicked(e);"
      onmapready="onMapReady(e);"
      onmapzoomchanged="onMapZoomChanged(e);"
      onmarkerdragend="onMarkerDraggedEnd(e);" />

<contents name="@PuntosEntrega" src="PuntosEntregaColl" />
```

---

### 15.2 API JavaScript del control de mapa

El control de mapa se obtiene desde JavaScript con la función global nativa `getControl(name, [dataObject])`:

```javascript
let mapControl = getControl("MAP_MAPA");
```

#### Navegación y zoom

```javascript
// Centrar el mapa en unas coordenadas (sin cambiar zoom)
mapControl.moveTo(38.886546, -7.0043193);

// Centrar con nivel de zoom específico
mapControl.zoomTo(38.886546, -7.0043193);
mapControl.zoomTo(38.886546, -7.0043193, 15);          // nivel de zoom 15
mapControl.zoomTo(38.886546, -7.0043193, 500, true);   // 500 metros de radio

// Zoom para mostrar todos los POIs
// (equivalente al atributo zoom-to-pois en tiempo de carga)
mapControl.zoomToBounds(["lat1, lon1", "lat2, lon2"]);

// Zoom a datos polyline encoded
mapControl.zoomToEncodeData(sPolylineEncoded);

// Zoom a mi localización con nivel concreto
mapControl.zoomToMyLocation(20);

// Nivel de zoom actual
let nZoom = mapControl.getZoom();

// Establecer zoom
mapControl.setZoom(13);

// Limites de zoom
mapControl.setMinZoom(10);
mapControl.setMaxZoom(15);
mapControl.resetMinMaxZoom();

// Centro actual del mapa -> { latitude, longitude }
let center = mapControl.getMapCenter();

// Limites actuales del mapa -> array de 2 puntos: [noreste, suroeste]
let bounds = mapControl.getMapBounds();

// Restringir desplazamiento a unos limites
mapControl.restrictMapToBounds(["lat1, lon1", "lat2, lon2"]);

// Seguir/dejar de seguir la ubicación del usuario
mapControl.setFollowUserLocation(true);
mapControl.setFollowUserLocation(false);

// Cambiar tipo de mapa en tiempo de ejecución
// Valores: normal / satellite / terrain / hybrid / none
mapControl.setMapType("satellite");
let sType = mapControl.getMapType();
```

#### Marcadores

Los marcadores se pueden añadir desde JavaScript (además de los que vienen de la colección `contents`).

> ⚠️ **Las claves de callback (`onClick`, `onClusterClick`) van en camelCase exacto.** A diferencia de los eventos en XML y en `bind()` —que son insensibles a mayúsculas/minúsculas—, estos callbacks se leen como propiedades del objeto de configuración por su nombre literal. Si los escribes en minúscula (`onclick`), el marcador se crea pero el callback **no se ejecuta nunca** (se ignora en silencio).

```javascript
// Añadir marcador por script
let params = {
    title    : "Titulo del marcador",    // Util con TalkBack
    latitude : evento.latitude,
    longitude: evento.longitude,
    rotation : 0,                        // Grados de rotacion
    alpha    : 1,                        // Opacidad 0.0 - 1.0
    draggable: true,
    anchor   : "top",                    // top / bottom / center
    icon     : "ic_marker.png",
    width    : 35,                       // Ancho del icono en puntos
    height   : 47,                       // Alto del icono en puntos
    tag      : "dato_extra",             // Dato personalizado
    onClick  : function(evento) {
        evento.marker.setIcon("ic_otro.png");
        evento.marker.showInfo();
    }
};
let marker = mapControl.addMarker(params);

// Operaciones sobre un marcador obtenido
marker.setVisible(true);
marker.setDraggable(true);          // En MapLibre es no-op silencioso
marker.setRotation(180);            // Animado por defecto. Para rotación instantánea: marker.setRotation(180, false). En MapLibre es no-op
marker.setAlpha(0.5);               // En MapLibre es no-op
marker.setAnchor("top");            // top / bottom / center. En MapLibre es no-op
marker.setIcon("ic_nuevo.png");
marker.setPosition({
    latitude : 38.8685452,
    longitude: -6.8170906,
    animate  : true,
    duration : 500                  // ms de animacion
});
let pos = marker.getPosition();     // [latitude, longitude]
marker.remove();
marker.showInfo();                  // Mostrar info window del marcador

// Eliminar todos los marcadores (coleccion + script)
let mapContent = self.getContents("@PuntosEntrega");
mapContent.unlock();
mapContent.clear();
mapContent.lock();
ui.refresh("MAP_MAPA");
```

#### Clusters de marcadores

Solo disponible en **Google Maps** (`viewmode="mapview"`). En `openstreetmap`, `maplibre` y `picturemap`, `addClusteredMarker` y `getClusterManager` **no existen**.

```javascript
// Añadir marcador a un cluster (solo Google Maps)
mapControl.addClusteredMarker({
    clusterId     : "grupo1",
    clusterIcon   : "ic_cluster.png",
    latitude      : 40.4165,
    longitude     : -3.70256,
    icon          : "ic_marker.png",
    title         : "Titulo",
    snippet       : "Descripción",
    itemCounter   : true,           // Mostrar contador de items en el cluster
    tag           : "dato",
    onClick       : function(tag, marker) {},
    onClusterClick: function(ev) {
        // ev.clusterId, ev.latitude, ev.longitude, ev.target
        mapControl.zoomTo(ev.latitude, ev.longitude, 15);
    }
});

// Obtener gestor del cluster
let cluster = mapControl.getClusterManager("grupo1");
cluster.clear();                    // Eliminar todos los marcadores del cluster
cluster.show();
cluster.hide();
```

#### Lineas

```javascript
// Dibujar línea
mapControl.drawLine({
    line       : "nombre_linea",    // Identificador para poder borrarla después
    strokeColor: "#FF0000",
    strokeWidth: 5.0,
    mode       : "normal",          // normal / dashed / dotted / mixed
    locations  : [
        { latitude: 37.35, longitude: -9.72 },
        { latitude: 37.35, longitude: -0.00 }
    ]
});

// Dibujar línea con datos polyline encoded
mapControl.drawLine({
    line       : "linea_encoded",
    strokeColor: "#FF00FF",
    strokeWidth: 12.0,
    mode       : "normal",
    data       : "u~ilF~bwi@iH~GuC_UvDaN"  // Polyline encoded
});

// Borrar una línea por nombre
mapControl.clearLine("nombre_linea");

// Borrar todas las lineas
mapControl.clearAllLines();
```

#### Rutas

```javascript
// Dibujar ruta calculada (Google Maps en mapview, OSRM/osm2po en openstreetmap)
mapControl.drawRoute({
    route      : "ruta1",           // Identificador
    waypoints  : [
        { latitude: 38.87789, longitude: -6.97061 },
        { latitude: 38.41667, longitude: -6.41667 }
    ],
    mode       : "driving",         // driving / walking / bicycling / transit
    strokeColor: "#00FF00",
    strokeWidth: 5.0,
    linePattern: "normal"           // normal / dashed / dotted / mixed
    // accurate: true               // Ruta precisa con Google Maps (consume mas recursos)
    // urlType: "osrm"              // Solo OpenStreetMap: osrm / osm2po
    // url: "http://..."            // URL del servidor de rutas OSM
});

// Borrar una ruta por nombre
mapControl.clearRoute("ruta1");

// Borrar todas las rutas
mapControl.clearAllRoutes();

// Dibujar ruta al POI mas cercano
mapControl.drawRoute({
    route     : "ClosestRoute",
    waypoints : [userLocation, closestPoi],
    strokeColor: "#FFFF00",
    strokeWidth: 5.0
});
```

#### Rutas externas

```javascript
// Abrir app externa de navegacion
new GpsTools().routeTo({
    sourceLatitude     : 40.4167747,
    sourceLongitude    : -3.70379019,
    destinationLatitude : 41.3850632,
    destinationLongitude: 2.1734035,
    source             : "google_maps"  // internal / external / google_maps / osmand / osmand_plus
});
```

#### Áreas (poligonos)

```javascript
// Dibujar área con array de coordenadas
mapControl.drawArea({
    id       : "area1",
    fillColor: "#7F00FF00",    // ARGB semi-transparente ("fillcolor" en minúsculas: alias obsoleto)
    color    : "#FF0000FF",    // Color borde
    width    : 5,
    pattern  : "normal",       // normal / dashed / dotted / mixed
    onClick  : function() { ui.showToast("Click en área"); },
    data     : ["43.37, -8.42", "43.26, -2.93", "38.72, -9.13"]
});

// Dibujar área con polyline encoded
mapControl.drawEncodeArea({
    id       : "area2",
    fillColor: "#7F0000FF",
    color    : "#FFFF0000",
    width    : 5,
    pattern  : "normal",
    data     : new GpsTools().encode(["38.87, -6.82", "40.42, -3.70"])
});

// Borrar área por ID
mapControl.removeArea("area1");

// Borrar todas las areas
mapControl.clearAllAreas();
```

#### Circulos

```javascript
// Dibujar circulo
let circle = mapControl.drawCircle({
    location   : { latitude: 38.87789, longitude: -6.97061 },
    visible    : true,
    radius     : 1000,             // Radio en metros
    pattern    : "dashed",         // normal / dashed / dotted / mixed
    fillColor  : "#00000000",      // Color relleno (ARGB)
    strokeColor: "#00FF00",        // Color borde
    strokeWidth: 10                // Grosor borde en pixeles
});

// Operaciones sobre el circulo
circle.setVisible(true);
let location = circle.getLocation();
circle.setLocation({
    latitude : location.latitude + 0.005,
    longitude: location.longitude,
    animate  : true
});

// Mostrar/ocultar todos los circulos
// (gestion manual con array)
```

#### POIs (puntos de interes del contents)

```javascript
// Cambiar el filtro de la coleccion de POIs y refrescar el mapa
let mapContent = self.getContents("@PuntosEntrega");
mapContent.setFilter("t1.NOMBRE = 'Madrid'");
mapContent.unlock();
mapContent.clear();
mapContent.loadAll();
mapContent.lock();
ui.refresh("MAP_MAPA");

// Menu de POIs
mapControl.showPoisMenu();
mapControl.hidePoisMenu();
mapControl.togglePoisMenu();

// Para gestionar muchos marcadores creados por script, guarda sus wrappers
// en una variable propia (array/objeto) al llamar a addMarker() y
// recorrelos para llamar setVisible/setDraggable/remove. No existe un
// "showMarkers/hideMarkers/setMarkersDraggable/removeMarkers" globales.
```

#### Localización del usuario

```javascript
// Obtener la localización actual del usuario desde el mapa
let userLocation = mapControl.getUserLocation();
// userLocation: { latitude, longitude, altitude, speed, accuracy,
//                 bearing, time, provider }

// Habilitar/deshabilitar la capa de localización
mapControl.isUserLocationEnabled();  // -> boolean
mapControl.enableUserLocation();
mapControl.disableUserLocation();
```

#### Street View (solo Google Maps)

```javascript
// Mostrar Street View en una ubicación
mapControl.showStreetView({ latitude: 38.886, longitude: -7.004 });

// Eliminar Street View y volver al mapa
mapControl.removeStreetView();

// Iniciar drag para soltar en el mapa y abrir StreetView en ese punto
// (usar con onlongclick en un frame flotante)
ui.startDrag(control, {});
// El evento ondrop del mapa recibe e.latitude, e.longitude
```

#### Captura de imagen del mapa

```javascript
let sImagePath = mapControl.captureImage();
ui.openFile(sImagePath);
```

#### Capas adicionales

```javascript
// Añadir capa WMS
mapControl.addWmsTileOverlay({
    name                  : "nombre_capa",
    urlDomain             : "https://servidor.com/wms",
    version               : "1.1.1",
    request               : "GetMap",
    layers                : "nombre:capa",
    width                 : 256,
    height                : 256,
    spatialReferenceSystem: "EPSG:900913",
    format                : "image/png",
    transparent           : true,
    debug                 : false
});

// Eliminar capa WMS (true = eliminar también cache)
mapControl.removeWmsTileOverlay(true);

// Añadir capa GeoJSON
mapControl.addGeoJson({
    id         : "capa_geojson",
    dataFile   : "fichero.json",     // Fichero JSON en carpeta de la app
    // data    : sJsonString,        // Alternativa: string JSON o objeto JS
    strokeColor: "#0000FF",          // Genérico: contorno de polígonos y color de líneas
    strokeWidth: 4.0,                // Genérico: grosor en píxeles (polígonos y líneas)
    fillColor  : "#3300FF00"         // Relleno de polígonos (ARGB), solo polígono
    // strokeColor/strokeWidth/fillColor funcionan en los tres motores de mapa.
    //
    // Solo Google Maps — estiliza además líneas y puntos:
    //   Genéricos (todo): strokePattern (dashed/dotted/mixed), zIndex, visible, clickable
    //   Override por tipo: polygonStrokeWidth, lineStrokeWidth, lineStrokeColor, ...
    //                      pointZIndex, pointVisible
    //   Solo polígono: strokeJointType, geodesic
    //   Solo punto: icon (+iconWidth/iconHeight), alpha, rotation, draggable,
    //               title, snippet, anchorU/anchorV
});
mapControl.removeGeoJson("capa_geojson");
mapControl.removeAllGeoJson();              // Eliminar TODAS las capas GeoJSON
let ids = mapControl.getGeoJsonLayerIds();  // -> array de strings

// Añadir capa KML / KMZ
mapControl.addKml({
    id         : "capa_kml",
    dataFile   : "fichero.kmz",
    strokeColor: "#0000FF",
    fillColor  : "#00FF00"
});
mapControl.removeKml("capa_kml");
mapControl.removeAllKml();                  // Eliminar TODAS las capas KML
let kmlIds = mapControl.getKmlLayerIds();   // -> array de strings
```

#### Limpiar el mapa completo

```javascript
// Limpia rutas, líneas, áreas, polylines, GeoJSON y KML dibujados por script.
// NO toca: marcadores de la coleccion @contents, capas WMS, StreetView,
// zoom/centro/tipo de mapa.
mapControl.clearMap();
```

Equivale a llamar en cadena a `clearAllRoutes()`, `clearAllLines()`, `clearAllAreas()`, `clearAllPolylines()`, `removeAllGeoJson()` y `removeAllKml()`. Cada motor omite las operaciones que no soporta (p. ej. MapLibre solo limpia lineas y GeoJSON).

#### Utilidades de polyline

```javascript
// Codificar array de coordenadas a polyline encoded
let sEncoded = new GpsTools().encode(["38.87, -6.82", "40.42, -3.70"]);

// Decodificar polyline encoded a array de { latitude, longitude }
let locations = new GpsTools().decode("moflFxmrh@kkmHca_R");

// Simplificar polyline (reducir puntos manteniendo forma)
let simplified = new GpsTools().simplifyPolyline({
    polyline : [{ latitude: 43.104, longitude: -3.4261 }, ...],
    tolerance: 3000  // En metros. Mayor = menos vertices
});

// Codificar polyline del mapa actual (solo Google Maps)
let sPolyline = mapControl.encodePolyline();

// Descargar tiles offline (solo openstreetmap)
mapControl.downloadTiles({
    coordinates      : [{ latitude: 38.89, longitude: -6.92 },
                        { latitude: 38.88, longitude: -6.89 }],
    onCompleted      : function(nErrors) {},
    onProgressUpdated: function(nProgress, nCurrentZoomLevel) {},
    onDownloadStarted: function() {}
});
```

#### Brujula (solo openstreetmap)

```javascript
mapControl.showCompass();
mapControl.hideCompass();
mapControl.toggleCompass();
```

#### Medidor de distancia

Solo está implementado en Google Maps (`viewmode="mapview"`). En `openstreetmap`, `maplibre` y `picturemap` las llamadas lanzan `UnsupportedOperationException("Not implemented yet")`.

```javascript
// Iniciar medidor de distancia interactivo (objeto JS)
mapControl.startDistanceMeter({
    latitude      : 38.886546,
    longitude     : -7.0043193,
    startMarkerIcon: "ic_start.png",   // opcional
    endMarkerIcon  : "ic_end.png"      // opcional
});

// Forma posicional alternativa: location + iconos (máx. 2 iconos)
mapControl.startDistanceMeter("38.886546,-7.0043193", "ic_start.png", "ic_end.png");

// Sin parámetros: usa el centro actual de la cámara como punto de partida
mapControl.startDistanceMeter();

// El evento ondistancemeter se dispara al terminar de arrastrar
// cualquiera de los dos marcadores (no solo el final).
// Parámetros: e.distance (metros, geodésica), e.location1, e.location2.
// location1/location2 contienen latitude, longitude, altitude, accuracy,
// bearing, speed, time (los cinco últimos siempre a 0).

mapControl.stopDistanceMeter();
```

---

### 15.3 GPS: ui.startGps, ui.stopGps y checkGpsStatus

El GPS del dispositivo se controla con funciones `ui` globales. Los datos GPS se exponen a traves de una coleccion **declarada por el proyecto** (convencionalmente llamada `GpsCollection`) con un connector de tipo GPS. No es una coleccion built-in del framework: el proyecto debe declararla en su mapping para poder hacer `appData.getCollection("GpsCollection")`.

```javascript
// Activar GPS (modo básico)
ui.startGps();

// Activar GPS con configuración
ui.startGps({
    nodeName                  : "callbackgps",   // Nombre del handler custom que se invocara
    timeBetweenUpdates        : 10000,            // Milisegundos entre actualizaciones
    minimumMetersDistanceRange: 10,               // Metros minimos de desplazamiento
    maxUpdateDelayMillis      : 0,
    priority                  : "high",           // high / balanced / low_power / passive
    maxUpdates                : 1000,
    durationMs                : 3600000,
    granularity               : "permission_level",  // permission_level / fine / coarse
    waitForAccurateLocation   : true
});

// Desactivar GPS
ui.stopGps();

// Comprobar estado del GPS
let nStatus = ui.checkGpsStatus();
// 0 = Sin GPS en el dispositivo
// 1 = GPS activo
// 2 = Localización por redes wifi/telefonia activa
// 3 = Sin localización activada -> llamar a ui.askUserForGpsPermission()
// 4 = GPS + redes activos
// -1 = Error inesperado

// Pedir al usuario que active el GPS
ui.askUserForGpsPermission({
    onEnabled: function() { ui.showToast("GPS activado"); },
    onDenied : function() { ui.showToast("GPS denegado"); }
});
```

#### Leer datos GPS desde GpsCollection

```javascript
let collGps = appData.getCollection("GpsCollection");
collGps.loadAll();
let objGps = collGps.get(0);
if (objGps && objGps.STATUS == 1 && objGps.LONGITUD) {
    let lat      = objGps.LATITUD;
    let lon      = objGps.LONGITUD;
    let alt      = objGps.ALTITUD;
    let vel      = objGps.VELOCIDAD;
    let rumbo    = objGps.RUMBO;
    let fecha    = objGps.FGPS;
    let hora     = objGps.HGPS;
    let sats     = objGps.SATELITES;
    let fuente   = objGps.FUENTE;
    let precision= objGps.PRECISION;
    let fake     = objGps.FAKE;   // 1 = localización falsa (mock)
}
```

#### Permiso location-background

Para tracking en segundo plano (Android) es necesario declarar el permiso en la coleccion:

```xml
<permissions>
    <permission name="location-foreground" />
    <permission name="location-background" />
</permissions>
```

---

### 15.4 GpsTools: API de utilidades GPS

`GpsTools` es un objeto JavaScript para calculos geograficos y geocodificacion. Se instancia con `new GpsTools()`.

```javascript
// Calcular distancia entre dos puntos (en metros)
let nMetros = new GpsTools().distanceTo([
    { latitude: 38.8685452, longitude: -6.8170906 },
    { latitude: 40.4167747, longitude: -3.70379019 }
]);

// Calcular distancia entre dos puntos (alternativa)
let nMetros2 = new GpsTools().distanceBetweenCoordinates(
    { latitude: 38.87, longitude: -6.97 },
    { latitude: 40.42, longitude: -3.70 }
);

// Geocodificacion inversa: coordenadas -> dirección
let result = new GpsTools().getAddressFromPosition("38.8862106, -7.0040345");
// result: { locality, subLocality, adminArea, subAdminArea, features,
//           country, countryCode, street, number, address, postal }

// Geocodificacion directa: dirección -> coordenadas
let pos = new GpsTools().getPositionFromAddress("Badajoz");
// pos: { latitude, longitude } o null si no se encuentra

// Ultima localización conocida del dispositivo
let location = new GpsTools().getLastKnownLocation();
// location: { latitude, longitude, accuracy, altitude, bearing, speed, time }

// Comprobar si un punto esta dentro de un poligono
let bDentro = new GpsTools().containsLocation(
    "40.3633442, -1.0893794",   // Punto a comprobar
    ["43.37, -8.42", "43.26, -2.93", "38.72, -9.13"]  // Vertices del poligono
);

// Codificar array de coordenadas a polyline encoded
let sEncoded = new GpsTools().encode(["38.87, -6.82", "40.42, -3.70"]);

// Decodificar polyline encoded
let locations = new GpsTools().decode("moflFxmrh@kkmHca_R");

// Simplificar polyline (reducir puntos)
let simplified = new GpsTools().simplifyPolyline({
    polyline : [{ latitude: 43.104, longitude: -3.4261 }, ...],
    tolerance: 3000  // metros
});

// Añadir metadatos EXIF de localización a una imagen
new GpsTools().addExifLocationToFile({
    file     : "foto.jpg",
    latitude : 40.4165000,
    longitude: -3.7025600
});
```


---

## 14. Errores Comunes a Evitar

### Error 1: Usar CSS Web Estándar

```css
/* INCORRECTO */
prop { font-size: 14px; margin-top: 10px; }

/* CORRECTO */
prop { fontsize: 14; tmargin: 10p; }
```

### Error 2: Olvidar ##PREF## en SQL

```xml
<!-- INCORRECTO -->
<coll sql="SELECT * FROM Productos">

<!-- CORRECTO -->
<coll sql="SELECT * FROM ##PREF##Productos">
```

### Error 3: Tipos No Validos

```xml
<!-- INCORRECTO -->
<prop name="NOMBRE" type="STRING" />

<!-- CORRECTO -->
<prop name="NOMBRE" type="T" />
```

### Error 4: Sin objname para Persistencia

```xml
<!-- NO SE PERSISTE -->
<coll name="Productos">

<!-- SE PERSISTE -->
<coll name="Productos" objname="Productos">
```

### Error 5: APIs Web en JavaScript

```javascript
// INCORRECTO
document.getElementById("campo").value = "test";
localStorage.setItem("key", "value");

// CORRECTO
self.MAP_CAMPO = "test";
appData.setGlobalMacro("KEY", "value");
```

### Error 6: Todas las Colecciones en mappings.xne

mappings.xne solo debe contener Empresas y Usuarios. Las demas colecciones van en archivos `.xne` separados.

### Error 7: Campos Obligatorios Faltantes

Empresas necesita: `CODIGO`, `NOMBRE`, `ROWID`
Usuarios necesita: `CODIGO`, `NOMBRE`, `IDEMPRESA`, `LOGIN`, `PWD`, `ROWID`

### Error 8: Prefijo Diferente a "gen" Sin Autorización

Siempre usar `prefix="gen"` a menos que el usuario lo solicite explicitamente.

### Error 9: Falta @ en name del Contents

```xml
<!-- INCORRECTO -->
<contents name="MiContenido" src="MiColeccion" />

<!-- CORRECTO -->
<contents name="@MiContenido" src="MiColeccion" />
```

El `@` va siempre en el `name` del nodo `<contents>` y en el atributo `contents` del `<prop type="Z">` que lo referencia.

### Error 10: Sintaxis de Otros Frameworks

No usar HTML (`<div>`, `<input>`), ni sintaxis React/Angular/Vue. Usar siempre nodos XOne (`<frame>`, `<prop>`, `<coll>`).

### Error 11: progid incorrecto en Empresas / Usuarios

`progid` es **opcional**: si se omite, la coll se comporta como un objeto de datos genérico (equivalente a `ASData.CASBasicDataObj`). El error real es **olvidar el progid propio en las colecciones especiales** Empresas y Usuarios, que lo necesitan para activar su lógica de negocio:

```xml
<!-- INCORRECTO: Empresas/Usuarios sin su progid propio -->
<coll name="Empresas" objname="empresa" ...>
<coll name="Usuarios" objname="usuarios" ...>

<!-- CORRECTO -->
<coll name="Empresas" objname="empresa" progid="ASGestion.CASEmpresa" ...>
<coll name="Usuarios" objname="usuarios" progid="ASGestion.CASUser" ...>
```

Valores:
- (omitido) o `ASData.CASBasicDataObj` — cualquier coleccion de negocio genérica
- `ASGestion.CASEmpresa` — coleccion Empresas, en mappings.xne
- `ASGestion.CASUser` — coleccion Usuarios, en mappings.xne

### Error 12: Encoding incoherente en ficheros XNE

El motor respeta el `encoding` declarado en el prólogo del `.xne` (y asume UTF-8 si no se declara). UTF-8 e `iso-8859-15` son **ambos válidos**. El error real es la **discrepancia**: declarar un encoding distinto de cómo está realmente guardado el fichero, lo que corrompe tildes y ñ.

```xml
<!-- INCORRECTO: declara iso-8859-15 pero el fichero está guardado como UTF-8 (o al revés) -->
<?xml version="1.0" encoding="iso-8859-15"?>   <!-- ...y los bytes son UTF-8: tildes/ñ corruptas -->

<!-- CORRECTO: el encoding declarado coincide con cómo se guarda el fichero -->
<?xml version="1.0" encoding="utf-8"?>          <!-- fichero realmente guardado en UTF-8 -->
```

### Error 13: Estructura Incorrecta de mappings.xne

```xml
<!-- INCORRECTO: collprops no existe en XOne -->
<xml>
    <collprops type="general">
        <coll name="Empresas" ...>

<!-- CORRECTO: las colecciones van directamente dentro de <xml> -->
<xml>
    <app .../>
    <coll name="Empresas" progid="ASGestion.CASEmpresa" ...>
    <coll name="Usuarios" progid="ASGestion.CASUser" ...>
</xml>
```

### Error 14: filter y sort dentro del SQL

```xml
<!-- INCORRECTO: el filtro dentro del SQL no es gestionado por el framework -->
<coll sql="SELECT * FROM ##PREF##Productos WHERE ACTIVO=1 ORDER BY NOMBRE">

<!-- CORRECTO: filter y sort como atributos separados del nodo coll -->
<coll sql="SELECT t1.* FROM ##PREF##Productos t1"
      filter="ACTIVO=1"
      sort="NOMBRE ASC">
```

### Error 15: Evento del Calendario con Guion

```xml
<!-- INCORRECTO -->
<ondate-selected>
    <script>self.FECHA = e.selectedDate;</script>
</ondate-selected>

<!-- CORRECTO: sin guion, y el parametro es DATEVALUE (no e.selectedDate) -->
<ondateselected>
    <action name="runscript">
        <param name="DATEVALUE" />
        <script language="javascript">
            self.MAP_FECHA_SEL = DATEVALUE;
        </script>
    </action>
</ondateselected>
```

### Error 16: Usar APIs del DOM en JavaScript

XOne no es HTML y no ejecuta código en un navegador. Estas APIs del DOM **no existen** en el entorno XOne y causarán errores:

```javascript
// INCORRECTO — APIs del DOM, no existen en XOne
document.getElementById("campo").value = "hola";
document.querySelector(".clase").style.display = "none";
window.location.href = "otraPantalla";
localStorage.setItem("clave", "valor");
sessionStorage.getItem("clave");
navigator.geolocation.getCurrentPosition(cb);
history.back();

// CORRECTO — usar las APIs propias de XOne (idiomáticas)
self.MAP_CAMPO = "hola";                          // escribir en campo
ui.openEditView("OtraPantalla");                  // navegar (forma corta: XOne crea el dataObject internamente)
appData.setGlobalMacro("CLAVE", "valor");         // almacenar globalmente
appData.getGlobalMacro("CLAVE");                  // recuperar valor global
$http.get("https://api.ejemplo.com/datos", ...);  // petición HTTP idiomática
ui.startGps(...);                                 // GPS

// TAMBIÉN funcionan — implementación custom XOne, semántica spec-compatible
fetch("https://api.ejemplo.com/datos").then(r => r.json());  // alternativa a $http
new Promise((resolve, reject) => { resolve(42); });           // Promise ES2024
setTimeout(() => doIt(), 1000);                               // ms (no segundos)
```

### Error 17: Nombres de nodos duplicados dentro de una coleccion

**Esta es una restricción crítica de la plataforma XOne.** Dentro de una `<coll>`, cada nodo con atributo `name` debe tener un nombre único en su ambito. Tampoco puede haber dos `<coll>` con el mismo nombre en el proyecto.

```xml
<!-- INCORRECTO: dos <group> con el mismo name -->
<coll name="MiPantalla" special="true">
    <group name="grpPrincipal" id="1">...</group>
    <group name="grpPrincipal" id="2">...</group>  <!-- ERROR -->
</coll>

<!-- INCORRECTO: dos <prop> con el mismo name -->
<group name="grpDatos" id="1">
    <prop name="NOMBRE" type="T" visible="7"/>
    <prop name="NOMBRE" type="L" visible="2"/>    <!-- ERROR -->
</group>

<!-- INCORRECTO: dos <frame> con el mismo name -->
<group name="grpPrincipal" id="1">
    <frame name="frmBody" width="100%" height="200p"/>
    <frame name="frmBody" width="100%" height="-2"/> <!-- ERROR -->
</group>

<!-- INCORRECTO: dos eventos del mismo tipo -->
<coll name="MiPantalla" special="true">
    <before-edit>...</before-edit>
    <before-edit>...</before-edit>                 <!-- ERROR -->
</coll>

<!-- CORRECTO: todos los nombres son unicos en su ambito -->
<coll name="MiPantalla" special="true">
    <before-edit>...</before-edit>
    <group name="grpPrincipal" id="1">
        <frame name="frmHeader" width="100%" height="100p"/>
        <frame name="frmBody"   width="100%" height="-2"/>
        <prop name="MAP_TITULO"    type="L" visible="7"/>
        <prop name="MAP_SUBTITULO" type="L" visible="7"/>
    </group>
    <group name="grpSecundario" id="2">...</group>
</coll>
```

**Lo que SI es valido:** dos `<coll>` con distinto `name` pero contenido identico. La restricción es sobre el nombre, no sobre el contenido.

---

*Documento de referencia generado a partir de las knowledgebases del proyecto XOneAI, la base de conocimiento estructurada (docs/kb/) y el análisis de 572 archivos .xne de 224 proyectos reales.*

**Anterior:** [d - Patrones y mappings](xone-xml-ui-d-patrones-mappings.md) · **Índice:** [xone-xml-ui-reference.md](xone-xml-ui-reference.md)