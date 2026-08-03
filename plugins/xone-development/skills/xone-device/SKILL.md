---
name: xone-device
description: Acceso a dispositivos y hardware en XOne. Usar al implementar GPS y geolocalización, cámara y captura de fotos/video, escaneo QR/códigos, firma digital, permisos y biometría (huella/face), Bluetooth e impresión, NFC/DNI electrónico, WebSocket, FileManager, o al simular device features con mock/device.json.
---

# XOne Device

Integra GPS, cámara, escáner, firma, permisos, biometría, Bluetooth, NFC, archivos y utilidades del dispositivo. El simulador `xone-simulator` permite reproducir muchas capacidades con `mock/device.json`.

## Reglas críticas

- Pide y comprueba permisos antes de GPS, cámara, micrófono o biometría; en el simulador el permiso se concede automáticamente.
- Para GPS: `ui.startGps()` antes de leer `GPSColl`; usa `startBrowse`/`endBrowse`, comprueba `STATUS == 1` y que `LONGITUD` no esté vacío.
- En callbacks de cámara, GPS y escáner conserva `self` antes de la operación y refresca solo los campos modificados.
- Cierra Bluetooth y WebSocket cuando termines. Prefiere `ui.executeActionAfterDelay()` a `ui.sleep()`.
- Usa `biometricsManager` para biometría nueva; `fingerprintManager` es legacy.
- En archivos comprueba `fileExists(...) === 0`; `saveFile(..., false)` sobrescribe.

## GPS, cámara y firma

```javascript
ui.startGps({ nodeName: "callbackgps", timeBetweenUpdates: 10000,
    minimumMetersDistanceRange: 10, foreground: true });
var status = ui.checkGpsStatus();
if (status == 0 || status == 3) ui.askUserForGpsPermission({
    onEnabled: function() { ui.startGps(); },
    onDenied: function() { ui.showToast("Active el GPS"); }
});
```

Lee `GPSColl` dentro de un browse y copia `LATITUD`, `LONGITUD`, `ALTITUD`, `VELOCIDAD`, `RUMBO`, `FGPS`, `HGPS`, `STATUS`, `SATELITES`, `FUENTE` y `PRECISION` según necesites. La cámara usa el control de `type="VD"` (`takePicture`/`record`); la firma documentada usa `type="IMG"` con CSS `img-sign` y procesa el valor en `onchange`.

## Anti-patrones

| Evitar | Usar |
|---|---|
| Leer GPS sin iniciar ni pedir permiso | `startGps` + estado + permiso |
| Aceptar cualquier coordenada | `STATUS == 1` y longitud válida |
| Usar `fingerprintManager` en código nuevo | `biometricsManager` |
| Bloquear la UI con `ui.sleep()` | `executeActionAfterDelay` |
| Dejar conexiones abiertas | `disconnect`/`close` en el flujo de salida |
| Asumir que el simulador tiene datos | Configurar `mock/device.json` |

## Recursos adicionales

- APIs de hardware, archivos, biometría, Bluetooth, NFC, WebSocket y utilidades: [references/api.md](references/api.md)
- Ejemplos de integración: [references/examples.md](references/examples.md)
- Diagnóstico de dispositivo y simulador: [references/troubleshooting.md](references/troubleshooting.md)
