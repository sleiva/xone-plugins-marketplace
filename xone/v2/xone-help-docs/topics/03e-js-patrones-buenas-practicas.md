# JavaScript API — Patrones, seguridad, optimización y best practices

Sub-archivo del [Tópico 03 - Guía Completa de JavaScript](03-javascript-api-guide.md). Recopila los patrones críticos de código (lock/unlock, startBrowse/endBrowse, filter/restore, callbacks asíncronos, WaitDialog, cursores SQL), seguridad (SQL injection, validación, encriptación, credenciales), optimización y rendimiento, ejemplos comunes (CRUD, filtrado, maestro-detalle, GPS, fotos, chat, QR, descargas, sincronización, login), funciones utilitarias recomendadas, debugging/troubleshooting y top 20 best practices.

## Tabla de Contenidos

- [9. Patrones Críticos de Código](#9-patrones-criticos-de-codigo)
- [10. Seguridad en JavaScript XOne](#10-seguridad-en-javascript-xone)
- [11. Optimización y Rendimiento](#11-optimizacion-y-rendimiento)
- [12. Patrones Comunes con Ejemplos](#12-patrones-comunes-con-ejemplos)
- [13. Funciones Utilitarias Recomendadas](#13-funciones-utilitarias-recomendadas)
- [14. Debugging y Troubleshooting](#14-debugging-y-troubleshooting)
- [15. Best Practices - Top 20](#15-best-practices---top-20)

---

## 9. Patrones Críticos de Código

Patrones fundamentales que todo desarrollador XOne debe dominar. El uso incorrecto de estos patrones es la causa principal de errores y memory leaks.

### 9.1 Patron lock/unlock (Modificación de Colecciones)

**Siempre** usar `finally` para garantizar que se ejecute `lock()`, incluso si hay error:

```javascript
function agregarRegistro(nombreColl, datos) {
    var coll = appData.getCollection(nombreColl);
    coll.unlock();
    try {
        var obj = coll.createObject();
        for (var key in datos) {
            if (datos.hasOwnProperty(key)) {
                obj[key] = datos[key];
            }
        }
        coll.addItem(obj);
        obj.save();
        return true;
    } catch(error) {
        ui.showToast("Error: " + error);
        return false;
    } finally {
        coll.lock();  // SIEMPRE se ejecuta
    }
}
```

### 9.2 Patron startBrowse/endBrowse (Navegación de Colecciones)

**Siempre** usar `finally` para garantizar que se ejecute `endBrowse()`:

```javascript
function procesarColeccion(nombreColl) {
    var coll = appData.getCollection(nombreColl);
    coll.startBrowse();
    try {
        coll.moveFirst();
        while (coll.getCurrentItem() != null) {
            var obj = coll.getCurrentItem();
            console.log(obj.MAP_NOMBRE);
            coll.moveNext();
        }
    } finally {
        coll.endBrowse();  // SIEMPRE se ejecuta
    }
}
```

### 9.3 Patron filter/restore (Filtrado Seguro)

**Siempre** guardar el filtro original y restaurarlo después de usar, idealmente en `finally`:

```javascript
function procesarRegistrosActivos(nombreColl) {
    var coll = appData.getCollection(nombreColl);
    var filtroOriginal = coll.getFilter();

    try {
        coll.setFilter("ACTIVO = 1 AND ESTADO = 'PENDIENTE'");
        coll.loadAll();

        var count = coll.count();
        for (var i = 0; i < count; i++) {
            var obj = coll.get(i);
            // Procesar...
        }

        coll.clear();
    } finally {
        coll.setFilter(filtroOriginal);  // Restaurar SIEMPRE
    }
}
```

### 9.4 Patron de Preservacion de Contexto en Callbacks Asíncronos

En callbacks asíncronos de `$http`, `executeActionAfterDelay` y otros, el objeto `self` **puede cambiar de contexto**. Se debe guardar la referencia **antes** de la llamada:

```javascript
function cargarDatosServidor(url) {
    var contexto = self;  // GUARDAR referencia antes del callback

    $http.get(url,
        function(sData) {
            // INCORRECTO: self.MAP_DATO = sData;
            contexto.MAP_DATO = sData;
            ui.refresh("MAP_DATO");
        },
        function(nError, sDesc) {
            ui.showToast("Error: " + sDesc);
        }
    );
}
```

### 9.5 Patron WaitDialog Seguro

**Siempre** ocultar el WaitDialog en un bloque `finally`:

```javascript
function operacionLarga() {
    ui.showWaitDialog("Procesando...");
    try {
        var coll = appData.getCollection("Datos");
        coll.loadAll();
        // ...procesar...
    } catch(ex) {
        ui.showToast("Error: " + ex);
    } finally {
        ui.hideWaitDialog();
    }
}
```

### 9.6 Patron Cursor SQL Seguro

**Siempre** cerrar el cursor y la conexión en bloques `finally`:

```javascript
function consultarDatos(query, parametros) {
    var sqlManager = new SqlManager();
    try {
        sqlManager.openDatabase({
            databasePath: "gestion.db",
            useExistingConnection: true
        });

        var cursor = sqlManager.doRawQuery(query, parametros);
        try {
            if (cursor.getCount() > 0) {
                cursor.moveToFirst();
                return {
                    id: cursor.getInteger("ID"),
                    nombre: cursor.getString("NOMBRE")
                };
            }
            return null;
        } finally {
            cursor.close();
        }
    } finally {
        sqlManager.close();
    }
}
```

---

## 10. Seguridad en JavaScript XOne

### 10.1 Prevencion de SQL Injection

**Código VULNERABLE (NUNCA hacer esto):**

```javascript
// PELIGROSO: concatenacion directa de input del usuario
function buscarUsuario(loginUsuario) {
    let coll = appData.getCollection("Usuarios");
    // Si loginUsuario = "' OR 1=1 --" obtendria todos los registros
    let usuario = coll.findObject("LOGIN = '" + loginUsuario + "'");
    return usuario;
}

// PELIGROSO: SQL directo sin parametrizar
function eliminarRegistro(id) {
    appData.executeSql("DELETE FROM gen_Productos WHERE ID = " + id);
}
```

**Código SEGURO (hacer SIEMPRE esto):**

```javascript
// SEGURO: SqlManager con parametros (consultas parametrizadas)
function buscarUsuarioSeguro(loginUsuario) {
    let sqlManager = new SqlManager();
    try {
        sqlManager.openDatabase({
            databasePath: "gestion.db",
            useExistingConnection: true
        });

        let cursor = sqlManager.doRawQuery(
            "SELECT * FROM gen_Usuarios WHERE LOGIN=?",
            loginUsuario  // El parametro se escapa automaticamente
        );
        try {
            if (cursor.getCount() > 0) {
                cursor.moveToFirst();
                return {
                    id    : cursor.getInteger("ID"),
                    nombre: cursor.getString("NOMBRE"),
                    login : cursor.getString("LOGIN")
                };
            }
            return null;
        } finally {
            cursor.close();
        }
    } finally {
        sqlManager.close();
    }
}

// SEGURO: Escapar comillas simples para findObject
function buscarObjetoSeguro(nombreColl, campo, valor) {
    let valorEscapado = cstr(valor).replace(/'/g, "''");
    let coll = appData.getCollection(nombreColl);
    return coll.findObject(campo + "='" + valorEscapado + "'");
}

// SEGURO: Validar que sea numerico antes de concatenar
function eliminarRegistroSeguro(id) {
    let nId = parseInt(id);
    if (isNaN(nId) || nId <= 0) {
        ui.showToast("ID no valido");
        return;
    }
    appData.executeSql("DELETE FROM gen_Productos WHERE ID = " + nId);
}
```

### 10.2 Validación de Entrada

```javascript
// === Funciones de validación esenciales ===

function isEmpty(val) {
    return val === undefined || val === null || val === "";
}

function cstr(val) {
    if (val === undefined || val === null) return "";
    return val.toString();
}

function cnum(val) {
    if (val === undefined || val === null || val === "") return 0;
    let num = parseFloat(val);
    return isNaN(num) ? 0 : num;
}

// === Sanitizacion ===
function sanearEntrada(valor, maxLength) {
    if (isEmpty(valor)) return "";
    let sValor = cstr(valor).trim();
    if (maxLength && sValor.length > maxLength) {
        sValor = sValor.substring(0, maxLength);
    }
    return sValor;
}

function validarEmail(email) {
    if (isEmpty(email)) return false;
    return email.indexOf("@") > 0 && email.indexOf(".") > 0;
}

function validarTelefono(telefono) {
    if (isEmpty(telefono)) return false;
    let limpio = telefono.replace(/[^\d+]/g, '');
    return limpio.length >= 9;
}

function validarRango(valor, min, max) {
    let num = cnum(valor);
    return num >= min && num <= max;
}

// === Patron completo antes de guardar ===
function validarFormulario() {
    if (isEmpty(self.MAP_NOMBRE)) {
        ui.showToast("El nombre es obligatorio");
        return false;
    }
    if (cstr(self.MAP_NOMBRE).length > 100) {
        ui.showToast("El nombre no puede superar 100 caracteres");
        return false;
    }
    if (cnum(self.MAP_CANTIDAD) <= 0) {
        ui.showToast("La cantidad debe ser mayor a 0");
        return false;
    }
    if (!validarEmail(self.MAP_EMAIL)) {
        ui.showToast("Email no valido");
        return false;
    }
    return true;
}
```

### 10.3 Encriptación de Datos Sensibles

```javascript
// === Encriptacion básica del framework ===
let encrypted = appData.encryptString("dato sensible");
let decrypted = appData.decryptString(encrypted);

// === API Crypto avanzada ===

// Hashing (unidireccional, para passwords)
function hashPassword(password) {
    return crypto.sha256({
        data        : password,
        outputFormat: "hex"
    });
}

// Cifrado simetrico AES
function cifrarDato(texto) {
    let aesKey = crypto.generateAesKey({
        alias           : "app_datos_key",
        keySize         : 256,
        useSecureHardware: true,
        useStrongBox    : true
    });

    return crypto.encrypt({
        data        : texto,
        dataFormat  : "string",
        algorithm   : "AES/GCM/NoPadding",
        key         : aesKey,
        outputFormat: "base64"
    });
}

function descifrarDato(textoCifrado) {
    let aesKey = crypto.generateAesKey({
        alias           : "app_datos_key",
        keySize         : 256,
        useSecureHardware: true
    });

    return crypto.decrypt({
        data        : textoCifrado,
        dataFormat  : "base64",
        algorithm   : "AES/GCM/NoPadding",
        key         : aesKey,
        outputFormat: "string"
    });
}

// Cifrar/descifrar archivos
crypto.encrypt({
    data: "documento.pdf", dataFormat: "file",
    algorithm: "AES/GCM/NoPadding", key: aesKey,
    outputFormat: "file", output: "documento.pdf.enc"
});

// Firma digital con clave pública/privada
let keyPair = crypto.generateKeyPair({
    alias: "firma_app", algorithm: "EC", keySize: 384,
    output: "key", outputFormat: "file", useSecureHardware: true
});

let signature = crypto.sign({
    data: "datos a firmar", algorithm: "SHA256withECDSA",
    privateKey: keyPair.getPrivateKey().toPem(), outputFormat: "base64"
});

// Encoding
let base64 = crypto.toBase64({ data: "texto", urlSafe: true });
let decoded = crypto.fromBase64({ data: base64 });

// Checksum
let crc32 = crypto.getChecksum({ type: "crc32", data: "texto" });
```

### 10.4 Manejo Seguro de Credenciales

```javascript
// INCORRECTO: hardcodear passwords / loguear datos sensibles
let password = "admin123";              // NUNCA
console.log("Password: " + password);   // NUNCA

// CORRECTO: macros globales encriptadas
function guardarTokenSesion(token) {
    let tokenCifrado = appData.encryptString(token);
    appData.setGlobalMacro("##SESSION_TOKEN##", tokenCifrado);
}

function obtenerTokenSesion() {
    let tokenCifrado = appData.getGlobalMacro("##SESSION_TOKEN##");
    if (isEmpty(tokenCifrado)) return null;
    return appData.decryptString(tokenCifrado);
}

// CORRECTO: limpiar credenciales al cerrar sesion
function cerrarSesion() {
    appData.setGlobalMacro("##SESSION_TOKEN##", "");
    appData.setGlobalMacro("##USERID##", "");
    appData.setGlobalMacro("##USERNAME##", "");
    appData.setGlobalMacro("##USERROLE##", "");
    appData.logout();
}

// CORRECTO: comunicaciones seguras
function crearRequestSeguro(token) {
    return {
        headers: {
            "Authorization": "Bearer " + token,
            "Content-Type" : "application/json"
        },
        parameters: {
            connectTimeout         : 30000,
            readTimeout            : 30000,
            allowUnsafeCertificates: false,  // NUNCA true en produccion
            enablePinning          : true
        }
    };
}
```

---

## 11. Optimización y Rendimiento

### 11.1 Minimizar Refreshes

```javascript
// INCORRECTO: multiples refresh individuales
self.MAP_NOMBRE = "Juan";
ui.refresh("MAP_NOMBRE");
self.MAP_ESTADO = "Activo";
ui.refresh("MAP_ESTADO");

// CORRECTO: un solo refresh con multiples campos
self.MAP_NOMBRE = "Juan";
self.MAP_ESTADO = "Activo";
ui.refresh("MAP_NOMBRE,MAP_ESTADO");

// Solo actualizar el valor sin reconstruir la vista
ui.refreshValue("MAP_CAMPO");
```

### 11.2 Gestion de Colecciones

```javascript
// Usar lock/unlock para evitar recargas innecesarias
function modificarContentEficiente(contentName, datos) {
    let content = self.getContents(contentName);
    content.unlock();
    try {
        let obj = content.createObject();
        for (let key in datos) obj[key] = datos[key];
        content.addItem(obj);
    } finally {
        content.lock();
    }
    content.saveAll();
    ui.refresh(contentName);
}

// findObject en lugar de loadAll cuando solo se busca uno
// INCORRECTO (carga TODOS los registros):
let coll = appData.getCollection("Productos");
coll.loadAll();
for (let i = 0; i < coll.getCount(); i++) {
    if (coll.get(i).CODIGO == "PROD001") { break; }
}

// CORRECTO (busca directamente en BD):
let coll = appData.getCollection("Productos");
let producto = coll.findObject("CODIGO = 'PROD001'");
```

### 11.3 Evitar Bucles Costosos

```javascript
// INCORRECTO: saveAll dentro de un bucle
for (let i = 0; i < items.length; i++) {
    let obj = coll.createObject();
    obj.MAP_NOMBRE = items[i].nombre;
    coll.addItem(obj);
    obj.save();  // Escribe en BD en cada iteracion
}

// CORRECTO: un solo saveAll al final
coll.unlock();
for (let i = 0; i < items.length; i++) {
    let obj = coll.createObject();
    obj.MAP_NOMBRE = items[i].nombre;
    coll.addItem(obj);
}
coll.lock();
coll.saveAll();

// CORRECTO: para inserciones masivas, usar batch SQL
let sqlManager = new SqlManager();
try {
    sqlManager.openDatabase({ databasePath: "gestion.db", useWal: true, useExistingConnection: true });
    let sqls = [];
    for (let i = 0; i < items.length; i++) {
        sqls.push("INSERT INTO gen_Tabla (NOMBRE) VALUES ('" +
            items[i].nombre.replace(/'/g, "''") + "')");
    }
    sqlManager.doBatchParseSqls(sqls);
} finally {
    sqlManager.close();
}
```

### 11.4 Uso Eficiente de Contents

```javascript
// Filtrar para limitar la carga
let content = self.getContents("@Lineas");
content.setFilter("ACTIVO = 1");
content.unlock();
content.clear();
content.loadAll();
content.lock();

// Limitar registros para listas grandes
function cargarUltimosRegistros(nombreColl, limite) {
    limite = limite || 50;
    let coll = appData.getCollection(nombreColl);
    coll.clear();
    coll.loadAll();
    coll.doSort("FECHA DESC");

    let items = [];
    let count = Math.min(coll.getCount(), limite);
    for (let i = 0; i < count; i++) {
        items.push(coll.get(i));
    }
    return items;
}
```

### 11.5 Promesas para Operaciones Asíncronas

El motor XOne tiene una implementación custom de `Promise` compatible con ES2024 (`.then`, `.catch`, `.finally`, `Promise.all/allSettled/race/any/withResolvers`). Soporta ramificación (varias `.then` sobre la misma promesa producen cadenas independientes).

```javascript
function startUpdateGpsLoop() {
    new Promise((resolve, reject) => {
        let ventana = ui.getView(self);
        while (!bBreakUpdateGpsLoop) {
            if (!ventana) { reject(new Error("Sin ventana")); return; }
            try {
                actualizarGps();
            } catch (error) {
                reject(error);
                return;
            }
            ventana.refreshValue("MAP_LONGITUD", "MAP_LATITUD");
        }
        resolve();
    })
        .then(() => ui.showToast("GPS loop terminado OK"))
        .catch(err => ui.showToast("Error en GPS loop: " + err.message))
        .finally(() => console.log("cleanup"));
}
```

**Patrón con `Promise.all` (paralelo, fast-fail):**

```javascript
Promise.all([cargarUsuario(), cargarConfig(), cargarPermisos()])
    .then(([usuario, config, permisos]) => {
        pintarPantalla(usuario, config, permisos);
    })
    .catch(err => ui.msgBox("Error cargando datos: " + err));
```

**Patrón con `Promise.allSettled` (paralelo, espera todas):**

```javascript
Promise.allSettled([p1, p2, p3]).then(results => {
    results.forEach((r, i) => {
        if (r.status === "fulfilled") console.log("OK p" + i + ":", r.value);
        else console.log("FAIL p" + i + ":", r.reason);
    });
});
```

**Patrón con `Promise.withResolvers` (ES2024, evita la indirección del constructor):**

```javascript
const { promise, resolve, reject } = Promise.withResolvers();
// resolve/reject pueden invocarse desde cualquier callback posterior
ui.startGps(coords => resolve(coords));
return promise;
```

---

## 12. Patrones Comunes con Ejemplos

### 12.1 CRUD Completo

```javascript
// === CREAR ===
function crearProducto() {
    if (!validarRequerido(self.MAP_NOMBRE, "Nombre")) return;
    if (!validarRequerido(self.MAP_PRECIO, "Precio")) return;

    let coll = appData.getCollection("Productos");
    coll.unlock();
    try {
        let obj = new Productos({
            MAP_NOMBRE: cstr(self.MAP_NOMBRE),
            MAP_PRECIO: cnum(self.MAP_PRECIO),
            MAP_ACTIVO: 1,
            MAP_FECHA_ALTA: new Date()
        });
        coll.addItem(obj);
        obj.save();
        ui.showToast("Producto creado");
        cerrarPantalla();
    } catch(ex) {
        ui.showToast("Error: " + ex);
    } finally {
        coll.lock();
    }
}

// === LEER ===
function buscarProducto(codigo) {
    let coll = appData.getCollection("Productos");
    let escapado = cstr(codigo).replace(/'/g, "''");
    return coll.findObject("MAP_CODIGO = '" + escapado + "'");
}

function listarProductosActivos() {
    let coll = appData.getCollection("Productos");
    coll.setFilter("MAP_ACTIVO = 1");
    coll.clear();
    coll.loadAll();
    coll.doSort("MAP_NOMBRE ASC");

    let items = [];
    for (let i = 0; i < coll.getCount(); i++) {
        items.push(coll.get(i));
    }
    return items;
}

// === ACTUALIZAR ===
function actualizarProducto(producto) {
    if (!producto) return;
    producto.MAP_FECHA_MOD = new Date();
    producto.save();
    ui.showToast("Producto actualizado");
}

// === ELIMINAR ===
function eliminarProducto(producto) {
    if (!producto) return;
    if (!confirmar("Eliminar " + producto.MAP_NOMBRE + "?", "Eliminar")) return;

    let coll = appData.getCollection("Productos");
    for (let i = 0; i < coll.getCount(); i++) {
        if (coll.get(i).ID == producto.ID) {
            coll.deleteItem(i);
            break;
        }
    }
    ui.showToast("Producto eliminado");
}
```

### 12.2 Filtrado Dinámico

```javascript
function buscarProductos(criterio, precioMin, precioMax, activo) {
    let filtros = [];

    if (!isEmpty(criterio)) {
        let escapado = cstr(criterio).replace(/'/g, "''");
        filtros.push("MAP_NOMBRE LIKE '%" + escapado + "%'");
    }
    if (!isEmpty(precioMin)) filtros.push("MAP_PRECIO >= " + cnum(precioMin));
    if (!isEmpty(precioMax)) filtros.push("MAP_PRECIO <= " + cnum(precioMax));
    if (!isEmpty(activo))   filtros.push("MAP_ACTIVO = " + cnum(activo));

    let coll = appData.getCollection("Productos");
    coll.setFilter(filtros.length > 0 ? filtros.join(" AND ") : "");
    coll.clear();
    coll.loadAll();
    coll.doSort("MAP_NOMBRE ASC");
    ui.refresh("MAP_LISTA_PRODUCTOS");
}
```

### 12.3 Navegación Maestro-Detalle

```javascript
function onItemSeleccionado() {
    let collDetalle = appData.getCollection("DetalleProducto");
    let obj = new DetalleProducto({
        MAP_NOMBRE: self.MAP_NOMBRE,
        MAP_PRECIO: self.MAP_PRECIO,
        MAP_ID_PRODUCTO: self.ID
    });
    collDetalle.addItem(obj);

    ui.openEditView(obj);
}

function cargarDetalle() {
    let idProducto = self.MAP_ID_PRODUCTO;
    if (isEmpty(idProducto)) return;

    let coll = appData.getCollection("Productos");
    let producto = coll.findObject("ID = " + idProducto);
    if (producto) {
        let lineas = producto.getContents("@LineasProducto");
        lineas.unlock();
        lineas.clear();
        lineas.loadAll();
        lineas.lock();
    }
}
```

### 12.4 Manejo de GPS en Tiempo Real

```javascript
var rastreoActivo = false;

function iniciarRastreo() {
    let estadoGPS = ui.checkGpsStatus();
    if (estadoGPS == 0 || estadoGPS == 3) {
        ui.askUserForGpsPermission({
            onEnabled: function() { activarGPS(); },
            onDenied : function() { ui.showToast("Se necesita GPS"); }
        });
    } else {
        activarGPS();
    }
}

function activarGPS() {
    ui.startGps({
        nodeName                  : "onPosicionActualizada",
        timeBetweenUpdates        : 5000,
        minimumMetersDistanceRange: 10,
        foreground                : true,
        title                     : "Rastreo GPS",
        text                      : "Registrando ubicación..."
    });
    rastreoActivo = true;
    ui.showToast("Rastreo GPS iniciado");
}

function detenerRastreo() {
    ui.stopGps();
    rastreoActivo = false;
    ui.showToast("Rastreo GPS detenido");
}

// Callback GPS (nodo "onPosicionActualizada" en XML)
function onPosicionRecibida() {
    let collGps = appData.getCollection("GPSColl");
    collGps.startBrowse();
    try {
        let gps = collGps.getCurrentItem();
        if (!gps || gps.STATUS != 1) return;

        self.MAP_LATITUD = gps.LATITUD;
        self.MAP_LONGITUD = gps.LONGITUD;
        self.MAP_VELOCIDAD = gps.VELOCIDAD;
        ui.refresh("MAP_LATITUD,MAP_LONGITUD,MAP_VELOCIDAD");

        guardarPosicion(gps.LATITUD, gps.LONGITUD, gps.PRECISION);

        let mapControl = getControl("MAP_MAPA");
        if (mapControl) {
            mapControl.zoomTo(gps.LATITUD, gps.LONGITUD, 15);
        }
    } finally {
        collGps.endBrowse();
    }
}

function guardarPosicion(lat, lng, precision) {
    let coll = appData.getCollection("Posiciones");
    coll.unlock();
    try {
        let obj = new Posiciones({
            MAP_LATITUD: lat,
            MAP_LONGITUD: lng,
            MAP_PRECISION: precision,
            MAP_TIMESTAMP: new Date()
        });
        coll.addItem(obj);
        obj.save();
    } finally {
        coll.lock();
    }
}
```

### 12.5 Tomar y Mostrar Fotos

```javascript
// Foto con prop tipo PH (se activa automaticamente al pulsar)
// En <onchange> de MAP_FOTO:
function onFotoCapturada() {
    let foto = self.MAP_FOTO;
    if (isEmpty(foto)) {
        ui.showToast("Captura cancelada");
        return;
    }
    self.MAP_FECHA_FOTO = new Date();
    self.save();
    ui.showToast("Foto capturada");
    ui.refresh("MAP_FOTO");
}

// Foto con camara tipo VD (control manual)
function tomarFotoConCamara() {
    let control = getControl("MAP_CAMERA");
    if (!control) return;

    control.takePicture({
        filename     : "foto_" + Date.now() + ".jpg",
        saveToGallery: false,
        width        : 640,
        height       : 480,
        onFinished   : function(sFileName) {
            if (sFileName) {
                self.MAP_FOTO = sFileName;
                self.save();
                ui.refresh("MAP_FOTO");
                ui.showToast("Foto guardada");
            }
        }
    });
}
```

### 12.6 Sistema de Chat

```javascript
// Inicializar chat
function inicializarChat() {
    self.MAP_GRUPOSEL = 1;
    self.MAP_VERFLOTANTE = 0;
    self.MAP_RECORDON = 0;
    self.MAP_USERLOGIN = appData.getGlobalMacro("##USERNAME##");
    self.getContents("Chat").setMacro("##MACRO##", self.MAP_USERLOGIN);
}

// Crear un chat entre dos usuarios
function createChat(userFrom, userTo) {
    let coll = self.getContents("Chat");
    coll.unlock();
    let obj = coll.findObject(
        "(USUARIO='" + userFrom + "' AND USUARIO2='" + userTo + "') OR " +
        "(USUARIO='" + userTo + "' AND USUARIO2='" + userFrom + "')"
    );
    if (obj == null) {
        obj = coll.createObject();
        obj.USUARIO = userFrom;
        obj.USUARIO2 = userTo;
        obj.FECHA = new Date();
        obj.save();
    }
    let index = obj.getObjectIndex();
    coll.lock();
    return index;
}

// Enviar mensaje
function sendMessage(colMensajes, obj, titleField, isFromUser) {
    if (obj[titleField].length == 0) return;

    let msg = new MensajesReader();

    if (isFromUser) {
        msg.USUARIOTO = self.MAP_CCUSUARIO;
        msg.USUARIOFROM = appData.getGlobalMacro("##USERNAME##");
    } else {
        msg.USUARIOTO = appData.getGlobalMacro("##USERNAME##");
        msg.USUARIOFROM = self.MAP_CCUSUARIO;
    }

    msg.FECHA = new Date();
    msg.MENSAJE = self[titleField];
    msg.TIPO = self.MAP_TIPO;
    msg.IDCHAT = self.MAP_IDCHATSEL;
    msg.save();

    self[titleField] = "";
    ui.refresh("MensajesUsuarios," + titleField);
}
```

### 12.7 Escaneo QR/Barcode

```javascript
function iniciarEscaneoQR() {
    let control = getControl("MAP_CAMERA");
    if (!control) {
        ui.showToast("Control de camara no encontrado");
        return;
    }

    control.setOnCodeScanned(function(evento) {
        self.MAP_CODIGO_ESCANEADO = evento.data;
        self.MAP_TIPO_CODIGO = evento.type;
        ui.refresh("MAP_CODIGO_ESCANEADO,MAP_TIPO_CODIGO");

        let nResult = ui.msgBox(
            "Código: " + evento.data + "\nTipo: " + evento.type,
            "Lectura correcta?", 4
        );
        return (nResult == 6);
    });
}
```

### 12.8 Descarga de Archivos del Servidor

```javascript
function descargarDocumento(url, nombre) {
    ui.showWaitDialog("Descargando " + nombre + "...");

    let miObjeto = self;
    let request = {
        headers: { "Authorization": "Bearer " + obtenerToken() },
        parameters: { connectTimeout: 30000, readTimeout: 60000 }
    };

    $http.download(url, request,
        function(sPath, headers, nStatus) {
            ui.hideWaitDialog();
            miObjeto.MAP_ARCHIVO = sPath;
            miObjeto.save();
            ui.refresh("MAP_ARCHIVO");

            let nResult = ui.msgBox("Abrir archivo?", "Descarga completa", 4);
            if (nResult == 6) {
                ui.openFile(sPath);
            }
        },
        function(nError, sMessage) {
            ui.hideWaitDialog();
            ui.showToast("Error: " + sMessage);
        }
    );
}
```

### 12.9 Sincronización con Servidor

```javascript
function sincronizarPendientes(nombreColl, endpoint) {
    let coll = appData.getCollection(nombreColl);
    coll.setFilter("MAP_SINCRONIZADO = 0");
    coll.clear();
    coll.loadAll();

    let count = coll.getCount();
    if (count == 0) {
        ui.showToast("No hay registros pendientes");
        return;
    }

    ui.showWaitDialog("Sincronizando " + count + " registros...");

    let pendientes = [];
    for (let i = 0; i < count; i++) {
        pendientes.push(coll.get(i).toJson());
    }

    let miColl = coll;
    let request = {
        headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer " + obtenerToken()
        },
        parameters: { connectTimeout: 30000, readTimeout: 120000 },
        data: { registros: pendientes }
    };

    $http.post(endpoint, request,
        function(sData) {
            for (let i = 0; i < miColl.getCount(); i++) {
                let obj = miColl.get(i);
                obj.MAP_SINCRONIZADO = 1;
                obj.MAP_FECHA_SYNC = new Date();
                obj.save();
            }
            ui.hideWaitDialog();
            ui.showToast(count + " registros sincronizados");
        },
        function(nError, sDesc) {
            ui.hideWaitDialog();
            ui.showToast("Error sync: " + sDesc);
        }
    );
}
```

### 12.10 Login Personalizado

```javascript
function doLogin() {
    let usuario = cstr(self.MAP_LOGIN).trim();
    let password = cstr(self.MAP_PASSWORD).trim();

    // Solo validamos el usuario: en XOne puede haber cuentas sin contraseña
    // (invitado, kiosco) y, si la contraseña es incorrecta o falta cuando hace
    // falta, el backend la rechaza vía onLoginFailed (no la validamos en cliente).
    if (isEmpty(usuario)) { ui.showToast("Introduzca el usuario"); return; }

    appData.login({
        userName          : usuario,
        password          : password,
        entryPoint        : "MenuPrincipal",
        onLoginSuccessful : function() {
            appData.setGlobalMacro("##USERNAME##", usuario);
            ui.showToast("Bienvenido, " + usuario);
        },
        onLoginFailed     : function() {
            ui.showToast("Usuario o contraseña incorrectos");
            self.MAP_PASSWORD = "";
            ui.refresh("MAP_PASSWORD");
        }
    });
}

function doLogout() {
    if (confirmar("Cerrar sesion?", "Confirmar")) {
        appData.setGlobalMacro("##USERNAME##", "");
        appData.setGlobalMacro("##SESSION_TOKEN##", "");
        appData.logout();
    }
}
```

---

## 13. Funciones Utilitarias Recomendadas

Coleccion de funciones helper que todo proyecto XOne deberia incluir en `functions.js`.

```javascript
/**
 * Funciones Utilitarias para XOne
 * Incluir en functions.js de todo proyecto
 */

// ============================================
// CONVERSIONES Y VERIFICACIONES
// ============================================

function isEmpty(val) {
    return val === undefined || val === null || val === "";
}

function cstr(val) {
    if (val === undefined || val === null) return "";
    return val.toString();
}

function cnum(val) {
    if (val === undefined || val === null || val === "") return 0;
    let num = parseFloat(val);
    return isNaN(num) ? 0 : num;
}

function isNothing(obj) {
    return obj === null || obj === undefined || obj == "undefined";
}

// ============================================
// ACCESO A CONTROLES
// ============================================

// getControl(name, [dataObject]) es NATIVA del motor — NO declararla aquí.
// Si un proyecto ya tiene su propio "function getControl(...)" como helper
// legacy, lo respetamos: la declaración del script sombrea a la nativa en
// su scope local sin tocar la del global.

// ============================================
// NAVEGACION
// ============================================

function mostrarGrupo(nGroup, sAnimIn, sAnimOut) {
    sAnimIn = sAnimIn || "##ALPHA_IN##";
    sAnimOut = sAnimOut || "##ALPHA_OUT##";
    ui.showGroup(nGroup, sAnimIn, 200, sAnimOut, 200);
}

function cerrarPantalla() {
    let window = ui.getView(self);
    if (window) window.exit();
}

// ============================================
// MENSAJES Y DIALOGOS
// ============================================

function confirmar(mensaje, titulo) {
    titulo = titulo || "Confirmar";
    let nResult = ui.msgBox(mensaje, titulo, 4);
    return nResult == 6;
}

function mostrarToast(mensaje) {
    ui.showToast(mensaje);
}

function mostrarToastExito(mensaje) {
    ui.showToast({
        text: mensaje, color: "#4CAF50",
        textColor: "#FFFFFF", duration: "short"
    });
}

function mostrarToastError(mensaje) {
    ui.showToast({
        text: mensaje, color: "#F44336",
        textColor: "#FFFFFF", duration: "long"
    });
}

function mostrarCargando(mensaje) {
    ui.showWaitDialog(mensaje || "Cargando...");
}

function ocultarCargando() {
    ui.hideWaitDialog();
}

// ============================================
// COLECCIONES Y DATOS
// ============================================

function obtenerColeccion(nombreColl) {
    return appData.getCollection(nombreColl);
}

function crearObjeto(nombreColl) {
    let coll = appData.getCollection(nombreColl);
    let obj = coll.createObject();
    coll.addItem(obj);
    return obj;
}

function buscarObjeto(nombreColl, campo, valor) {
    let escapado = cstr(valor).replace(/'/g, "''");
    let coll = appData.getCollection(nombreColl);
    return coll.findObject(campo + "='" + escapado + "'");
}

// ============================================
// VALIDACIONES
// ============================================

function validarRequerido(valor, nombreCampo) {
    if (isEmpty(valor)) {
        mostrarToastError("El campo " + nombreCampo + " es obligatorio");
        return false;
    }
    return true;
}

function validarEmail(email) {
    if (isEmpty(email)) return false;
    return email.indexOf("@") > 0 && email.indexOf(".") > 0;
}

function sanearEntrada(valor, maxLength) {
    if (isEmpty(valor)) return "";
    let sValor = cstr(valor).trim();
    if (maxLength && sValor.length > maxLength) {
        sValor = sValor.substring(0, maxLength);
    }
    return sValor;
}

// ============================================
// FECHAS Y TIEMPO
// ============================================

function obtenerFechaActual() {
    let f = new Date();
    return ("0" + f.getDate()).slice(-2) + "/" +
           ("0" + (f.getMonth() + 1)).slice(-2) + "/" +
           f.getFullYear();
}

function obtenerHoraActual() {
    let f = new Date();
    return ("0" + f.getHours()).slice(-2) + ":" +
           ("0" + f.getMinutes()).slice(-2);
}

function obtenerAhora() {
    return new Date();
}

// ============================================
// CONVERSION BINARIA (NFC, Bluetooth, etc.)
// ============================================

function toUint8Array(str) {
    let arr = new Uint8Array(str.length);
    for (let i = 0; i < str.length; i++) arr[i] = str.charCodeAt(i);
    return arr;
}

function toStringFromUint8Array(arr) {
    let str = "";
    for (let i = 0; i < arr.length; i++) str += String.fromCharCode(arr[i]);
    return str;
}

// ============================================
// GUID
// ============================================

function generarGUID() {
    return 'xxxxxxxxxxxx4xxxyxxxxxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = Math.random() * 16 | 0;
        var v = c == 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
}
```

---

## 14. Debugging y Troubleshooting

### 14.1 console.* (API WHATWG completa)

```javascript
// Métodos disponibles: log, info, debug, warn, error, trace, assert,
//                     group, groupCollapsed, groupEnd, time, timeLog, timeEnd,
//                     count, countReset, dir, dirxml, clear, table
console.log("Valor de campo: " + self.MAP_NOMBRE);
console.warn("Aviso: parámetro fuera de rango");
console.error("Error al guardar:", err);            // varargs soportados
console.info("Carga completada");
console.debug("Estado interno:", { id: 42, ok: true });

// Formato con placeholders %s/%d/%i/%f/%o/%O/%j/%%
console.log("Usuario %s tiene %d puntos", nombre, puntos);

// Agrupar logs
console.group("Procesando pedido");
console.log("ID:", pedido.ID);
console.log("Líneas:", pedido.LINEAS.length);
console.groupEnd();

// Medir tiempos
console.time("consulta");
let res = $http.get(url, req, ok, err);
console.timeEnd("consulta");                        // "consulta: 142ms"

// Log condicional
function logDebug(mensaje) {
    if (appData.getCurrentEnterprise().getVariable("Debug") === true) {
        console.debug("DEBUG: " + mensaje);
    }
}

// Alternativa: consola del framework (XOne-specific)
appData.writeConsoleString("Debug: proceso iniciado");
```

### 14.2 ui.showToast() para Debug Rápido

```javascript
function debugToast(variable, nombre) {
    ui.showToast(nombre + " = " + cstr(variable));
}

// Ejemplos
debugToast(self.MAP_ESTADO, "Estado");
debugToast(typeof self.MAP_PRECIO, "Tipo precio");
debugToast(self.getOwnerCollection().getName(), "Coleccion");

function debugMsgBox(variable, nombre) {
    ui.msgBox(nombre + " = " + cstr(variable) + "\nTipo: " + typeof variable, "Debug", 0);
}
```

### 14.3 try/catch

```javascript
function operacionSegura() {
    try {
        let resultado = operacionRiesgosa();
        if (!resultado) throw "No se pudo completar la operación";
        return resultado;
    } catch(ex) {
        console.log("Error en operacionSegura: " + ex);
        appData.writeConsoleString("Error: " + ex);
        ui.showToast("Error: " + ex);
        return null;
    } finally {
        ui.hideWaitDialog();
    }
}

// Verificar errores del framework
function verificarErrores() {
    let error = appData.error();
    if (error.getNumber() != 0) {
        console.log("Código: " + error.getNumber());
        console.log("Descripción: " + error.getDescription());
        console.log("SQL fallido: " + error.getFailedSql());
        error.clear();
        return true;
    }
    return false;
}
```

### 14.4 Errores Comunes y Soluciones

| Error | Causa | Solución |
|-------|-------|----------|
| `self es null` | Se accede a `self` fuera de contexto | Guardar referencia antes de callbacks asíncronos |
| `coleccion bloqueada` | Se intenta addItem sin unlock | Usar patron `coll.unlock(); try {...} finally { coll.lock(); }` |
| `NaN en calculos` | Valor null/undefined en operación matematica | Usar `cnum()` para conversiones numéricas seguras |
| `campo no encontrado` | Nombre de propiedad incorrecto | Verificar nombre exacto en el XML (sensible a mayusculas) |
| `cursor no cerrado` | Fuga de recursos SQL | SIEMPRE cerrar cursor en bloque `finally` |
| `WaitDialog no desaparece` | Error antes de `hideWaitDialog()` | Usar `try/finally` para garantizar que se oculte |
| `GPS STATUS != 1` | GPS no activado o sin cobertura | Verificar `ui.checkGpsStatus()` y pedir permiso |
| `Error en JSON.parse` | Respuesta del servidor no es JSON valido | Envolver en try/catch y verificar la respuesta |
| `window es null` | Pantalla cerrada mientras se ejecuta callback | Verificar `window != null` antes de acceder a controles |
| `refresh no actualiza` | Nombre de campo incorrecto en refresh | Usar el nombre exacto de la propiedad (MAP_CAMPO) |

---

## 15. Best Practices - Top 20

### 1. Guardar referencia de `self` antes de callbacks asíncronos

```javascript
let miObjeto = self;
$http.get(url, request, function(sData) {
    miObjeto.MAP_DATO = sData;  // CORRECTO
    // self.MAP_DATO = sData;   // INCORRECTO
}, errorCb);
```

### 2. Siempre usar lock/unlock al modificar colecciones

```javascript
coll.unlock();
try {
    let obj = coll.createObject();
    coll.addItem(obj);
} finally {
    coll.lock();
}
```

### 3. Usar `isEmpty()`, `cstr()`, `cnum()` para conversiones seguras

Nunca acceder a valores sin verificar que no sean null/undefined.

### 4. Refrescar solo los campos necesarios

```javascript
ui.refresh("MAP_NOMBRE,MAP_ESTADO");  // CORRECTO
ui.refresh();                          // INCORRECTO - refresca todo
```

### 5. Usar consultas parametrizadas para prevenir SQL injection

```javascript
sqlManager.doRawQuery("SELECT * FROM tabla WHERE campo=?", valor);
```

### 6. Cerrar cursores y conexiones SQL en bloques `finally`

```javascript
try { cursor = sqlManager.doRawQuery(...);
    try { /* usar cursor */ } finally { cursor.close(); }
} finally { sqlManager.close(); }
```

### 7. Ocultar WaitDialog en bloque `finally`

```javascript
ui.showWaitDialog("Cargando...");
try { /* operacion */ }
catch(ex) { ui.showToast("Error: " + ex); }
finally { ui.hideWaitDialog(); }
```

### 8. Verificar existencia de objetos antes de usarlos

```javascript
let usuario = coll.findObject("ID = 1");
if (!usuario) { ui.showToast("No encontrado"); return; }
```

### 9. No usar APIs web que no existen en XOne

No `document`, `window`, `localStorage`, `XMLHttpRequest`, `navigator`. **Sí** existen, con implementación custom y semántica compatible: `Promise` (full ES2024 incluyendo `all`/`allSettled`/`race`/`any`/`withResolvers`), `fetch`, `setTimeout`/`setInterval`, `URL`, `Headers`, `AbortController`, `TextEncoder`/`TextDecoder`, `console.{log,warn,error,...}`, `performance.now()`, `atob`/`btoa`.

### 10. `getControl(name, [dataObject])` es NATIVO — no redeclararlo

Es una función global del motor (Rhino y V8). Firma:
- `getControl(name)` → control en la última ventana visible.
- `getControl(name, dataObject)` → control en la ventana asociada a ese DataObject.

Semántica estricta: lanza error si el nombre está vacío, el control no existe en la ventana destino, no hay ventana, o el dataObject no es válido. No hace falta verificar null.

Proyectos antiguos con su propio `function getControl(...){...}` siguen funcionando: la declaración del script sombrea a la nativa en el scope local del script.

### 11. Usar `ui.executeActionAfterDelay()` en lugar de `ui.sleep()`

`sleep()` bloquea toda la interfaz. `executeActionAfterDelay()` no.

### 12. Nunca hardcodear credenciales en el código

Usar macros globales o almacenamiento encriptado.

### 13. Validar datos antes de guardar (patron validarFormulario)

Verificar campos obligatorios, rangos y formatos antes de `save()`.

### 14. Organizar functions.js en secciones claras

Constantes, utilidades, navegación, mensajes, datos, validaciones, inicialización.

### 15. Usar `try/catch` en operaciones que pueden fallar

Especialmente: operaciones de red, acceso a BD, GPS, camara, archivos.

### 16. Liberar colecciones con `clear()` después de usarlas

Previene acumulacion de objetos en memoria.

### 17. Usar `saveAll()` al final en lugar de `save()` individual en bucles

Una sola escritura a BD en lugar de N.

### 18. Documentar funciones con proposito, parámetros y retorno

```javascript
/**
 * Calcula el precio con descuento
 * @param {number} precio - Precio original
 * @param {number} descuento - Porcentaje de descuento (0-100)
 * @returns {number} - Precio con descuento aplicado
 */
function calcularDescuento(precio, descuento) { ... }
```

### 19. Usar constantes para valores magicos

```javascript
var ESTADOS = { ACTIVO: "ACTIVO", INACTIVO: "INACTIVO" };
if (estado == ESTADOS.ACTIVO) ...
```

### 20. Separar lógica de negocio de la lógica de UI

Funciones que calculan o procesan datos NO deben contener `ui.showToast()`. Las funciones de UI llaman a las de negocio y muestran los resultados.

> **Referencia cruzada:** Para la estructura de carpetas del proyecto y como se integran los archivos JS, consultar el tópico [01 - Fundamentos](01-xone-fundamentals.md) (cubre también la guía de creación de proyectos nuevos).

---

**Anterior:** [03d - createObject](03d-js-createobject.md) · **Índice:** [03 - Guía JavaScript](03-javascript-api-guide.md)
