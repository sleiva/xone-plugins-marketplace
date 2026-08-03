# XOne Data Integration: ejemplos

## SQL parametrizado

```javascript
var sql = new SqlManager();
try {
    sql.openDatabase({ databasePath: "gestion.db", useExistingConnection: true });
    var cursor = sql.doRawQuery(
        "SELECT * FROM ##PREF##Usuarios WHERE LOGIN=? AND ACTIVO=?", "admin", 1);
    try {
        if (cursor.getCount() > 0) { cursor.moveToFirst(); }
    } finally { cursor.close(); }
} finally { sql.close(); }
```

## HTTP mock y callback

```json
[{"method":"POST","url":"https://api.ejemplo.com/usuarios","status":201,
  "body":"{\"id\":123}","headers":{"Content-Type":"application/json"}},
 {"urlPattern":"https://api.ejemplo.com/productos*","status":200,
  "bodyFile":"mock/productos.json"}]
```

`url` coincide exactamente y `urlPattern` admite `*`; `method` es opcional. El simulador ejecuta `xone-simulator run ./proyecto --coll MiColl --event miEvento` sin salir a internet.

## OAuth2, réplica y cifrado

```javascript
new OAuth2().withOptions({ authority: "https://auth.ejemplo.com/identity",
    clientID: "mi_client_id", clientSecret: "mi_client_secret",
    scope: "openid profile", responseType: "code id_token",
    persistenceKey: "oauth_key", redirectUri: "com.miapp.oauth:/callback"
}).authenticate({ onSuccess: function(result) {
    appData.setGlobalMacro("##OAUTH_TOKEN##", result.access_token);
}, onError: function() { ui.showToast("Error de autenticacion"); } });

var cifrado = appData.encryptString("dato sensible");
var claro = appData.decryptString(cifrado);
var hash = crypto.sha256({ data: "password", outputFormat: "hex" });
```
