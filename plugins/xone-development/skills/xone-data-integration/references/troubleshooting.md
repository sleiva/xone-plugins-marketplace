# XOne Data Integration: troubleshooting

| Síntoma | Causa | Solución |
|---|---|---|
| `no such table` | Tabla no generada o prefijo incorrecto | Regenerar BD; usar `##PREF##`, `objname` y `updateobj` |
| Colección vacía | SQL/filtro restrictivo | Revisar SQL, `setFilter("")` y recargar |
| `-8100` al guardar | Obligatorio vacío | Validar antes de `save()` |
| Réplica incompleta | URL, timeout, conexión o cola corrupta | Revisar `Empresas`, red y logs |
| `JSON.parse` falla | Body inválido | `try/catch` y revisar respuesta |
| Petición sin respuesta | No hay mock HTTP | Añadir `mock/http.json` o `setMock` |
| `self` null | Contexto perdido | Guardar referencia antes del callback |

Si `no such table` persiste, comprueba que el `.xne` fue procesado, que el nombre coincide y que la BD se regeneró con `--overwrite`. Para `sys-message` de provisionamiento, replica antes de `failWithMessage(-11888, "##EXITAPP##")` y revisa la cola si falla.
