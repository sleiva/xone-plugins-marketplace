# XOne JavaScript: ejemplos

## Callback HTTP

```javascript
var contexto = self;
var request = { headers: { "Content-Type": "application/json" },
    parameters: { connectTimeout: 120000, readTimeout: 120000,
        allowUnsafeCertificates: false }, data: { pagina: 1 } };
$http.get(url, request, function(sData) {
    try {
        contexto.MAP_RESULTADO = JSON.parse(sData).id;
        ui.refresh("MAP_RESULTADO");
    } catch (e) { ui.showToast("Respuesta JSON no valida"); }
}, function(nError, sDesc) { ui.showToast("Error " + nError + ": " + sDesc); });
```

## Contents

```javascript
var lineas = self.getContents("@LineasPedido");
lineas.unlock();
try {
    lineas.clear();
    var obj = lineas.createObject();
    obj.MAP_DESCRIPCION = "Linea";
    lineas.addItem(obj);
} finally { lineas.lock(); }
lineas.saveAll();
```

## Browse, filtros y GPS

```javascript
coll.startBrowse();
try {
    coll.moveFirst();
    while (coll.getCurrentItem() != null) { coll.moveNext(); }
} finally { coll.endBrowse(); }

var original = coll.getFilter();
try { coll.setFilter("ACTIVO = 1"); coll.loadAll(); }
finally { coll.setFilter(original); }

ui.startGps({ nodeName: "callbackgps", timeBetweenUpdates: 10000, foreground: true });
var gps = appData.getCollection("GPSColl");
gps.startBrowse();
try {
    var p = gps.getCurrentItem();
    if (p && p.STATUS == 1 && p.LONGITUD) {
        self.MAP_LATITUD = p.LATITUD; self.MAP_LONGITUD = p.LONGITUD;
        ui.refresh("MAP_LATITUD,MAP_LONGITUD");
    }
} finally { gps.endBrowse(); }
```

## Cursor y WaitDialog

```javascript
var sql = new SqlManager();
try {
    sql.openDatabase({ databasePath: "gestion.db", useExistingConnection: true });
    var cursor = sql.doRawQuery("SELECT * FROM gen_Usuarios WHERE LOGIN=?", "admin");
    try { if (cursor.getCount() > 0) { cursor.moveToFirst(); } }
    finally { cursor.close(); }
} finally { sql.close(); }

ui.showWaitDialog("Procesando...");
try { /* trabajo */ } catch (e) { ui.showToast("Error: " + e); }
finally { ui.hideWaitDialog(); }
```
