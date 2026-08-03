---
name: xone-data-integration
description: Integración de datos en XOne. Usar al configurar colecciones y SQL con ##PREF##, SQL directo con SqlManager, peticiones $http con TLS/pinning, OAuth2, réplica con el objeto replica, mocks HTTP para pruebas, encriptación y seguridad de datos, o sincronización cliente-servidor por ROWID.
---

# XOne Data Integration

Integra la base SQLite local, SQL seguro, HTTP, OAuth2, réplica, mocks y protección de datos.

## Modelo local

La BD es `gestion.db`, normalmente bajo `bd/`; las tablas suelen llevar prefijo `gen_`. Usa siempre `##PREF##`, nunca un prefijo literal. Cada registro replicable tiene `ROWID` como GUID hexadecimal de 32 caracteres sin guiones y debe declararse `type="T" fieldsize="32"`. Las colecciones con `objname`/`updateobj` generan tabla; si falta o el `.xne` no se procesa, regenera con `python3 -m xone_db_generator mi_proyecto --overwrite`.

Macros útiles: `##PREF##`, `##ENTID##`, `##USERID##`, `##NOW##`, `##NOW_DATE##`, `##NOW_TIME##` y `##FLD_CAMPO##`. Guarda y restaura filtros con `try/finally`; limpia la colección antes de recargar.

## Seguridad obligatoria

- Parametriza SQL con `SqlManager.doRawQuery(..., ?)`; nunca concatena entrada de usuario. Si un filtro exige texto, escapa `'` a `''`; valida numéricos antes de concatenar.
- Cierra cursor y conexión en `finally`.
- Usa HTTPS; `allowUnsafeCertificates: false` siempre en producción. Pinning usa `enablePinning`/`allowedRootCas`; mTLS usa `privateKey`/`certificateChain`.
- No hardcodees ni registres credenciales. Cifra tokens antes de macros globales y límpialos al cerrar sesión.
- Valida campos obligatorios, longitud, rangos y formato antes de `save()`; un obligatorio vacío produce `-8100`.

## Integración y réplica

`$http` devuelve respuestas string y futures cancelables: parsea con `try/catch`, preserva `self` en callbacks y cancela la búsqueda anterior. OAuth2 usa `new OAuth2().withOptions(...).authenticate(...)`. `replica.processReplicatorQueue` sincroniza por `ROWID`; la configuración programada está en `maintenance` de `Empresas`. `-11888` con `##EXIT##` cierra la pantalla y con `##EXITAPP##` cierra la aplicación.

## Anti-patrones

| Evitar | Usar |
|---|---|
| `gen_` escrito en XML/SQL portable | `##PREF##` |
| SQL concatenado | parámetros o escape validado |
| cursor/conexión sin cierre | `finally` |
| `allowUnsafeCertificates: true` | HTTPS y verificación TLS |
| token plano en logs/macros | cifrado, limpieza y no logging |
| leer `self` directamente en callback | conservar contexto antes |

## Recursos adicionales

- APIs completas de SQL, HTTP, OAuth2, réplica y crypto: [references/api.md](references/api.md)
- Ejemplos y manifests mock: [references/examples.md](references/examples.md)
- Diagnóstico de datos e integración: [references/troubleshooting.md](references/troubleshooting.md)
