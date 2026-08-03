---
name: xone-device
description: Acceso a dispositivos y hardware en XOne. Usar al implementar GPS y geolocalización, cámara y captura de foto o vídeo, escaneo QR y códigos de barras, firma con type DR, permisos en runtime, biometría con biometricsManager, Bluetooth, impresión, NFC y DNI electrónico, WifiManager, FileManager, o al simular hardware con mock/device.json.
---

# XOne Device

GPS, cámara, escáner, firma, permisos, biometría, Bluetooth, NFC, impresión, archivos y utilidades del dispositivo. `xone-simulator` reproduce muchas capacidades con `mock/device.json` (skill `xone-review`).

**No inventes métodos de hardware.** Cada objeto tiene su API en las referencias; si algo no aparece, dilo.

## Reglas críticas

- Pide y comprueba permisos antes de GPS, cámara, micrófono o biometría. Los permisos se solicitan con `systemSettings.requestPermissions`, que devuelve un future. En el simulador se conceden automáticamente.
- Declara los permisos que use la app en el nodo `<permissions>`: `location-foreground`, `location-background`, `camera`, `notifications`, `contacts`…
- GPS: `ui.startGps()` antes de leer la colección de GPS; recórrela con `startBrowse`/`endBrowse`, comprueba `STATUS == 1` y que `LONGITUD` no esté vacío. `ui.checkGpsStatus()` devuelve `0` sin hardware, `1` solo GPS, `2` solo redes, `3` ninguno y `4` GPS y redes.
- La colección de GPS (`GPSColl`/`GpsCollection`) **la declara el proyecto** con el connector GPS: no es built-in de XOne.
- En callbacks de cámara, GPS y escáner conserva `self` antes de la operación y refresca solo los campos modificados.
- Cierra Bluetooth y WebSocket al terminar. Prefiere `ui.executeActionAfterDelay()` (segundos) a una espera bloqueante.
- `biometricsManager` es el singleton actual; `fingerprintManager` es legacy.
- La firma se hace con `<prop type="DR">` (`stroke-color`, `stroke-width`, `apply-format-to-file`, `ui.saveDrawing`, `ui.clearDrawing`). `type="IMG" readonly="false"` es la forma **obsoleta**.
- En archivos, comprueba `fileExists(...) === 0`; `saveFile(..., false)` sobrescribe.

## GPS

```javascript
ui.startGps({ nodeName: "callbackgps", timeBetweenUpdates: 10000,
    minimumMetersDistanceRange: 10, priority: "high",
    granularity: "permission_level", waitForAccurateLocation: true });

var status = ui.checkGpsStatus();
if (status == 0 || status == 3) ui.askUserForGpsPermission({
    onEnabled: function () { ui.startGps(); },
    onDenied:  function () { ui.showToast("Active el GPS"); }
});
```

Del registro de GPS se leen `LATITUD`, `LONGITUD`, `ALTITUD`, `VELOCIDAD`, `RUMBO`, `FGPS`, `HGPS`, `STATUS`, `SATELITES`, `FUENTE`, `PRECISION` y el campo `FAKE`. Para cálculos hay `GpsTools` (`distanceBetweenCoordinates`, `getPositionFromAddress`, encode/decode, `simplifyPolyline`, `addExifLocationToFile`, `routeTo`).

## Anti-patrones

| Incorrecto | Correcto |
|---|---|
| Leer GPS sin iniciarlo ni pedir permiso | `startGps` + `checkGpsStatus` + permiso |
| Aceptar cualquier coordenada | `STATUS == 1` y longitud válida |
| `type="IMG" readonly="false"` para firma | `type="DR"` |
| `fingerprintManager` en código nuevo | `biometricsManager` |
| `appData.createObject("XOneWifiManager")` | `new WifiManager()` |
| `appData.createObject("XOneBiometricsManager")` | Singleton `biometricsManager` |
| `new DeviceInfo()` / `new SystemSettings()` | Singletons `deviceInfo` / `systemSettings` |
| `deviceInfo.getMobileNetworkSignalStrengh()` | `getMobileNetworkSignalStrength()` |
| Bloquear la UI esperando | `ui.executeActionAfterDelay` |
| Dejar conexiones abiertas | `disconnect`/`close` al salir |
| Asumir que el simulador tiene datos de hardware | Configurar `mock/device.json` |

## Referencias

| Para… | Lee |
|---|---|
| FileManager, XOnePDF, XOnePrinter, BarcodeGenerator, Datawedge, XOneNFC, XOneOCR, BluetoothSerialPort, WifiManager, Animation, deviceInfo, GpsTools, OAuth2, WebSocket y fingerprintManager | [references/objetos-de-dispositivo.md](references/objetos-de-dispositivo.md) |
| `systemSettings`: permisos en runtime con futures, brillo, red, batería, memoria y espacio, hardware, rutas, MDM, XOneLive e Intune | [references/systemsettings-y-permisos.md](references/systemsettings-y-permisos.md) |
| Segunda redacción del corpus para `systemSettings`, más extensa | [references/systemsettings-referencia-ampliada.md](references/systemsettings-referencia-ampliada.md) |
| `biometricsManager`, `ImageDrawing`, otros objetos utilitarios y tabla resumen de complementarios | [references/biometria-imagedrawing-y-otros.md](references/biometria-imagedrawing-y-otros.md) |

Los métodos de los controles de cámara, vídeo, dibujo y escáner están en `xone-javascript` → `references/metodos-de-los-controles.md`. Los atributos XML de esos props, en `xone-xml-ui`.
