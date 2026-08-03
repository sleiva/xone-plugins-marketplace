---
description: Integración de datos en XOne. Usar al configurar colecciones y SQL con ##PREF##, SQL directo con SqlManager, peticiones $http con TLS/pinning, OAuth2, réplica con el objeto replica, mocks HTTP para pruebas, encriptación y seguridad de datos, o sincronización cliente-servidor por ROWID.
---

# XOne Data Integration

Guía de integración de datos en XOne: modelo de datos local (SQLite con prefijo `gen_`), SQL directo seguro, comunicación HTTP con `$http`, autenticación OAuth2, réplica/sincronización con el servidor, mocks HTTP para pruebas y seguridad de datos.

## Modelo de datos local

XOne usa una base de datos SQLite local (`gestion.db` en la carpeta `bd/`). Cada registro tiene un campo `ROWID` con un GUID de 32 caracteres hexadecimales sin guiones, que identifica el registro de forma única en cualquier dispositivo y es la base de la réplica y la resolución de conflictos. Definir `ROWID` como `type="T"` con `fieldsize="32"`.

Las tablas se nombran con el prefijo de base de datos seguido de `_` (típicamente `gen_`). Nunca escribas el prefijo literal: usa la macro `##PREF##`, que se sustituye por el prefijo configurado:

```xml
<coll name="Clientes"
      sql="SELECT * FROM ##PREF##Clientes"
      objname="Clientes" updateobj="Clientes" />
```

La base de datos y sus tablas se generan con el generador:

```bash
python3 -m xone_db_generator mi_proyecto --overwrite
```

La tabla de una colección no se genera si la colección no tiene `objname`/`updateobj`, si el `.xne` no fue procesado, o si el nombre no coincide (recordar `gen_`). Un error "no such table" se resuelve regenerando la BD.

### Colecciones y filtros

Las colecciones se cargan con `loadAll()`; los filtros se definen con `setFilter()` y se restauran tras usarlos:

```javascript
var coll = appData.getCollection("Clientes");
var original = coll.getFilter();
try {
    coll.setFilter("ID_EMPRESA=##ENTID## AND ACTIVO=1");
    coll.loadAll();
    // procesar
    coll.clear();
} finally {
    coll.setFilter(original);
}
```

Macros de datos más útiles: `##PREF##` (prefijo de tablas), `##ENTID##` (ID de empresa actual), `##USERID##` (ID del usuario logueado), `##NOW##`/`##NOW_DATE##`/`##NOW_TIME##` (fecha/hora), `##FLD_CAMPO##` (valor de un campo del registro actual, para filtrar contents hijo).

## SQL directo con SqlManager

`SqlManager` permite consultas e inserciones avanzadas. Siempre cerrar el cursor y la conexión en bloques `finally`:

```javascript
var sql = new SqlManager();
try {
    sql.openDatabase({ databasePath: "gestion.db", useExistingConnection: true });

    // Consulta parametrizada (SEGURA contra SQL injection)
    var cursor = sql.doRawQuery(
        "SELECT * FROM ##PREF##Usuarios WHERE LOGIN=? AND ACTIVO=?", "admin", 1);
    try {
        if (cursor.getCount() > 0) {
            cursor.moveToFirst();
            var nombre = cursor.getString("NOMBRE");
            var id = cursor.getInteger("ID");
        }
    } finally { cursor.close(); }

    // Insert con parametros
    sql.insert({
        tableName: "gen_Productos",
        fields: { CODIGO: "PROD001", NOMBRE: "Nuevo", PRECIO: 29.99 }
    });
} finally { sql.close(); }
```

Otros métodos documentados: `doBatchParseSqls(sqls)` para lotes, `doWalCheckpoint()` y `doVacuum()` para mantenimiento. `appData.executeSql(sql)` ejecuta SQL directo (solo usar con valores validados/numéricos).

### Prevención de SQL injection

NUNCA concatenar entrada del usuario en SQL:

```javascript
// PELIGROSO - inyección: login = "' OR 1=1 --" devuelve todos los registros
var u = coll.findObject("LOGIN = '" + loginUsuario + "'");
// PELIGROSO - id = "1; DROP TABLE gen_Usuarios;"
appData.executeSql("DELETE FROM gen_Productos WHERE ID = " + id);
```

Formas seguras:
- `SqlManager.doRawQuery` con `?` y parámetros (se escapan automáticamente).
- Escapar comillas simples en filtros: `valor.replace(/'/g, "''")`.
- Validar numéricos con `parseInt` + `isNaN` antes de concatenar.
- Usar `sql.insert` con objeto `fields` en lugar de construir `INSERT`.

## HTTP con `$http`

```javascript
var contexto = self;   // preservar contexto para callbacks

var request = {
    headers: { "Content-Type": "application/json", "Authorization": "Bearer " + token },
    parameters: {
        connectTimeout: 30000,
        readTimeout: 30000,
        allowUnsafeCertificates: false,   // NUNCA true en producción
        enablePinning: true,              // certificate pinning
        allowedRootCas: ["mi_ca.pem"]
    },
    data: { pagina: 1, limite: 50 },
    privateKey: authenticationKey,        // mTLS: certificado de cliente
    certificateChain: certificateChain
};

$http.post("https://api.ejemplo.com/usuarios", request,
    function(sData, headers, nHttpStatusCode) {
        var json = JSON.parse(sData);
        contexto.MAP_RESULTADO = json.id;
        ui.refresh("MAP_RESULTADO");
    },
    function(nError, sErrorDesc) {
        ui.showToast("Error " + nError + ": " + sErrorDesc);
    });
```

- Verbos: `$http.get(url, [request], ok, err)`, `$http.post/put/delete/patch(url, request, ok, err)`, `$http.download(url, request, ok, err)`.
- En `$http.download`, el éxito recibe la ruta local del archivo; abrir con `ui.openFile(sPath)`.
- La respuesta siempre es string: parsear con `JSON.parse` dentro de `try/catch`.
- El método retorna un `future` con `.cancel()`. Patrón de cancelación para búsquedas:

```javascript
if (requestActual) requestActual.cancel();
requestActual = $http.get(url + "?q=" + termino, request,
    function(sData) { requestActual = null; procesar(JSON.parse(sData)); },
    function(nError, sDesc) { requestActual = null; });
```

### TLS y seguridad de conexión

- `allowUnsafeCertificates: false` siempre en producción (nunca deshabilitar la verificación TLS).
- `enablePinning: true` con `allowedRootCas` para certificados de confianza (pinning).
- Para mTLS (certificado de cliente), pasar `privateKey` y `certificateChain` en el request.
- Usar siempre HTTPS.

## Pruebas HTTP con el simulador

El `xone-simulator` ejecuta `$http` en modo mock por defecto. Para simular respuestas sin red real, crea un manifest `mock/http.json` en la raíz del proyecto:

```json
[
  {
    "method": "POST",
    "url": "https://api.ejemplo.com/usuarios",
    "status": 201,
    "body": "{\"id\":123,\"nombre\":\"Juan\"}",
    "headers": { "Content-Type": "application/json" }
  },
  {
    "urlPattern": "https://api.ejemplo.com/productos*",
    "status": 200,
    "bodyFile": "mock/productos.json"
  }
]
```

Reglas del manifest:
- `url` coincide exactamente; `urlPattern` admite comodines `*`.
- `body` contenido inline o `bodyFile` ruta relativa a la raíz del proyecto.
- `method` opcional (coincide con GET/POST/PUT/DELETE/PATCH).
- En ejecución: `xone-simulator run ./proyecto --coll MiColl --event miEvento` usa la red mock y devuelve el resultado sin salir a internet.

También se pueden registrar mocks desde código con `$http.setMock(url, status, body, headers)` antes de la llamada.

## OAuth2

```javascript
function doAuthLogin() {
    new OAuth2().withOptions({
        authority:      "https://auth.miservidor.com/identity",
        clientID:       "mi_client_id",
        clientSecret:   "mi_client_secret",
        scope:          "openid profile",
        responseType:   "code id_token",
        persistenceKey: "oauth_key",
        redirectUri:    "com.miapp.oauth:/callback"
    }).authenticate({
        onSuccess: function(result) {
            appData.setGlobalMacro("##OAUTH_TOKEN##", result.access_token);
        },
        onError: function(err) {
            ui.showToast("Error de autenticacion");
        }
    });
}

function doAuthLogout() {
    new OAuth2().withOptions({
        authority: "https://auth.miservidor.com/identity",
        clientID: "mi_client_id", clientSecret: "mi_client_secret",
        scope: "openid profile", persistenceKey: "oauth_key",
        responseType: "code id_token", redirectUri: "com.miapp.oauth:/callback"
    }).logout();
}
```

Parámetros: `authority` (URL del servidor de autorización), `clientID`, `clientSecret`, `scope`, `responseType`, `persistenceKey` (clave de sesión persistente), `redirectUri` (esquema de URL de la app).

## Réplica y sincronización

La réplica sincroniza bidireccionalmente el dispositivo con el servidor usando el `ROWID` de cada registro.

```javascript
function sincronizar() {
    var bResult = replica.processReplicatorQueue(function(response) {
        console.log("Replica: " + response);
    });
    if (bResult) {
        ui.showToast("Sincronizacion completada");
    } else {
        ui.showToast("Error en sincronizacion");
    }
}
```

- `replica.start()` inicia la réplica; `appData.isReplicating()` comprueba si está en curso.
- La configuración de réplica y las tareas programadas se definen en el nodo `maintenance` de la colección `Empresas` en `mappings.xne`.

### Flujo de provisionamiento seguro (sys-message)

La colección `Empresas` puede recibir eventos `sys-message` para gestionar actualizaciones:

```javascript
function sysMessage(codigo, message) {
    switch(codigo) {
        case 1000: break;                    // actualización descargándose
        case 1001: break;                    // actualización aplicada
        case 1002: break;                    // todas las actualizaciones aplicadas
        case 1003:                           // provisionamiento seguro: replicar y cerrar
            ui.msgBox("Se va a actualizar la BD. Se replicaran datos y cerrara la app.", "Mensaje", 0);
            var bResult = replica.processReplicatorQueue(function(response) {
                console.log(response);
            });
            if (bResult) {
                appData.failWithMessage(-11888, "##EXITAPP##");
            }
            break;
    }
}
```

Si la réplica falla, verificar: conexión a internet, URL del servidor, timeout de conexión y datos corruptos en la cola de réplica.

## Seguridad de datos

### Encriptación

```javascript
// Encriptación básica del framework
var enc = appData.encryptString("dato sensible");
var dec = appData.decryptString(enc);

// Hashing de passwords
var hash = crypto.sha256({ data: password, outputFormat: "hex" });

// Cifrado simétrico AES con clave en hardware
var key = crypto.generateAesKey({
    alias: "app_datos_key", keySize: 256,
    useSecureHardware: true, useStrongBox: true
});
var cifrado = crypto.encrypt({
    data: "texto", dataFormat: "string",
    algorithm: "AES/GCM/NoPadding", key: key, outputFormat: "base64"
});

// Firma digital con clave EC
var keyPair = crypto.generateKeyPair({ alias: "firma_app", algorithm: "EC", keySize: 384, useSecureHardware: true });
var signature = crypto.sign({
    data: "datos a firmar", algorithm: "SHA256withECDSA",
    privateKey: keyPair.getPrivateKey().toPem(), outputFormat: "base64"
});

// Encoding y checksum
var b64 = crypto.toBase64({ data: "texto", urlSafe: true });
var crc = crypto.getChecksum({ type: "crc32", data: "texto" });
```

### Manejo de credenciales

- Nunca hardcodear passwords ni tokens en el código.
- Nunca loguear datos sensibles con `console.log`.
- Guardar tokens cifrados en macros globales (no en texto plano):

```javascript
function guardarTokenSesion(token) {
    appData.setGlobalMacro("##SESSION_TOKEN##", appData.encryptString(token));
}
function obtenerTokenSesion() {
    var t = appData.getGlobalMacro("##SESSION_TOKEN##");
    return isEmpty(t) ? null : appData.decryptString(t);
}
```

- Limpiar credenciales al cerrar sesión (`setGlobalMacro("##...##", "")` + `appData.logout()`).

### Validación de entrada antes de guardar

Validar siempre antes de `save()`: campos obligatorios (`isEmpty`), longitud (`cstr().length`), rangos (`cnum()`, `validarRango`), formato (email/teléfono). Un campo obligatorio sin valor produce el error `-8100`.

## Errores y diagnóstico

| Síntoma | Causa | Solución |
|---------|-------|----------|
| "no such table" | Tabla no generada o prefijo incorrecto | Regenerar BD; usar `##PREF##` y nombre exacto |
| Colección vacía tras `loadAll()` | SQL sin `##PREF##`, filtro restrictivo | Corregir SQL/filtro; `setFilter("")` y recargar |
| `-8100` al guardar | Campo obligatorio sin valor | Validar antes de `save()` |
| Réplica no completa | URL/timeout/conexión o cola corrupta | Revisar config de `Empresas` y logs |
| `Error en JSON.parse` | Respuesta no es JSON válido | `try/catch` al parsear; revisar el body |
| Petición sin respuesta | Red mock sin entrada en `mock/http.json` | Añadir entrada al manifest o `setMock` |
| Self null en callback | Contexto perdido en async | Guardar referencia antes del callback |

## Buenas prácticas

1. Usar `##PREF##` en toda SQL de colecciones; nunca el prefijo literal.
2. `ROWID` tipo `T` con `fieldsize="32"`.
3. Parametrizar SQL con `SqlManager`; escapar comillas en `findObject`.
4. Cerrar cursor y conexión siempre en `finally`.
5. `allowUnsafeCertificates: false` en producción; usar TLS y HTTPS.
6. Guardar tokens cifrados en macros; limpiar al cerrar sesión.
7. Probar `$http` con `mock/http.json` y el `xone-simulator` sin red real.
8. Validar entradas antes de `save()` para evitar `-8100`.
9. Preservar `self` (contexto) en callbacks asíncronos de `$http`.
10. Restaurar filtros de colección tras usarlos.
