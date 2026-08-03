# JavaScript Patterns — Buenas prácticas, seguridad, optimización, patrones críticos y errores

Sub-archivo de [xone-javascript-patterns.md](xone-javascript-patterns.md). Cubre buenas prácticas de organización, manejo de errores, acceso seguro a controles, seguridad (validación de entradas, SQL injection, almacenamiento seguro, TLS, datos sensibles), optimización de memoria/UI/BD/HTTP, funciones utilitarias estándar, patrones comunes (login biometrico, CRUD, GPS, fotos, firma, API HTTP, offline-first, voz), patrones críticos (lock/unlock, browse, filtros, callbacks, WaitDialog, cronometros) y errores comunes a evitar.

## Tabla de Contenidos

- [3. Buenas Prácticas](#3-buenas-practicas)
- [4. Seguridad](#4-seguridad)
- [5. Optimización](#5-optimizacion)
- [6. Funciones Utilitarias Estándar](#6-funciones-utilitarias-estandar)
- [7. Patrones Comunes](#7-patrones-comunes)
- [8. Patrones Críticos de Código](#8-patrones-criticos-de-codigo)
- [9. Errores Comunes a Evitar](#9-errores-comunes-a-evitar)

---

## 3. Buenas Prácticas

### 3.1 Organización del Código

#### Estructura Recomendada de `functions.js`

```javascript
/**
 * NombreProyecto - Funciones Globales
 * Descripción breve de la aplicacion
 */

// ============================================
// CONSTANTES
// ============================================
var ESTADOS = { ACTIVO: "ACTIVO", INACTIVO: "INACTIVO", PENDIENTE: "PENDIENTE" };
var ROLES = { ADMIN: "ADMIN", OPERADOR: "OPERADOR", CONSULTA: "CONSULTA" };

// ============================================
// UTILIDADES GENERALES
// ============================================
function isEmpty(val) { return val === undefined || val === null || val === ""; }
function cstr(val) { if (val === undefined || val === null) return ""; return val.toString(); }
function cnum(val) { if (val === undefined || val === null || val === "") return 0; let num = parseFloat(val); return isNaN(num) ? 0 : num; }

// ============================================
// NAVEGACION
// ============================================
function mostrarGrupo(nGroup, sAnimIn, sAnimOut) { /* ... */ }
function navegarA(nombrePantalla) { /* ... */ }
function cerrarPantalla() { /* ... */ }

// ============================================
// MENSAJES Y DIALOGOS
// ============================================
function confirmar(mensaje, titulo) { /* ... */ }
function mostrarToast(mensaje) { /* ... */ }
function mostrarToastExito(mensaje) { /* ... */ }
function mostrarToastError(mensaje) { /* ... */ }
function mostrarCargando(mensaje) { /* ... */ }
function ocultarCargando() { /* ... */ }

// ============================================
// COLECCIONES Y DATOS
// ============================================
function obtenerColeccion(nombreColl) { /* ... */ }
function crearObjeto(nombreColl) { /* ... */ }
function buscarObjeto(nombreColl, campo, valor) { /* ... */ }
function obtenerUsuarioActual() { /* ... */ }

// ============================================
// VALIDACIONES
// ============================================
function validarRequerido(valor, nombreCampo) { /* ... */ }

// ============================================
// FECHAS Y TIEMPO
// ============================================
function obtenerFechaActual() { /* ... */ }
function obtenerHoraActual() { /* ... */ }
function obtenerAhora() { /* ... */ }

// ============================================
// INICIALIZACION
// ============================================
function inicializarApp() { /* ... */ }
```

#### Convencion de Nombres

| Tipo | Convencion | Ejemplos |
|------|-----------|----------|
| Variables globales (constantes) | MAYUSCULAS_CON_GUIONES | `ESTADOS_ENVIO`, `TIPOS_PAQUETE` |
| Variables locales | camelCase | `miVariable`, `contadorItems` |
| Funciones | camelCase descriptivo | `obtenerUsuarioActual()`, `calcularPrecioViaje()` |
| Colecciones | PascalCase | `MenuPrincipal`, `DetalleProducto` |
| Propiedades mapeadas | MAP_ + MAYUSCULAS | `MAP_NOMBRE`, `MAP_ESTADO` |

### 3.2 Manejo de Errores

```javascript
function operacionCritica() {
    mostrarCargando("Procesando...");
    try {
        let resultado = procesarDatos();
        if (!resultado) throw "No se pudo procesar los datos";
        mostrarToastExito("Operación completada");
    } catch(ex) {
        mostrarToastError("Error: " + ex);
    } finally {
        ocultarCargando();  // SIEMPRE se ejecuta
    }
}
```

### 3.3 Acceso a Controles - `getControl(name, [dataObject])` NATIVO

`getControl` es una función global del motor (Rhino y V8). NO declararla:

```javascript
let ctrl = getControl("MAP_BOTON");                 // ventana actual
let ctrlPadre = getControl("MAP_TITULO", padre);    // ventana asociada al DataObject
```

Semántica ESTRICTA: lanza error si el nombre está vacío, el control no existe en la ventana destino, no hay ventana, o el dataObject no es válido. Si un proyecto antiguo ya tiene `function getControl(...){...}` propia, esa sombrea a la nativa en su scope local (compatible).

### 3.4 Callbacks HTTP con Contexto

```javascript
function cargarDatosDeAPI() {
    let miObjeto = self;  // IMPORTANTE: guardar referencia
    mostrarCargando("Cargando datos...");

    $http.get(url, request,
    function(sData, headers, nStatus) {
        try {
            let json = JSON.parse(sData);
            miObjeto.MAP_DATOS = json.resultado;
            ui.refresh("MAP_DATOS");
        } catch(ex) {
            mostrarToastError("Error al procesar respuesta");
        } finally {
            ocultarCargando();
        }
    },
    function(nError, sDesc) {
        mostrarToastError("Error de conexión: " + sDesc);
        ocultarCargando();
    });
}
```

### 3.5 Bloqueo/Desbloqueo de Colecciones

```javascript
function agregarLinea(contenido, datos) {
    contenido.unlock();
    try {
        let obj = contenido.createObject();
        obj.MAP_DESCRIPCION = datos.descripcion;
        contenido.addItem(obj);
    } finally {
        contenido.lock();  // NUNCA olvidar lock
    }
    contenido.saveAll();
}
```

### 3.6 Verificaciones de Seguridad

```javascript
function operacionSegura() {
    if (!self) throw "Contexto no disponible";

    let window = ui.getView(self);
    if (!window) throw "Ventana no disponible";

    let usuario = obtenerUsuarioActual();
    if (!usuario) { mostrarToastError("Debe iniciar sesion"); return; }

    if (cstr(usuario.ROL) != "ADMIN") {
        mostrarToastError("No tiene permisos"); return;
    }

    if (isEmpty(self.MAP_CAMPO_OBLIGATORIO)) {
        mostrarToastError("Complete los campos obligatorios"); return;
    }
}
```

---

## 4. Seguridad

### 4.1 Validación de Entradas

```javascript
function sanearEntrada(valor, maxLength) {
    if (isEmpty(valor)) return "";
    let sValor = cstr(valor).trim();
    if (maxLength && sValor.length > maxLength) sValor = sValor.substring(0, maxLength);
    return sValor;
}

function validarEmail(email) {
    if (isEmpty(email)) return false;
    return email.indexOf("@") > 0 && email.indexOf(".") > 0;
}

function validarTelefono(telefono) {
    if (isEmpty(telefono)) return false;
    return telefono.length >= 9;
}

function validarRango(valor, min, max) {
    let num = cnum(valor);
    return num >= min && num <= max;
}
```

### 4.2 Prevencion de Inyeccion SQL

```javascript
// INCORRECTO - Vulnerable
let cursor = sqlManager.doRawQuery(
    "SELECT * FROM gen_Usuarios WHERE LOGIN='" + loginUsuario + "'"
);

// CORRECTO - Consultas parametrizadas
let cursor = sqlManager.doRawQuery(
    "SELECT * FROM gen_Usuarios WHERE LOGIN=?", loginUsuario
);

// Para findObject, escapar comillas
function buscarObjetoSeguro(nombreColl, campo, valor) {
    let valorEscapado = cstr(valor).replace(/'/g, "''");
    let coll = appData.getCollection(nombreColl);
    return coll.findObject(campo + "='" + valorEscapado + "'");
}
```

### 4.3 Almacenamiento Seguro

```javascript
function guardarDatoSensible(clave, valor) {
    let aesKey = crypto.generateAesKey({
        alias: "app_storage_key", keySize: 256, useSecureHardware: true
    });
    let encrypted = crypto.encrypt({
        data: valor, dataFormat: "string",
        algorithm: "AES/GCM/NoPadding", key: aesKey, outputFormat: "base64"
    });
    appData.setGlobalMacro("##" + clave + "##", encrypted);
}
```

### 4.4 Comunicaciones Seguras

```javascript
function crearRequestSeguro(token) {
    return {
        headers: {
            "Authorization": "Bearer " + token,
            "Content-Type": "application/json"
        },
        parameters: {
            connectTimeout: 30000, readTimeout: 30000,
            allowUnsafeCertificates: false,  // NUNCA true en produccion
            enablePinning: true
        }
    };
}
```

### 4.5 Proteccion de Datos Sensibles

```javascript
function hashPassword(password) {
    return crypto.sha256({ data: password, outputFormat: "hex" });
}

// NO log de datos sensibles
// NUNCA: console.log("Password: " + pass);

function limpiarSesion() {
    appData.setGlobalMacro("##TOKEN##", "");
    appData.setGlobalMacro("##USERID##", "");
    appData.setGlobalMacro("##USERROLE##", "");
}
```

---

## 5. Optimización

### 5.1 Optimización de Memoria

```javascript
// Liberar colecciones
function limpiarColeccion(nombreColl) {
    let coll = appData.getCollection(nombreColl);
    coll.clear();
}

// Limitar registros cargados
function cargarUltimosRegistros(nombreColl, limite) {
    limite = limite || 50;
    let coll = appData.getCollection(nombreColl);
    coll.clear(); coll.loadAll(); coll.doSort("FECHA DESC");
    let items = [];
    let count = Math.min(coll.getCount(), limite);
    for (let i = 0; i < count; i++) items.push(coll.get(i));
    return items;
}

// Usar findObject en lugar de loadAll para buscar uno
function buscarRegistroEficiente(nombreColl, campo, valor) {
    let coll = appData.getCollection(nombreColl);
    return coll.findObject(campo + "='" + valor + "'");
}
```

### 5.2 Optimización de UI

```javascript
// Refrescar campos especificos, NO toda la vista
ui.refresh("MAP_NOMBRE,MAP_ESTADO");  // MEJOR
// ui.refresh();  // PEOR

// Agrupar updates en un solo refresh
function actualizarMultiplesCampos(datos) {
    self.MAP_NOMBRE = datos.nombre;
    self.MAP_ESTADO = datos.estado;
    self.MAP_TOTAL = datos.total;
    ui.refresh("MAP_NOMBRE,MAP_ESTADO,MAP_TOTAL");
}

// Cuando los campos son condicionales, acumular en un array y refrescar una vez
// (refresh/refreshValue aceptan varargs, string con comas, o un array)
function actualizarCondicional(datos) {
    let campos = [];
    if (datos.nombre != null) { self.MAP_NOMBRE = datos.nombre; campos.push("MAP_NOMBRE"); }
    if (datos.total  != null) { self.MAP_TOTAL  = datos.total;  campos.push("MAP_TOTAL"); }
    if (campos.length) ui.refresh(campos);
}
```

### 5.3 Optimización de Base de Datos

```javascript
// Usar batch para multiples operaciones
function insertarMasivo(registros) {
    let sqlManager = new SqlManager();
    try {
        sqlManager.openDatabase({ databasePath: "gestion.db", useWal: true, useExistingConnection: true });
        let sqls = [];
        for (let i = 0; i < registros.length; i++) {
            sqls.push("INSERT INTO gen_Tabla (CODIGO, NOMBRE) VALUES ('" + registros[i].CODIGO + "', '" + registros[i].nombre + "')");
        }
        sqlManager.doBatchParseSqls(sqls);
    } finally { sqlManager.close(); }
}

// Mantenimiento periodico
function mantenimientoBD() {
    let sqlManager = new SqlManager();
    try {
        sqlManager.openDatabase({ databasePath: "gestion.db", useExistingConnection: true });
        sqlManager.doWalCheckpoint();
        sqlManager.doVacuum();
    } finally { sqlManager.close(); }
}
```

### 5.4 Optimización de Peticiones HTTP

```javascript
// Cancelar requests que ya no se necesitan
var requestActual = null;
function buscarEnAPI(termino) {
    if (requestActual) requestActual.cancel();
    requestActual = $http.get(url, request,
        function(sData) { requestActual = null; procesarResultados(JSON.parse(sData)); },
        function(nError, sDesc) { requestActual = null; if (nError != -1) mostrarToastError(sDesc); }
    );
}

// Evitar peticiones duplicadas
var cargandoDatos = false;
function cargarDatosSiNoEstaCargando() {
    if (cargandoDatos) return;
    cargandoDatos = true;
    $http.get(url, request,
        function(sData) { cargandoDatos = false; procesarDatos(sData); },
        function(nError, sDesc) { cargandoDatos = false; mostrarToastError(sDesc); }
    );
}
```

---

## 6. Funciones Utilitarias Estándar

Estas funciones deben incluirse en todo proyecto XOne en el archivo `functions.js`:

### 6.1 isEmpty, cstr, cnum

```javascript
function isEmpty(val) { return val === undefined || val === null || val === ""; }

function cstr(val) {
    if (val === undefined || val === null) return "";
    return val.toString();
}

function cnum(val) {
    if (val === undefined || val === null || val === "") return 0;
    let num = parseFloat(val);
    return isNaN(num) ? 0 : num;
}
```

### 6.2 getControl (NATIVA — no incluir como helper)

`getControl(name, [dataObject])` es función global del motor (Rhino y V8). Ver §3.3 para semántica y ejemplos. NO la añadas a la librería utilitaria del proyecto. Si un proyecto antiguo ya la tiene declarada, su versión sombrea a la nativa en su scope local (compat).

### 6.3 mostrarGrupo

```javascript
function mostrarGrupo(nGroup, sAnimIn, sAnimOut) {
    sAnimIn = sAnimIn || "##ALPHA_IN##";
    sAnimOut = sAnimOut || "##ALPHA_OUT##";
    ui.showGroup(nGroup, sAnimIn, 200, sAnimOut, 200);
}
```

### 6.4 cerrarPantalla

```javascript
function cerrarPantalla() {
    let window = ui.getView(self);
    if (window) window.exit();
}
```

### 6.5 confirmar

```javascript
function confirmar(mensaje, titulo) {
    titulo = titulo || "Confirmar";
    let nResult = ui.msgBox(mensaje, titulo, 4);
    return nResult == 6;
}
```

### 6.6 mostrarToast, mostrarToastExito, mostrarToastError

```javascript
function mostrarToast(mensaje) { ui.showToast(mensaje); }

function mostrarToastExito(mensaje) {
    ui.showToast({ text: mensaje, color: "#4CAF50", textColor: "#FFFFFF", duration: "short" });
}

function mostrarToastError(mensaje) {
    ui.showToast({ text: mensaje, color: "#F44336", textColor: "#FFFFFF", duration: "long" });
}
```

### 6.7 obtenerColeccion, crearObjeto, buscarObjeto

```javascript
function obtenerColeccion(nombreColl) { return appData.getCollection(nombreColl); }

function crearObjeto(nombreColl) {
    let coll = appData.getCollection(nombreColl);
    let obj = coll.createObject();
    coll.addItem(obj);
    return obj;
}

function buscarObjeto(nombreColl, campo, valor) {
    let coll = appData.getCollection(nombreColl);
    return coll.findObject(campo + "='" + valor + "'");
}
```

### 6.8 toUint8Array, toStringFromUint8Array

```javascript
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
```

---

## 7. Patrones Comunes

### 7.1 Login con Biometria

```javascript
function loginConBiometria() {
    if (!biometricsManager.isHardwareAvailable()) {
        mostrarToastError("Biometria no disponible");
        loginConCredenciales();
        return;
    }

    if (!biometricsManager.hasEnrolledFingerprints()) {
        mostrarToast("Configure la biometria en ajustes");
        biometricsManager.launchSecuritySettings();
        return;
    }

    biometricsManager.setCallback({
        title: "Iniciar Sesion", subtitle: "Autenticacion biométrica",
        description: "Coloque su dedo en el sensor",
        negativeButtonText: "Usar credenciales",
        onSuccess: function(result) {
            let usuario = appData.getGlobalMacro("##SAVED_USER##");
            let token = appData.getGlobalMacro("##SAVED_TOKEN##");
            if (!isEmpty(usuario) && !isEmpty(token)) {
                procesoPostLogin(usuario);
            } else {
                mostrarToastError("No hay sesion guardada");
                loginConCredenciales();
            }
        },
        onFailure: function(nError, sErrorMessage) {
            mostrarToastError("Error biométrico: " + sErrorMessage);
        }
        // Nota: `onHelp` no existe — la API moderna BiometricPrompt no expone callback de "help".
    });
    biometricsManager.launch();
}

function loginConCredenciales() {
    let usuario = cstr(self.MAP_LOGIN);
    let password = cstr(self.MAP_PASSWORD);
    // Solo validamos el usuario. En XOne puede haber cuentas sin contraseña
    // (invitado, kiosco); si falta o es incorrecta, el backend la rechaza
    // vía onLoginFailed.
    if (isEmpty(usuario)) {
        mostrarToastError("Introduzca el usuario");
        return;
    }
    appData.login({
        userName: usuario, password: password,
        entryPoint: "MenuPrincipal",
        onLoginSuccessful: function() {
            appData.setGlobalMacro("##SAVED_USER##", usuario);
            mostrarToastExito("Bienvenido");
        },
        onLoginFailed: function() {
            mostrarToastError("Credenciales incorrectas");
        }
    });
}
```

### 7.2 CRUD Completo

```javascript
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
            MAP_FECHA_ALTA: obtenerAhora()
        });
        coll.addItem(obj);
        obj.save();
        mostrarToastExito("Producto creado");
        cerrarPantalla();
    } catch(ex) {
        mostrarToastError("Error al crear: " + ex);
    } finally { coll.lock(); }
}

function actualizarProducto(producto) {
    if (!producto) return;
    producto.MAP_FECHA_MOD = obtenerAhora();
    producto.save();
    mostrarToastExito("Producto actualizado");
}

function eliminarProducto(producto) {
    if (!producto) return;
    if (!confirmar("Eliminar " + producto.MAP_NOMBRE + "?", "Eliminar")) return;
    let coll = appData.getCollection("Productos");
    for (let i = 0; i < coll.getCount(); i++) {
        if (coll.get(i).ID == producto.ID) { coll.deleteItem(i); break; }
    }
    mostrarToast("Producto eliminado");
}
```

### 7.3 Carga de Listas con Filtros

```javascript
function cargarLista(nombreColl, filtro, orden, limite) {
    let coll = appData.getCollection(nombreColl);
    if (!isEmpty(filtro)) coll.setFilter(filtro);
    coll.clear();
    coll.loadAll();
    if (!isEmpty(orden)) coll.doSort(orden);

    let items = [];
    let count = coll.getCount();
    if (limite > 0) count = Math.min(count, limite);
    for (let i = 0; i < count; i++) items.push(coll.get(i));
    return items;
}
```

### 7.4 Rastreo GPS

```javascript
var rastreoActivo = false;

function iniciarRastreo() {
    let estadoGPS = ui.checkGpsStatus();
    if (estadoGPS == 0 || estadoGPS == 3) {
        ui.askUserForGpsPermission({
            onEnabled: function() { activarGPS(); },
            onDenied: function() { mostrarToastError("Se necesita GPS"); }
        });
    } else { activarGPS(); }
}

function activarGPS() {
    ui.startGps({
        nodeName: "onPosicionActualizada",
        timeBetweenUpdates: 5000,
        minimumMetersDistanceRange: 10,
        foreground: true,
        title: "Rastreo GPS",
        text: "Registrando ubicación..."
    });
    rastreoActivo = true;
}

function onPosicionRecibida(location) {
    let posicion = {
        latitud: location.latitude, longitud: location.longitude,
        precision: location.accuracy, velocidad: location.speed,
        timestamp: new Date()
    };
    guardarPosicion(posicion);
    let mapControl = getControl("MAP_MAPA");
    if (mapControl) mapControl.zoomTo(posicion.latitud, posicion.longitud, 15);
}

function detenerRastreo() {
    ui.stopGps();
    rastreoActivo = false;
}

function guardarPosicion(posicion) {
    let coll = appData.getCollection("Posiciones");
    coll.unlock();
    try {
        let obj = new Posiciones({
            MAP_LATITUD: posicion.latitud,
            MAP_LONGITUD: posicion.longitud,
            MAP_PRECISION: posicion.precision,
            MAP_TIMESTAMP: posicion.timestamp
        });
        coll.addItem(obj);
        obj.save();
    } finally { coll.lock(); }
}
```

### 7.5 Captura de Foto con Camara

```javascript
// La propiedad tipo PH activa la camara automaticamente al pulsar
// En XML: <prop name="MAP_FOTO" type="PH" visible="7" />
// El resultado se almacena en self.MAP_FOTO

function onFotoCapturada() {
    // Se ejecuta en <onchange> de MAP_FOTO
    let foto = self.MAP_FOTO;
    if (isEmpty(foto)) { mostrarToast("Captura cancelada"); return; }
    self.MAP_FECHA_FOTO = obtenerAhora();
    self.save();
    mostrarToastExito("Foto capturada");
    ui.refresh("MAP_FOTO");
}
```

### 7.6 Captura de Firma Digital

```javascript
// En XML: <prop name="MAP_FIRMA" type="IMG" visible="7" class="propFirma" />
// En CSS:
// .propFirma { img-sign: bt_Firma.png; img-sign-sel: bt_Firma_sel.png;
//              sign-title: "Firme aquí"; sign-clear-text: "Borrar"; sign-save-text: "Guardar"; }

function onFirmaCapturada() {
    let firma = self.MAP_FIRMA;
    if (isEmpty(firma)) { mostrarToast("Firma cancelada"); return; }
    self.MAP_FECHA_FIRMA = obtenerAhora();
    self.MAP_FIRMADO_POR = obtenerUsuarioActual().MAP_NOMBRE;
    self.save();
    mostrarToastExito("Firma capturada");
}
```

### 7.7 Consumo de API HTTP

```javascript
var API_BASE_URL = "https://api.miservidor.com/v1";

function crearHeadersAPI() {
    let token = appData.getGlobalMacro("##API_TOKEN##");
    return {
        "Content-Type": "application/json",
        "Authorization": "Bearer " + token,
        "Accept": "application/json"
    };
}

function apiGet(endpoint, params, onSuccess, onError) {
    let miObjeto = self;
    let request = {
        headers: crearHeadersAPI(),
        parameters: { connectTimeout: 30000, readTimeout: 30000 },
        data: params || {}
    };
    $http.get(API_BASE_URL + endpoint, request,
        function(sData, headers, nStatus) {
            try {
                let json = JSON.parse(sData);
                if (onSuccess) onSuccess(json);
            } catch(ex) { if (onError) onError("Error al procesar: " + ex); }
        },
        function(nError, sDesc) {
            if (nError == 401) mostrarToastError("Sesion expirada");
            else if (onError) onError("Error " + nError + ": " + sDesc);
        }
    );
}

function apiPost(endpoint, data, onSuccess, onError) {
    let request = {
        headers: crearHeadersAPI(),
        parameters: { connectTimeout: 30000, readTimeout: 60000 },
        data: data || {}
    };
    $http.post(API_BASE_URL + endpoint, request,
        function(sData, headers, nStatus) {
            try {
                let json = JSON.parse(sData);
                if (onSuccess) onSuccess(json);
            } catch(ex) { if (onError) onError("Error al procesar: " + ex); }
        },
        function(nError, sDesc) { if (onError) onError("Error " + nError + ": " + sDesc); }
    );
}
```

### 7.8 Patron Offline-First con Sincronización

```javascript
function guardarLocal(nombreColl, datos) {
    let coll = appData.getCollection(nombreColl);
    coll.unlock();
    try {
        let obj = coll.createObject();
        for (let key in datos) obj[key] = datos[key];
        obj.MAP_SINCRONIZADO = 0;
        obj.MAP_FECHA_LOCAL = obtenerAhora();
        coll.addItem(obj);
        obj.save();
        return obj;
    } finally { coll.lock(); }
}

function sincronizarPendientes(nombreColl, endpoint) {
    let coll = appData.getCollection(nombreColl);
    coll.setFilter("MAP_SINCRONIZADO = 0");
    coll.clear(); coll.loadAll();
    let count = coll.getCount();
    if (count == 0) { mostrarToast("No hay registros pendientes"); return; }

    mostrarCargando("Sincronizando " + count + " registros...");
    let pendientes = [];
    for (let i = 0; i < count; i++) pendientes.push(coll.get(i).toJson());

    apiPost(endpoint, { registros: pendientes },
        function(json) {
            for (let i = 0; i < count; i++) {
                let obj = coll.get(i);
                obj.MAP_SINCRONIZADO = 1;
                obj.MAP_FECHA_SYNC = obtenerAhora();
                obj.save();
            }
            ocultarCargando();
            mostrarToastExito(count + " registros sincronizados");
        },
        function(error) {
            ocultarCargando();
            mostrarToastError("Error: " + error);
        }
    );
}

function contarPendientes(nombreColl) {
    let coll = appData.getCollection(nombreColl);
    coll.setFilter("MAP_SINCRONIZADO = 0");
    coll.clear(); coll.loadAll();
    return coll.getCount();
}
```

### 7.9 Patron Control por Voz (TTS + STT)

XOne expone síntesis y reconocimiento de voz a traves del objeto global `ui`:

- `ui.speak({...})` — el dispositivo **habla** un texto.
- `ui.recognizeSpeech({...})` — el dispositivo **escucha** y devuelve el texto reconocido.

El patron completo encadena ambos: hablar primero (pregunta) y arrancar la escucha desde `onCompleted` de `speak`. Así el microfono solo se activa cuando el TTS ha terminado, evitando que el reconocedor capture la propia voz sintetizada.

```xml
<!-- Botón que lanza la interaccion por voz -->
<prop name="MAP_BT_VOZ" type="B" visible="1" title="Preguntar por voz"
      onclick="doSpeakYRecoger('es', '¿Que opción quieres?', self, null);" />

<!-- Icono del microfono con tres estados visuales -->
<prop name="MAP_IMGLISTENING" type="IMG" visible="1" width="64p" height="64p"/>
```

```javascript
// Habla primero, cuando termina arranca la escucha
function doSpeakYRecoger(sLanguage, strText, objSource, objAR) {
    ui.speak({
        language   : sLanguage,
        text       : strText,
        speechRate : 120,
        onCompleted: function() {
            objSource.MAP_IMGLISTENING = "microRojo.png"; // estado "escuchando"
            ui.refresh("MAP_IMGLISTENING");
            doRecognize(sLanguage, objSource, objAR);
        }
    });
}

// Escucha, procesa, restaura UI
function doRecognize(sLanguage, objSource, objAR) {
    ui.recognizeSpeech({
        language: sLanguage,
        timeoutAfterSilence: 10000,

        onRecognize: function(sText) {
            sText = (sText || "").toUpperCase();

            if (objSource.MAP_INITAR == 1 && objAR != null) {
                // Caso A: comparar con opciones predefinidas
                let idx = 100;
                if      (objAR.MAP_TITLE0.toUpperCase() == sText) idx = 0;
                else if (objAR.MAP_TITLE1.toUpperCase() == sText) idx = 1;
                else if (objAR.MAP_TITLE2.toUpperCase() == sText) idx = 2;
                // ...actuar según idx...
            } else {
                // Caso B: simple dictado
                objSource.MAP_TEXT = sText;
                ui.refreshValue("MAP_TEXT");
            }
        },

        onError: function(nErrorCode, sError) {
            objSource.MAP_IMGLISTENING = "microGris.png"; // siempre restaurar
            ui.refresh("MAP_IMGLISTENING");
        },

        onEndOfSpeech: function() {
            objSource.MAP_IMGLISTENING = "microGris.png";
            ui.refresh("MAP_IMGLISTENING");
        }
    });
}
```

**Variante "solo dictado"** (sin TTS previo):

```javascript
function dictarNota() {
    ui.recognizeSpeech({
        language: "es",
        timeoutAfterSilence: 10000,
        onRecognize: function(sText) {
            self.MAP_NOTA = sText;
            ui.refreshValue("MAP_NOTA");
        },
        onError: function(nErrorCode, sError) {
            ui.showToast("Error de voz: " + sError);
        }
    });
}
```

**Checklist del patron:**

- [ ] Encadenar `recognizeSpeech` dentro de `onCompleted` de `speak`, nunca antes.
- [ ] Cambiar el icono del microfono en cada transición (inactivo / hablando / escuchando).
- [ ] Normalizar el texto reconocido (`.toUpperCase()` o `.toLowerCase()`) antes de compararlo con opciones.
- [ ] `timeoutAfterSilence` entre 5000 y 10000 ms (valores típicos).
- [ ] `onError` **siempre** restaura el estado visual del microfono.

Ver también: `2.-desarrollo-app/2.5.-controles-by-xone/control_por_voz/start.md` en el wiki.

---

## 8. Patrones Críticos de Código

Estos patrones son fundamentales para la estabilidad de las aplicaciones XOne. Cualquier desviación puede causar fugas de memoria, bloqueos de datos o errores impredecibles.

### 8.1 Patron lock/unlock (try/finally)

**Obligatorio** para cualquier operación de escritura en colecciones y contents.

> ⚠️ **Cómo funciona `lock()`/`unlock()` en XOne.** `lock()` activa el modo solo lectura (con la bandera activa, `clear()` y `loadAll()` son **no-ops silenciosos** — devuelven `true` sin hacer nada). `unlock()` desbloquea para poder modificar. Las colecciones **nacen desbloqueadas**, pero el patrón estable del proyecto es `unlock(); try {...} finally { lock(); }`: deja la coll bloqueada después para evitar que código posterior mute la coll por accidente.

El `lock()` debe ir **siempre** en el bloque `finally` para garantizar el estado bloqueado al salir, incluso si ocurre un error.

```javascript
// Patron correcto: lock/unlock con try/finally
function agregarRegistro(nombreColl, datos) {
    var coll = appData.getCollection(nombreColl);
    try {
        coll.unlock();
        var obj = coll.createObject();
        for (var key in datos) {
            if (datos.hasOwnProperty(key)) {
                obj[key] = datos[key];
            }
        }
        coll.addItem(obj);
        obj.save();
        return obj;
    } catch(error) {
        ui.showToast("Error: " + error);
        return null;
    } finally {
        coll.lock();  // SIEMPRE en finally, NUNCA omitir
    }
}

// Ejemplo con content de chat
function crearChat(userFrom, userTo) {
    var content = self.getContents("Chat");
    try {
        content.unlock();
        var obj = content.findObject(
            "(USUARIO='" + userFrom + "' AND USUARIO2='" + userTo + "') OR " +
            "(USUARIO='" + userTo + "' AND USUARIO2='" + userFrom + "')"
        );
        if (obj == null) {
            obj = content.createObject();
            obj.USUARIO = userFrom;
            obj.USUARIO2 = userTo;
            obj.FECHA = new Date();
            obj.save();
        }
        return obj.getObjectIndex();
    } finally {
        content.lock();
    }
}

// Bloquear multiples contents a la vez
function lockContents(listContents) {
    for (var i = 0; i < listContents.length; i++) {
        var content = self.getContents(listContents[i]);
        if (content != null) {
            content.lock();
        }
    }
}
```

### 8.2 Patron startBrowse/endBrowse (try/finally)

**Obligatorio** para navegación browse por colecciones. El `endBrowse()` debe ir **siempre** en el bloque `finally`.

```javascript
// Patron correcto: startBrowse/endBrowse
function obtenerDatosGPS() {
    var collGps = appData.getCollection("GPSColl");
    collGps.startBrowse();
    try {
        var objGps = collGps.getCurrentItem();
        if (!objGps) throw "GPS no disponible";
        if (objGps.STATUS != 1) throw "GPS sin señal. STATUS: " + objGps.STATUS;
        if (!objGps.LONGITUD) throw "Sin cobertura GPS";

        self.MAP_LONGITUD = objGps.LONGITUD;
        self.MAP_LATITUD = objGps.LATITUD;
        self.MAP_ALTITUD = objGps.ALTITUD;
        self.MAP_VELOCIDAD = objGps.VELOCIDAD;
        self.MAP_PRECISION = objGps.PRECISION;

        ui.refresh("MAP_LONGITUD,MAP_LATITUD,MAP_ALTITUD,MAP_VELOCIDAD,MAP_PRECISION");
    } catch(error) {
        ui.showToast("Error GPS: " + error);
    } finally {
        collGps.endBrowse();  // SIEMPRE en finally
    }
}

// Búsqueda con browse y verificación de errores
function buscarConBrowse(nombreColl, filtro) {
    var coll = appData.getCollection(nombreColl);
    var filtroOriginal = coll.getFilter();
    coll.setFilter(filtro);
    coll.startBrowse();
    try {
        if (appData.error().getNumber() != 0) {
            throw appData.error().getDescription();
        }
        var item = coll.getCurrentItem();
        return item;
    } catch(error) {
        ui.msgBox("Error: " + error, "Error", 0);
        appData.error().clear();
        return null;
    } finally {
        coll.setFilter(filtroOriginal);
        coll.endBrowse();
    }
}
```

### 8.3 Patron filtro con restauracion (save/apply/restore)

**Fundamental** para evitar que los filtros temporales afecten a otras partes de la aplicación. Guardar el filtro original **antes** de modificarlo y restaurarlo **siempre** en `finally`.

```javascript
// Patron correcto: guardar, aplicar, restaurar
function procesarPedidosActivos() {
    var coll = appData.getCollection("Pedidos");
    var filtroOriginal = coll.getFilter();
    try {
        coll.setFilter("ESTADO = 'ACTIVO'");
        coll.loadAll();

        var count = coll.count();
        for (var i = 0; i < count; i++) {
            var pedido = coll.get(i);
            pedido.ESTADO = "PROCESADO";
            pedido.FECHA_PROCESO = new Date();
            pedido.save();
        }
    } finally {
        coll.setFilter(filtroOriginal);  // SIEMPRE restaurar
    }
}

// Patron completo: filtro + carga + procesamiento + limpieza
function procesarDatosFiltrados(nombreColl, filtro, fnProcesar) {
    var coll = appData.getCollection(nombreColl);
    var filtroOriginal = coll.getFilter();
    try {
        coll.setFilter(filtro);
        coll.loadAll();

        if (appData.error().getNumber() != 0) {
            throw appData.error().getDescription();
        }

        var count = coll.count();
        for (var i = 0; i < count; i++) {
            fnProcesar(coll.get(i));
        }
        return count;
    } catch(error) {
        ui.msgBox("Error: " + error, "Error", 0);
        appData.error().clear();
        return 0;
    } finally {
        coll.setFilter(filtroOriginal);
        coll.clear();  // Liberar memoria
    }
}
```

### 8.4 Preservacion de contexto en callbacks asíncronos

El objeto `self` puede cambiar de contexto dentro de callbacks asíncronos (`$http`, `scanAvailableNetworks`, etc.). Es **crítico** guardar la referencia antes de la llamada asíncrona.

```javascript
// Patrón básico: var contexto = self
function cargarDesdeAPI(endpoint) {
    var contexto = self;  // CRITICO: guardar referencia
    var miView = ui.getView(self);

    $http.get(API_BASE_URL + endpoint,
        function(sData) {
            // Aquí 'self' puede NO ser el mismo objeto
            var json = JSON.parse(sData);
            contexto.MAP_RESULTADO = json.resultado;
            contexto.MAP_TOTAL = json.total;
            ui.refresh("MAP_RESULTADO,MAP_TOTAL");
        },
        function(nError, sDesc) {
            ui.showToast("Error: " + sDesc);
        }
    );
}

// Patron avanzado: preservar contexto en callbacks con propiedad de funcion
function scanWifiNetworks() {
    self.MAP_LOADING = 1;
    ui.refresh("frmLoading");
    self.getContents("ContentWifis").clear();

    var wifiManager = new WifiManager();
    if (wifiManager.isWifiAdapterEnabled()) {
        onWifiFound.OBJETO = self;  // Guardar contexto en propiedad de la funcion
        wifiManager.scanAvailableNetworks(onWifiFound);
    } else {
        ui.executeActionAfterDelay("scanWifiNetworks", 5);
    }
}

function onWifiFound(wifiNetworks) {
    self = onWifiFound.OBJETO;  // Restaurar contexto
    // Procesar resultados de WiFi...
    self.MAP_LOADING = 0;
    ui.refresh("ContentWifis,frmLoading");
}
```

### 8.5 Patron completo: operación con WaitDialog + try/finally

```javascript
function operacionCompleta() {
    ui.showWaitDialog("Procesando...");
    try {
        var coll = appData.getCollection("Datos");
        var filtroOriginal = coll.getFilter();
        try {
            coll.setFilter("PENDIENTE = 1");
            coll.loadAll();
            var count = coll.count();

            ui.setMaxWaitDialog(count);
            for (var i = 0; i < count; i++) {
                ui.updateWaitDialog("Registro " + (i + 1) + " de " + count, i);
                var obj = coll.get(i);
                obj.PENDIENTE = 0;
                obj.FECHA_PROCESO = new Date();
                obj.save();
            }
        } finally {
            coll.setFilter(filtroOriginal);
            coll.clear();
        }
        ui.showToast("Procesados: " + count + " registros");
    } catch(error) {
        ui.msgBox("Error: " + error, "Error", 0);
        appData.error().clear();
    } finally {
        ui.hideWaitDialog();  // SIEMPRE ocultar el WaitDialog
    }
}
```

### 8.6 Cronometros y temporizadores: `startChronometer` vs `executeActionAfterDelay`

Hay dos APIs y NO son intercambiables. Elegir mal degrada el rendimiento de la app.

| Caso de uso | API correcta |
|-------------|--------------|
| Una acción puntual tras un retardo corto (toast, redirigir desde una pantalla de bienvenida, mostrar aviso) | `ui.executeActionAfterDelay(action, segundos)` |
| Temporizador continuo / reloj en pantalla / contador que tickea cada segundo / polling regular | **`startChronometer`** (API XOne nativa) |

> **ANTIPATRON — NO HACER:** encadenar `executeActionAfterDelay` recursivamente para simular un `setInterval`. Tecnicamente funciona, pero **consume mucha memoria y ralentiza el dispositivo** porque cada iteración acumula overhead. Usado como base de un reloj continuo, **cargaria la app**.

```javascript
// MAL — patron prohibido (cronometro encadenando executeActionAfterDelay)
function iniciarCronometro() {
    self.MAP_RECORDON = 1;
    ui.executeActionAfterDelay("onSetTime", 1);
}
function onSetTime() {
    actualizarTiempo();
    if (self.MAP_RECORDON == 1) {
        ui.executeActionAfterDelay("onSetTime", 1);  // <-- destroza memoria
    }
}

// BIEN — uso aislado de executeActionAfterDelay (un solo disparo)
ui.executeActionAfterDelay("mostrarAvisoFinal", 30);  // un aviso a los 30s: OK
```

#### API correcta para cronometros continuos: `control.startChronometer` / `control.stopChronometer`

> **CLAVE:** `startChronometer` y `stopChronometer` **NO son métodos de `ui.*`**, son métodos de un **control** (un nodo `<prop>` de la pantalla, típicamente `type="T"`). Hay que obtener el control primero con `getControl(sPropName)` o desde la window via `ui.getView(self)`.

**Firma:**
```
control.startChronometer(jsOptions);  // arranca
control.stopChronometer();             // detiene
```

**Parámetros de `jsOptions`:**

| Campo        | Tipo   | Descripción |
|--------------|--------|-------------|
| `fromDate`   | Date   | Fecha desde la que arranca el cronometro. Típico: `new Date()`. |
| `dateFormat` | string | Formato de visualizacion del tiempo. Ej. `"mm:ss"`, `"HH:mm:ss"`. |

**Ejemplo completo (XML + JS):**

```xml
<coll name="Menu" notab="true" special="true">
    <group name="General" id="1" align="center">
        <prop name="MAP_T"     type="T" visible="7" labelwidth="0"  width="80%" height="10%" />
        <prop name="MAP_START" type="B" visible="7" width="80%" height="10%" title="Start" onclick="start('MAP_T');" />
        <prop name="MAP_STOP"  type="B" visible="7" width="80%" height="10%" title="Stop"  onclick="stop('MAP_T');" />
    </group>
</coll>
```

```javascript
function start(sPropName) {
    let control = getControl(sPropName);
    if (!control) return;
    let jsOptions = {
        fromDate  : new Date(),
        dateFormat: "mm:ss"
    };
    control.startChronometer(jsOptions);
}

function stop(sPropName) {
    let control = getControl(sPropName);
    if (!control) return;
    control.stopChronometer();
}
```

**Patron alternativo (acceso via `ui.getView`):**

```javascript
function startChronometer() {
    let window = ui.getView(self);
    if (!window) return;
    let control = window.MAP_CHRONO;
    if (!control) return;
    control.startChronometer();
}
```

> **NO existe `ui.startChronometer(...)`** — es método del control, no del objeto global `ui`.

---

## 9. Errores Comunes a Evitar

### 9.1 Usar APIs Web que No Existen en XOne

```javascript
// INCORRECTO - NO existen en XOne
document.getElementById("miElemento");
localStorage.setItem("key", "value");
async function miFuncion() {}  // async/await todavía no soportado

// CORRECTO - Equivalentes XOne
let control = getControl("MAP_ELEMENTO");
appData.setGlobalMacro("##KEY##", "value");

// SÍ existen y se pueden usar (no son APIs web "que faltan"):
//   Promise (ES2024 completo, ver 11.5)
//   fetch(url, init)  — alternativa moderna a $http.get/post
//   setTimeout/setInterval — para timers; ojo, el patrón XOne idiomático
//                            es ui.executeActionAfterDelay() / startChronometer
new Promise((resolve, reject) => { /* ... */ });
fetch("https://api.example.com").then(r => r.json());

// Patrones XOne para timers (más idiomáticos que setTimeout):
ui.executeActionAfterDelay("miFuncion", 1);  // disparo único (segundos, no ms)
// Para timers continuos: ui.startChronometer (ver 8.6).
```

### 9.2 No Guardar Referencia de `self` antes de Callbacks

```javascript
// INCORRECTO
$http.get(url, request, function(sData) {
    self.MAP_DATOS = sData;  // BUG: self puede haber cambiado
}, function(nError, sDesc) {});

// CORRECTO
let miObjeto = self;
$http.get(url, request, function(sData) {
    miObjeto.MAP_DATOS = sData;
    ui.refresh("MAP_DATOS");
}, function(nError, sDesc) { mostrarToastError(sDesc); });
```

### 9.3 No Usar lock/unlock en Colecciones

```javascript
// INCORRECTO
let coll = appData.getCollection("Items");
let obj = new Items();
coll.addItem(obj);  // Error: coleccion bloqueada

// CORRECTO
coll.unlock();
try {
    let obj = new Items();
    coll.addItem(obj);
    obj.save();
} finally { coll.lock(); }
```

### 9.4 No Cerrar Cursores ni Conexiones SQL

```javascript
// INCORRECTO - Fuga de recursos
let sqlManager = new SqlManager();
sqlManager.openDatabase({ databasePath: "gestion.db" });
let cursor = sqlManager.doRawQuery("SELECT * FROM gen_Tabla");
let nombre = cursor.getString("NOMBRE");
// Cursor y conexión quedan abiertos

// CORRECTO
try {
    sqlManager.openDatabase({ databasePath: "gestion.db", useExistingConnection: true });
    let cursor = sqlManager.doRawQuery("SELECT * FROM gen_Tabla");
    try {
        if (cursor.getCount() > 0) { cursor.moveToFirst(); return cursor.getString("NOMBRE"); }
    } finally { cursor.close(); }
} finally { sqlManager.close(); }
```

### 9.5 Olvidar Ocultar el WaitDialog

```javascript
// INCORRECTO
function cargar() {
    mostrarCargando("Cargando...");
    let resultado = operacionRiesgosa();  // Si falla, WaitDialog queda visible
    ocultarCargando();
}

// CORRECTO
function cargar() {
    mostrarCargando("Cargando...");
    try { operacionRiesgosa(); }
    catch(ex) { mostrarToastError("Error: " + ex); }
    finally { ocultarCargando(); }
}
```

### 9.6 Usar Unidades CSS Web

```javascript
// INCORRECTO: width: 100px; margin: 10em; font-size: 14rem;
// CORRECTO:   width: 100p; margin: 10p; fontsize: 14;
// Unidades validas en XOne: p (puntos), % (porcentaje)
```

### 9.7 Concatenar Valores sin Conversion Segura

```javascript
// INCORRECTO
return cantidad * precio;  // NaN si alguno es null

// CORRECTO
return cnum(cantidad) * cnum(precio);
```

### 9.8 No Verificar Existencia de Objetos

```javascript
// INCORRECTO
let usuario = buscarObjeto("Usuarios", "ID", id);
mostrarToast("Nombre: " + usuario.MAP_NOMBRE);  // Error si null

// CORRECTO
let usuario = buscarObjeto("Usuarios", "ID", id);
if (!usuario) { mostrarToastError("No encontrado"); return; }
mostrarToast("Nombre: " + cstr(usuario.MAP_NOMBRE));
```

### 9.9 Usar ui.sleep() Innecesariamente

```javascript
// INCORRECTO - Bloquea la UI
ui.sleep(5); procesarDatos();

// CORRECTO
ui.executeActionAfterDelay("procesarDatos", 5);
```

### 9.10 Inyeccion SQL en findObject

```javascript
// INCORRECTO - Vulnerable
coll.findObject("NOMBRE = '" + nombre + "'");

// CORRECTO - Escapar comillas
let escapado = cstr(nombre).replace(/'/g, "''");
coll.findObject("NOMBRE = '" + escapado + "'");

// MEJOR - SqlManager con parametros
sqlManager.doRawQuery("SELECT * FROM gen_Productos WHERE NOMBRE=?", nombre);
```

### 9.11 No Validar Campos Antes de Guardar

```javascript
// INCORRECTO
self.save(); cerrarPantalla();

// CORRECTO
if (!validarRequerido(self.MAP_NOMBRE, "Nombre")) return;
if (cnum(self.MAP_CANTIDAD) < 0) { mostrarToastError("Cantidad invalida"); return; }
try {
    self.save();
    mostrarToastExito("Guardado");
    cerrarPantalla();
} catch(ex) { mostrarToastError("Error: " + ex); }
```

### 9.12 Refrescar Toda la UI

```javascript
// INCORRECTO
self.MAP_CONTADOR = cnum(self.MAP_CONTADOR) + 1;
ui.refresh();  // Refresca TODA la pantalla

// CORRECTO
self.MAP_CONTADOR = cnum(self.MAP_CONTADOR) + 1;
ui.refresh("MAP_CONTADOR");  // Solo este campo
```

---

*Documento de referencia generado a partir de las knowledgebases del proyecto XOneAI y el análisis de 254 archivos JavaScript (35,497 lineas) de 216 proyectos XOne reales.*

**Anterior:** [d - createObject](xone-javascript-patterns-d-createobject.md) · **Índice:** [xone-javascript-patterns.md](xone-javascript-patterns.md)