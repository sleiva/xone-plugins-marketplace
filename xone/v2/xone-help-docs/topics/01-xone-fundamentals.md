# XOne Fundamentals - Guía de Conceptos y Arquitectura

## Tabla de Contenidos

- [1. Que es XOne?](#1-que-es-xone)
- [2. Arquitectura de XOne](#2-arquitectura-de-xone)
  - [2.1 Modelo Declarativo + Imperativo](#21-modelo-declarativo--imperativo)
  - [2.2 Ciclo de Vida: Coleccion, Objeto, Propiedad](#22-ciclo-de-vida-coleccion-objeto-propiedad)
  - [2.3 Flujo de Datos](#23-flujo-de-datos)
  - [2.4 Sincronización con Servidor](#24-sincronizacion-con-servidor)
- [3. Anatomia de un Proyecto XOne](#3-anatomia-de-un-proyecto-xone)
  - [3.1 Archivos Obligatorios](#31-archivos-obligatorios)
  - [3.2 Carpetas Obligatorias](#32-carpetas-obligatorias)
  - [3.3 Carpetas Opcionales](#33-carpetas-opcionales)
  - [3.4 Diagrama de Estructura Completa](#34-diagrama-de-estructura-completa)
- [4. Archivos de Configuración](#4-archivos-de-configuracion)
  - [4.1 app.xml](#41-appxml)
  - [4.2 app.ini](#42-appini)
  - [4.3 mappings.xne](#43-mappingsxne)
- [5. Tipos de Archivos en XOne](#5-tipos-de-archivos-en-xone)
- [6. Conceptos Clave](#6-conceptos-clave)
  - [6.1 Colecciones](#61-colecciones)
  - [6.2 Objetos de Datos (DataObject)](#62-objetos-de-datos-dataobject)
  - [6.3 Propiedades (Props)](#63-propiedades-props)
  - [6.4 Prefix PREF](#64-prefix-pref)
  - [6.5 Macros del Sistema](#65-macros-del-sistema)
  - [6.6 Códigos de Error](#66-codigos-de-error)
  - [6.7 Sintaxis JavaScript soportada por el motor](#67-sintaxis-javascript-soportada-por-el-motor)
- [7. Flujo de Navegación](#7-flujo-de-navegacion)
- [8. Convenciones de Nomenclatura](#8-convenciones-de-nomenclatura)
- [9. Primeros Pasos - Crear un Proyecto Básico](#9-primeros-pasos---crear-un-proyecto-basico)
- [10. Errores Comunes de Principiantes](#10-errores-comunes-de-principiantes)

---

## 1. Que es XOne?

XOne es una **plataforma de desarrollo de aplicaciones móviles** que permite generar apps nativas para Android e iOS a partir de un único código fuente. A diferencia de otros frameworks multiplataforma, XOne utiliza un enfoque **declarativo basado en XML** para definir la interfaz de usuario, combinado con **JavaScript** para la lógica de negocio.

### Componentes del Ecosistema

El ecosistema XOne se compone de tres elementos principales:

| Componente | Descripción |
|------------|-------------|
| **Framework XOne** | Motor que interpreta los archivos XML, CSS y JS para generar las interfaces nativas en cada plataforma |
| **Runtime XOne** | Entorno de ejecución que corre en el dispositivo móvil, renderizando la UI y ejecutando la lógica |
| **Servidor de Replica** | Componente de backend que permite la sincronización bidireccional de datos entre dispositivos y servidor central |

### Que hace diferente a XOne?

Si vienes del desarrollo web, estas analogias te ayudaran a entender la filosofia de XOne:

| Concepto Web | Equivalente XOne | Diferencia Clave |
|-------------|-----------------|------------------|
| HTML | Archivos `.xne` (XML) | XOne usa nodos como `<coll>`, `<prop>`, `<frame>` en vez de `<div>`, `<input>`, `<span>` |
| CSS | `default.css` | Sintaxis similar pero con atributos propietarios; unidades `p` y `%` en vez de `px` y `em` |
| JavaScript | `functions.js` | API propia (`ui.*`, `self.*`, `appData.*`) en vez de APIs del navegador (`document.*`, `window.*`) |
| Base de datos | `bd/gestion.db` (SQLite) | Base de datos local integrada que se sincroniza automáticamente con el servidor |

> **Nota importante:** Aunque la sintaxis pueda parecer familiar, XOne NO es desarrollo web. No tiene DOM, no tiene navegador, no tiene `document` ni `window`. Las APIs son completamente propias de la plataforma.

### Ventajas Principales

1. **Código único, apps nativas**: Un solo proyecto genera apps para Android e iOS con rendimiento nativo
2. **Funcionamiento offline**: La base de datos SQLite local permite trabajar sin conexión
3. **Sincronización automática**: El sistema de replica sincroniza datos cuando hay conectividad
4. **Desarrollo rápido**: El modelo declarativo reduce drasticamente el código necesario
5. **Sin compilación**: Los cambios en XML/CSS/JS se reflejan sin necesidad de recompilar

---

## 2. Arquitectura de XOne

### 2.1 Modelo Declarativo + Imperativo

XOne combina dos paradigmas de programación:

**Declarativo (XML):** Define QUE mostrar en la pantalla. Se usa para:
- Estructura de la interfaz de usuario
- Definición de campos y tipos de datos
- Layout y posicionamiento de elementos
- Configuración de eventos

**Imperativo (JavaScript):** Define COMO comportarse. Se usa para:
- Lógica de negocio
- Validaciones complejas
- Navegación programatica
- Integraciones con APIs externas
- Manipulación de datos

```
 +-----------------------+     +------------------------+
 |    XML Declarativo    |     |  JavaScript Imperativo |
 |  (.xne / .xml / .css)|     |       (.js)            |
 +-----------+-----------+     +-----------+------------+
             |                             |
             v                             v
       +-----+-----------------------------+------+
       |        Runtime XOne (Dispositivo)        |
       |  - Renderiza UI nativa                   |
       |  - Ejecuta logica JS                     |
       |  - Gestiona BD local                     |
       |  - Sincroniza con servidor               |
       +------------------------------------------+
                         |
               +---------+---------+
               |                   |
         +-----+------+    +------+------+
         |  Android   |    |    iOS      |
         |  (Nativo)  |    |  (Nativo)   |
         +------------+    +-------------+
```

### 2.2 Ciclo de Vida: Coleccion, Objeto, Propiedad

El modelo de datos de XOne se organiza en tres niveles jerarquicos. Si vienes de bases de datos, la analogia es directa:

| Nivel XOne | Equivalente BD | Equivalente Web | Descripción |
|------------|---------------|-----------------|-------------|
| **Coleccion** (`coll`) | Tabla | Página/Componente | Define estructura de datos + UI |
| **Objeto** (DataObject) | Fila/Registro | Instancia | Una unidad de datos concreta |
| **Propiedad** (`prop`) | Columna/Campo | Input/Label | Un dato individual + su representación visual |

Cada coleccion tiene su propio ciclo de vida con eventos bien definidos:

```
  Coleccion creada
       |
       v
   [create]  -->  Se ejecuta una sola vez al crear la instancia
       |
       v
    [load]   -->  Se ejecuta cada vez que la pantalla se muestra
       |
       v
  [onchange] -->  Se ejecuta cuando cambia el valor de un campo
       |
       v
  [onback]   -->  Se ejecuta cuando el usuario pulsa el boton "atras"
```

**Ejemplo práctico del ciclo de vida:**

```xml
<coll name="DetalleTarea" title="Detalle de Tarea">
    <!-- Se ejecuta UNA vez al crear la coleccion -->
    <create>
        <action name="runscript">
            <script language="javascript">
                // Inicializar valores por defecto
                self.MAP_FECHA = new Date();
                self.MAP_ESTADO = "PENDIENTE";
            </script>
        </action>
    </create>

    <!-- Se ejecuta CADA VEZ que la pantalla se muestra -->
    <load>
        <action name="runscript">
            <script language="javascript">
                // Actualizar contadores o datos dinamicos
                actualizarContador();
            </script>
        </action>
    </load>

    <!-- Se ejecuta cuando CAMBIA el valor de un campo -->
    <onchange>
        <field name="MAP_ESTADO">
            <action name="runscript">
                <script language="javascript">
                    // Reaccionar al cambio de estado
                    if (self.MAP_ESTADO == "COMPLETADA") {
                        self.MAP_FECHA_FIN = new Date();
                    }
                </script>
            </action>
        </field>
    </onchange>

    <!-- Contenido de la pantalla aquí -->

    <!-- Se ejecuta al pulsar ATRAS -->
    <onback>
        <action name="runscript">
            <script language="javascript">
                let window = ui.getView(self);
                if (window) {
                    window.exit();
                }
            </script>
        </action>
    </onback>
</coll>
```

### 2.3 Flujo de Datos

El flujo de datos en XOne sigue un patron claro entre la base de datos local, las colecciones en memoria y la interfaz de usuario:

```
  +----------------+          +-------------------+          +----------+
  | BD Local       |  <---->  | Coleccion         |  <---->  | UI       |
  | (gestion.db)   |  SQL     | (objetos en       |  binding | (props,  |
  | SQLite         |          |  memoria)         |          |  frames) |
  +----------------+          +-------------------+          +----------+
         ^
         |  Sincronización
         v
  +----------------+
  | Servidor       |
  | de Replica     |
  +----------------+
```

1. **BD Local -> Coleccion**: Las colecciones cargan datos de SQLite mediante el atributo `sql`
2. **Coleccion -> UI**: Las propiedades (`prop`) muestran los datos de la coleccion automáticamente
3. **UI -> Coleccion**: Cuando el usuario edita un campo, el valor se actualiza en el objeto (DataObject)
4. **Coleccion -> BD Local**: Al llamar a `save()`, los cambios se persisten en SQLite
5. **BD Local <-> Servidor**: El sistema de replica sincroniza los datos bidireccionalmente

### 2.4 Sincronización con Servidor

La sincronización es una de las caracteristicas más poderosas de XOne. Cada registro en la base de datos tiene un campo `ROWID` que contiene un GUID (identificador único global) de 32 caracteres hexadecimales. Este GUID permite:

- Identificar de forma única cada registro en cualquier dispositivo
- Resolver conflictos de sincronización
- Mantener la integridad referencial entre dispositivos

```
  Dispositivo A          Servidor            Dispositivo B
  +----------+          +--------+          +----------+
  | ROWID:   |  push    |        |  pull    | ROWID:   |
  | a1b2c3.. | -------> | a1b2.. | -------> | a1b2c3.. |
  +----------+          +--------+          +----------+
```

> **Nota:** El `ROWID` es una **columna de plataforma**: el framework la crea y la rellena sola (autogenera el GUID de 32 caracteres hex en cada alta) y el motor de réplica la usa como clave global de fila. **No hace falta declararla** como `<prop>` (igual que el `ID`); declararla es válido pero redundante, así que mejor omitirla por limpieza.

---

## 3. Anatomia de un Proyecto XOne

### 3.1 Archivos Obligatorios

Todo proyecto XOne requiere estos archivos en la raiz:

| Archivo | Proposito | Equivalente Web |
|---------|-----------|-----------------|
| `app.xml` | Configuración global de la aplicación | `package.json` + configuración del framework |
| `app.ini` | Metadatos de la aplicación (nombre, icono) | `manifest.json` |
| `mappings.xne` | Colecciones base (Empresas y Usuarios) | Schema de base de datos |
| `default.css` | Estilos globales de la aplicación | Archivo CSS global |
| `functions.js` | Funciones JavaScript compartidas | Archivo JS de utilidades |
| `EntradaApp.xne` | Pantalla de entrada de la aplicación | `index.html` |

Además, cada coleccion adicional y cada pantalla se define en su propio archivo `.xne`:

```
MenuPrincipal.xne     -->  Pantalla del menu principal
ListaTareas.xne       -->  Pantalla con lista de tareas
DetalleTarea.xne      -->  Pantalla de detalle/edicion
Tareas.xne            -->  Definición de coleccion (tabla + campos)
Categorias.xne        -->  Otra coleccion
```

### 3.2 Carpetas Obligatorias

| Carpeta | Contenido | Por que es obligatoria |
|---------|-----------|----------------------|
| `bd/` | `gestion.db` (base de datos SQLite) | Sin BD la app no puede almacenar ni consultar datos |
| `icons/` | Iconos y recursos gráficos (PNG, JPG, SVG) | La app necesita iconos para botones, menú, etc. (el splash NO va aquí — ver §4.1) |
| `files/` | Archivos dinámicos (fotos, firmas, documentos) | Directorio de trabajo para archivos generados en runtime |

### 3.3 Carpetas Opcionales

| Carpeta | Contenido | Cuando usarla |
|---------|-----------|---------------|
| `fonts/` | Fuentes tipograficas (.ttf, .otf) | Cuando necesitas tipografía personalizada |
| `lang/` | Subcarpetas por idioma (`en/`, `es/`, `fr/`) | Para apps multiidioma |
| `native/` | Código nativo (`Android/`, `IOS/`) | Para integraciones nativas avanzadas |
| `scripts/` | Scripts JS organizados en subcarpetas | En proyectos grandes con mucho JS |
| `certificates/` | Certificados SSL/TLS (.crt, .pem) | Para conexiones seguras personalizadas |

### 3.4 Diagrama de Estructura Completa

A continuacion, el diagrama de un proyecto XOne típico. Los elementos marcados con `[OBL]` son obligatorios:

```
MiProyectoXOne/
|
|-- app.xml                    [OBL] Configuración de la aplicacion
|-- app.ini                    [OBL] Metadatos (nombre, icono)
|-- mappings.xne               [OBL] SOLO Empresas y Usuarios
|-- default.css                [OBL] Estilos globales
|-- functions.js               [OBL] Funciones JS globales
|-- EntradaApp.xne             [OBL] Pantalla de entrada
|-- splash.png                 [OPC] Imagen de splash (ver §4.1 "Pantalla de splash")
|
|-- MenuPrincipal.xne          Pantalla del menu
|-- Login.xne                  Pantalla de login
|-- ListaClientes.xne          Pantalla de listado
|-- DetalleCliente.xne         Pantalla de detalle
|-- Clientes.xne               Colección (datos de clientes)
|-- Productos.xne              Colección (datos de productos)
|
|-- bd/                        [OBL] Base de datos
|   +-- gestion.db             Archivo SQLite
|
|-- icons/                     [OBL] Recursos gráficos
|   |-- app_icon.png           Icono de la app (192x192)
|   |-- ic_menu.png            Icono de menú (48x48)
|   |-- ic_search.png          Icono de búsqueda (48x48)
|   +-- ic_arrow_back.png      Flecha atrás (48x48)
|
|-- files/                     [OBL] Archivos dinamicos
|   |-- fotos/
|   |-- documentos/
|   +-- firmas/
|
|-- fonts/                     [REC] Fuentes tipograficas
|   |-- Roboto-Regular.ttf
|   +-- Roboto-Bold.ttf
|
|-- scripts/                   [OPC] Scripts organizados
|   |-- login/
|   +-- general/
|
+-- lang/                      [OPC] Multiidioma
    |-- en/
    +-- es/
```

> **Regla crítica:** El archivo `mappings.xne` SOLO debe contener las colecciones `Empresas` y `Usuarios`. Todas las demas colecciones van en archivos `.xne` separados, uno por cada coleccion. Ver sección [4.3 mappings.xne](#43-mappingsxne) para más detalle.

---

## 4. Archivos de Configuración

### 4.1 app.xml

El archivo `app.xml` es el **punto de partida** de toda la configuración. Define como se comporta la aplicación, donde están sus recursos y cual es la pantalla inicial.

#### Estructura Completa

```xml
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xml>
    <app
        prefix="gen"
        version="1.0.0"
        debug="true"
        autologon="false"
        screen-orientation="portrait"
        resolution-width="1080"
        resolution-height="1920"
        scale-fontsize="true"
        android-font-factor="7"
        ios-font-factor="7"
        default-language="javascript">

        <!-- Conexión a una base de datos alternativa. La base de datos principal NO necesita este nodo. -->
        <connection name="other_db" connstring="bd/other_db.db" />

        <!-- Primera pantalla que se abre al iniciar la app -->
        <entry-point>
            <item name="EntradaApp" conditions="" />
        </entry-point>

        <!-- Pantalla de login (opcional pero recomendada) -->
        <login-coll>
            <item name="Login" conditions="" />
        </login-coll>

        <!-- Archivos CSS -->
        <style url="default.css" encoding="UTF-8" />

        <!-- Archivos JavaScript -->
        <include file="functions.js" language="javascript" encoding="UTF-8"/>
    </app>
</xml>
```

#### Atributos Explicados Linea por Linea

| Atributo | Valor | Explicacion |
|----------|-------|-------------|
| `prefix` | `"gen"` | Prefijo para las tablas en la BD. Las tablas se llamaran `gen_Empresas`, `gen_Usuarios`, etc. **Siempre usar "gen" por defecto** a menos que el usuario pida otro |
| `versión` | `"1.0.0"` | Versión semantica de la aplicación |
| `debug` | `"true"` / `"false"` | Activa mensajes de depuracion. Usar `"true"` en desarrollo, `"false"` en produccion |
| `autologon` | `"false"` | Si es `"true"`, salta la pantalla de login y entra directamente con el usuario `admin` sin password. **Solo para desarrollo/pruebas** |
| `screen-orientation` | `"portrait"` | Orientación forzada: `"portrait"` (vertical), `"landscape"` (horizontal), `"all"` (ambas) |
| `resolution-width` | dinámico | Ancho en pixeles del dispositivo físico de referencia. Ver sistema de escalado más abajo |
| `resolution-height` | dinámico | Alto en pixeles del dispositivo físico de referencia |
| `scale-fontsize` | `"true"` | Escala automáticamente las fuentes según la resolución del dispositivo |
| `android-font-factor` | `"7"` | Factor de ajuste de fuentes para Android |
| `ios-font-factor` | `"7"` | Factor de ajuste de fuentes para iOS |
| `default-language` | `"javascript"` | Lenguaje de scripting. Siempre `"javascript"` en proyectos modernos |
| `load-wait` | `"false"` | Si es `"true"`, muestra una pantalla de espera durante la carga inicial de la app |
| `compatibility-mode` | `"false"` | **CRÍTICO:** Si es `"true"`, desactiva completamente todos los estilos CSS |
| `companycolor` | — | Color corporativo general (menús, pestañas, selecciones donde no haya color específico) |
| `forecolor` | `"#FFFFFF"` | Color de texto general de la aplicación |
| `sql-profiler` | `"false"` | Registra las consultas SQL con tiempos de ejecución. **Desactivar en producción** |
| `load-imgbk` | — | Imagen de fondo del EditView (NO es el splash de carga; el splash se pone con un fichero `splash.png` en la raíz del proyecto) |
| `application-max-priority` | `"false"` | Marca la app como prioritaria para evitar que el SO la cierre en segundo plano |
| `application-notification-title` | — | Título de la notificación persistente de la app en Android |
| `application-notification-text` | — | Texto de la notificación persistente de la app en Android |
| `gps-service-notification-title` | — | Título de la notificación del servicio GPS en segundo plano |
| `gps-service-notification-text` | — | Texto de la notificación del servicio GPS en segundo plano |
| `secure-window` | `"false"` | Si es `"true"`, impide capturar pantalla (screenshot) |
| `replica-debug` | `"false"` | Loguea información de debug del proceso de réplica |
| `autologon-username` | `"admin"` | Usuario para el autologin (cuando `autologon="true"`) |
| `autologon-password` | — | Contraseña para el autologin |

> **Atributos que NO van en `<app>`:**
> - `fullscreen` — es atributo de `<coll>` (oculta barras de estado en una pantalla concreta).
> - `sql-debug` — es atributo de `<coll>` (loguea las SQL de esa colección).

#### Atributo `conditions` en los subnodos `<style>`, `<entry-point>` y `<login-coll>`

El atributo `conditions` permite que un subnodo se aplique solo cuando se cumple una condición de plataforma, tamaño de pantalla u orientación. Formato: `PLATAFORMA:TAMANO:ORIENTACION` — solo se especifican las partes necesarias.

| Parte | Valores posibles |
|-------|-----------------|
| Plataforma | `android`, `ios`, `wm` (Windows Mobile), `bb` (BlackBerry), `wp` (Windows Phone) |
| Tamaño | `phone` (móvil estándar), `tablet`, `mini` (Android < 3.5"), `hiphone` (Android 4.5"–7") |
| Orientación | `vertical`, `horizontal` |

```xml
<!-- Base: se aplica siempre -->
<style url="default.css" strict-mode="true" />
<!-- Solo en movil orientacion horizontal -->
<style url="default_hor.css" conditions="phone:horizontal" strict-mode="true" />
<!-- Solo en iOS -->
<style url="default-ios.css" conditions="ios" strict-mode="true" />
<!-- Solo en tablet vertical -->
<style url="default_tablet.css" conditions="tablet:vertical" strict-mode="true" />
<!-- Solo en iPhone -->
<style url="default_iphone.css" conditions="ios:phone" strict-mode="true" />

<!-- Entry point distinto según dispositivo -->
<entry-point>
    <item name="EntradaApp" conditions="" />
    <item name="EntradaAppTablet" conditions="tablet:horizontal" />
</entry-point>
```

> **Regla:** El fichero `default.css` (sin `conditions`) se aplica **siempre** como base. Los demas CSS con `conditions` se aplican adicionalmente cuando se cumple la condición, sobreescribiendo los estilos base donde haya conflicto.

#### Que es `<entry-point>`

El nodo `<entry-point>` le indica a XOne **cual es la primera coleccion que debe abrirse** cuando el usuario entra en la app. Se ejecuta justo después del login (o directamente al arrancar si `autologon="true"`).

La colección apuntada por `<entry-point>` es siempre `special="true"` — no tiene tabla en BD. Puede ser una pantalla de bienvenida, un dashboard, un menú principal, etc. El nombre más habitual es `EntradaApp`. (No confundir con el splash: el splash es un fichero `splash.png` en la raíz, no una `<coll>`.)

```xml
<!-- Entry-point simple -->
<entry-point>
    <item name="EntradaApp" conditions="" />
</entry-point>

<!-- Entry-point con coleccion distinta según dispositivo -->
<entry-point>
    <item name="EntradaApp" conditions="" />
    <item name="EntradaAppTablet" conditions="tablet:horizontal" />
</entry-point>
```

> **Convencion:** Usar `EntradaApp` como nombre por defecto. Solo cambiar si la app arranca directamente en el menu principal (`MenuPrincipal`) sin pantalla de bienvenida.

#### Que es `<login-coll>`

El nodo `<login-coll>` le indica a XOne **cual es la coleccion que gestiona el proceso de autenticación**. XOne muestra esta coleccion **antes** del `<entry-point>`, y solo pasa al entry-point cuando el login es correcto.

La coleccion de login es siempre `special="true"`. Contiene el formulario de usuario y contrasena, y la lógica JavaScript que valida las credenciales.

```xml
<login-coll>
    <item name="LoginColl" conditions="" />
</login-coll>
```

**Flujo de arranque completo:**

```
[Arranque]
    |
    v
autologon="true"? ── SI ──> [entry-point] ──> App lista
    |
    NO
    |
    v
[login-coll] → usuario introduce usuario y contraseña
    |
    v
credenciales OK? ── SI ──> [entry-point] ──> App lista
    |
    NO
    |
    v
[login-coll] ← vuelve al login con mensaje de error
```

> **IMPORTANTE:** Si `autologon="false"` y no se define `<login-coll>`, XOne usa su pantalla de login interna por defecto, que no es personalizable. En apps de produccion **siempre** definir `<login-coll>` con una coleccion propia.

#### Pantalla de splash

El splash que se muestra durante la carga inicial de la app **NO es una `<coll>` XML** — es un fichero estático en la raíz del proyecto que el framework carga automáticamente desde `LoadAppActivity`.

**Convención:** poner un fichero `splash.png` en la carpeta raíz del proyecto.

El framework busca los siguientes ficheros, en este orden, y usa el primero que encuentre:

| Tipo | Ficheros (raíz del proyecto, por orden de prioridad) |
|------|------------------------------------------------------|
| Vídeo | `splash.3gp`, `splash.mp4` |
| Imagen | `splash.jpg`, `splash.png`, `splash.gif`, `splash.bmp`, `splash.webp`, `splash.apng` |

- Si no se encuentra ninguno, el framework usa una imagen de splash interna por defecto.
- Para vídeos (`.3gp` / `.mp4`), `LoadAppActivity` añade un botón "Saltar" automáticamente y oculta la barra de progreso y el mensaje.
- Para imágenes animadas: `.gif` se carga con `GifDrawable`; `.webp` animado se reproduce automáticamente en Android 9+ (`AnimatedImageDrawable`); `.apng` se decodifica con `PngReadHelper`.
- El ancho de la imagen se ajusta al 100% del ancho de la pantalla manteniendo el ratio.

**No confundir** con:
- `load-imgbk` en `<app>`: imagen de fondo del EditView (NO el splash).
- `EntradaApp.xne`: pantalla post-login que se abre tras autenticarse (NO el splash).

#### Leer y escribir los contactos del teléfono

XOne expone la agenda de contactos del dispositivo como una **fuente de datos consultable con SQL**, a través de un proveedor de datos especial. No hay que importar nada: el proveedor forma parte del framework. Se usa en tres pasos.

**1. Declarar la conexión** en el nodo `<app>` (en `app.xml`):

```xml
<connection name="ContactsConnection"
    connstring="Provider=Xone Remote Provider;ProgID=com.xone.db.impl.contacts.ContactsConnection" />
```

**2. Pedir el permiso** de contactos (en el nodo `<permissions>` de `app.xml`):

```xml
<permission name="contacts" />
```

**3. Crear una colección** que use esa conexión. La "tabla" se llama `Contacts`:

```xml
<coll name="Contacts"
    sql="SELECT id,name,email,phone,photo,photo_thumbnail FROM Contacts"
    connection="ContactsConnection"
    idfieldname="id" stringkey="true"
    check-owner="false" dependent="false"
    show-toolbar="false" notab="true"
    onback="ui.getView(e.objItem).exit();">
    <group name="General" id="1">
        <prop visible="7" name="id"              type="T"   title="ID"              width="100%" labelbox="false" text-border="false" />
        <prop visible="7" name="name"            type="T"   title="Name"            width="100%" labelbox="false" text-border="false" />
        <prop visible="7" name="email"           type="T"   title="Email"           width="100%" labelbox="false" text-border="false" />
        <prop visible="7" name="phone"           type="T"   title="Phone"           width="100%" labelbox="false" text-border="false" />
        <prop visible="7" name="photo"           type="IMG" title="Photo"           width="100%" height="35%" keep-aspect-ratio="true" />
        <prop visible="7" name="photo_thumbnail" type="IMG" title="Photo thumbnail" width="100%" height="35%" keep-aspect-ratio="true" />
    </group>
</coll>
```

**Campos disponibles en el SELECT** (tabla `Contacts`):

| Campo | Tipo prop | Contenido |
|-------|-----------|-----------|
| `id` | `T` | Identificador del contacto. Es la clave de la coll (`idfieldname="id"` + `stringkey="true"`). |
| `name` | `T` | Nombre a mostrar del contacto. |
| `email` | `T` | Primer email del contacto. |
| `phone` | `T` | Primer teléfono del contacto (vacío si el contacto no tiene ninguno). |
| `photo` | `IMG` | Foto en alta resolución. El proveedor la vuelca a un fichero en la carpeta `files` del proyecto y devuelve el nombre del fichero; por eso se mapea a `type="IMG"`. |
| `photo_thumbnail` | `IMG` | Miniatura de la foto, con el mismo mecanismo. |

**Notas de la fuente de contactos:**

- La consulta devuelve **como máximo 100 contactos**. Usa `WHERE` (filtro) y `ORDER BY` (orden) en el SQL para acotar y ordenar el resultado; los nombres de campo del filtro y el orden son los mismos de la tabla (`name`, `phone`, etc.).
- El SELECT debe incluir al menos uno de los campos anteriores; en caso contrario no devuelve resultados.
- **Alta y modificación:** un `INSERT`/`UPDATE` sobre `Contacts` crea o actualiza un contacto en la agenda del dispositivo. Además de `name`, `phone` y `email`, al escribir se aceptan `landlinephone` (teléfono fijo), `workphone` (teléfono de trabajo), `company` (empresa) y `job` (puesto). El **borrado de contactos no está soportado**.

#### Sistema de Escalado, Resoluciones y Tamaños de UI

**Como funciona `resolution-width` y `resolution-height`**

Estos atributos definen la resolución del dispositivo físico con el que se diseña y prueba la app. No son valores fijos — deben coincidir exactamente con la resolución real del dispositivo de referencia usado en el desarrollo.

Cuando la app se ejecuta en un dispositivo con distinta resolución, XOne escala automáticamente todos los tamaños con esta formula:

```
tamaño_real_px = valor_p × (resolucion_real_dispositivo / resolution-width)
```

**Valores típicos según dispositivo de referencia:**

| Dispositivo de referencia | `resolution-width` | `resolution-height` |
|--------------------------|-------------------|---------------------|
| HDPI Compact             | `"480"`           | `"800"`             |
| XHDPI Standard           | `"720"`           | `"1280"`            |
| XXHDPI Classic (emulador XOneStudio por defecto) | `"1080"` | `"1920"`            |
| Dispositivo típico actual | `"1080"`          | `"1920"`            |
| XXXHDPI Premium          | `"1440"`          | `"2560"`            |

> **CRITICO:** Si `resolution-width` no coincide con la resolución del dispositivo con el que se diseña, todos los elementos quedaran desproporcionados. El emulador de XOneStudio usa `1080x1920` por defecto — si el dispositivo físico real es distinto (por ejemplo `1080x2220`), hay que cambiar estos valores en `app.xml`.

**La unidad `p` (pixel en el dispositivo de referencia)**

Todas las dimensiones en XOne se expresan en `p`. En el dispositivo de referencia (`resolution-width` × `resolution-height`) **`1p = 1px` real**. En cualquier otro dispositivo XOne aplica el escalado automáticamente con la fórmula del bloque anterior.

> **CRÍTICO: `p` ≠ Material `dp`.** Es un error común — y conduce a barras/botones ~3× más pequeños de lo necesario en 1080×1920. Material `56dp` (toolbar estándar) **NO** es `56p`: en xxhdpi (1080×1920, density 3×) son **~168p** (workflow estándar: 164p). Si vienes de Material Design, multiplica los `dp` por **~3** para obtener el valor `p` correcto en 1080×1920.

```xml
<!-- Correcto: siempre usar p o % -->
<frame name="frmTopBar" width="100%" height="164p" />
<prop name="MAP_BTN" width="60%" height="124p" />

<!-- Incorrecto: NUNCA usar px, em, rem, dp. Tampoco asumir que p = Material dp -->
```

**Tabla de tamaños estándar** (para `resolution-width="1080"` / `resolution-height="1920"`)

Los siguientes valores funcionan correctamente en proyectos reales diseñados para este dispositivo. Si se usa otra resolución de referencia, escalar proporcionalmente con la formula.

| Elemento | `height` | `width` | Notas |
|----------|----------|---------|-------|
| TopBar / BottomBar | `164p` | `100%` | Barra de título superior o inferior |
| Header fijo completo (topBar + tabs) | `404p` | `100%` | Topbar + barra de estado + pestañas |
| Botón de acción principal (pill) | `124p` | `43–60%` | "Aceptar", "Guardar", "Iniciar viaje" |
| Botón principal ancho completo | `124p` | `92%` | Botón único centrado en footer |
| Botón de pestaña / tab | `144p` | `33–50%` | Pestañas tipo "Activa", "Mis OTs" |
| Campo de texto editable `type="T"` | `144p` | `80–92%` | Campos de formulario estándar |
| Label `type="L"` estándar | `96p` | `100%` | Etiquetas de sección |
| Icono de navegación `type="B"` | `104p` | `104p` | Botones con icono cuadrado en topbar |
| Icono de acción grande | `150p` | `150p` | Camara, galería, adjuntar |
| Modal / popup | `-2` (alto dinámico) | `840p` | Dialogo centrado (~78% del ancho) |
| Separador fino | `4p` | `100%` | Linea divisoria entre secciones |
| Separador medio | `8p` | `100%` | Indicador de pestaña activa |
| Margen entre elementos `tmargin` | `30p` | — | Espacio entre elementos del mismo bloque |
| Margen entre bloques `tmargin` | `50p` | — | Espacio entre secciones distintas |
| Margen lateral contenido `lmargin` | `50p` | — | Sangria del contenido respecto al borde |

**Sistema de fuentes**

El tamaño de fuente se controla con `fontsize` en el prop, o idealmente via clases CSS para reutilizarlo en todo el proyecto. El nombre de la fuente puede ser cualquier tipografía incluida en el proyecto (`Roboto`, `OpenSans`, etc.) — el fichero `.ttf` o `.otf` debe estar en la carpeta `fonts/` del proyecto.

```css
/* Definición en CSS — lo mas recomendable */
.font5  { fontsize: 5;  text-fontsize: 5;  labelfontsize: 5;  label-fontsize: 5;  }
.font7  { fontsize: 7;  text-fontsize: 7;  labelfontsize: 7;  label-fontsize: 7;  }
.font10 { fontsize: 10; text-fontsize: 10; labelfontsize: 10; label-fontsize: 10; }
.font-bold    { fontname: Roboto-Bold; }
.font-regular { fontname: Roboto-Regular; }
```

```xml
<!-- Uso en el prop via clase CSS — recomendado -->
<prop name="MAP_TITULO" type="L" class="font7 font-bold" />

<!-- También valido: fontsize directamente en el prop -->
<prop name="MAP_TITULO" type="L" fontsize="7" />
```

| Rango | Uso típico |
|-------|------------|
| `fontsize` 1–2 | Textos mínimos, contadores, notas |
| `fontsize` 3–4 | Textos secundarios, metadatos, fechas |
| `fontsize` 5 | Texto estándar de campos y labels — **el más usado** |
| `fontsize` 6–7 | Títulos de sección, pestañas, números destacados |
| `fontsize` 8–9 | Títulos de tarjeta, subtítulos de pantalla |
| `fontsize` 10–11 | Títulos de topbar, cabeceras de modal |
| `fontsize` 12 | Títulos grandes, nombre de la app |

#### Ejemplo Real: Proyecto UseCars

Este es el `app.xml` del proyecto de ejemplo UseCars (tipo Uber):

```xml
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xml>
    <app
        prefix="gen"
        version="1.0.0"
        debug="true"
        autologon="false"
        screen-orientation="portrait"
        resolution-width="1080"
        resolution-height="1920"
        scale-fontsize="true"
        android-font-factor="7"
        ios-font-factor="7"
        default-language="javascript"
        application-notification-title="UseCars"
        application-max-priority="true">

        <entry-point>
            <item name="EntradaApp" conditions="" />
        </entry-point>

        <login-coll>
            <item name="Login" conditions="" />
        </login-coll>

        <!-- Se pueden incluir multiples archivos CSS -->
        <style url="default.css" encoding="UTF-8" />
        <style url="colors.css" encoding="UTF-8" />

        <!-- Se pueden incluir multiples archivos JS -->
        <include file="functions.js" language="javascript" encoding="UTF-8"/>
        <include file="viajes.js" language="javascript" encoding="UTF-8"/>
        <include file="ubicacion.js" language="javascript" encoding="UTF-8"/>
    </app>
</xml>
```

> **Tip:** Puedes incluir multiples archivos CSS y JS. Es una buena práctica separar estilos por tema (colores, layout) y scripts por funcionalidad (login, negocio, utilidades).

### 4.2 app.ini

El archivo `app.ini` contiene los metadatos básicos de la aplicación en formato INI (clave=valor). Es más simple que `app.xml` pero igualmente necesario.

```ini
Name=MiProyecto
Title=Mi Proyecto XOne
Caption=Descripción corta de la aplicacion
Icon=app_icon.png
IconFolder=icons
FilesFolder=files
HideSplash=false
```

#### Campos Explicados

| Campo | Descripción | Obligatorio |
|-------|-------------|-------------|
| `Name` | Nombre interno del proyecto (sin espacios ni caracteres especiales) | Si |
| `Title` | Título visible de la aplicación | Recomendado |
| `Caption` | Subtítulo o descripción corta | Opcional |
| `Icon` | Nombre del archivo del icono de la app (debe estar en `icons/`) | Recomendado |
| `IconFolder` | Carpeta de iconos. **Siempre `icons`** | Si |
| `FilesFolder` | Carpeta de archivos dinámicos. **Siempre `files`** | Si |
| `HideSplash` | Si es `true`, no muestra la pantalla de carga | Opcional |

#### Ejemplo Real: Proyecto UseCars

```ini
Name=UseCars
Title=UseCars
Caption=Tu viaje, a un toque de distancia
Icon=app_icon.png
IconFolder=icons
FilesFolder=files
HideSplash=false
```

### 4.3 mappings.xne

El archivo `mappings.xne` es uno de los más importantes y, al mismo tiempo, uno de los que más errores genera en principiantes. Su proposito es **definir exclusivamente las colecciones base del sistema**: `Empresas` y `Usuarios`.

#### Regla Fundamental

> **IMPORTANTE:** El archivo `mappings.xne` SOLO debe contener las colecciones `Empresas` y `Usuarios`. NUNCA pongas otras colecciones aquí. Las colecciones adicionales (Productos, Pedidos, Tareas, etc.) van en archivos `.xne` separados.

#### Por que solo Empresas y Usuarios?

Estas dos colecciones son especiales porque:
- Son necesarias para el sistema de autenticación y login
- Son requeridas por el motor de sincronización/replica
- El framework las busca automáticamente en `mappings.xne`
- Definen la estructura organizativa básica (empresa -> usuarios)

#### Campos Obligatorios

**Coleccion Empresas:**

| Campo | Tipo | Visible | Descripción |
|-------|------|---------|-------------|
| `CODIGO` | `N` | `7` | Identificador numérico de la empresa |
| `NOMBRE` | `T` | `7` | Nombre de la empresa (fieldsize="150") |

**Coleccion Usuarios:**

| Campo | Tipo | Visible | Descripción                                                                                                               |
|-------|------|---------|---------------------------------------------------------------------------------------------------------------------------|
| `CODIGO` | `N` | `7` | Identificador numérico del usuario                                                                                        |
| `NOMBRE` | `T` | `7` | Nombre del usuario (fieldsize="100")                                                                                      |
| `IDEMPRESA` | `N` | `7` | Relación con la empresa (mapcol="Empresas")                                                                               |
| `LOGIN` | `T` | `7` | Nombre de usuario para login (fieldsize="50")                                                                             |
| `PWD` | `X` | `0` | Contrasena (tipo X = enmascarado, fieldsize="100"). El nombre del campo DEBE ser `PWD` — El framework lo lee literalmente |

> **No hace falta declarar `ID` ni `ROWID` como `<prop>`** (ni aquí ni en ninguna coll): son columnas de plataforma que XOne gestiona automáticamente — el `ID` es la clave autonumérica y el `ROWID` el GUID de 32 hex de sincronización que el framework autogenera en cada alta. Declararlas es válido pero redundante (mejor omitirlas por limpieza). En el `sql=` de la coll, el `ID` sí se rescata en el SELECT; el `ROWID` no es necesario.

#### Ejemplo Completo con Explicaciones

```xml
<?xml version="1.0" encoding="utf-8"?>
<xml>
    <!--
        Cabecera del mappings.xne
        El atributo prefix DEBE coincidir con el de app.xml
    -->
    <app prefix="gen" version="1.0.0" debug="true" default-language="javascript">
        <style url="default.css" />
    </app>

    <!--
        collprops type="general" envuelve todas las colecciones
        definidas en este archivo
    -->
    <collprops type="general">

        <!--
            COLECCION: Empresas
            - Define las empresas/organizaciones del sistema
            - sql: usa ##PREF## para insertar el prefijo automaticamente
            - objname: nombre de la tabla en BD (genera gen_Empresas)
            - updateobj: nombre del objeto para operaciones de escritura
            - loadall: carga todos los registros al abrir
        -->
        <coll name="Empresas"
              sql="SELECT * FROM ##PREF##Empresas"
              objname="Empresas"
              updateobj="Empresas"
              loadall="true">
            <group name="General" id="1">
                <!--
                    ID y ROWID los gestiona el framework: no hace falta declararlos como <prop>
                    (declararlos es válido pero redundante).
                    - ID: clave autonumérica de la tabla
                    - ROWID: GUID de 32 caracteres hex de sincronización/replica que el
                      framework autogenera en cada alta (ej: "a1b2c3d4e5f6789012345678abcdef12")
                -->

                <!-- === CAMPOS OBLIGATORIOS === -->
                <prop name="CODIGO" type="N" visible="7" />
                <prop name="NOMBRE" type="T" visible="7" fieldsize="150" />

                <!-- === CAMPOS OPCIONALES (según necesidades) === -->
                <prop name="CIF" type="T" visible="7" fieldsize="20" />
                <prop name="DIRECCION" type="T" visible="7" fieldsize="255" />
                <prop name="TELEFONO" type="T" visible="7" fieldsize="20" />
                <prop name="EMAIL" type="T" visible="7" fieldsize="150" />
                <prop name="ACTIVO" type="NC" visible="7" />
            </group>
        </coll>

        <!--
            COLECCION: Usuarios
            - Define los usuarios que pueden hacer login
            - Tiene relacion con Empresas via IDEMPRESA
        -->
        <coll name="Usuarios"
              sql="SELECT * FROM ##PREF##Usuarios"
              objname="Usuarios"
              updateobj="Usuarios"
              loadall="true">
            <group name="General" id="1">

                <!-- === CAMPOS OBLIGATORIOS === -->
                <prop name="CODIGO" type="N" visible="7" />
                <prop name="NOMBRE" type="T" visible="7" fieldsize="100" />
                <!--
                    IDEMPRESA: Relacion con la tabla Empresas
                    - mapcol="Empresas" indica la coleccion relacionada
                    - mapfld="ID" indica el campo de enlace
                -->
                <prop name="IDEMPRESA" type="N" visible="7"
                      mapcol="Empresas" mapfld="ID" />
                <prop name="LOGIN" type="T" visible="7" fieldsize="50" />
                <!--
                    PWD: Tipo X para campos de contraseña
                    - El nombre DEBE ser "PWD" — El framework lo lee literalmente
                    - visible="0" para que no se muestre en listas
                    - El tipo X enmascara el contenido con asteriscos
                -->
                <prop name="PWD" type="X" visible="0" fieldsize="100" />

                <!-- === CAMPOS OPCIONALES === -->
                <prop name="EMAIL" type="T" visible="7" fieldsize="150" />
                <prop name="TELEFONO" type="T" visible="7" fieldsize="20" />
                <prop name="ROL" type="T" visible="7" fieldsize="20" />
                <prop name="ACTIVO" type="NC" visible="7" />
            </group>
        </coll>

        <!--
            OTRAS COLECCIONES: En archivos .xne separados
            NO agregarlas aquí. Cada una va en su propio archivo:
            - Productos.xne
            - Pedidos.xne
            - Clientes.xne
            - etc.
        -->

    </collprops>
</xml>
```

#### Que pasa con las demas colecciones?

Cada coleccion adicional se define en su propio archivo `.xne`. Por ejemplo, `Tareas.xne`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<!--
    Coleccion: Tareas
    Descripción: Almacena las tareas del sistema
-->
<coll name="Tareas"
      sql="SELECT * FROM ##PREF##Tareas"
      objname="Tareas"
      updateobj="Tareas"
      loadall="true">
    <group name="General" id="1">
        <prop name="TITULO" type="T" visible="7" fieldsize="200" />
        <prop name="DESCRIPCION" type="T" visible="7" fieldsize="500" />
        <prop name="ESTADO" type="T" visible="7" fieldsize="20" />
        <prop name="PRIORIDAD" type="N" visible="7" />
        <prop name="FECHA_CREACION" type="DT" visible="7" />
        <prop name="FECHA_LIMITE" type="D" visible="7" />
    </group>
</coll>
```

> Para profundizar en la definición de colecciones y la estructura XML completa, consulta el tópico [02 - Estructura XML y Colecciones](./02-xml-ui-complete-guide.md).

---

## 5. Tipos de Archivos en XOne

XOne utiliza varios tipos de archivos, cada uno con un proposito especifico:

| Extensión | Tipo | Proposito | Equivalente Web |
|-----------|------|-----------|-----------------|
| `.xne` | XML propietario | Definición de colecciones y pantallas | `.html` + `.json` (schema) |
| `.css` | CSS propietario | Estilos visuales (NO es CSS web estándar) | `.css` (con diferencias importantes) |
| `.js` | JavaScript | Lógica de negocio y funciones | `.js` (API diferente) |
| `.xml` | XML estándar | Configuración (`app.xml`) | Archivos de configuración |
| `.ini` | Texto plano | Metadatos (`app.ini`) | `.env` / `manifest.json` |
| `.db` | SQLite | Base de datos local | Base de datos del backend |

### Archivos .xne (fuente) vs .xml (generado por XOneStudio)

En XOne hay una distincion fundamental entre **fuente** y **salida generada**:

| Extensión | Rol | Quien lo edita |
|-----------|-----|----------------|
| `.xne` | **Fichero fuente** de colecciones y pantallas | El programador (y la IA) — es lo único que se edita |
| `.xml` (de colecciones/pantallas) | **Artefacto generado automáticamente** por XOneStudio a partir del `.xne` correspondiente | **Nadie** — se regenera solo |
| `app.xml` | Configuración global de la aplicación (única excepción) | El programador — es fuente, no tiene `.xne` que lo genere |

Los archivos `.xne` son el corazón de XOne. Aunque tienen contenido XML, usan la extensión `.xne` (XOne Native Extensión). Un mismo archivo `.xne` puede definir:

- **Una coleccion de datos** (como una tabla de BD con sus campos)
- **Una pantalla** (con su layout, botones y lógica)
- **Ambas cosas a la vez** (coleccion + presentación visual)

#### Por que existen los `.xml` de colecciones

XOneStudio genera automáticamente un `.xml` por cada `.xne` porque **algunos motores de ejecución del framework todavia leen `.xml`**. No son ficheros legacy ni restos de proyectos antiguos: se generan hoy, en proyectos nuevos, como artefacto de build. El plan de futuro es que desaparezcan y todo quede solo en `.xne`.

#### Regla operativa: solo `.xne`

> **Al trabajar sobre un proyecto XOne (nuevo o existente), solo se tocan los ficheros `.xne`. Los `.xml` de colecciones o pantallas que aparezcan se ignoran por completo: no se leen, no se editan, no se consultan, no se crean. La única excepción es `app.xml` (configuración global), que SI es fuente.**

Esto aplica tanto si el proyecto tiene solo `.xne` como si tiene `.xne` y `.xml` conviviendo. La coexistencia es normal hoy en día; el trabajo con IA se comporta como si los `.xml` (excepto `app.xml`) no existieran.

### Archivos .css (Estilos Propietarios)

El CSS de XOne se parece al CSS web pero tiene diferencias cruciales:

| Caracteristica | CSS Web | CSS XOne |
|---------------|---------|----------|
| Unidades de medida | `px`, `em`, `rem`, `vw` | `p` (puntos), `%` (porcentaje) |
| Selectores | `#id`, `.clase`, `tag`, `[attr]` | `coll`, `prop`, `prop:TYPE`, `.clase` |
| Herencia | `inherit`, cascada natural | `extends:.otraClase` |
| Colores | `#RGB`, `rgb()`, `hsl()`, nombres | `#RRGGBB`, `#AARRGGBB` |
| Modelo de caja | `box-sizing`, `margin`, `padding` | `tmargin`, `bmargin`, `lmargin`, `rmargin` |

> Para la referencia completa de atributos CSS, consulta el tópico [04 - Estilos CSS en XOne](./04-css-styling-guide.md).

### Archivos .js (JavaScript)

El JavaScript de XOne usa un motor propio con APIs específicas:

```javascript
// Esto NO funciona en XOne (APIs del DOM):
document.getElementById("miCampo");     // NO existe
window.addEventListener("click", fn);   // NO existe
localStorage.setItem("key", "val");     // NO existe

// Esto SÍ funciona en XOne (APIs propias):
self.MAP_CAMPO;                         // Acceder a un campo
ui.showToast("Mensaje");                // Mostrar notificación
appData.getCollection("Tareas");        // Obtener coleccion
$http.get(url, request, ok, err);       // Petición HTTP (forma idiomática)

// Esto también funciona (implementación custom XOne, compatible con spec):
fetch("https://api.com/datos").then(r => r.json());       // sí existe
new Promise((resolve, reject) => { resolve(42); });        // sí existe (ES2024)
setTimeout(() => console.log("hola"), 1000);               // sí existe
class Tarea { constructor(t) { this.titulo = t; } }       // sí existe
```

> Para la referencia completa de la API JavaScript, consulta el tópico [03 - API JavaScript](./03-javascript-api-guide.md).

---

## 6. Conceptos Clave

### 6.1 Colecciones

Una **coleccion** en XOne es el concepto más fundamental. Combina tres roles que en desarrollo web suelen estar separados:

1. **Tabla de base de datos**: Define la estructura de datos (campos, tipos)
2. **Pantalla/Vista**: Define como se presenta la información al usuario
3. **Formulario**: Define como el usuario interactua con los datos

#### Tipos de Colecciones

| Tipo | Tiene tabla en BD? | Uso típico | Ejemplo |
|------|-------------------|------------|---------|
| **Con datos** (SQL) | Si | Almacenar registros persistentes | `Tareas`, `Clientes`, `Productos` |
| **Especial** (sin tabla) | No | Pantallas de menu, entrada, login | `EntradaApp`, `MenuPrincipal` |
| **Dependiente** | Depende del padre | Datos hijos de otra coleccion | `LineasPedido` (dentro de `Pedidos`) |

#### Coleccion con datos (persistente)

Se identifica porque tiene los atributos `sql` y `objname`:

```xml
<coll name="Clientes"
      sql="SELECT * FROM ##PREF##Clientes"
      objname="Clientes"
      updateobj="Clientes"
      loadall="true">
    <!-- Esta coleccion TIENE tabla en la BD: gen_Clientes -->
</coll>
```

El atributo `objname` es la clave: le dice a XOne que esta coleccion necesita una tabla en la base de datos. Sin `objname`, la coleccion solo existe en memoria.

#### Coleccion especial (sin tabla)

Se identifica porque tiene `special="true"` y NO tiene `objname`:

```xml
<coll name="EntradaApp" title="Bienvenido"
      special="true" notab="true" show-toolbar="false">
    <!-- Esta coleccion NO tiene tabla, es solo una pantalla -->
</coll>
```

#### Colecciones base vs colecciones adicionales

| Aspecto | Colecciones Base | Colecciones Adicionales |
|---------|-----------------|----------------------|
| **Cuales son** | `Empresas`, `Usuarios` | Todas las demas |
| **Donde se definen** | `mappings.xne` | Archivos `.xne` separados |
| **Son obligatorias?** | Si, siempre | Solo las que necesite el proyecto |
| **Campos obligatorios** | Si (ver sección 4.3) | Los que defina el desarrollador |

#### Herencia entre colecciones (`inherits`)

Una coleccion puede heredar la estructura (grupos, frames, props y eventos) de otra usando el atributo `inherits` en el nodo `<coll>`. La hija sobrescribe los elementos del padre que tengan el mismo `name`, y conserva el resto.

```xml
<coll name="groupsFixed" special="true">
    <!-- Header y footer comunes... -->
</coll>

<coll name="PantallaX" inherits="groupsFixed" special="true">
    <!-- Hereda todo de groupsFixed y añade lo propio -->
</coll>
```

Uso típico: scaffolding visual compartido (header/footer/navegación) definido una sola vez en una coll `special="true"` y reutilizado por todas las pantallas que lo necesiten. Soporta cadenas (A → B → C) pero NO herencia multiple. Para la referencia completa y `<include-layout>`, ver [topics/02d-xml-layouts-herencia.md, sección 10](./02d-xml-layouts-herencia.md#10-herencia-entre-colecciones-y-composicion-xml).

### 6.2 Objetos de Datos (DataObject)

Un **DataObject** (u "objeto de datos") es una instancia individual de una coleccion. Si la coleccion es una tabla, el DataObject es una fila.

#### Acceso al objeto actual: `self`

Dentro de cualquier script de una coleccion, `self` referencia al DataObject actual:

```javascript
// Leer un campo del objeto actual
let nombre = self.NOMBRE;
let codigo = self.CODIGO;

// Escribir un campo
self.NOMBRE = "Nuevo nombre";
self.ESTADO = "COMPLETADO";

// Ambas sintaxis son validas:
let valor1 = self.MAP_CAMPO;      // Notacion punto
let valor2 = self["MAP_CAMPO"];   // Notacion corchetes (util con nombres dinamicos)
```

#### Métodos disponibles del DataObject

```javascript
// Guardar cambios en la BD
self.save();

// Obtener la coleccion propietaria
let coll = self.getOwnerCollection();
let nombreColl = coll.getName();

// Obtener contenidos embebidos (colecciones hijas)
let comentarios = self.getContents("@Comentarios");

// Cargar datos desde JSON
self.loadFromJson('{"NOMBRE": "Test", "CODIGO": 1}');

// Exportar a JSON
let jsonObj = self.toJson();
let jsonStr = self.toJsonString();
```

#### Concepto de Campos MAP_

El prefijo `MAP_` es una **señal al framework** que indica: *"este prop NO es una columna de la tabla BD, no intentes persistirlo"*. Cuando el framework lee un `<prop>` cuyo `name` empieza por `MAP_`, lo excluye de los `INSERT` y `UPDATE` que se generan contra la tabla apuntada por `objname`. Por eso **`MAP_loquesea` no existe ni debe existir como columna en la base de datos**.

**Regla de oro:** Si el valor del prop NO proviene de una columna de la tabla de `objname`, su `name` **debe empezar por `MAP_`**.

##### Los tres casos en los que se usa MAP_

**Caso 1 — Campos que vienen de un JOIN en el SQL de la coll**

Cuando la coleccion hace un `LEFT JOIN` a otra tabla para mostrar una descripción, el alias del campo enlazado debe empezar por `MAP_`:

```xml
<coll name="Pedidos"
      sql="SELECT t1.*,
           c.NOMBRE AS MAP_NOMBRECLIENTE,
           c.TELEFONO AS MAP_TELEFONOCLIENTE
           FROM ##PREF##Pedidos t1
           LEFT OUTER JOIN ##PREF##Clientes c ON t1.IDCLIENTE=c.ID"
      objname="pedidos"
      updateobj="pedidos"
      progid="ASData.CASBasicDataObj">

    <group name="General" id="1">
        <!-- FK normal: SI es columna de la tabla Pedidos -->
        <prop name="IDCLIENTE" type="N" visible="7" mapcol="Clientes" mapfld="ID" />

        <!-- Campos del JOIN: NO son columnas de Pedidos, llevan MAP_ -->
        <prop name="MAP_NOMBRECLIENTE"   type="T" visible="7" locked="true" fieldsize="150" />
        <prop name="MAP_TELEFONOCLIENTE" type="T" visible="7" locked="true" fieldsize="20" />
    </group>
</coll>
```

**Caso 2 — Campos enlazados via `linkedto` (combos/lookups)**

El patron combo en XOne usa dos props: uno oculto que guarda el ID (es columna BD, sin `MAP_`) y otro visible que muestra la descripción obtenida del lookup (no es columna BD, lleva `MAP_`):

```xml
<!-- Prop oculto: guarda el ID del tipo. SI es columna de la tabla -->
<prop name="IDTIPO" type="N" visible="0"
      mapcol="TiposProducto" mapfld="ID" />

<!-- Prop visible: muestra la descripción obtenida del lookup. NO es columna -->
<prop name="MAP_TIPO_DESC" type="T" visible="1"
      title="Tipo de producto"
      linkedto="IDTIPO"
      linkedfield="DESCRIPCION"
      showinline="true" />
```

**Caso 3 — Props puramente visuales (sin origen de datos)**

Cualquier prop que no representa un dato guardable también debe llevar `MAP_`: etiquetas, botones, valores calculados en runtime, estados de UI, buscadores temporales, imágenes decorativas, etc.

| Uso | Ejemplo | Tipo típico |
|-----|---------|-------------|
| Etiquetas / títulos | `MAP_TITULO`, `MAP_SUBTITULO` | `L` (alias legacy: `TL`) |
| Botones | `MAP_BTN_GUARDAR`, `MAP_BTN_CANCELAR` | `B` |
| Valores calculados | `MAP_TOTAL`, `MAP_SUBTOTAL_IVA` | `N2`, `F` |
| Estados de UI | `MAP_TAB`, `MAP_MODO`, `MAP_SELECCIONADO` | `T`, `N`, `NC` |
| Buscadores / filtros | `MAP_BUSQUEDA`, `MAP_FILTRO` | `T` |
| Imágenes decorativas | `MAP_LOGO` | `IMG` |
| Callbacks / objetos JS | `MAP_CALLBACK` | `O` |

```xml
<!-- Etiqueta (no se guarda) -->
<prop name="MAP_TITULO" type="L" title="Gestion de Pedidos" class="textoTitulo" />

<!-- Botón (no se guarda) -->
<prop name="MAP_BTN_GUARDAR" type="B" visible="1" title="Guardar"
      method="executenode(guardar)" />

<!-- Total calculado en runtime (no se guarda) -->
<prop name="MAP_TOTAL" type="N2" visible="1" locked="true" title="Total" />

<!-- Buscador temporal (no se guarda) -->
<prop name="MAP_BUSQUEDA" type="T" visible="1" title="Buscar" onchange="Refresh" />
```

##### Mecanismo interno y consecuencias

- El framework **excluye** los `MAP_*` de los `INSERT` y `UPDATE` contra `objname`.
- El valor vive **solo en memoria** dentro del DataObject (`self`), durante la vida de la pantalla.
- Se lee y escribe normalmente desde JavaScript: `self.MAP_CAMPO`, `self["MAP_CAMPO"]` o `self.getValue("MAP_CAMPO")`.
- Se puede referenciar en `disablevisible`, en macros de CSS/XML (`##FLD_MAP_xxx##`), y como destino de `ui.refresh("MAP_xxx")`.
- Los `MAP_` **no son de solo lectura**: se les puede asignar valor desde JS, desde `<action name="setval">`, desde un `linkedto`, etc. El `locked="true"` de los ejemplos es una decisión de UI, no una consecuencia de ser MAP_.

##### Comparativa: con y sin MAP_

```xml
<!-- Este campo SI se guarda en BD (es columna de la tabla) -->
<prop name="NOMBRE" type="T" visible="7" fieldsize="100" />

<!-- Este campo NO se guarda en BD (prefijo MAP_ -> el framework lo excluye) -->
<prop name="MAP_BTN_EDITAR" type="B" visible="7" title="Editar" />
```

##### Anti-patrones (errores típicos)

| Error | Consecuencia |
|-------|--------------|
| Poner `MAP_` a un campo que SI esta en la tabla BD | El framework no lo persiste: el dato se pierde al guardar |
| Omitir `MAP_` en un alias de JOIN | El framework intenta hacer UPDATE de esa columna: error SQL porque no existe |
| Omitir `MAP_` en el prop visible de un combo con `linkedto` | El framework intenta guardar la descripción como columna: error SQL |
| Poner `MAP_` a una etiqueta `L`/`TL` que se conecta a un campo BD | La etiqueta no refleja el dato persistido correctamente |
| Declarar una columna `MAP_LOQUESEA` en la tabla SQL | No se usa nunca: el framework nunca escribe en ella |

### 6.3 Propiedades (Props)

Las propiedades (`<prop>`) son el elemento fundamental de XOne. Tienen un **rol dual**:

1. **Campo de datos**: Define un dato (nombre, tipo, tamaño)
2. **Elemento visual**: Define como se ve y se interactua con ese dato

#### Sistema de Tipos

Cada propiedad tiene un `type` que determina tanto el tipo de dato como el control visual:

| Type | Nombre | Dato | Control Visual | Ejemplo |
|------|--------|------|---------------|---------|
| `T` | Texto | String | Campo de texto editable | Nombres, descripciones |
| `L` | Texto Label | String | Texto de solo lectura — forma preferida. Sin `title`, muestra el valor del campo | Títulos, etiquetas |
| `TL` | Texto Label (alias legacy) | String | Alias legacy de `L`: mismo control. | Equivalente a `L` |
| `N` | Numérico | Integer | Campo numérico | IDs, cantidades |
| `N2` | Numérico 2 dec | Real (2 decimales) | Campo decimal | Precios, porcentajes |
| `N6` | Numérico 6 dec | Real (6 decimales) | Campo decimal preciso | Coordenadas GPS |
| `B` | Botón | No persiste | Botón de acción | Guardar, Cancelar |
| `IMG` | Imagen | Ruta (String) | Visor/captura de imagen | Fotos, logos |
| `NC` | Checkbox | Integer (0/1) | Toggle/checkbox | Activo si/no |
| `D` | Fecha | String (fecha) | Selector de fecha | Fecha nacimiento |
| `DT` | Fecha/Hora | String (datetime) | Selector fecha + hora | Timestamps |
| `X` | Password | String | Campo enmascarado | Contrasenas |
| `Z` | Zona/Content | No persiste | Lista embebida | Listas dentro de pantalla |
| `DR` | Firma/Dibujo | Ruta (String) | Canvas de firma o dibujo libre | Firma digital |

> Para la tabla completa de tipos y sus variantes, consulta [02 - Estructura XML y Colecciones](./02-xml-ui-complete-guide.md).

#### Bitmask de Visibilidad

El atributo `visible` usa un **mapa de bits** para controlar donde se muestra cada propiedad:

| Valor | Significado | Cuando se usa |
|-------|-------------|---------------|
| `0` | Oculto | Campos internos, IDs, ROWIDs |
| `1` | Solo en modo edición | Campos que solo se ven al editar un registro |
| `2` | Solo en modo lista | Campos que solo se ven en el listado |
| `4` | Solo en contents | Campos visibles dentro de listas embebidas |
| `7` | Visible en todos los modos | Campos que siempre deben mostrarse (1+2+4=7) |

**Ejemplo práctico:**

```xml
<!-- Oculto: el usuario nunca lo ve, pero se usa internamente -->

<!-- Solo visible al editar un registro individual -->
<prop name="DESCRIPCION_DETALLADA" type="T" visible="1" />

<!-- Solo visible en la lista de registros -->
<prop name="RESUMEN" type="L" visible="2" />

<!-- Visible en todos los contextos -->
<prop name="NOMBRE" type="T" visible="7" />
```

#### Visibilidad Condicional

Además del bitmask estático, se puede controlar la visibilidad de forma dinámica con `disablevisible`:

```xml
<!-- Se oculta si MAP_TIPO es igual a 0 -->
<prop name="MAP_CAMPO_EXTRA" type="T"
      disablevisible="MAP_TIPO=0" />

<!-- Se oculta si MAP_MODO es vacio -->
<frame name="frmAvanzado"
       disablevisible="MAP_MODO=''" >
    <!-- Contenido avanzado -->
</frame>
```

### 6.4 Prefix PREF

El **prefijo** es un concepto fundamental en XOne que conecta las colecciones con las tablas de la base de datos.

#### Que es?

El prefijo (configurado en `app.xml` con el atributo `prefix`) se antepone al nombre de cada tabla en la base de datos. Por defecto, el prefijo es `"gen"`.

#### Como funciona?

```
prefix = "gen"
+
objname = "Tareas"
=
Tabla en BD: gen_Tareas
```

#### La macro ##PREF##

En las consultas SQL de las colecciones, se usa la macro `##PREF##` para que el sistema inserte automáticamente el prefijo con el guion bajo:

```xml
<!-- Esto: -->
<coll name="Tareas" sql="SELECT * FROM ##PREF##Tareas" ...>

<!-- Se convierte en tiempo de ejecución en: -->
<!-- SELECT * FROM gen_Tareas -->
```

#### Por que usar ##PREF## en vez de escribir "gen_" directamente?

Porque el prefijo puede cambiar entre proyectos. Si un cliente tiene prefijo `"inv"`, la misma consulta generara:

```
SELECT * FROM inv_Tareas
```

Sin necesidad de modificar ningun archivo `.xne`.

> **Error común:** Olvidar `##PREF##` en las consultas SQL. Si escribes `SELECT * FROM Tareas`, la consulta fallara porque la tabla real se llama `gen_Tareas`.

### 6.5 Macros del Sistema

XOne proporciona macros que se resuelven en tiempo de ejecución. Se identifican por estar entre dobles `##`:

#### Macros de Base de Datos

| Macro | Descripción | Ejemplo de uso |
|-------|-------------|----------------|
| `##PREF##` | Prefijo de tablas + guion bajo | `sql="SELECT * FROM ##PREF##Tareas"` |
| `##ENTID##` | ID de la empresa actual | `filter="IDEMPRESA=##ENTID##"` |
| `##USERID##` | ID del usuario logueado | `filter="ID_USUARIO=##USERID##"` |

#### Macros de Aplicación

| Macro | Descripción | Ejemplo de uso |
|-------|-------------|----------------|
| `##VERSION##` | Versión de la app (definida en `<app versión="...">`) | `title="Versión ##VERSION##"` |
| `##FRAME_VERSION##` | Versión del framework XOne | `title="Framework ##FRAME_VERSION##"` |
| `##APP##` | Ruta de la carpeta de la aplicación en el dispositivo | `path="##APP##\icons\imagen.png"` |
| `##LOGIN_LASTUSER##` | Último usuario que hizo login | Pre-rellenar campo de login |

#### Macros de Dispositivo

| Macro | Descripción | Ejemplo de uso |
|-------|-------------|----------------|
| `##DEVICEID##` | Identificador único del dispositivo | `filter="DEVICE=##DEVICEID##"` |
| `##DEVICE_MODEL##` | Modelo del dispositivo | `title="Modelo: ##DEVICE_MODEL##"` |
| `##DEVICE_OS##` | Sistema operativo del dispositivo (`"android"` o `"ios"`) | `value="MyApp_##DEVICE_OS##"` |

Las macros de dispositivo se pueden leer también desde JavaScript:

```javascript
var so = appData.getGlobalMacro("##DEVICE_OS##");
var deviceId = appData.getGlobalMacro("##DEVICEID##");
var modelo = appData.getGlobalMacro("##DEVICE_MODEL##");
```

#### Cerrar pantalla / cerrar aplicación

Formas correctas desde JavaScript:

```javascript
// Cerrar la pantalla actual y volver a la anterior
ui.getView(self).exit();

// Cerrar completamente la aplicación
appData.exit();
```

**Nota sobre código heredado:** En proyectos antiguos puede aparecer el patrón `appData.failWithMessage(-11888, "##EXIT##")` (con la macro `##EXIT##` y el código `-11888`) para cerrar la pantalla. Sigue funcionando, pero la forma preferida es `ui.getView(self).exit()`.

#### Macros de Fecha/Hora

| Macro | Descripción | Formato |
|-------|-------------|---------|
| `##NOW##` | Fecha y hora actual del sistema | Depende de la configuración |
| `##NOW_DATE##` | Fecha actual | `dd/MM/yyyy` |
| `##NOW_TIME##` | Hora actual | `HH:mm:ss` |

#### Macros de Campo (`##FLD_CAMPO##`)

Las macros `##FLD_CAMPO##` se resuelven al valor actual del campo especificado. Son extremadamente útiles para crear interfaces dinámicas:

| Uso | Descripción | Ejemplo |
|-----|-------------|---------|
| Filtros de contents | Filtrar datos hijos por campo del padre | `filter="ID_PADRE=##FLD_ID##"` |
| Colores dinámicos | Cambiar colores según un campo | `bgcolor="##FLD_MAP_COLOR##"` |
| Textos dinámicos | Mostrar texto variable en atributos | `title="##FLD_MAP_TITULO##"` |
| Imágenes dinámicas | Cambiar imagen según un campo | `img="##FLD_MAP_ICONO##"` |

```xml
<!-- Color de fondo dinámico basado en un campo -->
<prop name="MAP_LABEL" type="L"
      bgcolor="##FLD_MAP_COLOR1##"
      forecolor="##FLD_MAP_COLOR2##" />

<!-- Imagen dinámica basada en un campo -->
<prop name="BTORDENAR" type="B"
      img="##FLD_MAP_BTORDEN##"
      imgsel="##FLD_MAP_BTORDENCLICK##" />

<!-- Filtro de contents con campo del padre -->
<contents name="@Detalles" src="Detalles"
          filter="ID_PADRE=##FLD_ID##" />

<!-- Color dinámico en CSS de frame -->
.frmsuperior {
    bgcolor: ##FLD_MAP_COLORACTIVO##;
}
```

#### Ejemplo de uso combinado de macros

```xml
<!-- Macro en consulta SQL -->
<coll name="MisTareas"
      sql="SELECT * FROM ##PREF##Tareas WHERE ID_USUARIO = ##USERID##">

<!-- Macro en evento create para mostrar version -->
<create>
    <action name="setval" field="MAP_VERSION"
            value="Versión ##VERSION## - Framework ##FRAME_VERSION##" />
</create>

<!-- Macro de campo para color dinámico -->
<prop name="MAP_INDICADOR" type="L"
      bgcolor="##FLD_MAP_COLOR_ESTADO##" />
```

#### Macros de Animación

XOne tiene animaciones predefinidas accesibles via macros. Las más comunes:

| Macro | Efecto |
|-------|--------|
| `##ALPHA_IN##` / `##ALPHA_OUT##` | Aparecer / Desaparecer (fade) |
| `##ZOOM_IN##` / `##ZOOM_OUT##` | Zoom de entrada / salida |
| `##LEFT_IN##` / `##LEFT_OUT##` | Entrar / salir desde la izquierda |
| `##RIGHT_IN##` / `##RIGHT_OUT##` | Entrar / salir desde la derecha |
| `##TOP_IN##` / `##BOTTOM_IN##` | Entrar desde arriba / abajo |
| `##PUSH_IN##` / `##PUSH_OUT##` | Empujar hacia arriba / abajo |
| `##PUSH_DOWN_IN##` / `##PUSH_DOWN_OUT##` | Empujar hacia abajo (entrada / salida) |
| `##SLIDE_DOWN_IN##` / `##SLIDE_UP_OUT##` | Deslizamiento hacia abajo / arriba |

```javascript
// Mostrar grupo 2 con animacion fade
ui.showGroup(2, "##ALPHA_IN##", 200, "##ALPHA_OUT##", 200);
```

```xml
<!-- Animacion en frames -->
<frame name="frmDetalle"
       animation-in="##RIGHT_IN##"
       animation-out="##LEFT_OUT##"
       animation-in-delay="250"
       animation-out-delay="250" />

<!-- Animacion en colecciones especiales -->
<coll name="EspecialMenu" special="true"
      animation-in="##RIGHT_IN##"
      animation-out="##LEFT_OUT##">
```

> Para la lista completa de macros de animación y ejemplos avanzados, consulta [05 - Eventos, Patrones y FAQ](./05-events-patterns-faq.md).

### 6.6 Códigos de Error

XOne utiliza códigos de error numéricos especificos para controlar el flujo de la aplicación. Los dos códigos más importantes son:

| Código | Significado | Uso |
|--------|------------|-----|
| `-8100` | Campos obligatorios faltantes / validación | `appData.failWithMessage(-8100, "mensaje")` |
| `-11888` | Código heredado para cerrar pantalla con la macro `##EXIT##` (forma preferida hoy: `ui.getView(self).exit()`) | `appData.failWithMessage(-11888, "##EXIT##")` |

#### Uso del código -8100 (Validación)

El código `-8100` se usa para interrumpir una operación cuando faltan datos obligatorios o una validación no se cumple. Muestra un mensaje al usuario y cancela la acción en curso:

```javascript
// Validar antes de guardar
function validarFormulario() {
    if (!self.NOMBRE || self.NOMBRE === "") {
        appData.failWithMessage(-8100, "El campo Nombre es obligatorio");
        return false;
    }
    if (!self.EMAIL || self.EMAIL === "") {
        appData.failWithMessage(-8100, "El campo Email es obligatorio");
        return false;
    }
    return true;
}
```

#### Cerrar pantalla / aplicación (control de flujo)

Formas correctas desde JavaScript:

```javascript
// Salir de la pantalla actual (volver atrás)
ui.getView(self).exit();

// Salir completamente de la aplicación
appData.exit();
```

**Código heredado:** Algunos proyectos antiguos usan `appData.failWithMessage(-11888, "##EXIT##")` para cerrar la pantalla. Sigue funcionando, pero las formas de arriba son preferidas.

#### Verificación de errores después de operaciones

Después de operaciones como `save()`, se puede verificar si ocurrio un error:

```javascript
self.save();
if (appData.error().getNumber() != 0) {
    ui.showToast("Error: " + appData.error().getDescription());
    appData.error().clear();
}
```

| Método | Descripción |
|--------|-------------|
| `appData.error().getNumber()` | Devuelve el código numérico del último error (0 = sin error) |
| `appData.error().getDescription()` | Devuelve la descripción textual del error |
| `appData.error().clear()` | Limpia el estado de error actual |

### 6.7 Sintaxis JavaScript soportada por el motor

El motor JavaScript de XOne está basado en un **fork de Mozilla Rhino** fuertemente parcheado en Java 17, con backports selectivos: soporta **ES5 completo + buena parte de ES6+** (incluyendo `class` y `Promise`). No es ES2015 completo. Conocer qué piezas concretas funcionan evita errores en tiempo de parseo o de ejecución.

#### Sintaxis ES6+ SÍ disponible

| Característica ES6+ | Notas |
|---------------------|-------|
| `let` / `const` | Funcionan con su semántica de *block scope*. |
| Arrow functions `() => {}` | Funcionan, incluido el binding léxico de `this`. |
| Destructuring `var {a, b} = obj` y de parámetros `function f({x, y})` | Funciona. |
| `for...of` | Sobre `String`, `Array` y arrays-like. NO funciona sobre generators del fork (que son estilo legacy SpiderMonkey, ver fila siguiente). |
| Generadores con `yield` | Funcionan. El parser acepta dos sintaxis: (a) función normal con `yield` en el cuerpo (detección retroactiva, estilo legacy), y (b) la sintaxis explícita `function*` / `*method()` dentro de class. Ambas equivalentes. **Runtime estilo SpiderMonkey legacy**: `gen.next()` devuelve el valor directamente (no `{value, done}`) y lanza `StopIteration` al terminar. `for...of` NO los itera; usar `try { while (true) v = iter.next(); ... } catch (e) {}`. |
| `Symbol` / `Symbol.iterator` | Iteración estándar sobre nativos. |
| `class` ES6+ | Declaraciones, expresiones, `extends`, `super`, `static`, getters/setters, computed keys (`[expr]() {}`), **field declarations** (`field = expr;` / `static field = expr;`), **generator methods** (`*method()` / `static *method()`). Implementado vía desugar a `function` + `prototype`. NO soporta: private fields (`#name`), static blocks, `new.target`. Ver sección dedicada en este archivo. |
| `Promise` (custom, ES2024-compatible) | API completa: constructor, `resolve`, `reject`, `all`, `allSettled`, `race`, `any` (con `AggregateError`-like), `withResolvers`. Instancia: `.then`, `.catch`, `.finally`, `.status`. Implementación custom en el módulo `xonejavascript_lib/objects/promises/Promise`. Limitaciones: no hay microtask scheduling real (callbacks despachan en threads); asimilación de thenables solo para Promise nativos (no objetos genéricos con `.then`). |
| Métodos modernos de `String` | `padStart`, `padEnd`, `replaceAll`, `matchAll`, `at`, `trimStart`, `trimEnd`, `includes`, `startsWith`, `endsWith`, `repeat`, `normalize`, `codePointAt`, `fromCodePoint`, `String.raw` (forma con objeto manual), `isWellFormed`, `toWellFormed` — todos los del estándar hasta ES2024. |
| Métodos modernos de `Array` | `map`, `filter`, `reduce`, `forEach`, `find`, `findIndex`, `includes`, `some`, `every` — disponibles desde ES5/ES6. |
| Typed arrays | `Int8Array`, `Uint8Array`, `Int16Array`, `Uint16Array`, `Int32Array`, `Uint32Array`, `Float32Array`, `Float64Array`, `ArrayBuffer`. |
| `JSON.parse()` / `JSON.stringify()` | Estándar. |

#### Sintaxis ES6+ NO disponible

| Característica ES6+ | Por qué falla | Alternativa en XOne |
|---------------------|--------------|---------------------|
| **Template literals** `` `${var}` `` | El lexer no reconoce el carácter backtick (`` ` ``) — *illegal character*. | Concatenación `"texto " + var` |
| `async` / `await` | Palabras reservadas — parse error. | Callbacks o `Promise` custom (sí soportado, ver arriba). |
| `import` / `export` | No hay sistema de módulos. | `<include>` en `app.xml`, `appData.loadIncludeFile()` |
| Spread/rest `...args` | No implementado. | Usar `arguments` o `apply(thisArg, argsArray)` |
| Default parameters `function f(x=1)` | No implementado. | `function f(x){ if (x===undefined) x = 1; ... }` |
| Computed property names en object literals `{[k]: v}` | El parser no acepta la sintaxis dentro de `{}`. **SÍ** la acepta dentro de cuerpos de clase (`class { [k]() {} }`). | Object literal: crear vacío + asignar `var o = {}; o[k] = v;` |
| Shorthand props `{a, b}` (sin destructuring) | No implementado en object literals. | `{a: a, b: b}` |
| Optional chaining `?.` / nullish coalescing `??` | No implementados. | Chequeos manuales: `obj && obj.x`, `x !== undefined ? x : default` |
| Private fields `#name` en clase | No implementado (necesita runtime con WeakMap-like scoping). | Convención: prefijo `_`, e.g. `this._x`. |
| Static blocks `static { ... }` en clase | No implementado. | Sentencias `ClassName.x = ...;` justo después de la clase. |
| `new.target` dentro de constructores | No implementado. | Convención manual (e.g. `if (!(this instanceof Foo)) ...`). |

#### Sintaxis ES5 (base, siempre disponible)

| Característica | Notas |
|----------------|-------|
| `var` | Function scope. |
| Funciones declarativas `function nombre() {}` | Estándar. |
| `try / catch / finally` | Estándar. |
| `Math`, `Date`, `RegExp` | Globales estándar. |
| `console.{log,info,debug,warn,error,trace,assert,group,groupCollapsed,groupEnd,time,timeLog,timeEnd,count,countReset,dir,dirxml,clear,table}` | API `console` completa (WHATWG-like) con varargs y formato `%s/%d/%i/%f/%o/%O/%j/%%`. |

#### Ejemplo comparativo

```javascript
// INCORRECTO - sintaxis que NO funciona en XOne
var template = `Hola ${nombre}`;              // template literal: parse error
function saludo(nombre = "anon") { }          // default params: parse error
function f(...rest) { }                       // rest params: parse error
var obj = {a, b};                             // shorthand props: parse error
var obj2 = {[k]: 1};                          // computed keys en object literal: parse error
var v = obj?.x;                               // optional chaining: parse error

// CORRECTO - sintaxis válida en XOne
var template = "Hola " + nombre;
function saludo(nombre) { if (nombre === undefined) nombre = "anon"; }
var obj = {a: a, b: b};
var obj2 = {}; obj2[k] = 1;
var v = obj && obj.x;

// SÍ funciona: let/const, arrow functions, destructuring, class, Promise,
// generadores, métodos modernos de String y Array
let saludar = (nombre) => "Hola " + nombre;
const MAX = 10;
let items = lista.map(i => i.nombre);
let [a, b] = [1, 2];                          // destructuring
"5".padStart(3, "0");                         // "005"
"a-b-c".replaceAll("-", "+");                 // "a+b+c"
"abc".at(-1);                                 // "c"

class Persona {                               // class declarations
    edad = 0;                                 // field declaration (instance)
    static contador = 0;                      // field declaration (static)
    constructor(nombre) {
        this.nombre = nombre;
        Persona.contador++;
    }
    saludar() { return "Hola, soy " + this.nombre; }
    static crear(n) { return new Persona(n); }
    *iterFields() { yield this.nombre; yield this.edad; }  // generator method
}
class Empleado extends Persona {              // extends + super
    constructor(nombre, rol) {
        super(nombre);
        this.rol = rol;
    }
    saludar() { return super.saludar() + " (" + this.rol + ")"; }
}
var e = new Empleado("Juan", "dev");
e.saludar();                                  // "Hola, soy Juan (dev)"

new Promise((resolve, reject) => {            // Promise ES2024
    setTimeout(() => resolve(42), 100);
}).then(v => console.log(v))                  // .then funciona
  .catch(err => console.error(err))           // .catch funciona (ya no es .Catch)
  .finally(() => console.log("listo"));       // .finally también

Promise.all([p1, p2]).then(([a, b]) => {});  // estáticos completos
Promise.allSettled([p1, p2]);
Promise.any([p1, p2]);
const { promise, resolve, reject } = Promise.withResolvers();
```

#### APIs de navegador NO disponibles

XOne no ejecuta JavaScript en un navegador. Las siguientes APIs **no existen**:

| API NO disponible | Alternativa XOne |
|-------------------|-----------------|
| `document.getElementById()` | `ui.getView(self)` o `getControl("X")` |
| `window` / `window.location` / `window.history` | `ui.openEditView(...)`, `ui.getView(self).exit()` |
| `localStorage` / `sessionStorage` | `appData.setGlobalMacro` / `appData.getGlobalMacro` |
| `XMLHttpRequest()` | `$http.get/post/...` (idiomático) o `fetch(url, init)` (ver tabla siguiente) |
| `navigator.geolocation` | `ui.startGps({nodeName: "..."})` / `new GpsTools()` |
| `alert()` / `confirm()` / `prompt()` | `ui.msgBox()` / `ui.showToast()` |
| `async` / `await` (palabras reservadas, parse error) | Callbacks o `Promise` (sí soportado vía implementación custom — ver tabla siguiente). |

#### APIs WHATWG/Node SÍ disponibles (implementación custom XOne)

Compatible con la semántica de la spec, registrado en `RhinoJavascriptEngine.addNativeJavascriptObjects`:

| API | Notas |
|-----|-------|
| `console.{log,info,debug,warn,error,trace,assert,group,groupCollapsed,groupEnd,time,timeLog,timeEnd,count,countReset,dir,dirxml,clear,table}` | Varargs y formato `%s/%d/%i/%f/%o/%O/%j/%%`. |
| `fetch(input, init?)` | Devuelve `Promise<Response>`. Soporta `method`, `headers`, `body` (string / `URLSearchParams` / `ArrayBuffer` / typed array), `signal`. **NO** soporta `Request` como primer arg, body `FormData`/`Blob`/`ReadableStream`, ni cancelación in-flight real (el `AbortSignal` solo rechaza el Promise; la red sigue en background). Ignora `mode/credentials/cache/redirect/referrer/integrity/keepalive`. |
| `Response` | `status`, `ok`, `headers`, `url`, `text()`, `json()`, `arrayBuffer()`, `clone()`. |
| `Headers` | Case-insensitive, multi-valor con `, ` (regla WHATWG). |
| `AbortController` / `AbortSignal` | `signal.aborted`, `abort(reason)`, hereda de `EventTarget`. |
| `setTimeout` / `clearTimeout` / `setInterval` / `clearInterval` / `queueMicrotask` | Tiempos en **ms** (semántica spec). El patrón XOne idiomático sigue siendo `ui.executeActionAfterDelay(node, segundos)` para un disparo único integrado con la UI, pero `setTimeout` con `(fn, ms)` también es válido. |
| `Promise` | ES2024 casi completo. Estáticos: `resolve`, `reject`, `all`, `allSettled`, `race`, `any`, `withResolvers`. Instancia: `.then`, `.catch`, `.finally`, `.status` (`"pending"`/`"fulfilled"`/`"rejected"`). Limitación: no hay microtask scheduling real; asimilación de thenables solo para instancias de `Promise`. |
| `URL` / `URLSearchParams` | Constructores estilo WHATWG. |
| `EventTarget` | `addEventListener`, `removeEventListener`, `dispatchEvent`, opción `once`. |
| `TextEncoder` (UTF-8) / `TextDecoder` (UTF-8/16/Latin-1/ASCII + fallback `Charset.forName`) | |
| `performance.now()` / `performance.timeOrigin` | |
| `atob` / `btoa` | WHATWG, Latin-1. |
| `structuredClone` | Detección de ciclos; soporta Date/RegExp/Array/objeto/ArrayBuffer/typed arrays. |
| `DOMParser` / `XMLSerializer` | |
| `globalThis` | Auto-referencia al scope global. |
| `crypto`, `clipboard`, `deviceInfo`, `systemSettings`, `packageManager`, `biometricsManager`, … | Singletons XOne; ver tópico 06. |

> Para más detalles sobre buenas prácticas de JavaScript en XOne, consulta [03 - Guía de API JavaScript](./03-javascript-api-guide.md).

---

## 7. Flujo de Navegación

La navegación en XOne sigue un patron predecible. La app siempre arranca en la pantalla definida como `entry-point` en `app.xml`, típicamente `EntradaApp`.

### Flujo Típico

```
  Splash             Login            EntradaApp           Pantallas
  (splash.png)    (login-coll)      (entry-point)        (funcionales)
  +----------+    +----------+      +-------------+    +-------------+
  | Imagen   | -> | Usuario  | ->   | Bienvenida  | -> | ListaTareas |
  | de carga |    | Password |      | Opción 1 --+--> | DetalleTarea|
  | (fichero |    | [Entrar] |      | Opción 2 --+--> | ListaClient |
  |  splash) |    |          |      | Opción 3 --+--> | Reportes    |
  |          |    |          |      | [Salir]    |    |             |
  +----------+    +----------+      +-------------+    +-------------+
```

El **splash** lo gestiona el framework automáticamente cargando un fichero `splash.png` (u otros formatos, ver más abajo) de la raíz del proyecto durante la carga inicial. NO es una `<coll>` XML.

### Funciones de Navegación

```javascript
// Abrir una pantalla (forma corta: pasar el nombre de la coll)
// XOne crea internamente un dataObject vacío y abre su EditView.
ui.openEditView("MenuPrincipal");

// Abrir un objeto existente o pre-rellenado
ui.openEditView(dataObject);

// Cerrar la vista origen al abrir la nueva (flujos lineales sin botón atrás)
ui.openEditView(dataObject, true);

// Cerrar la pantalla actual y volver a la anterior
let window = ui.getView(self);
window.exit();

// Salir completamente de la aplicación
appData.exit();
```

> Para el caso especial de abrir directamente la **lista** de una coll (no su EditView), ver [topics/03b-js-ui.md §3.1](03b-js-ui.md#31-navegacion) → `ui.openMenu("Coll", mask, 0)`.

### Pasar Datos entre Pantallas

Para abrir una pantalla pasándole datos, el patrón canónico es **obtener un dataObject de la colección destino, asignarle propiedades y lanzarlo con `ui.openEditView()`**:

```javascript
// === En la pantalla ORIGEN: preparar el objeto destino y abrir su vista ===
let coll = appData.getCollection("DetalleTarea");
let obj = new DetalleTarea({ MAP_ID_TAREA: self.ID });
coll.addItem(obj);
ui.openEditView(obj);

// === Abrir un objeto EXISTENTE de la BD ===
let coll = appData.getCollection("Tareas");
let tarea = coll.findObject("ID = " + nId);
if (tarea) {
    ui.openEditView(tarea);
}
```

> **Forma corta:** `ui.openEditView("DetalleTarea")` crea un objeto vacío y lo abre en una sola llamada — útil cuando no hay que pre-rellenar nada. Detalles en [topics/03c-js-appdata-http.md §4.3](03c-js-appdata-http.md#43-navegacion-entre-pantallas-con-datos).

### Ejemplo Completo: EntradaApp con Navegación

```xml
<?xml version="1.0" encoding="utf-8"?>
<coll name="EntradaApp" title="Bienvenido"
      special="true" notab="true" show-toolbar="false">

    <create>
        <action name="runscript">
            <script language="javascript">
                // Inicialización al crear la pantalla
            </script>
        </action>
    </create>

    <group name="grpPrincipal" id="1" class="groupNoTab">
        <!-- Cabecera con logo -->
        <frame name="frmHeader" class="frameHeader">
            <prop name="imgLogo" type="IMG" visible="7"
                  width="200p" height="80p" align="center"
                  src="./icons/app_icon.png"/>
        </frame>

        <!-- Cuerpo con botón de entrada -->
        <frame name="frmBody" class="frameBody">
            <prop name="lblBienvenida" type="L" visible="7"
                  width="100%" height="50p" align="center"
                  class="textoTitulo" title="Bienvenido a Mi App"/>

            <prop name="btnEntrar" type="B" visible="7"
                  width="80%" height="50p" align="center"
                  class="btnPrimario" title="Entrar" tmargin="30p"
                  onclick="ui.openEditView('MenuPrincipal');" />
        </frame>
    </group>

    <!-- Manejo del botón atrás: confirmar antes de salir -->
    <onback>
        <action name="runscript">
            <script language="javascript">
                let nResult = ui.msgBox(
                    "¿Desea salir de la aplicación?",
                    "Confirmar salida",
                    4  // Tipo 4 = Si/No
                );
                if (nResult == 6) {  // 6 = Si
                    appData.exit();
                }
            </script>
        </action>
    </onback>
</coll>
```

> Para profundizar en los patrones de navegación avanzados y el uso de `contents`, consulta [02 - Estructura XML y Colecciones](./02-xml-ui-complete-guide.md).

---

## 8. Convenciones de Nomenclatura

Seguir convenciones de nomenclatura consistentes es fundamental para mantener un proyecto XOne organizado y legible.

### Colecciones y Pantallas

| Elemento | Convencion | Ejemplos |
|----------|-----------|----------|
| Nombre de coleccion | **PascalCase** | `MenuPrincipal`, `DetalleTarea`, `ListaClientes` |
| Archivo de coleccion | **PascalCase.xne** | `MenuPrincipal.xne`, `Tareas.xne` |
| Pantallas de lista | Prefijo `Lista` | `ListaTareas`, `ListaClientes`, `ListaPedidos` |
| Pantallas de detalle | Prefijo `Detalle` | `DetalleTarea`, `DetalleCliente` |
| Pantalla de entrada | Siempre `EntradaApp` | `EntradaApp.xne` |

### Propiedades y Campos

| Tipo de campo | Convencion | Ejemplos |
|-------------|-----------|----------|
| Campos de BD | **MAYUSCULAS** | `CODIGO`, `NOMBRE`, `FECHA_CREACION` |
| Campos temporales (UI) | Prefijo **MAP_** | `MAP_BTN_GUARDAR`, `MAP_TOTAL`, `MAP_BUSQUEDA` |
| Botones | `MAP_BTN_` + acción | `MAP_BTN_GUARDAR`, `MAP_BTN_CANCELAR`, `MAP_BTN_BUSCAR` |
| Labels informativos | `MAP_LBL_` + nombre | `MAP_LBL_TITULO`, `MAP_LBL_SUBTITULO` |
| Propiedades con `title` | camelCase o descriptivo | `txtNombre`, `btnGuardar`, `lblTitulo` |

### Clases CSS

| Tipo de clase | Convencion | Ejemplos |
|-------------|-----------|----------|
| Frames | Prefijo descriptivo | `.frameHeader`, `.frameBody`, `.frameFooter` |
| Botones | Prefijo `.btn` | `.btnPrimario`, `.btnSecundario`, `.btnPeligro` |
| Texto | Prefijo `.texto` | `.textoTitulo`, `.textoSubtitulo`, `.textoEditable` |
| Iconos | Prefijo `.icono` | `.iconoAccion`, `.iconoMenu` |
| Grupos | Prefijo `.group` | `.groupNoTab`, `.groupConTab` |

### Funciones JavaScript

| Tipo de función | Convencion | Ejemplos |
|----------------|-----------|----------|
| Funciones generales | **camelCase** | `mostrarToast()`, `cerrarPantalla()` |
| Funciones de validación | Prefijo `validar` | `validarFormulario()`, `validarCampo()` |
| Funciones de negocio | Verbo descriptivo + sustantivo | `doLogin()`, `createPDF()`, `validateUserInput()` |
| Funciones de evento | Prefijo `on` o `do` | `onMapClicked()`, `doLogin()` |
| Callbacks | Prefijo `callback` | `callbackGps()`, `callbackHttp()` |

### Variables JavaScript

| Tipo de variable | Convencion | Ejemplos |
|-----------------|-----------|----------|
| Variables locales | **camelCase** | `userName`, `isConnected`, `maxRetries` |
| Constantes | **MAYUSCULAS con guion bajo** | `MAX_RETRY_ATTEMPTS`, `DEFAULT_TIMEOUT` |
| Campos de interfaz (en self) | Prefijo **MAP_** | `MAP_USER`, `MAP_PASSWORD`, `MAP_COLORACTIVO`, `MAP_LOADING` |
| Objetos de configuración | **MAYUSCULAS** | `APP_CONFIG`, `CONNECTION_STATUS` |

```javascript
// CORRECTO - Variables locales en camelCase
var userName = "admin";
var isConnected = false;
var maxRetries = 3;

// CORRECTO - Constantes en MAYUSCULAS
var MAX_RETRY_ATTEMPTS = 3;
var DEFAULT_TIMEOUT = 5000;

// CORRECTO - Campos de interfaz con MAP_
self.MAP_USER = "usuario";
self.MAP_PASSWORD = "clave";
self.MAP_LOADING = 0;

// CORRECTO - Funciones con verbos descriptivos
function doLogin(user, pass) { }
function createPDF(fileName, pdf) { }
function validateUserInput() { }

// INCORRECTO - Nombres ambiguos o genericos
function process() { }
function handle() { }
var x = "admin";
var flag = true;
```

### Nomenclatura de Iconos

```
[prefijo]_[descripcion].png

Prefijos estándar:
  ic_       Iconos de interfaz        ic_menu.png, ic_search.png
  app_      Icono de aplicación       app_icon.png
  avatar_   Fotos de perfil           avatar_default.png
```

> **Nota:** La carpeta `icons/` acepta PNG, JPG y SVG. El formato PNG es el más habitual, pero SVG es perfectamente valido y no necesita conversion.

---

## 9. Primeros Pasos - Crear un Proyecto Básico

A continuacion, un checklist paso a paso para crear tu primer proyecto XOne funcional:

### Checklist: Proyecto "Hola Mundo"

```
 1. [ ] Crear la estructura de carpetas
 2. [ ] Crear app.xml con configuracion basica
 3. [ ] Crear app.ini con metadatos
 4. [ ] Crear mappings.xne con Empresas y Usuarios
 5. [ ] Crear default.css con estilos base
 6. [ ] Crear functions.js con utilidades
 7. [ ] Crear EntradaApp.xne como punto de entrada
 8. [ ] Crear MenuPrincipal.xne
 9. [ ] Generar la base de datos
10. [ ] Insertar datos iniciales (Empresa + Usuario admin)
11. [ ] Generar iconos
```

### Archivos Mínimos Necesarios

Un proyecto XOne funcional mínimo necesita exactamente estos archivos:

```
MiPrimerProyecto/
|-- app.xml               # Configuración
|-- app.ini               # Metadatos
|-- mappings.xne          # Empresas + Usuarios
|-- default.css           # Estilos
|-- functions.js          # Funciones globales
|-- EntradaApp.xne        # Pantalla de entrada
|-- MenuPrincipal.xne     # Menu principal
|-- bd/
|   +-- gestion.db        # Base de datos (generada)
|-- icons/
|   +-- app_icon.png      # Al menos un icono
+-- files/                # Carpeta vacia (para runtime)
```

### Ejemplo: Proyecto "Hola Mundo" Completo

#### 1. app.xml

```xml
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xml>
    <app
        prefix="gen"
        version="1.0.0"
        debug="true"
        autologon="true"
        screen-orientation="portrait"
        resolution-width="1080"
        resolution-height="1920"
        scale-fontsize="true"
        android-font-factor="7"
        default-language="javascript">

        <entry-point>
            <item name="EntradaApp" conditions="" />
        </entry-point>

        <style url="default.css" encoding="UTF-8" />
        <include file="functions.js" language="javascript" encoding="UTF-8"/>
    </app>
</xml>
```

> Nota: `autologon="true"` salta el login para simplificar este ejemplo.

#### 2. app.ini

```ini
Name=HolaMundo
Title=Hola Mundo XOne
Caption=Mi primer proyecto XOne
Icon=app_icon.png
IconFolder=icons
FilesFolder=files
HideSplash=false
```

#### 3. mappings.xne (mínimo obligatorio)

```xml
<?xml version="1.0" encoding="utf-8"?>
<xml>
    <app prefix="gen" version="1.0.0" debug="true" default-language="javascript">
        <style url="default.css" />
    </app>

    <collprops type="general">
        <coll name="Empresas"
              sql="SELECT * FROM ##PREF##Empresas"
              objname="Empresas"
              updateobj="Empresas"
              loadall="true">
            <group name="General" id="1">
                <prop name="CODIGO" type="N" visible="7" />
                <prop name="NOMBRE" type="T" visible="7" fieldsize="150" />
            </group>
        </coll>

        <coll name="Usuarios"
              sql="SELECT * FROM ##PREF##Usuarios"
              objname="Usuarios"
              updateobj="Usuarios"
              loadall="true">
            <group name="General" id="1">
                <prop name="CODIGO" type="N" visible="7" />
                <prop name="NOMBRE" type="T" visible="7" fieldsize="100" />
                <prop name="IDEMPRESA" type="N" visible="7"
                      mapcol="Empresas" mapfld="ID" />
                <prop name="LOGIN" type="T" visible="7" fieldsize="50" />
                <prop name="PWD" type="X" visible="0" fieldsize="100" />
            </group>
        </coll>
    </collprops>
</xml>
```

#### 4. default.css (estilos básicos)

```css
/* Configuración global */
prop {
    fontname: Roboto-Regular.ttf;
    fontsize: 10;
    labelbox: false;
    label-wrap: true;
    text-border: false;
}

coll {
    notab: true;
    show-toolbar: false;
    group-swipe: false;
    editmask: 0;
}

/* Clases de layout */
.frameHeader {
    width: 100%;
    height: 120p;
    bgcolor: #2196F3;
    align: center;
}

.frameBody {
    width: 100%;
    height: 100%;
    scroll: true;
    bgcolor: #FFFFFF;
}

/* Clases de botones */
.btnPrimario {
    width: 90%;
    height: 50p;
    bgcolor: #2196F3;
    forecolor: #FFFFFF;
    border-corner-radius: 8;
    text-align: center;
    fontsize: 14;
}

/* Clases de texto */
.textoTitulo {
    fontsize: 18;
    forecolor: #212121;
    text-align: center;
}

.textoSubtitulo {
    fontsize: 14;
    forecolor: #757575;
    text-align: center;
}

/* Grupos sin pestana */
.groupNoTab {
    tab-visible: false;
}
```

#### 5. functions.js

```javascript
/**
 * Funciones globales - Hola Mundo XOne
 */

/**
 * Verifica si un valor esta vacio
 */
function isEmpty(val) {
    return val === undefined || val === null || val === "";
}

/**
 * Muestra un mensaje de confirmacion Si/No
 */
function confirmar(mensaje, titulo) {
    titulo = titulo || "Confirmar";
    let nResult = ui.msgBox(mensaje, titulo, 4);
    return nResult == 6;
}

/**
 * Muestra un toast simple
 */
function mostrarToast(mensaje) {
    ui.showToast(mensaje);
}

/**
 * Cierra la pantalla actual
 */
function cerrarPantalla() {
    let window = ui.getView(self);
    if (window) {
        window.exit();
    }
}
```

#### 6. EntradaApp.xne

```xml
<?xml version="1.0" encoding="utf-8"?>
<coll name="EntradaApp" title="Hola Mundo"
      special="true" notab="true" show-toolbar="false">

    <create>
        <action name="runscript">
            <script language="javascript">
                // Ir directamente al menu
                ui.openEditView("MenuPrincipal");
            </script>
        </action>
    </create>

    <group name="grpPrincipal" id="1" class="groupNoTab">
        <frame name="frmBody" class="frameBody">
            <prop name="lblCargando" type="L" visible="7"
                  width="100%" height="50p" align="center"
                  class="textoTitulo" title="Cargando..."/>
        </frame>
    </group>

    <onback>
        <action name="runscript">
            <script language="javascript">
                if (confirmar("Desea salir?", "Salir")) {
                    appData.exit();
                }
            </script>
        </action>
    </onback>
</coll>
```

#### 7. MenuPrincipal.xne

```xml
<?xml version="1.0" encoding="utf-8"?>
<coll name="MenuPrincipal" title="Menu Principal"
      special="true" notab="true" show-toolbar="false">

    <group name="grpMenu" id="1" class="groupNoTab">
        <frame name="frmHeader" class="frameHeader">
            <prop name="lblTitulo" type="L" visible="7"
                  width="100%" height="60p" align="center"
                  forecolor="#FFFFFF" fontsize="20"
                  title="Hola Mundo XOne"/>
        </frame>

        <frame name="frmBody" class="frameBody">
            <prop name="lblMensaje" type="L" visible="7"
                  width="100%" height="80p" align="center"
                  class="textoTitulo" tmargin="40p"
                  title="Bienvenido a tu primer proyecto XOne!"/>

            <prop name="lblInfo" type="L" visible="7"
                  width="90%" height="60p" align="center"
                  class="textoSubtitulo" tmargin="20p"
                  title="Este es un proyecto básico de ejemplo."/>

            <prop name="btnSaludo" type="B" visible="7"
                  width="80%" height="50p" align="center"
                  class="btnPrimario" title="Saludar" tmargin="40p"
                  onclick="ui.showToast('Hola desde XOne!');" />
        </frame>
    </group>

    <onback>
        <action name="runscript">
            <script language="javascript">
                if (confirmar("¿Desea salir de la aplicación?", "Salir")) {
                    appData.exit();
                }
            </script>
        </action>
    </onback>
</coll>
```

> Para una guía completa de creación de proyectos con todas las tareas finales (generar BD, insertar datos, descargar iconos), consulta el tópico [05 - Eventos, Patrones y FAQ](./05-events-patterns-faq.md).

---

## 10. Errores Comunes de Principiantes

### Error 1: Usar unidades CSS web (`px`, `em`, `rem`)

```css
/* INCORRECTO - XOne no entiende px ni em */
.miBoton {
    width: 200px;
    height: 50px;
    font-size: 14px;
    margin-top: 10em;
}

/* CORRECTO - Usar p (puntos) o % (porcentaje) */
.miBoton {
    width: 200p;
    height: 50p;
    fontsize: 14;
    tmargin: 10p;
}
```

**Por que falla:** XOne usa `p` (pixel en el dispositivo de referencia definido por `resolution-width`/`resolution-height`) como unidad principal de dimensiones. El `fontsize` NO necesita unidad — usa la escala XOne 1-12 directamente. `p` no es Material `dp`: en 1080×1920, Material 56dp ≈ 168p.

---

### Error 2: Olvidar ##PREF## en consultas SQL

```xml
<!-- INCORRECTO - La tabla no se encontrara -->
<coll name="Tareas" sql="SELECT * FROM Tareas" ...>

<!-- INCORRECTO - Hardcodear el prefijo -->
<coll name="Tareas" sql="SELECT * FROM gen_Tareas" ...>

<!-- CORRECTO - Usar la macro ##PREF## -->
<coll name="Tareas" sql="SELECT * FROM ##PREF##Tareas" ...>
```

**Por que falla:** Sin `##PREF##`, la consulta busca una tabla que no existe. Con el prefijo hardcodeado, deja de funcionar si cambia el prefijo del proyecto.

---

### Error 3: Poner colecciones extra en mappings.xne

```
INCORRECTO:
mappings.xne contiene: Empresas, Usuarios, Productos, Clientes, Pedidos

CORRECTO:
mappings.xne   -->  Solo Empresas y Usuarios
Productos.xne  -->  Coleccion Productos
Clientes.xne   -->  Coleccion Clientes
Pedidos.xne    -->  Coleccion Pedidos
```

**Por que falla:** Aunque tecnicamente puede funcionar, viola la convencion del framework y causa problemas de mantenimiento. Cada coleccion debe tener su propio archivo.

---

### Error 4: Usar APIs del DOM

```javascript
// INCORRECTO - APIs del DOM que NO existen en XOne
document.getElementById("campo").value = "test";
localStorage.setItem("key", "value");
window.alert("Hola");
console.log(document.querySelector(".clase"));

// CORRECTO - APIs de XOne
self.MAP_CAMPO = "test";
appData.setGlobalMacro("KEY", "value");
ui.msgBox("Hola", "Título", 0);
let control = ui.getView(self)["MAP_CAMPO"];

// ATENCION: `fetch` SI existe en XOne (implementación custom).
// El patrón idiomático sigue siendo $http, pero fetch es válido:
$http.get("https://api.com/datos", {}, successCb, errorCb);   // idiomático
fetch("https://api.com/datos").then(r => r.json());           // también válido
```

**Por que falla:** XOne no tiene DOM, ni `document`, ni `window`, ni `localStorage`. Tiene sus propias APIs. Lo que SÍ está disponible son las APIs WHATWG/Node enumeradas en §6.7 (`Promise`, `fetch`, `setTimeout`, `URL`, `Headers`, `AbortController`, `console.*` completo, `TextEncoder`/`TextDecoder`, `performance.now()`, `atob`/`btoa`, `structuredClone`, `DOMParser`/`XMLSerializer`, `globalThis`).

---

### Error 5: No crear la carpeta bd/

```
INCORRECTO:
MiProyecto/
|-- app.xml
|-- mappings.xne
+-- default.css
(sin carpeta bd/)

CORRECTO:
MiProyecto/
|-- app.xml
|-- mappings.xne
|-- default.css
|-- bd/
|   +-- gestion.db
+-- ...
```

**Por que falla:** La aplicación no puede funcionar sin la base de datos local. La carpeta `bd/` y el archivo `gestion.db` son imprescindibles.

---

### Error 6: Usar nombres CSS web para atributos

```css
/* INCORRECTO - Atributos CSS web */
.miClase {
    background-color: red;
    font-size: 14px;
    border-radius: 10px;
    margin-top: 20px;
    color: blue;
}

/* CORRECTO - Atributos CSS XOne */
.miClase {
    bgcolor: #FF0000;
    fontsize: 14;
    border-corner-radius: 10;
    tmargin: 20p;
    forecolor: #0000FF;
}
```

**Por que falla:** XOne tiene sus propios nombres de atributos CSS. `background-color` no existe, se usa `bgcolor`. `border-radius` no existe, se usa `border-corner-radius`.

---

### Error 7: Olvidar objname en colecciones que necesitan tabla

```xml
<!-- INCORRECTO - Esta coleccion NO creara tabla en BD -->
<coll name="Tareas" sql="SELECT * FROM ##PREF##Tareas">
    <!-- Falta objname, así que no se persiste -->
</coll>

<!-- CORRECTO - Con objname, se creara la tabla gen_Tareas -->
<coll name="Tareas"
      sql="SELECT * FROM ##PREF##Tareas"
      objname="Tareas"
      updateobj="Tareas">
    <!-- objname indica que esta coleccion necesita tabla en BD -->
</coll>
```

**Por que falla:** Sin el atributo `objname`, XOne trata la coleccion como especial (solo memoria). No se genera tabla y los datos no se guardan.

---

### Error 8: Usar formatos de imagen no soportados en icons/

XOne soporta **PNG, JPG y SVG** en la carpeta `icons/`. Los tres formatos funcionan correctamente como iconos y recursos gráficos.

```
CORRECTO — cualquiera de estos formatos funciona:
icons/
|-- ic_menu.png
|-- ic_menu.svg
+-- ic_menu.jpg
```

El formato más habitual es PNG por compatibilidad historica, pero SVG es perfectamente valido y tiene la ventaja de escalar sin perder calidad.

**Anti-patrón frecuente — NO renderizar SVG con un `type="WEB"`:** el soporte de SVG en XOne es nativo y completo. Un `.svg` es una imagen más: se refiere con `type="IMG"` (`path="dibujo.svg"`) o con los atributos `img`/`imgbk`, igual que un PNG. Envolverlo en un WebView (`type="WEB"`) para "que se vea" es innecesario, no aporta nada y rompe el escalado y la integración con el control. El control `WEB` es solo para contenido web remoto (URLs), nunca para imágenes locales.

---

### Error 9: Pensar que hay que declarar `ID` o `ROWID`

`ID` (clave autonumérica) y `ROWID` (GUID de 32 hex de sincronización) son **columnas de plataforma**: XOne las crea y las rellena por su cuenta (el `ROWID` se autogenera en cada alta). **No hace falta declararlas** como `<prop>` — basta con los campos de negocio:

```xml
<!-- Suficiente: ID y ROWID los gestiona XOne -->
<coll name="Empresas" ...>
    <group name="General" id="1">
        <prop name="CODIGO" type="N" visible="7" />
        <prop name="NOMBRE" type="T" visible="7" fieldsize="150" />
    </group>
</coll>
```

Declararlas explícitamente (`<prop name="ID">` / `<prop name="ROWID">`) **no causa ningún problema** — el framework sigue gestionando sus valores —, pero es **redundante**; la recomendación es omitirlas por limpieza. En el `sql=` de la coll, el `ID` sí se rescata en el SELECT; el `ROWID` no es necesario.

---

### Error 10: Mezclar sintaxis de otros frameworks

```xml
<!-- INCORRECTO - Esto NO es React ni Angular -->
<div class="container">
    <input type="text" ng-model="nombre" />
    <button onClick={() => guardar()}>Guardar</button>
</div>

<!-- CORRECTO - Sintaxis XOne -->
<frame name="frmContenedor" width="100%" height="100%">
    <prop name="MAP_NOMBRE" type="T" visible="7"
          width="80%" height="40p" />
    <prop name="MAP_BTN_GUARDAR" type="B" visible="7"
          width="80%" height="50p" title="Guardar"
          onclick="guardar();" />
</frame>
```

**Por que falla:** XOne es un framework completamente independiente. No usa HTML, no tiene `<div>`, `<input>` ni `<button>`. Los componentes son `<coll>`, `<frame>`, `<prop>` y `<group>`.

---

### Error 11: Repetir nombres de nodos dentro de la misma coleccion

> **El ambito de unicidad es la `<coll>` ENTERA**, no el `<group>` o `<frame>` inmediato. Dos `<prop>` con el mismo `name` fallan **aunque estén en `<group>` o `<frame>` distintos** dentro de la misma coll. Lo mismo aplica a `<group>`, `<frame>` y a los nodos de evento.

```xml
<\!-- INCORRECTO - dos group con el mismo name -->
<coll name="MiPantalla" special="true">
    <group name="grpPrincipal" id="1">
        <frame name="frmHeader" width="100%" height="100p"/>
    </group>
    <group name="grpPrincipal" id="2">  <\!-- ERROR: nombre duplicado -->
        <frame name="frmBody" width="100%" height="-2"/>
    </group>
</coll>

<\!-- INCORRECTO - dos prop con el mismo name dentro del mismo group -->
<group name="grpDatos" id="1">
    <prop name="NOMBRE" type="T" visible="7"/>
    <prop name="NOMBRE" type="L" visible="2"/>  <\!-- ERROR: nombre duplicado -->
</group>

<\!-- INCORRECTO - dos prop con el mismo name en GROUPS DISTINTOS de la misma coll -->
<coll name="MiPantalla" special="true">
    <group name="grpUno" id="1">
        <frame name="frm1" width="100%" height="50%">
            <prop name="MAP_DATO" type="T" visible="1"/>
        </frame>
    </group>
    <group name="grpDos" id="2">
        <frame name="frm2" width="100%" height="50%">
            <prop name="MAP_DATO" type="L" visible="2"/>  <\!-- ERROR: el name "MAP_DATO" ya existe en grpUno -->
        </frame>
    </group>
</coll>

<\!-- INCORRECTO - dos prop con el mismo name en FRAMES DISTINTOS dentro del mismo group -->
<group name="grpUnico" id="1">
    <frame name="frmA">
        <prop name="MAP_X" type="T" visible="1"/>
    </frame>
    <frame name="frmB">
        <prop name="MAP_X" type="L" visible="2"/>  <\!-- ERROR: el name "MAP_X" ya existe en frmA -->
    </frame>
</group>

<\!-- CORRECTO - nombres unicos en TODA la coll (no solo dentro de cada group/frame) -->
<coll name="MiPantalla" special="true">
    <group name="grpHeader" id="1">
        <frame name="frmHeader" width="100%" height="100p"/>
    </group>
    <group name="grpBody" id="2">
        <frame name="frmBody" width="100%" height="-2"/>
        <prop name="MAP_NOMBRE_EDIT" type="T" visible="1"/>
        <prop name="MAP_NOMBRE_LISTA" type="L" visible="2"/>
    </group>
</coll>
```

**Por que falla:** El `name` de cada nodo (`<prop>`, `<group>`, `<frame>`, eventos) se publica a nivel de la propia `<coll>` (los `collprops`), no del `<group>` o `<frame>` que lo contiene. Por eso, si se repitiera el `name` en cualquier sitio dentro de la misma coll, actuaria como identificador único ambiguo. La unicidad se evalua sobre la coll completa.

**Lo que SI es valido:** dos `<coll>` distintas con contenido **identico** (incluso los mismos `name` de prop/group/frame internos) siempre que el atributo `name` **de la propia coll** sea distinto. Cada coll es un ambito independiente.

**Lo que NO es valido:** dos `<coll>` con el mismo `name` en el proyecto.

---

Esta guía ha cubierto los conceptos fundamentales de XOne:

| Concepto | Resumen |
|----------|---------|
| **Plataforma** | Framework para apps móviles nativas (Android + iOS) desde código único |
| **Arquitectura** | XML declarativo (UI) + JavaScript imperativo (lógica) + SQLite (datos) |
| **Archivos principales** | `app.xml`, `app.ini`, `mappings.xne`, `default.css`, `functions.js` |
| **Colecciones** | Concepto central que une tabla + pantalla + formulario |
| **Propiedades** | Elemento dual: campo de datos + control visual |
| **Navegación** | `ui.openEditView()`, `window.exit()` |
| **Prefijo** | `##PREF##` en SQL para referencia dinámica a tablas |
| **Regla de oro** | `mappings.xne` solo contiene Empresas y Usuarios |

### Proximos Pasos

- **[02 - Estructura XML y Colecciones](./02-xml-ui-complete-guide.md)**: Profundiza en la sintaxis XML, nodos, atributos y patrones de colecciones
- **[04 - Estilos CSS en XOne](./04-css-styling-guide.md)**: Referencia completa de atributos CSS propietarios
- **[03 - API JavaScript](./03-javascript-api-guide.md)**: Documentación detallada de `ui.*`, `self.*`, `appData.*` y más
- **[05 - Eventos, Patrones y FAQ](./05-events-patterns-faq.md)**: Tutorial paso a paso para crear proyectos completos

---

*Este documento forma parte del sistema de ayuda XOne. Basado en el análisis de 224 proyectos de ejemplo reales, 5 proyectos sinteticos documentados y la documentación oficial de la plataforma.*
