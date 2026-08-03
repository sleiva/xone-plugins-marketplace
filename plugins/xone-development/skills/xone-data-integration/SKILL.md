---
name: xone-data-integration
description: Integración de datos en XOne. Usar al configurar colecciones y SQL con ##PREF##, SQL directo con SqlManager, appData y macros globales, peticiones $http con TLS/pinning/mTLS, futures, OAuth2, réplica con el objeto replica, mocks HTTP para pruebas, encriptación con crypto o sincronización cliente-servidor por ROWID.
---

# XOne Data Integration

Base SQLite local, SQL seguro, `appData`, `$http`, OAuth2, réplica, mocks y protección de datos.

**No inventes parámetros de `$http` ni métodos de `SqlManager`.** Están en las referencias; si algo no aparece, dilo y pide el dato.

## Modelo local

La BD es `gestion.db`, normalmente bajo `bd/`, y las tablas suelen llevar prefijo `gen_`. Usa siempre `##PREF##`, nunca el prefijo literal. Cada registro replicable tiene `ROWID` como GUID hexadecimal de 32 caracteres sin guiones, declarado `type="T" fieldsize="32"`. Las colecciones con `objname`/`updateobj` generan tabla; si falta, regenera con `python3 -m xone_db_generator mi_proyecto --overwrite`.

`ID` y `ROWID` los gestiona la plataforma: no hace falta declararlos como `<prop>`. En el `sql=` de la coll, `ID` sí se rescata en el SELECT; `ROWID` no es necesario.

Macros habituales: `##PREF##`, `##ENTID##`, `##USERID##`, `##NOW##`, `##NOW_DATE##`, `##NOW_TIME##`, `##FLD_CAMPO##`. Guarda y restaura filtros con `try/finally` y limpia la colección antes de recargar.

## Seguridad

- Parametriza SQL: `sqlManager.doRawQuery("… WHERE ID=?", id)`. Nunca concatenes entrada de usuario. Si un filtro exige texto, escapa `'` como `''`; valida los numéricos antes de concatenar.
- Cierra cursor y conexión en `finally`.
- HTTPS siempre, con `allowUnsafeCertificates: false` en producción. Pinning con `enablePinning`/`allowedRootCas`; mTLS con `privateKey`/`certificateChain`.
- No hardcodees ni registres credenciales. Cifra los tokens antes de guardarlos en macros globales y límpialos al cerrar sesión.
- Valida obligatorios, longitud, rangos y formato antes de `save()`: un obligatorio vacío produce `-8100`.

## Integración y réplica

`$http` devuelve respuestas string y futures cancelables: parsea con `try/catch`, preserva `self` antes del callback y cancela la búsqueda anterior antes de lanzar otra. OAuth2 se usa con `new OAuth2()`. `replica.processReplicatorQueue` sincroniza por `ROWID`; la configuración programada vive en el evento `maintenance` de `Empresas`. El error `-11888` con `##EXIT##` cierra la pantalla y con `##EXITAPP##` cierra la aplicación.

Para almacenamiento clave-valor, el equivalente de `localStorage` es `appData.setGlobalMacro`/`getGlobalMacro`; para datos de sesión, variables de colección (`setVariable`/`getVariable`).

## Anti-patrones

| Incorrecto | Correcto |
|---|---|
| `gen_` literal en XML o SQL portable | `##PREF##` |
| SQL concatenado con entrada externa | Parámetros `?` |
| Cursor o conexión sin cerrar | `finally` |
| `allowUnsafeCertificates: true` en producción | Verificación TLS |
| Token en claro en logs o macros | Cifrado, limpieza y sin logging |
| Leer `self` dentro del callback | Guardar el contexto antes |
| `appData.createObject("Http")` | Singleton `$http` |
| `new XMLHttpRequest()` | `$http.get(url, request, success, error)` |

## Referencias

| Para… | Lee |
|---|---|
| `appData` completo: colecciones, login/logout, paso de datos entre pantallas, macros globales, SQL directo, detección de dispositivo, `loadIncludeFile` y `loadCssFile` | [references/appdata.md](references/appdata.md) |
| `$http`: verbos, descarga de fichero, futures y llamadas en paralelo, TLS y mutual TLS, pinning, proxy y WebSocket | [references/http.md](references/http.md) |
| OAuth2 completo y objeto `replica` | [references/oauth2-y-replica.md](references/oauth2-y-replica.md) |
| Segunda redacción del corpus para `appData`, con ejemplos adicionales | [references/appdata-referencia-ampliada.md](references/appdata-referencia-ampliada.md) |
| Segunda redacción para `$http`, más `SqlManager` y la API `crypto` | [references/http-sqlmanager-y-crypto.md](references/http-sqlmanager-y-crypto.md) |

Los **eventos** implicados en la sincronización y el provisionamiento (`maintenance`, `sys-message` con sus códigos detallados, eventos de réplica) están documentados en `xone-xml-ui/references/eventos-sistema-login-y-personalizados.md`, porque se declaran en el XML.

Para probar integraciones sin backend, usa `mock/http.json` con `xone-simulator` (skill `xone-review`).
