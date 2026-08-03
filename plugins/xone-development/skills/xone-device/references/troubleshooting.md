# XOne Device: troubleshooting

| Síntoma | Causa | Solución |
|---|---|---|
| GPS `STATUS != 1` | GPS apagado o sin señal | `checkGpsStatus`, permiso y `GPSColl` |
| Coordenadas `0`/null | GPS no iniciado o sin permiso | `startGps` antes de leer |
| Foto no se guarda | Permiso o filename ausente | Pedir permiso y pasar `filename` |
| Firma cancelada | Valor vacío en `onchange` | Comprobar `isEmpty` antes de guardar |
| Escáner sin resultado | Falta `scanResult` | Añadirlo a `mock/device.json` |
| Bluetooth no conecta | No descubierto o apagado | Estado Bluetooth, nombre y MAC |
| WebSocket sin mensajes | Red/servidor/payload | Validar JSON con `try/catch` |

El manifest mock usa posición por defecto `{0,0, STATUS:1, FAKE:1}` y avisa si no se configura `gps`. `scanResult` alimenta scanner/eventos y `photoPath` alimenta captura. Para reproducir escenarios ejecuta `xone-simulator smoke ./proyecto --json` o `run`/`render`.
