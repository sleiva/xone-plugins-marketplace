# XOne JavaScript: API

## DataObject y colección

`self.getOwnerCollection()`, `save()`, `getContents(name)`, `executeNode(name)`, `getFieldPropertyValue(field, property)`, `setFieldPropertyValue(field, property, value)`, `toJSON()`, `getObjectIndex()`, `getVariables(name)`, `setVariables(name, value)`, `getDirty()`, `isNew()` y `getOldValue(field)`.

`selfDataColl` es la colección directa. Métodos de `DataCollection`: `createObject`, `addItem`, `deleteItem(index)`, `browseDeleteAll`, `clear`, `getCount`/`count`, `get(index)`, `indexOf`, `getCurrentItem`, `moveFirst`, `moveNext`, `movePrevious`, `moveLast`, `moveTo`, `startBrowse`, `endBrowse`, `setFilter`, `getFilter`, `doSort`, `loadAll`, `findObject`, `findAllObjects`, `getItem`, `loadFromJson`, `saveAll`, `lock`, `unlock`, `createClone`, `setMacro`, `getMacro`, `setVariable`, `getVariable`, `createSearchIndex`, `doSearch`, `generateRowId`, `getName`, `getPropertyCount`, `propertyName` y `getPropType`.

## UserInterface

Navegación: `openEditView`, `openMenu`, `getView`. Mensajes: `msgBox`, `showToast`, `showSnackbar`. Espera: `showWaitDialog`, `hideWaitDialog`, `updateWaitDialog`, `setMaxWaitDialog`. Vista: `refresh`, `refreshValue`, `refreshContentRow`, `showGroup`, `hideGroup`, `isGroupOpen`, `setStatusBarColor`, `setBottomSheetState`. Tiempo: `executeActionAfterDelay`, `startChronometer`, `stopChronometer`. Dispositivo: `startGps`, `stopGps`, `checkGpsStatus`, `askUserForGpsPermission`, `takePicture`, `record`, `scanQr`, `openFile`, `pickFile`, `sendMail`, `openUrl`, `makePhoneCall`, `startCamera`, `startScanner`, `startAudioRecord`, `stopAudioRecord`, `startReplica`, `speak`, `recognizeSpeech`, `vibrate`, `playSoundAndVibrate`, `stopPlaySoundAndVibrate`, `showDatePicker` y `showTimePicker`.

Los controles específicos se obtienen con `getControl(name, [dataObject])` o `window.NOMBRE` según el proyecto. Stepper expone `getValue`, `setValue`, `setMin`, `setMax`, `setStepSize`; OTP expone `getOtpValue`, `clearOtp`, `focusOtp`.

## AppData

`getCollection`, `setGlobalMacro`/`getGlobalMacro`, `pushValue`/`popValue`, `getCurrentUser`, `getCurrentEnterprise`, `login`/`logout`, `exit`, `restart`, `executeSql`, `failWithMessage`, `executeNode`, `getAppPath`, `getFilesPath`, `error`, `loadIncludeFile`, `loadCssFile` y `unloadCssFile`.

## HTTP y SQL

`$http.get`, `post`, `put`, `delete`, `patch` y `download` reciben URL, request opcional y callbacks de éxito/error; devuelven un future con `cancel()`. `parameters` admite timeouts, `allowUnsafeCertificates`, `enablePinning`, `allowedRootCas`, `dumpCertificateChainPath` y proxy; mTLS usa `privateKey` y `certificateChain`. WebSocket admite `url`, `certificate` y `protocol`.

`SqlManager` usa `openDatabase`, `doRawQuery`, `insert`, `doBatchParseSqls`, `doWalCheckpoint`, `doVacuum` y `close`. El cursor expone `getCount`, `moveToFirst`, `getString`, `getInteger` y `close`.

## Utilidades y globales

`new FileManager()`, `new GpsTools()`, `new OAuth2()`, `new Worker()`, `new Animation()`, `new WebSocket()` y los creables documentados por el runtime. Son singletons, sin `new`: `$http`, `crypto`, `clipboard`, `deviceInfo`, `systemSettings`, `replica`, `biometricsManager`, `fingerprintManager`, `bluetoothSerial`, `sensorManager` y `packageManager`.

No confundas `getControl` nativo con una función local que lo sombree. `Animation` usa API fluida, `setTarget(string)`, `setRelativeX/Y(value)` y un único `setCircularReveal(cx, cy, bReveal)`.

## Macros, sesión y controles

`appData.setGlobalMacro`/`getGlobalMacro` sustituyen el uso de `localStorage`; macros frecuentes son `##TOKEN##` y `##DEVICE_OS##`. `pushValue`/`popValue` pasan valores entre pantallas. `login` acepta `userName`, `password`, `entryPoint`, `onLoginSuccessful` y `onLoginFailed`.

`ui.msgBox` puede ser síncrono o recibir un `dataObject`; `showToast` y `showSnackbar` aceptan texto/opciones. `ui.openMenu` abre directamente la lista de una colección; `ui.openEditView` es el patrón de navegación principal. `getView` permite `exit`, controles por nombre y refresco. `setBottomSheetState`/`getBottomSheetState` gestionan el bottom sheet.

GPS usa `startGps` con `priority`, `granularity`, `waitForAccurateLocation`, `timeBetweenUpdates`, `minimumMetersDistanceRange`, `foreground`, `title` y `text`. La colección `GpsCollection`/`GPSColl` es declarada por el proyecto, no un objeto built-in; se lee con `loadAll`/`get(0)` o browse y puede incluir `FAKE`.

`selfDataColl.getCount`/`count` devuelven el tamaño; `loadFromJson`, `toJson` y `toJsonString` serializan colecciones. El patrón preferido para objetos es `new NombreColeccion({ PROP: valor })`; `createObject()` queda para contents anidados o nombres dinámicos.

`deviceInfo` expone `getBatteryLevelPercentage` y `getMobileNetworkSignalStrength` (sin variantes con typo). `systemSettings` cubre brillo, red, batería, `requestPermissions` con futures, memoria/espacio (`getMemoryLevel`, `getInternalFreeSpace`, `getExternalFreeSpace`), hardware (`getManufacturer`, `getDeviceModel`, `getBrand`), rutas, MDM, XOneLive e Intune.
