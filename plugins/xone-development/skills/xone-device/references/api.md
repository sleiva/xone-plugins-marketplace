# XOne Device: API

## Permisos y GPS

`systemSettings.isPermissionGranted(name)` y `requestPermissions(names, onSuccess, onFailure)`. `ui.startGps`, `stopGps`, `checkGpsStatus`, `askUserForGpsPermission`; `GpsTools` expone `distanceTo`, `getAddressFromPosition`, `containsLocation`, `getLastKnownLocation` y las utilidades de coordenadas documentadas por el runtime.

Los estados GPS son `0` sin hardware, `1` solo GPS, `2` solo redes, `3` ninguno y `4` óptimo. `GPSColl` entrega `LATITUD`, `LONGITUD`, `ALTITUD`, `VELOCIDAD`, `RUMBO`, `FGPS`, `HGPS`, `STATUS`, `SATELITES`, `FUENTE`, `PRECISION` y `FAKE`.

## Cámara, archivos y códigos

El control de cámara expone `takePicture`, `record`, `stopRecording`, `startPreview`, `stopPreview`, `isCameraOpened`, `isAutoFocus`, `setAutoFocus`, `getSupportedAspectRatios`, `setFlashMode`, `getFlashMode`, `getCamera`, `setCamera` y `setOnCodeScanned`. UI ofrece `startCamera`, `captureImage`, `takePicture`, `startScanner`, `scanQr`, `openFile`, `pickFile`.

`FileManager`: `fileExists`, `readFile`, `saveFile`, `delete`, `copy`, `move`, `rename`, `getSize`, `toBase64`, `toFile`, `getChecksum`, `download` y `uploadFile`. El simulador registra como warning las operaciones no soportadas `zip`, `unzip` y `downloadFile`.

`codeScanner.startCamera(callback, type, confirmPhoto)` y `scanFromFile(path, type)`. `BarcodeGenerator` usa `setType`, `setResolution`, `setDestinationFile` y `generate`.

## Biometría, Bluetooth, impresión y NFC

`biometricsManager.authenticate({onSuccess, onFailure})`. Legacy: `fingerprintManager.setCallback`, `listen`, `stopListening`, `launchFingerprintSettings`, `launch`.

`bluetoothSerial`: `getDiscoverableBluetoothDevices`, `connect`, `write`, `read`, `disconnect`; UI: `getBluetoothStatus`, `setBluetoothStatus`. `XOnePrinter`: `setDriver`, `setDelay`, `useStoredPrinter`, `selectBluetoothPrinter`, `connect`, `setMaxCharacterWidth`, `printImage`, `printLineCentered`, `disconnect`.

`XOneNFC.enableDnieReader`, `writeNdefMessageAsync`, `readNdefMessageAsync`; el resultado DNIe expone `getName`, `getSurname`, `getDniNumber`, `getUserImage`.

La lectura DNIe admite `readProfileData`, `readUserImage`, `canNumber`, `onDnieRead` y `onDnieReadError`. La generación de códigos soporta `code128`, `code39`, `ean13`, `qrcode`, `datamatrix` y `pdf417`.

## WebSocket y sistema

`new WebSocket({url, certificate, protocol, onOpen, onMessage, onError, onClose})`, `send` y `close`. `DeviceInfo` informa batería, temperatura, voltaje, tráfico, señal móvil y tipo de red. `WifiManager` expone estado, MAC, información activa, `connect` y `scanAvailableNetworks`. `systemSettings` también cubre brillo, red, memoria, almacenamiento, fabricante/modelo, MDM, Intune y actualizaciones.

UI incluye `isInBackground`, `returnToForeground`, `isWifiEnabled`, `vibrate`, sonido/vibración, teléfono, email, TTS, reconocimiento de voz, calendario y selectores de fecha/hora.

`showDatePicker` usa `initialYear`, `initialMonth`, `initialDay`, `title` y `onDateSet`; `showTimePicker` usa `initialHour`, `initialMinute`, `is24HoursMode` y `onTimeSet`. `ui.addCalendarItem` recibe `title`, `startDate` y `endDate`; `sendMail` admite destinatario, copia, asunto, cuerpo y adjunto.
