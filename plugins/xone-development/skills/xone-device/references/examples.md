# XOne Device: ejemplos

## Cámara y QR

```javascript
var contexto = self;
var control = getControl("MAP_CAMERA");
if (control) control.takePicture({ filename: "foto.jpg", saveToGallery: true,
    width: 360, height: 360, onFinished: function(path) {
        if (path) { contexto.MAP_FOTO = path; ui.refresh("MAP_FOTO"); }
    }});

codeScanner.startCamera(function(codigo, fichero) {
    contexto.MAP_CODIGO = codigo; ui.refresh("MAP_CODIGO");
}, "qrcode", true);
```

## Biometría, Bluetooth y NFC

```javascript
biometricsManager.authenticate({
    onSuccess: function(result) { ui.showToast("Identidad verificada"); },
    onFailure: function(error, message) { ui.showToast(message); }
});

var devices = bluetoothSerial.getDiscoverableBluetoothDevices();
if (devices.length) {
    bluetoothSerial.connect(devices[0].getMacAddress());
    bluetoothSerial.write("datos");
    bluetoothSerial.disconnect();
}

var nfc = createObject("XOneNFC");
nfc.readNdefMessageAsync(function(result) { ui.showToast("Leido: " + result); });
```

## Simulador

```json
{
  "gps": { "LATITUD": 38.8685, "LONGITUD": -6.8170, "STATUS": 1, "FAKE": 1 },
  "gpsStatus": 4,
  "gpsPermission": true,
  "scanResult": "QR-SIMULADO-123",
  "photoPath": "camera/photo.jpg",
  "geocode": { "38.8862106, -7.0040345": { "lat": 38.8862, "lon": -7.0040 } }
}
```
