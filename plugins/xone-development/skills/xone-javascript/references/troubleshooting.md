# XOne JavaScript: troubleshooting

| Síntoma | Causa | Solución |
|---|---|---|
| `self es null` | Contexto perdido en callback | Guardar `var contexto = self` antes |
| Colección bloqueada | `addItem` sin `unlock` | `unlock; try; finally { lock; }` |
| `NaN` | `null`/`undefined` | Usar `cnum()` y validar entrada |
| Campo no encontrado | Nombre distinto al XML | Respetar nombre y mayúsculas |
| Cursor no cerrado | Fuga SQL | `cursor.close()` en `finally` |
| WaitDialog persiste | Error antes de ocultarlo | `try/finally` con `hideWaitDialog` |
| GPS `STATUS != 1` | GPS o permisos | `checkGpsStatus` y permiso |
| `JSON.parse` falla | Respuesta no JSON | `try/catch` y revisar body |
| `window` es null | Pantalla cerrada | Comprobar vista antes de controles |
| `refresh` no actualiza | Prop incorrecta | Usar el `name` exacto del XML |

Para depurar usa `console.log`, `appData.writeConsoleString`, un toast temporal y `appData.error()` después de `save()`. Limpia los mensajes de error con `err.clear()`.

Helpers habituales de `functions.js`: `isEmpty`, `cstr`, `cnum`, `isNothing`, `getControl`, `confirmar` y `buscarObjeto`; al construir filtros escapa comillas simples (`'` -> `''`).
