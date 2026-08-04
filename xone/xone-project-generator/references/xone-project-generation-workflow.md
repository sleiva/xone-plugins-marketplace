# Flujo de Trabajo Completo para Generación de Proyectos XOne

## Guía Operativa para Agentes de IA

Este documento describe el flujo de trabajo completo, paso a paso, que un agente de IA debe seguir para generar un proyecto XOne funcional desde cero. Toda decisión debe basarse exclusivamente en la documentación de las knowledgebases del proyecto.

---

## Tabla de Contenidos

1. [Fase 0: Diagrama de Flujo Completo](#1-fase-0-diagrama-de-flujo-completo)
2. [Fase 1: Análisis de Requisitos](#2-fase-1-analisis-de-requisitos)
3. [Fase 2: Diseño del Modelo de Datos](#3-fase-2-diseno-del-modelo-de-datos)
4. [Fase 3: Estilos CSS](#4-fase-3-estilos-css)
5. [Fase 4: Creación de Estructura de Carpetas](#5-fase-4-creacion-de-estructura-de-carpetas)
6. [Fase 5: Generación de Archivos de Configuración](#6-fase-5-generacion-de-archivos-de-configuracion)
7. [Fase 6: Generación de Colecciones](#7-fase-6-generacion-de-colecciones)
8. [Fase 7: Generación de Pantallas](#8-fase-7-generacion-de-pantallas)
   - [7.13 ViewModes Disponibles para Generación](#713-viewmodes-disponibles-para-generacion)
   - [7.14 Filtros de Busqueda con asfilter](#714-filtros-de-busqueda-con-asfilter)
   - [7.15 Objetos Complementarios como Opciones de Integración](#715-objetos-complementarios-como-opciones-de-integracion)
9. [Fase 8: Eventos y Reglas de Negocio](#9-fase-8-eventos-y-reglas-de-negocio)
10. [Fase 9: Funciones JavaScript](#10-fase-9-funciones-javascript)
11. [Fase 10: Generación de READMEs](#11-fase-10-generacion-de-readmes)
12. [Fase 11: Tareas Finales](#12-fase-11-tareas-finales)
13. [Fase 12: Validación](#13-fase-12-validacion)
14. [Ejemplos por Sector](#14-ejemplos-por-sector)
15. [Actualización del Skill](#15-actualizacion-del-skill)
16. [Prohibiciones Explicitas](#16-prohibiciones-explicitas)
---

## 1. Fase 0: Diagrama de Flujo Completo

```
INICIO: Usuario solicita nuevo proyecto
         |
         v
[FASE 0] Diagrama / Planificacion
         |
         v
[FASE 1] Analisis de Requisitos
         |-- Identificar sector y funcionalidades
         |-- Determinar colecciones necesarias
         |-- Identificar pantallas requeridas
         |-- Definir paleta de colores e iconos
         |
         v
[FASE 2] Diseno del Modelo de Datos
         |-- Colecciones base (Empresas, Usuarios)
         |-- Colecciones adicionales del proyecto
         |-- Relaciones entre colecciones
         |-- Tipos de campos y visibilidad
         |
         v
[FASE 3] Estilos CSS
         |-- default.css (estilos globales)
         |-- colors.css (paleta de colores, opcional)
         |
         v
[FASE 4] Creación de Estructura de Carpetas
         |-- bd/, icons/, files/, fonts/
         |
         v
[FASE 5] Generacion de Archivos de Configuración
         |-- app.xml (configuracion global)
         |-- app.ini (metadatos)
         |-- mappings.xne (SOLO Empresas y Usuarios)
         |
         v
[FASE 6] Generacion de Colecciones
         |-- Un archivo .xne por cada coleccion adicional
         |-- Definir campos, tipos, visibilidad
         |
         v
[FASE 7] Generacion de Pantallas
         |-- Decidir si la app tiene autologin o login
         |-- Login.xne (solo si NO es autologin)
         |-- EntradaApp.xne / MenuPrincipal.xne (punto de entrada)
         |-- Consola.xne (obligatoria, siempre; con replica completa o solo info de dispositivo)
         |-- Pantallas de listas, detalle, mapas, config
         |
         v
[FASE 8] Eventos y Reglas de Negocio
         |-- Eventos de ciclo de vida (create, insert, before-edit, after-edit, delete)
         |-- Eventos de coleccion Empresas (onlogon, onlogoff, maintenance, replica-ok...)
         |-- Eventos de contents (selecteditem, load, auto-selecteditem)
         |-- Eventos de controles (onclick, onchange, onback, onfocus...)
         |-- Eventos especiales de app (on-app-foreground, on-app-background, inactividad)
         |
         v
[FASE 9] Funciones JavaScript
         |-- functions.js (funciones globales)
         |-- Scripts adicionales si es necesario
         |
         v
[FASE 10] Generacion de READMEs
         |-- README.md en cada carpeta (bd/, icons/, files/, fonts/)
         |-- README.md principal con prompt detallado
         |
         v
[FASE 11] Tareas Finales (en este orden exacto)
         |-- 1. Generar base de datos con xone-db-tools create-db
         |-- 2. Insertar datos iniciales (Empresa + Usuario admin)
         |-- 3. Descargar iconos (Iconify API — PNG, JPG o SVG validos)
         |
         v
[FASE 12] Validación
         |-- Ejecutar checklist completo
         |-- Verificar estructura, BD, iconos
         |
         v
FIN: Proyecto completo y validado
```

---

## 2. Fase 1: Análisis de Requisitos

### 2.1 Objetivo

Entender que hay que construir antes de escribir código. El agente debe inferir todo lo que pueda del contexto de la solicitud, y preguntar **únicamente lo que no pueda deducir por si mismo**.

> **REGLA:** No lanzar un interrogatorio. Analizar primero la solicitud, inferir, y preguntar solo lo mínimo imprescindible para no poder continuar.

---

### 2.2 Datos Mínimos Obligatorios

Son los únicos datos sin los cuales es imposible iniciar el proyecto. Si no están presentes en la solicitud, preguntar **en un único mensaje**, todos juntos:

| Dato | Por que es obligatorio |
|------|------------------------|
| **¿Que hace la app?** — descripción breve | Sin esto no se puede inferir nada: colecciones, pantallas, lógica |
| **¿Con login o sin login (autologin)?** | Determina si se genera Login.xne y como se configura app.xml |
| **¿Tiene replica con servidor?** | Determina el contenido de la Consola y la configuración de license.ini |

Si el programador ya lo ha descrito en su solicitud, no volver a preguntar.

---

### 2.3 Datos que el Agente Infiere

El agente deduce estos datos del contexto sin preguntar. Si la inferencia es dudosa, aplica el valor por defecto y avanza:

| Dato | Como inferirlo | Valor por defecto |
|------|----------------|-------------------|
| Nombre del proyecto | Del título o descripción de la solicitud | `MiProyecto` |
| Sector | De las entidades y funcionalidades descritas | `Servicios` |
| Colecciones necesarias | De las funcionalidades y entidades mencionadas | Se modelan según el sector |
| Pantallas necesarias | De las colecciones y el flujo descrito | Lista + Detalle por cada coleccion |
| Pantalla de entrada | Si no se indica, usar `EntradaApp` | `EntradaApp` |
| Roles de usuario | De la descripción o del sector | `Administrador, Usuario` |
| Prefijo BD | Si no se indica explicitamente | `gen` |
| Plataforma | Si no se indica | Android |
| Orientación | Si no se indica | Portrait |
| Resolución de referencia | Si no se indica | 1080x1920 |
| Colores | Si no se indican, usar paleta Material Design neutra | `#2196F3`, `#757575`, `#FF5722` |
| Fuente | Si no se indica | `Roboto-Regular.ttf` |
| Integraciones (GPS, camara, PDF...) | De las funcionalidades descritas | Ninguna |
| Datos iniciales BD | Siempre | Empresa de prueba + usuario admin |

---

### 2.4 Datos que el Programador Puede Aportar Voluntariamente

El agente no pregunta por estos, pero si el programador los aporta, los usa:

- Diseños de pantallas (Figma, wireframes, imágenes)
- Colores corporativos o logo
- Fuente tipografica corporativa
- Campos especificos de las entidades
- Restricciones técnicas (versión Android, seguridad, inactividad)
- URL del servidor de replica e intervalo de sincronización
- Prefijo de BD diferente a `gen`

---

### 2.5 Regla de Decisión Técnica

```
ANTES de escribir codigo:
1. ¿Existe documentacion en las knowledgebases?
   -> SI: Seguir la documentacion exactamente
   -> NO: Buscar ejemplos en templates/projects/

2. ¿Hay ejemplos similares en los proyectos?
   -> SI: Analizar el patron y adaptarlo
   -> NO: Preguntar al usuario antes de improvisar

3. ¿El atributo/funcion/propiedad esta documentado?
   -> SI: Usar solo valores documentados
   -> NO: NO inventar, buscar alternativas documentadas
```

---

### 2.6 Donde Buscar Referencia

| Necesidad | Fuente |
|-----------|--------|
| Estructura de proyecto | `knowledgebase/docs/xone-project-structure-knowledgebase.md` |
| Atributos XML | `knowledgebase/docs/xone-xml-structure-knowledgebase.md` |
| API JavaScript | `knowledgebase/docs/xone-javascript-api-knowledgebase.md` |
| Estilos CSS | `knowledgebase/docs/xone-css-knowledgebase.md` |
| Guía paso a paso | `knowledgebase/docs/xone-new-project-guide-knowledgebase.md` |
| Proyecto de ejemplo | `knowledgebase/examples/UseCars/` |
| Proyectos reales | `templates/projects/` |


## 3. Fase 2: Diseño del Modelo de Datos

### 3.1 Objetivo

Disenar el modelo de datos completo del proyecto, incluyendo colecciones, campos, tipos, visibilidad y relaciones entre entidades.

### 3.2 Colecciones Base Obligatorias

Toda aplicación XOne debe tener al mínimo estas dos colecciones en `mappings.xne`.

**Estructura mínima obligatoria de `mappings.xne`:**

```xml
<?xml version="1.0" encoding="iso-8859-15"?>
<xml>
  <collprops type="general">

    <coll name="Empresas" title="la empresa"
          sql="select e.* from ##PREF##empresa e"
          objname="empresa" updateobj="empresa" progid="ASGestion.CASEmpresa">
      <group name="General" id="1">
        <prop name="CODIGO" visible="3" type="N" fieldsize="12" />
        <prop name="NOMBRE" type="T" fieldsize="30" size="250" />
      </group>
    </coll>

    <coll name="Usuarios" title="el usuario"
          sql="select u.* from ##PREF##usuarios u"
          objname="usuarios" updateobj="usuarios" progid="ASGestion.CASUser">
      <group name="General" id="1">
        <prop name="IDEMPRESA" visible="0" type="N" mapcol="Empresas" mapfld="ID" />
        <prop name="CODIGO" visible="3" type="T" fieldsize="10" size="50" />
        <prop name="LOGIN" visible="3" type="T" fieldsize="10" size="50" />
        <prop name="PWD" type="X" fieldsize="10" size="50" visible="0" />
        <prop name="NOMBRE" visible="3" type="T" fieldsize="30" size="50" />
      </group>
      <create>
        <action name="setval" field="IDEMPRESA" value="##ENTID##" />
      </create>
    </coll>

  </collprops>
</xml>
```

**Reglas críticas del mappings.xne:**
- Solo contiene `Empresas` y `Usuarios`. El resto de colecciones van en archivos `.xne` separados
- El campo de relación en Usuarios es `IDEMPRESA` (FK a Empresas), con `mapcol="Empresas" mapfld="ID"`
- El evento `<create>` en Usuarios asigna automáticamente `##ENTID##` al crear un nuevo usuario
- El encoding puede ser UTF-8 o `iso-8859-15` (coherente con los bytes; el motor respeta el declarado)

### 3.3 Tipos de Propiedades Disponibles

Los tipos de XOne se dividen en dos categorías: los que **se persisten en base de datos** y los que son **solo visuales** (no generan columna en BD).

#### Tipos de Datos (se persisten en BD)

| Tipo | SQLite | Descripción | Ejemplo de Uso |
|------|--------|-------------|----------------|
| `T` | TEXT | Texto. Admite variantes: texto simple, multilinea (con `lines`) o mapeada (con `linkedto`) | Nombres, descripciones, campos enlazados |
| `N` | INTEGER | Número entero | IDs, cantidades, flags numéricos |
| `N2` | REAL | Número con 2 decimales | Precios, importes |
| `N3` | REAL | Número con 3 decimales | Coordenadas |
| `N4` | REAL | Número con 4 decimales | Precisión alta |
| `N5` | REAL | Número con 5 decimales | Precisión muy alta |
| `N6` | REAL | Número con 6 decimales | GPS lat/lon |
| `TN` | TEXT | Número almacenado como texto (entero) | Números con leading zeros, códigos numéricos |
| `TN2` | TEXT | Número almacenado como texto (2 decimales) | Importes formateados como texto |
| `TN3` | TEXT | Número almacenado como texto (3 decimales) | Medidas con precisión |
| `TN4` | TEXT | Número almacenado como texto (4 decimales) | Precisión alta |
| `TN5` | TEXT | Número almacenado como texto (5 decimales) | Precisión muy alta |
| `TN6` | TEXT | Número almacenado como texto (6 decimales) | GPS como texto |
| `X` | TEXT | Password — se muestra enmascarado, admite `hash-type` y `encode` | Contrasenas |
| `D` | TEXT | Fecha | Fechas |
| `DT` | TEXT | Fecha y hora | Timestamps |
| `TT` | TEXT | Hora en formato texto | Horas, duraciones |
| `NC` | INTEGER | Checkbox / Toggle (0=no, 1=si) | Opciones booleanas |
| `IMG` | TEXT | Imagen (ruta al fichero) | Fotos referenciadas, logos |
| `PH` | TEXT | Fotografía — captura desde camara del dispositivo | Fotos tomadas en campo |
| `VD` | TEXT | Video — grabacion, selección o escaner QR/barcode | Grabacion de video, lectura de códigos |
| `AT` | TEXT | Adjunto — permite adjuntar ficheros al registro | Documentos adjuntos |
| `DR` | TEXT | Dibujo / firma a mano alzada (ruta al fichero) | Firmas, croquis |
| `WEB` | TEXT | WebView — URL o HTML embebido | Contenido web, videos online |
| `O` | (no aplica) | Sub-objeto JavaScript — NO genera columna ni se persiste | Estructuras temporales en memoria |

#### Tipos de UI (NO se persisten en BD — solo visuales)

Estos tipos definen controles visuales que **no generan columna en la base de datos**. Se usan exclusivamente para la interfaz.

| Tipo | Descripción | Uso |
|------|-------------|-----|
| `L` | Etiqueta de texto (solo lectura) — forma preferida. Muestra el `title`; sin `title`, usa el valor del campo como fallback | Títulos, labels, textos informativos o valores dinámicos |
| `TL` | Alias legacy de `L` (mismo control) | Equivalente a `type="L"` |
| `THTML` | Etiqueta con contenido HTML enriquecido | Textos con formato HTML embebido (negrita, colores, enlaces) |
| `B` | Botón | Acciones, navegación, llamadas a ExecuteNode |
| `Z` | Contents — lista embebida dentro de otra coleccion | Subgrids, detalles de maestro-detalle, mapas (`viewmode="mapview"`), kanban, slider, etc. |

### 3.4 Sistema de Visibilidad (Bitmask)

El atributo `visible` define **en que contextos de la UI se pinta el campo**. Es estático — no se puede cambiar en tiempo de ejecución por script ni por condiciones. Si un campo tiene `visible="0"`, no existe en pantalla en ningun momento.

Cada bit representa un contexto:

| Bit | Valor | Contexto |
|-----|-------|----------|
| Bit 0 | 1 | Edición (formulario individual) |
| Bit 1 | 2 | Lista (vista de registros) |
| Bit 2 | 4 | Content (lista embebida `type="Z"`) |
| Bit 3 | 8 | Combo (desplegable) |

Cualquier combinacion de bits es valida. Las más usadas:

| Valor | Contextos | Uso típico |
|-------|-----------|------------|
| `0` | Ninguno | Campo puramente interno — solo para lógica |
| `1` | Edición | Solo en formulario individual |
| `2` | Lista | Solo en vista de registros |
| `3` | Edición + Lista | En formulario y en lista |
| `4` | Content | Solo en listas embebidas |
| `7` | Edición + Lista + Content | **El más habitual** |
| `8` | Combo | Solo en desplegables |
| `15` | Todos | Edición + Lista + Content + Combo |

**Regla general:**
- Campos de BD internos (ID, ROWID): `visible="0"`
- Campos visibles para el usuario: `visible="7"`
- Campos solo en formulario: `visible="1"`
- Campos solo en listas: `visible="2"`

> **Diferencia con `disablevisible`:** `visible` es estático — decide si el campo existe en pantalla en ese contexto. `disablevisible` es dinámico — el campo existe pero se muestra u oculta según el valor de otro campo en tiempo de ejecución.

### 3.5 Relaciones entre Colecciones (Foreign Keys)

Las relaciones se definen con los atributos `mapcol` y `mapfld`:

```xml
<!-- Campo que referencia otra coleccion -->
<prop name="IDEMPRESA" type="N" visible="7" mapcol="Empresas" mapfld="ID" />
<!-- Significa: IDEMPRESA referencia al campo ID de la coleccion Empresas -->
```

### 3.6 Ejemplo de Diseño de Modelo

Para una app de gestion de entregas:

```
Empresas (mappings.xne)
├── CODIGO, NOMBRE (declarar como <prop>; ID y ROWID los gestiona XOne, no hace falta declararlos)
├── CIF, DIRECCION, TELEFONO (adicionales)

Usuarios (mappings.xne)
├── CODIGO, NOMBRE, IDEMPRESA, LOGIN, PWD (declarar como <prop>; ID y ROWID los gestiona XOne)
├── ROL, EMAIL, TELEFONO, ACTIVO (adicionales)

Clientes (Clientes.xne)
├── ID, CODIGO, NOMBRE, DIRECCION, TELEFONO, EMAIL, LATITUD, LONGITUD

Pedidos (Pedidos.xne)
├── ID, ID_CLIENTE (FK->Clientes), FECHA, ESTADO, TOTAL, OBSERVACIONES

Entregas (Entregas.xne)
├── ID, ID_PEDIDO (FK->Pedidos), ID_REPARTIDOR (FK->Usuarios)
├── FECHA_ENTREGA, FIRMA, FOTO_ENTREGA, LATITUD, LONGITUD, ESTADO
```

---

## 4. Fase 3: Estilos CSS

### 4.1 Objetivo

Crear el archivo `default.css` con los estilos globales de la aplicación. Opcionalmente, crear `colors.css` para la paleta de colores.

> **ADVERTENCIA:** Si en el nodo `<app>` del mappings esta definido `compatibility-mode="true"`, los estilos CSS **NO se aplicaran**. Verificar siempre que este atributo no este presente o sea `false`.

---

### 4.2 Declaración de CSS en app.xml

Los ficheros CSS se declaran en el nodo `<app>` con el nodo `<style>`. Se pueden declarar multiples ficheros aplicados según condiciones de plataforma, tamaño y orientación:

```xml
<app prefix="gen" version="1.0.0" ...>
    <style url="default.css" />
    <style url="default_phone.css" conditions="phone:vertical"/>
    <style url="default_phone_hor.css" conditions="phone:horizontal"/>
    <style url="default_tablet.css" conditions="tablet:vertical"/>
    <style url="default_tablet_hor.css" conditions="tablet:horizontal"/>
    <style url="default_android_ver.css" conditions="android:phone:vertical"/>
    <style url="default_iphone.css" conditions="ios:phone"/>
    <style url="default_ipad_vertical.css" conditions="ios:tablet:vertical"/>
</app>
```

**Formato del atributo `conditions`:** `PLATAFORMA:TAMAÑO:ORIENTACION` — siempre en este orden y en minusculas.

| Parte | Valores posibles |
|-------|-----------------|
| Plataforma | `android`, `ios`, `wm`, `bb`, `wp` |
| Tamaño | `phone`, `tablet`, `mini` (android <3.5"), `hiphone` (android >4.5" y <7") |
| Orientación | `vertical`, `horizontal` |

> El fichero `default.css` (sin conditions) se aplica siempre como base. Los demas lo sobreescriben según condición.

---

### 4.3 Prioridad de Estilos (de menor a mayor)

Los estilos en XOne tienen este orden de prioridad. Un nivel superior sobreescribe al inferior:

| Prioridad | Origen | Ejemplo |
|-----------|--------|---------|
| 1 (más baja) | Valores predefinidos del framework | Valores por defecto internos de XOne |
| 2 | Nodos de sistema en CSS (`coll`, `group`, `frame`, `prop` sin punto) | `prop { fontsize: 10; }` |
| 3 | Clases de nodos de sistema en CSS (`prop.clase`, `group.clase`) | `prop.particular { labelbox: false; }` |
| 4 | Clases propias en CSS (`.miclase`) | `.btnPrimario { bgcolor: #2196F3; }` |
| 5 (más alta) | Atributos definidos directamente en la etiqueta XML | `<prop bgcolor="#FF0000" .../>` |

---

### 4.4 Tipos de Selectores CSS en XOne

#### Nodos de sistema (sin punto — afectan a todos los nodos de ese tipo)

```css
coll { editmask: 0; notab: true; }
group { imgbk: portada_interior.jpg; }
frame { width: 100%; framebox: false; }
prop { fontsize: 10; labelbox: false; }
```

#### Clases de nodo de coll (se aplican con `class=` en el nodo `coll`)

Cuando se pone `class="nombreclase"` en una `coll`, los estilos `prop.nombreclase`, `group.nombreclase` y `frame.nombreclase` se aplican automáticamente a todos sus hijos:

```css
prop.miColl { labelbox: false; fontsize: 9; }
group.miColl { imgbk: fondo.jpg; }
frame.miColl { bgcolor: #FFFFFF; }
```
```xml
<coll name="MiColl" class="miColl" ...>
```

#### Clases propias (con punto — se aplican con `class=` en cualquier nodo)

```css
.btnPrimario { bgcolor: #2196F3; forecolor: #FFFFFF; }
.frameHeader { width: 100%; height: 120p; bgcolor: #2196F3; }
```
```xml
<prop name="BTN" type="B" class="btnPrimario" />
<frame name="frmHeader" class="frameHeader" />
```

#### Selectores por tipo de prop (`prop:TIPO`)

```css
prop:B { bgcolor: #2196F3; forecolor: #FFFFFF; }
prop:IMG { width: 500p; height: 400p; }
prop:Z { width: 96%; lmargin: 2%; }
prop:NC { apply-css: true; }
prop:AT { img-att: attach.png; }
prop:PH { img-camera: camera.png; }
prop:VD { img-video: video.png; }
```

#### Herencia con `extends`

```css
.btnSecundario {
    extends: .btnPrimario;  /* hereda todos los atributos de btnPrimario */
    bgcolor: #757575;       /* sobreescribe solo el color */
}
```

---

### 4.5 Plantilla: default.css

```css
/* ============================================
   ESTILOS BASE - PROYECTO XONE
   NombreProyecto - v1.0.0
   ============================================ */

/* -------- NODOS DE SISTEMA -------- */
coll {
    notab: true;
    show-toolbar: false;
    group-swipe: false;
    editmask: 0;
    dependent: false;
    check-owner: false;
    cell-bgcolor: #FFFFFF;
    cell-border-width: 0;
    cell-border: false;
    cell-even-color: #F5F5F5;
    cell-odd-color: #FFFFFF;
    cell-height: 80p;
    cell-tpadding: 4p;
    cell-bpadding: 4p;
}

group {
    /* sin estilos globales por defecto */
}

frame {
    framebox: false;
    bgcolor: #00000000;
}

prop {
    fontname: Roboto-Regular.ttf; /* Puede ser cualquier fuente .ttf/.otf incluida en files/ */
    fontsize: 10;
    labelbox: false;
    label-wrap: true;
    text-border: false;
    width: 96%;
    lmargin: 2%;
    lines: 1;
    fixed-lines: true;
}

/* -------- TIPOS DE PROP -------- */
prop:B {
    forecolor: #FFFFFF;
    bgcolor: #2196F3;
    border-corner-radius: 8;
    ripple-effect: true;
    forecolor-disabled: #ADAA9C;
    bgcolor-disabled: #C6CEC6;
    forecolor-pressed: #FFFFFF;
    bgcolor-pressed: #1565C0;
}

prop:NC {
    apply-css: true;
}

prop:IMG {
    labelwidth: 0;
    width: 500p;
    height: 400p;
    file-maxwidth: 800;
    file-maxheight: 600;
    img-sign: bt_firma.png;
    img-sign-sel: bt_firma.png;
    img-delete: bt_delete.png;
    img-delete-sel: bt_delete.png;
    img-save: guardar.png;
    img-save-sel: guardar.png;
}

prop:PH {
    img-camera: bt_camera.png;
    img-camera-sel: bt_camera_sel.png;
}

prop:VD {
    img-video: bt_video.png;
    img-video-sel: bt_video_sel.png;
}

prop:AT {
    img-att: bt_attach.png;
    img-att-sel: bt_attach_sel.png;
}

prop:Z {
    extends: prop;
    bgcolor: #F2F2F2;
    width: 96%;
    lmargin: 2%;
    tmargin: 2%;
}

/* ============================================
   CLASES DE LAYOUT
   ============================================ */

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

.frameFooter {
    width: 100%;
    height: 100p;
    bgcolor: #F5F5F5;
    align: center;
}

/* ============================================
   CLASES DE GRUPOS
   ============================================ */

.groupNoTab {
    tab-visible: false;
}

.groupConTab {
    tab-visible: true;
    tab-height: 48p;
    tab-fontsize: 12;
    group-theme: material;
    tab-mode: scrollable;
}

.groupFixed {
    fixed: true;
    orientation: top;
}

/* ============================================
   CLASES DE BOTONES
   ============================================ */

.btnPrimario {
    width: 90%;
    height: 50p;
    bgcolor: #2196F3;
    forecolor: #FFFFFF;
    border-corner-radius: 8;
    text-align: center;
    fontsize: 14;
    align: center;
    ripple-effect: true;
}

.btnSecundario {
    extends: .btnPrimario;
    bgcolor: #757575;
}

.btnPeligro {
    extends: .btnPrimario;
    bgcolor: #F44336;
}

.btnExito {
    extends: .btnPrimario;
    bgcolor: #4CAF50;
}

.btnTransparente {
    bgcolor: #00000000;
    forecolor: #2196F3;
    fontsize: 14;
    text-align: center;
}

/* Boton con ejecucion asincrona (no bloquea UI) */
.btnAsync {
    extends: .btnPrimario;
    execute-async: true;
}

/* ============================================
   CLASES DE TEXTO
   ============================================ */

/* Labels (type="L"): el texto es el `title` (o el valor del campo si no hay `title`), que se
   pinta dentro del ancho de la etiqueta. NO usar labelwidth:0 aquí — ocultaría el texto.
   (labelwidth:0 solo es correcto en campos con contenido en el valor, o IMG.) */
.textoTitulo {
    fontsize: 18;
    forecolor: #212121;
    align: center;
    fontname: Roboto-Bold.ttf;
}

.textoSubtitulo {
    fontsize: 14;
    forecolor: #757575;
    align: center;
}

.textoEditable {
    labelwidth: 0;
    text-border: true;
    text-border-bottom: true;
    text-border-left: false;
    text-border-right: false;
    text-border-top: false;
    text-border-color: #BDBDBD;
    lpadding: 10p;
}

/* Campo de texto con tooltip flotante */
.textoConTooltip {
    labelwidth: 0;
    border-corner-radius: 8;
    floating-tooltip: true;
    tooltip-forecolor: #757575;
    expanded-hint-color: #757575;
    show-counter: true;
}

.textoSoloLectura {
    labelwidth: 0;
    text-border: false;
    locked: true;
    forecolor: #757575;
}

.etiquetaLabel {
    labelwidth: 7;
    labelfont-underline: false;
    labelshadow: false;
    labelbox: false;
    labelfont-bold: true;
    labelfont-size: 8;
}

/* ============================================
   CLASES DE ICONOS
   ============================================ */

.iconoAccion {
    width: 48p;
    height: 48p;
    labelwidth: 0;
}

.iconoMenu {
    width: 64p;
    height: 64p;
    labelwidth: 0;
}

/* ============================================
   CLASES DE TARJETAS (CARDS)
   ============================================ */

.cardItem {
    width: 90%;
    height: 100p;
    bgcolor: #FFFFFF;
    border-corner-radius: 8;
    align: center;
    tmargin: 10p;
}

/* ============================================
   CLASES DE LISTADOS (contents)
   ============================================ */

.listado {
    grid-bgcolor: #00000000;
    grid-text-bgcolor: #00000000;
    show-toolbar: false;
    check-owner: false;
    dependent: false;
    show-selected-item: false;
}

/* ============================================
   CLASES DE SEPARADORES
   ============================================ */

.separadorH {
    labelbox: false;
    width: 100%;
    height: 2p;
    bgcolor: #E0E0E0;
    tmargin: 5p;
}

/* ============================================
   CLASES DE CALENDARIO
   ============================================ */

.calendarioBase {
    show-toolbar: false;
}

.calendarioContenido {
    cell-bgcolor: #FF328BA9;
    cell-forecolor: #FFFFFF;
    cell-border-width: 4;
    cell-border-color: #00000000;
    cell-align: center;
    align: center;
    fontsize: 25;
    cell-selected-bgcolor: #00000000;
    cell-selected-forecolor: #FF328BA9;
    cell-selected-border-color: #00000000;
    weekdays-bgcolor: #00000000;
    weekdays-forecolor: #FF328BA9;
    weekdays-fontsize: 6;
    weekdays-longname: false;
    weekdays-align: top|left;
    border-width: 2;
    page-swipe: true;
    cell-other-month-bgcolor: #50000000;
    border: false;
}

/* ============================================
   CLASES DE ANIMACION
   ============================================ */

.animFadeIn {
    animation-in: ##ALPHA_IN##;
    animation-in-delay: 300;
    animation-out: ##ALPHA_OUT##;
    animation-out-delay: 300;
}

.animSlideRight {
    animation-in: ##RIGHT_IN##;
    animation-in-delay: 300;
    animation-out: ##LEFT_OUT##;
    animation-out-delay: 300;
}
```

---

### 4.6 Plantilla: colors.css (Opcional)

```css
/* ============================================
   PALETA DE COLORES - NombreProyecto
   Modificar estos colores segun el proyecto
   ============================================ */

/* Primarios */
.colorPrimario { bgcolor: #2196F3; }
.colorPrimarioDark { bgcolor: #1976D2; }
.colorPrimarioLight { bgcolor: #BBDEFB; }

/* Acento */
.colorAccento { bgcolor: #FF5722; }

/* Fondos */
.colorFondo { bgcolor: #FFFFFF; }
.colorSuperficie { bgcolor: #F5F5F5; }

/* Texto */
.textoColorPrimario { forecolor: #212121; }
.textoColorSecundario { forecolor: #757575; }
.textoColorBlanco { forecolor: #FFFFFF; }

/* Estado */
.colorExito { bgcolor: #4CAF50; }
.colorAdvertencia { bgcolor: #FFC107; }
.colorError { bgcolor: #F44336; }
```

---

### 4.7 Tabla de Transparencias Alpha

En XOne los colores usan formato `#AARRGGBB` donde `AA` es el canal alpha. Referencia:

| Alpha | Hex | Alpha | Hex |
|-------|-----|-------|-----|
| 100% (opaco) | `FF` | 45% | `73` |
| 95% | `F2` | 40% | `66` |
| 90% | `E6` | 35% | `59` |
| 85% | `D9` | 30% | `4D` |
| 80% | `CC` | 25% | `40` |
| 75% | `BF` | 20% | `33` |
| 70% | `B3` | 15% | `26` |
| 65% | `A6` | 10% | `1A` |
| 60% | `99` | 5% | `0D` |
| 55% | `8C` | 0% (transparente) | `00` |
| 50% | `80` | | |

Ejemplo: rojo al 50% de opacidad = `#80FF0000`

---

### 4.8 Referencia Rápida de Atributos CSS XOne

| Atributo XOne | Equivalente Web (NO USAR) | Descripción |
|---------------|---------------------------|-------------|
| `fontsize` | font-size | Tamaño de fuente |
| `fontname` | font-family | Nombre del fichero de fuente |
| `fontbold` | font-weight | Negrita (`true`/`false`) |
| `labelfont-bold` | — | Negrita del label |
| `labelfont-size` | — | Tamaño del label |
| `labelfont-underline` | — | Subrayado del label |
| `labelwidth` | — | Proporcion del label (0 = sin label) |
| `labelbox` | — | Muestra borde en el label (`true`/`false`) |
| `forecolor` | color | Color del texto |
| `bgcolor` | background-color | Color de fondo |
| `text-forecolor` | — | Color del texto dentro del campo editable |
| `text-bgcolor` | — | Color de fondo del campo editable |
| `text-forecolor-focus` | — | Color de texto al tener el foco |
| `text-bgcolor-focus` | — | Color de fondo al tener el foco |
| `text-forecolor-disabled` | — | Color de texto deshabilitado |
| `text-bgcolor-disabled` | — | Color de fondo deshabilitado |
| `forecolor-disabled` | — | Color de texto del botón deshabilitado |
| `bgcolor-disabled` | — | Color de fondo del botón deshabilitado |
| `forecolor-pressed` | — | Color de texto del botón pulsado |
| `bgcolor-pressed` | — | Color de fondo del botón pulsado |
| `tmargin` | margin-top | Margen superior |
| `bmargin` | margin-bottom | Margen inferior |
| `lmargin` | margin-left | Margen izquierdo |
| `rmargin` | margin-right | Margen derecho |
| `tpadding` | padding-top | Padding superior |
| `bpadding` | padding-bottom | Padding inferior |
| `lpadding` | padding-left | Padding izquierdo |
| `rpadding` | padding-right | Padding derecho |
| `border-corner-radius` | border-radius | Radio de esquinas |
| `border-width` | border-width | Ancho del borde |
| `border-color` | border-color | Color del borde |
| `text-align` | text-align | Alineacion del texto (`left`, `center`, `right`) |
| `align` | — | Alineacion del control dentro del frame |
| `text-border` | border | Borde del campo de texto (`true`/`false`) |
| `text-border-top` | border-top | Borde superior del campo |
| `text-border-bottom` | border-bottom | Borde inferior del campo |
| `text-border-left` | border-left | Borde izquierdo del campo |
| `text-border-right` | border-right | Borde derecho del campo |
| `text-border-color` | border-color | Color del borde del campo |
| `floating-tooltip` | placeholder | Tooltip flotante como placeholder |
| `tooltip` | placeholder | Texto del tooltip |
| `tooltip-forecolor` | — | Color del texto del tooltip |
| `expanded-hint-color` | — | Color del hint expandido (Material Design) |
| `show-counter` | — | Muestra contador de caracteres |
| `ripple-effect` | — | Efecto ripple en botones |
| `execute-async` | — | Ejecuta la acción del botón de forma asíncrona |
| `apply-css` | — | Aplica estilos CSS al control (requerido en `prop:NC`) |
| `file-maxwidth` | — | Ancho máximo de imagen capturada (px) |
| `file-maxheight` | — | Alto máximo de imagen capturada (px) |
| `img` | — | Imagen del botón principal |
| `img-sel` | — | Imagen al pulsar el botón |
| `img-delete` | — | Imagen del botón borrar |
| `img-search` | — | Imagen del botón lupa |
| `img-spinner` | — | Imagen del combo/spinner |
| `img-phone` | — | Imagen del botón telefono |
| `img-undo` | — | Imagen del botón deshacer |
| `img-date` | — | Imagen del botón fecha |
| `img-time` | — | Imagen del botón hora |
| `img-att` | — | Imagen del botón adjunto |
| `img-camera` | — | Imagen del botón camara (`prop:PH`) |
| `img-video` | — | Imagen del botón video (`prop:VD`) |
| `img-sign` | — | Imagen del botón firma (`prop:IMG`) |
| `img-save` | — | Imagen del botón guardar firma (`prop:IMG`) |
| `img-width` | — | Ancho del botón imagen |
| `img-height` | — | Alto del botón imagen |
| `imgbk` | background-image | Imagen de fondo del grupo o frame |


## 5. Fase 4: Creación de Estructura de Carpetas

### 5.1 Objetivo

Crear la estructura de carpetas y ficheros raiz obligatorios del proyecto.

### 5.2 Comandos de Creación

```bash
# Crear estructura completa
mkdir -p NombreProyecto
cd NombreProyecto
mkdir -p bd icons files fonts
```

### 5.3 Estructura Completa Resultante

```
NombreProyecto/
├── app.xml                      # [OBLIGATORIO] Configuración global
├── app.ini                      # [OBLIGATORIO] Metadatos
├── license.ini                  # [OBLIGATORIO] Licencia y conexion/replica
├── mappings.xne                 # [OBLIGATORIO] Solo Empresas y Usuarios
├── default.css                  # [OBLIGATORIO] Estilos globales
├── functions.js                 # [OBLIGATORIO] Funciones JavaScript
├── EntradaApp.xne               # [OBLIGATORIO] Punto de entrada (o MenuPrincipal.xne)
├── Consola.xne                  # [OBLIGATORIO] Consola tecnica siempre presente
├── Login.xne                    # [CONDICIONAL] Solo si autologon="false"
├── splash.png                   # [OPCIONAL] Imagen de splash de carga inicial
├── README.md                    # [OBLIGATORIO] Descripción del proyecto
│
├── [Coleccion].xne              # Un archivo por coleccion adicional
├── [Pantalla].xne               # Un archivo por pantalla de negocio
│
├── bd/                          # [OBLIGATORIO]
│   ├── gestion.db               # Se genera en Fase 11
│   └── README.md
├── icons/                       # [OBLIGATORIO]
│   ├── app_icon.png             # Se genera en Fase 11
│   └── README.md
├── files/                       # [OBLIGATORIO]
│   └── README.md
└── fonts/                       # [RECOMENDADO]
    └── README.md
```

### 5.4 Ficheros Raiz Obligatorios

| Fichero | Obligatorio | Generado en |
|---------|-------------|-------------|
| `app.xml` | Siempre | Fase 5 |
| `app.ini` | Siempre | Fase 5 |
| `license.ini` | Siempre | Fase 5 |
| `mappings.xne` | Siempre | Fase 5 |
| `default.css` | Siempre | Fase 3 |
| `functions.js` | Siempre | Fase 9 |
| `EntradaApp.xne` / `MenuPrincipal.xne` | Siempre (uno de los dos) | Fase 7 |
| `Consola.xne` | Siempre | Fase 7 |
| `Login.xne` | Solo si `autologon="false"` | Fase 7 |

### 5.4.1 Pantalla de splash

El splash que se muestra durante la carga inicial **no es una `<coll>` XML** — es un fichero estático en la raíz del proyecto. La carga la hace `LoadAppActivity` antes incluso de que arranque el sistema de colecciones.

**Convención:** poner un fichero `splash.png` en la carpeta raíz del proyecto.

El framework busca por orden los siguientes ficheros en la raíz y usa el primero que encuentre:

| Tipo | Ficheros (por orden de prioridad) |
|------|-----------------------------------|
| Vídeo | `splash.3gp`, `splash.mp4` |
| Imagen | `splash.jpg`, `splash.png`, `splash.gif`, `splash.bmp`, `splash.webp`, `splash.apng` |

- Si no hay ninguno, el framework usa un splash interno por defecto.
- Para vídeos, `LoadAppActivity` añade automáticamente un botón "Saltar".
- Imágenes animadas: `.gif` (`GifDrawable`), `.webp` animado (Android 9+), `.apng` (`PngReadHelper`).
- El ancho se ajusta al 100% de la pantalla manteniendo el ratio.

**No confundir** con:
- `load-imgbk` en `<app>`: imagen de fondo del EditView, no el splash.
- `EntradaApp.xne`: pantalla post-login que se abre tras autenticarse, no el splash.

### 5.5 Regla Crítica sobre Colecciones

```
mappings.xne     -> SOLO Empresas y Usuarios (nunca colecciones de negocio)
Productos.xne    -> Coleccion Productos (archivo separado)
Pedidos.xne      -> Coleccion Pedidos (archivo separado)
Clientes.xne     -> Coleccion Clientes (archivo separado)
```

### 5.6 Fuente `.xne` vs Salida Generada `.xml`

En XOne hay que distinguir claramente entre **ficheros fuente** (editables, lo que el agente crea/modifica) y **artefactos generados** (producidos automáticamente, se ignoran).

| Extensión | Rol | Quien lo edita | El agente... |
|-----------|-----|----------------|--------------|
| `.xne` | Fuente de colecciones y pantallas | Programador + agente IA | SI crea, SI edita, SI lee |
| `.xml` (colecciones/pantallas) | Artefacto generado por XOneStudio a partir del `.xne` | Nadie (se regenera) | NO crea, NO edita, NO lee, NO referencia |
| `app.xml` | Configuración global (única excepción — es fuente, no tiene `.xne` que lo genere) | Programador + agente IA | SI crea, SI edita, SI lee |
| `app.ini` | Metadatos de la app (fuente) | Programador + agente IA | SI crea, SI edita, SI lee |
| `.css` | Estilos propietarios (fuente) | Programador + agente IA | SI crea, SI edita, SI lee |
| `.js` | JavaScript (fuente) | Programador + agente IA | SI crea, SI edita, SI lee |

#### Por que existen los `.xml` de colecciones

XOneStudio genera automáticamente un `.xml` por cada `.xne` porque algunos motores de ejecución del framework todavia leen `.xml`. No son legacy ni restos de proyectos antiguos: se generan hoy, en proyectos nuevos. El plan de futuro es eliminarlos y dejar solo `.xne` en todas partes — el trabajo con IA ya se comporta como si esos `.xml` no existieran.

#### Regla operativa para el agente

> Al generar un proyecto nuevo: crear **solo** ficheros `.xne` para colecciones y pantallas (más `app.xml`, `app.ini`, `.css`, `.js` y recursos). **NUNCA** generar `.xml` de colecciones — eso lo hace XOneStudio automáticamente al abrir el proyecto.
>
> Al trabajar sobre un proyecto existente que ya tiene `.xne` y `.xml` conviviendo: tocar **solo** los `.xne`; los `.xml` de colecciones se ignoran por completo. Si se modifica un `.xml` a mano, el cambio se pierde en la siguiente regeneracion de XOneStudio.

---

## 6. Fase 5: Generación de Archivos de Configuración

### 5.1 app.xml - Configuración Global

```xml
<?xml version="1.0" encoding="iso-8859-15" standalone="yes"?>
<xml>
    <app
        prefix="gen"
        version="1.0.0"
        debug="false"
        autologon="false"
        screen-orientation="portrait"
        resolution-width="1080"
        resolution-height="1920"
        scale-fontsize="true"
        android-font-factor="7"
        ios-font-factor="7"
        default-language="javascript"
        companycolor="#2196F3"
        forecolor="#FFFFFF">

        <!-- Conexión a una base de datos alternativa. La base de datos principal NO necesita este nodo. -->
        <connection name="other_db" connstring="bd/other_db.db" />

        <!-- Estilos CSS — se pueden declarar varios según condicion de plataforma/tamano/orientacion -->
        <style url="default.css" strict-mode="true" />
        <style url="default_hor.css" conditions="phone:horizontal" strict-mode="true" />

        <!-- Scripts JavaScript -->
        <include file="functions.js" language="javascript" />

        <!-- Punto de entrada a la aplicación (tras login si lo hay) -->
        <entry-point>
            <item name="EntradaApp" conditions="" />
        </entry-point>

        <!-- Login personalizado — SOLO si autologon="false" -->
        <!-- <login-coll>
            <item name="LoginColl" conditions="" />
        </login-coll> -->

    </app>
</xml>
```

> **NOTA:** El encoding puede ser UTF-8 o `iso-8859-15` (coherente con los bytes; el motor respeta el declarado). El `entry-point` se define como nodo hijo, no como atributo del nodo `<app>`.

#### Atributos del nodo `<app>`

| Atributo | Descripción | Valor por Defecto |
|----------|-------------|-------------------|
| `prefix` | Define la macro `##PREF##` usada en todos los SQL de las colecciones. **IMPORTANTE:** al sustituirse, la macro inserta un **guion bajo** entre el prefix y el nombre de la tabla. Es decir, `##PREF##Empresas` se expande a `gen_Empresas` (NO `genEmpresas`). En los `.xne` se escribe siempre `##PREF##Empresas` sin guion bajo (la macro lo añade ella), pero al generar DDL/DML literal (`bd/createdb.sql`, `bd/seed.sql`) y al ejecutar SQL directo sin la macro (`appData.executeSql`, `sqlManager.doRawQuery` con string literal), el nombre real de la tabla es `<prefix>_<NombreColeccion>` y hay que escribirlo con el underscore explícito. | `"gen"` — NUNCA cambiar sin indicacion explicita del usuario |
| `versión` | Versión del mappings. XOneStudio la incrementa automáticamente al guardar | `"1.0.0"` |
| `debug` | Modo depuracion — muestra más información en el dispositivo | `"false"` (produccion) / `"true"` (desarrollo) |
| `sql-debug` | Loguea todas las SQL ejecutadas por el framework | `"false"` |
| `sql-profiler` | Registra las consultas SQL con tiempos de ejecución. **Desactivar en produccion** | `"false"` |
| `autologon` | Si es `"true"`, salta el login y entra con el usuario `admin` sin password. **Solo desarrollo/pruebas — nunca en produccion** | `"false"` |
| `autologon-username` | Usuario para el autologin (cuando `autologon="true"`) | `"admin"` |
| `autologon-password` | Contraseña para el autologin | — |
| `screen-orientation` | Orientación forzada de pantalla | `"portrait"` / `"landscape"` / `"all"` |
| `resolution-width` | Ancho en pixeles del dispositivo físico de referencia. Ver sección 5.1b | `"1080"` |
| `resolution-height` | Alto en pixeles del dispositivo físico de referencia | `"1920"` |
| `scale-fontsize` | Escala el tamaño de fuente proporcionalmente al cambiar la resolución | `"true"` |
| `android-font-factor` | Factor de ajuste de fuentes para Android | `"7"` |
| `ios-font-factor` | Factor de ajuste de fuentes para iOS | `"7"` |
| `default-language` | Lenguaje por defecto para scripts | `"javascript"` |
| `companycolor` | Color corporativo general (menús, pestañas, selecciones) | — |
| `forecolor` | Color de texto general de la aplicación | `"#FFFFFF"` |
| `compatibility-mode` | **CRÍTICO:** Si es `"true"`, desactiva completamente todos los estilos CSS | `"false"` |
| `load-wait` | Si es `"true"`, muestra una pantalla de espera durante la carga inicial | `"false"` |
| `load-imgbk` | Imagen de fondo del EditView (NO es el splash de carga). El splash se pone con un fichero `splash.png` en la raíz del proyecto (ver §5.4.1 Pantalla de splash) | — |
| `application-max-priority` | Marca la app como prioritaria para evitar que el SO la cierre en segundo plano | `"false"` |
| `application-notification-title` | Título de la notificación persistente de la app en Android | — |
| `application-notification-text` | Texto de la notificación persistente de la app en Android | — |
| `gps-service-notification-title` | Título de la notificación del servicio GPS en segundo plano | — |
| `gps-service-notification-text` | Texto de la notificación del servicio GPS en segundo plano | — |
| `secure-window` | Si es `"true"`, impide capturar pantalla (screenshot) de la app | `"false"` |
| `entry-point` | (Forma alternativa como atributo) Nombre de la colección de entrada. Preferir el nodo `<entry-point>` | — |
| `replica-debug` | Loguea información de debug del proceso de réplica | `"false"` |

> **Atributos que NO van en `<app>`:**
> - `fullscreen` — es atributo de `<coll>` (oculta barras de estado en una pantalla concreta).
> - `sql-debug` — es atributo de `<coll>` (loguea las SQL de esa colección).

#### Subnodos del nodo `<app>`

**`<connection>`** — Define una conexión a base de datos:

```xml
<!-- Conexión a una base de datos alternativa. La base de datos principal NO necesita este nodo. -->
<connection name="other_db" connstring="bd/other_db.db" />

<!-- Conexión a BD de replica de ficheros (solo Android, si hay replica de ficheros) -->
<connection name="Info_ReplicaFiles"
    connstring="Provider=Xone Remote Provider;Data Source=local;
    ProgID=com.xone.db.impl.replicafiles.RplFilesConnection;
    DBMS Name=Ibd;User Name=sa;Password=;appname=ClientMobility;Timeout=60"
    prefix="" />

<!-- Contactos del teléfono como fuente de datos (proveedor del framework) -->
<connection name="ContactsConnection"
    connstring="Provider=Xone Remote Provider;ProgID=com.xone.db.impl.contacts.ContactsConnection" />
```

##### Leer y escribir los contactos del teléfono

XOne expone la agenda de contactos del dispositivo como una **fuente de datos consultable con SQL**, mediante el proveedor especial mostrado arriba (`ContactsConnection`). El proveedor forma parte del framework: no hay que activar ningún módulo, solo declarar la conexión, **pedir el permiso** y crear una colección que la use.

```xml
<!-- En app.xml: permiso obligatorio -->
<permission name="contacts" />
```

La "tabla" se llama `Contacts`. Una colección de ejemplo para listar/ver contactos:

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

- La consulta devuelve **como máximo 100 contactos**. Usa `WHERE` (filtro) y `ORDER BY` (orden) en el SQL para acotar y ordenar; los nombres de campo del filtro y el orden son los mismos de la tabla (`name`, `phone`, etc.).
- El SELECT debe incluir al menos uno de los campos anteriores; en caso contrario no devuelve resultados.
- **Alta y modificación:** un `INSERT`/`UPDATE` sobre `Contacts` crea o actualiza un contacto en la agenda del dispositivo. Además de `name`, `phone` y `email`, al escribir se aceptan `landlinephone` (teléfono fijo), `workphone` (teléfono de trabajo), `company` (empresa) y `job` (puesto). El **borrado de contactos no está soportado**.

**`<style>`** — Declara un fichero CSS. Se pueden declarar varios con distintas `conditions` para cargar estilos diferentes según plataforma, tamaño u orientación:

```xml
<!-- Base: se aplica siempre -->
<style url="default.css" strict-mode="true" />
<!-- Solo en movil orientacion horizontal -->
<style url="default_hor.css" conditions="phone:horizontal" strict-mode="true" />
<!-- Solo en iOS -->
<style url="default-ios.css" conditions="ios" strict-mode="true" />
<!-- Solo en tablet vertical -->
<style url="default_tablet.css" conditions="tablet:vertical" strict-mode="true" />
<!-- Solo en Android movil vertical -->
<style url="default_android_ver.css" conditions="android:phone:vertical" strict-mode="true" />
<!-- Solo en iPhone -->
<style url="default_iphone.css" conditions="ios:phone" strict-mode="true" />
<!-- Solo en iPad vertical -->
<style url="default_ipad_vertical.css" conditions="ios:tablet:vertical" strict-mode="true" />
```

| Atributo | Descripción |
|----------|-------------|
| `url` | Nombre del fichero CSS |
| `strict-mode` | Si es `"true"`, el framework parsea el CSS y reporta errores de sintaxis que podrian impedir que estilos posteriores se apliquen correctamente |
| `conditions` | Condición que debe cumplirse para que se aplique este CSS. Formato: `PLATAFORMA:TAMANO:ORIENTACION` |

**Valores posibles para `conditions`:**

| Parte | Valores |
|-------|---------|
| Plataforma | `android`, `ios`, `wm` (Windows Mobile), `bb` (BlackBerry), `wp` (Windows Phone) |
| Tamaño | `phone`, `tablet`, `mini` (Android < 3.5"), `hiphone` (Android 4.5"–7") |
| Orientación | `vertical`, `horizontal` |

> **Regla:** El fichero `default.css` (sin `conditions`) se aplica **siempre** como base. Los demas CSS con `conditions` se aplican adicionalmente cuando se cumple la condición, sobreescribiendo los estilos base donde haya conflicto.

**`<include>`** — Incluye un fichero de script:

```xml
<include file="functions.js" language="javascript" />
```

**`<entry-point>`** — Indica a XOne cual es la primera coleccion que se abre cuando el usuario entra en la app (tras el login, o directamente si `autologon="true"`). La coleccion apuntada es siempre `special="true"`. Nombre habitual: `EntradaApp`.

```xml
<!-- Simple: siempre la misma coleccion de entrada -->
<entry-point>
    <item name="EntradaApp" conditions="" />
</entry-point>

<!-- Con condiciones: coleccion distinta según dispositivo -->
<entry-point>
    <item name="EntradaApp" conditions="" />
    <item name="EntradaAppTablet" conditions="tablet:horizontal" />
</entry-point>
```

**`<login-coll>`** — Indica a XOne cual es la coleccion que gestiona la autenticación del usuario. XOne la muestra **antes** del `<entry-point>` y solo pasa al entry-point cuando las credenciales son correctas. Solo necesario si `autologon="false"`. La coleccion es siempre `special="true"`.

```xml
<login-coll>
    <item name="LoginColl" conditions="" />
</login-coll>
```

**Flujo de arranque:**

```
[Arranque] → autologon="true"? → SI → [entry-point] → App lista
                    |
                    NO
                    |
             [login-coll] → credenciales OK? → SI → [entry-point] → App lista
                                    |
                                    NO
                             [login-coll] ← vuelve con error
```

> **REGLA:** Si `autologon="false"` y no se define `<login-coll>`, XOne usa su login interno no personalizable. En produccion siempre definir `<login-coll>`.

> **REGLA:** El atributo `prefix` SIEMPRE debe ser `"gen"` a menos que el usuario especifique explicitamente otro valor.


### 5.1b Sistema de Escalado, Resoluciones y Tamaños de UI

#### Como funciona `resolution-width` y `resolution-height`

Estos atributos definen la resolución del dispositivo físico con el que se diseña y prueba la app. No son valores fijos — deben coincidir exactamente con la resolución real del dispositivo de referencia.

Cuando la app se ejecuta en un dispositivo con distinta resolución, XOne escala automáticamente todos los tamaños con esta formula:

```
tamaño_real_px = valor_p × (resolucion_real_dispositivo / resolution-width)
```

**Valores típicos según dispositivo de referencia:**

| Dispositivo | `resolution-width` | `resolution-height` |
|-------------|-------------------|---------------------|
| HDPI Compact | `"480"` | `"800"` |
| XHDPI Standard | `"720"` | `"1280"` |
| XXHDPI Classic (emulador XOneStudio por defecto) | `"1080"` | `"1920"` |
| Dispositivo típico actual | `"1080"` | `"1920"` |
| XXXHDPI Premium | `"1440"` | `"2560"` |

> **CRITICO:** Si `resolution-width` no coincide con la resolución del dispositivo con el que se diseña, todos los elementos quedaran desproporcionados. El emulador de XOneStudio usa `1080x1920` por defecto — si el dispositivo físico real es distinto (por ejemplo `1080x2220`), hay que cambiar estos valores en `app.xml`.

#### La unidad `p` (puntos)

Todas las dimensiones en XOne se expresan en puntos (`p`). En el dispositivo de referencia `1p = 1px`. En cualquier otro dispositivo XOne aplica el escalado automáticamente.

```xml
<!-- Correcto: siempre usar p o % -->
<frame name="frmTopBar" width="100%" height="164p" />
<prop name="MAP_BTN" width="60%" height="124p" />

<!-- Incorrecto: NUNCA usar px, em, rem, dp -->
```

#### Tabla de tamaños estándar (para `resolution-width="1080"` / `resolution-height="1920"`)

Los siguientes valores funcionan correctamente en proyectos reales diseñados para este dispositivo. Si se usa otra resolución de referencia, escalar proporcionalmente con la formula anterior.

| Elemento | `height` | `width` | Notas |
|----------|----------|---------|-------|
| TopBar / BottomBar | `164p` | `100%` | Barra de título superior o inferior |
| Header fijo completo (topBar + tabs) | `404p` | `100%` | Topbar + barra de estado + pestañas |
| Botón de acción principal (pill) | `124p` | `43–60%` | "Aceptar", "Guardar", "Iniciar viaje" |
| Botón principal ancho completo | `124p` | `92%` | Botón único centrado en footer |
| Botón de pestaña / tab | `144p` | `33–50%` | Pestañas tipo "Activa", "Mis OTs" |
| Campo de texto editable `type="T"` | `144p` | `80–92%` | Campos de formulario estándar |
| Label `type="L"` estándar | `96p` | `100%` | Etiquetas de sección |
| Icono de navegación `type="B"` (cuadrado) | `104p` | `104p` | Botones con icono en topbar |
| Icono de acción grande | `150p` | `150p` | Camara, galería, adjuntar |
| Modal / popup | `-2` (alto dinámico) | `840p` | Dialogo centrado (~78% del ancho) |
| Separador fino | `4p` | `100%` | Linea divisoria entre secciones |
| Separador medio | `8p` | `100%` | Indicador de pestaña activa |
| Margen entre elementos `tmargin` | `30p` | — | Espacio entre elementos del mismo bloque |
| Margen entre bloques `tmargin` | `50p` | — | Espacio entre secciones distintas |
| Margen lateral contenido `lmargin` | `50p` | — | Sangria del contenido respecto al borde |

#### Sistema de fuentes

El tamaño de fuente se controla con `fontsize` en el prop, o idealmente via clases CSS para reutilizarlo en todo el proyecto. El nombre de la fuente puede ser cualquier tipografía incluida en el proyecto — el fichero `.ttf` o `.otf` debe estar en la carpeta `files/`.

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

| Rango de `fontsize` | Uso típico |
|--------------------|------------|
| 1–2 | Textos mínimos, contadores, notas |
| 3–4 | Textos secundarios, metadatos, fechas |
| 5 | Texto estándar de campos y labels — **el más usado** |
| 6–7 | Títulos de sección, pestañas, números destacados |
| 8–9 | Títulos de tarjeta, subtítulos de pantalla |
| 10–11 | Títulos de topbar, cabeceras de modal |
| 12 | Títulos grandes, nombre de la app |

### 5.2 app.ini - Metadatos

```ini
name=NombreProyecto
icon=icon.png
IconFolder=icons
FilesFolder=files
Title=Titulo de la Aplicación
Caption=Titulo de la Aplicación
LocationTrackingEnabled=false
LocationTrackingInterval=1800000
LocationTrackingMinimumAccuracy=-1
LocationTrackingSaveOnLocalDatabase=false
LocationTrackingReplicate=true
```

**Campos del app.ini:**

| Campo | Descripción | Obligatorio |
|-------|-------------|-------------|
| `name` | Nombre interno del proyecto | Si |
| `icon` | Nombre del fichero de icono de la app | Si |
| `IconFolder` | Carpeta de iconos. Siempre `icons` | Si |
| `FilesFolder` | Carpeta de ficheros adjuntos. Siempre `files` | Si |
| `Title` | Título visible de la aplicación | Recomendado |
| `Caption` | Subtítulo o descripción corta de la aplicación | Recomendado |
| `LocationTrackingEnabled` | Activa el tracking de localización en segundo plano | No |
| `LocationTrackingInterval` | Intervalo entre capturas de posición en milisegundos (por defecto 1800000 = 30 min) | No |
| `LocationTrackingMinimumAccuracy` | Precisión mínima aceptada en metros (-1 = sin limite) | No |
| `LocationTrackingSaveOnLocalDatabase` | Guarda las posiciones en la BD local | No |
| `LocationTrackingReplicate` | Replica las posiciones al servidor | No |

### 5.3 license.ini - Configuración de Conexión y Licencia

Fichero obligatorio que define la conexión a la base de datos, los parámetros de replica y la licencia de la aplicación.

```ini
Database=00000000
License=000000000000000000000000
Connstring=bd/gestion.db
HostName=
Interval=60
IntervalType=1
Timeout=30
ConnectionMode=direct
ServerPort=7757
FullDuplex=false
LogLevel=0
WriteLog=false
Disabled=true
```

**Campos del license.ini:**

| Campo | Descripción | Valor por Defecto |
|-------|-------------|-------------------|
| `Database` | Identificador de base de datos de la licencia | `00000000` |
| `License` | Clave de licencia de la aplicación | `000000000000000000000000` |
| `Connstring` | Ruta a la base de datos SQLite | `bd/gestion.db` |
| `HostName` | Host del servidor de replica (vacio = sin replica) | `` |
| `Interval` | Intervalo de sincronización en segundos | `60` |
| `IntervalType` | Tipo de intervalo (1 = segundos) | `1` |
| `Timeout` | Tiempo de espera de conexión en segundos | `30` |
| `ConnectionMode` | Modo de conexión (`direct` o `online`) | `direct` |
| `ServerPort` | Puerto del servidor de replica | `7757` |
| `FullDuplex` | Comunicación full duplex con el servidor | `false` |
| `LogLevel` | Nivel de log (0 = sin log) | `0` |
| `WriteLog` | Escribir log en fichero | `false` |
| `Disabled` | Deshabilitar replica (true = solo local) | `true` |

> **REGLA:** Para proyectos sin replica, dejar `HostName` vacio y `Disabled=true`. Los valores de `Database` y `License` son proporcionados por el cliente al activar la aplicación.

> **REGLA (tabla `master_replica_queue`):** El framework encola en `master_replica_queue` TODAS las operaciones de `save()` (INSERT/UPDATE/DELETE), **aunque la réplica esté deshabilitada** (`Disabled=true`). Si la tabla no existe en `gestion.db`, el primer `save()` falla con `no such table: master_replica_queue`. XOneStudio la crea al generar la BD; si la BD se crea por otra vía (p. ej. la herramienta de BD del MCP con `create`+`sync`, que NO la incluye), hay que crearla a mano:
> ```sql
> CREATE TABLE IF NOT EXISTS master_replica_queue (
>   ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
>   ROWID TEXT, OPERID TEXT, TIMESTAMP TEXT, OPER INTEGER,
>   SESSIONID INTEGER, MID INTEGER, SQL TEXT, DMID INTEGER,
>   CONDITIONAL INTEGER, TBL TEXT, TYPE INTEGER, APPNAME TEXT
> );
> ```
> Verificado en dispositivo: sin esta tabla ninguna coll de datos puede guardar.

### 5.4 mappings.xne - Colecciones Base

> **REGLA CRITICA:** Este archivo SOLO contiene las colecciones `Empresas` y `Usuarios`. Todas las demas colecciones van en archivos `.xne` separados sin excepción.

```xml
<?xml version="1.0" encoding="iso-8859-15"?>
<xml>
  <collprops type="general">

    <!-- COLECCION OBLIGATORIA: Empresas -->
    <coll name="Empresas" title="la empresa"
          sql="select e.* from ##PREF##empresa e"
          objname="empresa" updateobj="empresa"
          progid="ASGestion.CASEmpresa">
      <group name="General" id="1">
        <prop name="CODIGO" visible="3" type="N" fieldsize="12" />
        <prop name="NOMBRE" type="T" fieldsize="30" size="250" />
        <!-- Agregar aquí campos adicionales de Empresas si el proyecto lo requiere -->
      </group>
    </coll>

    <!-- COLECCION OBLIGATORIA: Usuarios -->
    <coll name="Usuarios" title="el usuario"
          sql="select u.* from ##PREF##usuarios u"
          objname="usuarios" updateobj="usuarios"
          progid="ASGestion.CASUser">
      <group name="General" id="1">
        <prop name="IDEMPRESA" visible="0" type="N" mapcol="Empresas" mapfld="ID" />
        <prop name="CODIGO" visible="3" type="T" fieldsize="10" size="50" />
        <prop name="LOGIN" visible="3" type="T" fieldsize="10" size="50" />
        <prop name="PWD" type="X" fieldsize="10" size="50" visible="0" />
        <prop name="NOMBRE" visible="3" type="T" fieldsize="30" size="50" />
        <!-- Agregar aquí campos adicionales de Usuarios si el proyecto lo requiere -->
      </group>
      <create>
        <action name="setval" field="IDEMPRESA" value="##ENTID##" />
      </create>
    </coll>

    <!-- EL RESTO DE COLECCIONES VAN EN FICHEROS .xne SEPARADOS -->

  </collprops>
</xml>
```

**Reglas críticas para mappings.xne:**

1. **Solo Empresas y Usuarios** — cualquier otra coleccion va en su propio `.xne`
2. **Encoding coherente** — UTF-8 (default del motor) o `iso-8859-15`; el declarado debe coincidir con los bytes del fichero
3. **`progid` solo en Empresas y Usuarios** — es OPCIONAL en el resto (sin él, objeto de datos genérico ≡ `ASData.CASBasicDataObj`). `ASGestion.CASEmpresa` para Empresas, `ASGestion.CASUser` para Usuarios
4. **`##PREF##` en todos los SQL** — nunca hardcodear el prefijo de tabla
5. **`objname` y `updateobj`** — obligatorios para persistencia en BD
6. **`ID` y `ROWID` los gestiona la plataforma** — ambos existen a nivel de BD (`ID` = clave primaria autoincremental; `ROWID` = GUID de 32 caracteres hex sin guiones, usado por XOne para la replica entre dispositivos) y XOne rellena sus valores solo. No hace falta declararlos como `<prop>` en el `<group>` (declararlos es válido pero redundante; mejor omitirlos por limpieza). En el SQL: **`ID` siempre se rescata en el SELECT** (`SELECT ID, ...`); el `ROWID` no es necesario en el SELECT
7. **Prefijo `MAP_`** — todo prop cuyo valor NO sea una columna de la tabla de `objname` debe nombrarse `MAP_ALGO`. El framework excluye los `MAP_*` de los `INSERT`/`UPDATE`, por lo que `MAP_loquesea` no existe ni debe existir como columna en BD. Se aplica en tres casos: (a) campos que vienen de un JOIN en el SQL de la coll, (b) props visibles enlazados via `linkedto` a un combo, (c) props puramente visuales sin origen de datos: etiquetas `L` (o su alias legacy `TL`), botones `B`, imágenes decorativas, valores calculados en runtime, estados de UI, buscadores temporales. Ver sección dedicada 6.2b
8. **Evento `<create>` en Usuarios** — asigna `##ENTID##` a `IDEMPRESA` automáticamente al crear un usuario
9. **Tipos validos** — solo los documentados en sección 3.3
10. **Visible bitmask** — valores típicos: 0 (oculto), 1 (edición), 3 (edición+lista), 7 (edición+lista+content), 8 (combo), 15 (todos). Ver sección 3.4

---

## 7. Fase 6: Generación de Colecciones

### 6.1 Objetivo

Crear un archivo `.xne` independiente por cada coleccion adicional del proyecto (todas excepto Empresas y Usuarios que van en `mappings.xne`).

### 6.2 Nomenclatura y Convenciones

- Nombre del archivo: `[NombreColeccion].xne` (PascalCase)
- Nombre de la coleccion (`name`): Mismo nombre que el archivo sin extensión
- Ejemplo: `Productos.xne` contiene `<coll name="Productos" ...>`

**Convenciones de nomenclatura de campos (name del prop):**

| Prefijo | Cuando usarlo | Ejemplo |
|---------|---------------|---------|
| Sin prefijo | Campos propios de la tabla, se graban en BD | `NOMBRE`, `FECHA`, `ESTADO` |
| `MAP_` | Valor NO es columna de la tabla `objname` (JOIN, `linkedto`, o prop puramente visual: L/TL, B, calculado, UI-state). No se graba en BD | `MAP_NOMBRECLIENTE`, `MAP_TIPO_DESC`, `MAP_TITULO`, `MAP_BTN_GUARDAR`, `MAP_TOTAL` |
| `@` | Campos tipo `Z` (contents embebidos) | `@LineasPedido` |
| `$` | Campos calculados (formula) | `$IMPORTE_TOTAL` |
| `%` | Campos tipo NC usados como bitmask | `%OPCIONES` |

### 6.2b Cuando usar el prefijo `MAP_`

El prefijo `MAP_` es una **señal al framework** que dice: *"este prop NO es una columna de la tabla apuntada por `objname`, no intentes persistirlo"*. Cuando el framework genera los `INSERT`/`UPDATE`, **excluye automáticamente** todos los props con prefijo `MAP_`. Por eso, **`MAP_loquesea` no existe ni debe existir como columna en la base de datos**.

#### Regla de oro

> **Si el valor del prop NO proviene de una columna de la tabla de `objname`, su `name` debe empezar por `MAP_`.**

#### Los tres casos en los que se usa `MAP_`

**Caso 1 — Campos que vienen de un JOIN en el SQL de la coll**

El SQL hace `LEFT JOIN` a otra tabla y trae descripciones. Los alias llevan `MAP_`:

```xml
<coll name="Pedidos"
      sql="SELECT t1.*,
           c.NOMBRE AS MAP_NOMBRECLIENTE,
           c.TELEFONO AS MAP_TELEFONOCLIENTE
           FROM ##PREF##Pedidos t1
           LEFT OUTER JOIN ##PREF##Clientes c ON t1.IDCLIENTE=c.ID"
      objname="pedidos" updateobj="pedidos" ...>
    <group name="General" id="1">
        <!-- FK: SI es columna de Pedidos, sin MAP_ -->
        <prop name="IDCLIENTE" type="N" visible="7" mapcol="Clientes" mapfld="ID" />

        <!-- Campos del JOIN: NO son columnas de Pedidos, con MAP_ -->
        <prop name="MAP_NOMBRECLIENTE"   type="T" visible="7" locked="true" fieldsize="150" />
        <prop name="MAP_TELEFONOCLIENTE" type="T" visible="7" locked="true" fieldsize="20" />
    </group>
</coll>
```

**Caso 2 — Campos enlazados via `linkedto` (combos/lookups)**

El combo usa dos props. El oculto con el ID es columna de la tabla (sin `MAP_`); el visible con la descripción obtenida del lookup lleva `MAP_`:

```xml
<!-- Oculto: FK, SI es columna -->
<prop name="IDTIPO" type="N" visible="0" mapcol="TiposProducto" mapfld="ID" />

<!-- Visible: descripción del lookup, NO es columna -->
<prop name="MAP_TIPO_DESC" type="T" visible="1"
      title="Tipo"
      linkedto="IDTIPO" linkedfield="DESCRIPCION" showinline="true" />
```

En combos con `mapcol-values` (valores inline en XML) el prop oculto también lleva `MAP_` porque no existe tabla de la que leer:

```xml
<prop name="MAP_IDTIPO" type="T" visible="0"
      mapcol-values="CC,TI,CE,Otro" mapfld="DATA" />
<prop name="MAP_TIPO" type="T" visible="1"
      linkedto="MAP_IDTIPO" linkedfield="DATA" showinline="true" />
```

**Caso 3 — Props puramente visuales (sin origen de datos)**

Cualquier prop sin dato persistible lleva `MAP_`:

| Uso | Tipo | Ejemplo |
|-----|------|---------|
| Etiquetas / títulos | `L` (alias legacy: `TL`) | `MAP_TITULO`, `MAP_SUBTITULO` |
| Botones | `B` | `MAP_BTN_GUARDAR`, `MAP_BTN_CANCELAR` |
| Imágenes decorativas | `IMG` | `MAP_LOGO`, `MAP_ICONO_CABECERA` |
| Contenedores de contents | `Z` | `MAP_LISTA_PRODUCTOS` |
| Valores calculados en runtime | `N2`, `F` | `MAP_TOTAL`, `MAP_SUBTOTAL_IVA` |
| Estados de UI | `T`, `N`, `NC` | `MAP_TAB`, `MAP_MODO`, `MAP_SELECCIONADO` |
| Buscadores / filtros temporales | `T` | `MAP_BUSQUEDA`, `MAP_FILTRO` |
| Callbacks / objetos JS | `O` | `MAP_CALLBACK` |

```xml
<prop name="MAP_TITULO"      type="L" title="Gestion de Pedidos" class="textoTitulo" />
<prop name="MAP_BTN_GUARDAR" type="B"  visible="1" title="Guardar" method="executenode(guardar)" />
<prop name="MAP_TOTAL"       type="N2" visible="1" locked="true" title="Total" />
<prop name="MAP_BUSQUEDA"    type="T"  visible="1" title="Buscar" onchange="Refresh" />
```

#### Mecanismo y consecuencias

- Los `MAP_*` **no se persisten**: el framework los excluye del SQL generado. Viven en memoria del DataObject durante la vida de la pantalla.
- Se leen y escriben desde JS como cualquier otro campo: `self.MAP_CAMPO`, `self["MAP_CAMPO"]`, `self.getValue("MAP_CAMPO")`.
- Pueden ser referenciados en `disablevisible`, en macros (`##FLD_MAP_xxx##`), en `ui.refresh("MAP_xxx")`, en `<action name="setval" field="MAP_xxx">`, etc.
- **No son de solo lectura.** `locked="true"` es una decisión de UI independiente del prefijo.

#### Anti-patrones

| Error | Consecuencia |
|-------|--------------|
| Poner `MAP_` a un campo que SI esta en BD | El dato no se persiste: se pierde al guardar |
| Omitir `MAP_` en un alias de JOIN | El framework genera UPDATE sobre columna inexistente -> error SQL |
| Omitir `MAP_` en el prop visible de un combo con `linkedto` | El framework intenta persistir la descripción del lookup -> error SQL |
| Declarar columna `MAP_LOQUESEA` en el `CREATE TABLE` | Columna muerta: el framework nunca escribe en ella |
| Poner `MAP_` a una etiqueta `L`/`TL` que muestra un campo real de BD | La etiqueta no refleja el dato persistido; confusion semantica |

### 6.3 Plantilla Base para Coleccion de Datos

```xml
<?xml version="1.0" encoding="iso-8859-15"?>
<coll name="NombreColeccion"
      title="nombre coleccion"
      sql="SELECT t1.* FROM ##PREF##NombreColeccion t1"
      objname="NombreColeccion"
      updateobj="NombreColeccion"
      progid="ASData.CASBasicDataObj"
      loadall="true"
      notab="true"
      group-swipe="false">

    <!-- GRUPO 1 - Formulario de edicion -->
    <group name="General" id="1">
        <!-- ID siempre oculto -->
        <!-- Campos de datos propios -->
        <prop name="CODIGO" type="T" visible="7" fieldsize="20" />
        <prop name="NOMBRE" type="T" visible="7" fieldsize="150" />
        <prop name="DESCRIPCION" type="T" visible="7" fieldsize="500" lines="3" />
        <prop name="ACTIVO" type="NC" visible="7" />
        <prop name="FECHA_CREACION" type="DT" visible="0" />
    </group>

</coll>
```

### 6.4 Plantilla para Coleccion con Foreign Key y campos enlazados

```xml
<?xml version="1.0" encoding="iso-8859-15"?>
<coll name="Pedidos"
      title="el pedido"
      sql="SELECT t1.*,
           c.NOMBRE AS MAP_NOMBRECLIENTE,
           u.NOMBRE AS MAP_NOMBREUSUARIO
           FROM ##PREF##Pedidos t1
           LEFT OUTER JOIN ##PREF##Clientes c ON t1.IDCLIENTE=c.ID
           LEFT OUTER JOIN ##PREF##usuarios u ON t1.IDUSUARIO=u.ID"
      objname="pedidos"
      updateobj="pedidos"
      progid="ASData.CASBasicDataObj"
      loadall="true"
      filter="t1.IDEMPRESA=##ENTID##"
      sort="t1.FECHA DESC"
      notab="true"
      group-swipe="false">

    <group name="General" id="1">
        <!-- Foreign Keys (IDLOQUESEA — todo junto, en mayusculas) -->
        <prop name="IDCLIENTE" type="N" visible="7" mapcol="Clientes" mapfld="ID" />
        <prop name="IDUSUARIO" type="N" visible="7" mapcol="Usuarios" mapfld="ID" />
        <!-- Campos enlazados de otras tablas (prefijo MAP_, no se graban en BD) -->
        <prop name="MAP_NOMBRECLIENTE" type="T" visible="7" locked="true" fieldsize="150" />
        <prop name="MAP_NOMBREUSUARIO" type="T" visible="7" locked="true" fieldsize="100" />
        <!-- Campos propios -->
        <prop name="FECHA" type="DT" visible="7" />
        <prop name="ESTADO" type="T" visible="7" fieldsize="20" />
        <prop name="TOTAL" type="N2" visible="7" />
        <prop name="OBSERVACIONES" type="T" visible="7" fieldsize="500" lines="3" />
    </group>

    <!-- Evento create: inicializar valores al crear un objeto nuevo -->
    <create>
        <action name="setval" field="FECHA" value="##NOW##" />
        <action name="setval" field="IDEMPRESA" value="##ENTID##" />
        <action name="setval" field="ESTADO" value="PENDIENTE" />
    </create>

</coll>
```

### 6.5 Atributos del nodo `<coll>`

#### Obligatorios para colecciones de datos

| Atributo | Descripción |
|----------|-------------|
| `name` | Nombre único de la coleccion en toda la app |
| `sql` | Query SQL. Siempre con `##PREF##`. El campo `ID` de la tabla principal SIEMPRE debe estar en el SELECT |
| `objname` | Nombre de la tabla principal para lectura de datos |
| `updateobj` | Nombre de la tabla para escritura. Normalmente igual que `objname` |
| `progid` | Tipo de objeto de datos. **Opcional** (default = genérico). `ASData.CASBasicDataObj` para colecciones de negocio; `ASGestion.CASEmpresa`/`ASGestion.CASUser` solo en Empresas/Usuarios |

#### Atributos de comportamiento frecuentes

| Atributo | Descripción | Valor por defecto |
|----------|-------------|-------------------|
| `title` | Nombre descriptivo de la coleccion | — |
| `loadall` | `true` carga todos los registros de golpe / `false` carga bajo demanda (usar para listas grandes) | `false` |
| `filter` | Clausula WHERE del SQL (sin la palabra WHERE). Soporta macros como `##ENTID##`, `##USERID##` | — |
| `sort` | Clausula ORDER BY (sin ORDER BY). Ej: `FECHA DESC, NOMBRE ASC` | — |
| `notab` | `true` oculta las pestanas de grupos y usa toda la pantalla | `false` |
| `group-swipe` | `true` permite deslizar entre grupos con el dedo | `true` |
| `special` | `true` indica coleccion especial (pantallas de menu, entrada, login) — no tiene tabla en BD | `false` |
| `editmask` | Bitmask que controla modos de edición (0=todos, 2=solo lista, 8=readonly) | `0` |
| `readonly` | `true` la coleccion es solo lectura, no permite modificaciones | `false` |
| `dependent` | `true` la coleccion depende del objeto padre | `false` |
| `check-owner` | `true` verifica que el registro pertenece al usuario actual | `false` |
| `autorefresh` | `true` refresca los datos al volver de otra ventana si hubo cambios | `false` |
| `cell-even-color` | Color de filas pares en modo lista | — |
| `cell-odd-color` | Color de filas impares en modo lista | — |
| `cell-height` | Alto de cada fila en modo lista (en puntos `p`) | — |
| `userawsql` | `true` usa el SQL exactamente como esta escrito sin modificaciones del framework | `false` |
| `start-from-bottom` | `true` el scroll empieza desde el final y se ancla al último item. Útil para chats. Se puede declarar en la coll o en el content (`type="Z"`); el del content tiene preferencia | `false` |
| `no-data-text` | Texto a mostrar cuando la coleccion no tiene registros | `" "` |
| `cell-height` | Alto fijo de cada fila en modo listado (en puntos `p`) | — |
| `cell-tpadding` | Margen interior superior de cada celda | — |
| `cell-bpadding` | Margen interior inferior de cada celda | — |
| `cell-bgcolor` | Color de fondo general de todas las celdas | — |
| `stringkey` | `true` indica que la clave primaria es de tipo texto en lugar de entero | `false` |
| `idfieldname` | Nombre del campo clave primaria cuando no se llama `ID` | `"ID"` |
| `group-theme` | `"material"` activa el estilo Material Design en las pestanas | — |
| `tab-mode` | `"fixed"` (pestanas fijas) o `"scrollable"` (pestanas con scroll) | — |
| `page-limit-off` | Limita el número de pestanas precargadas en memoria (por defecto 6) | `6` |

### 6.5b Herencia entre colecciones (`inherits`) y composición (`<include-layout>`)

XOne soporta dos mecanismos para reutilizar estructura XML entre colecciones. Son ortogonales al CSS `extends` — operan sobre groups, frames, props y eventos.

#### Atributo `inherits` en `<coll>`

Permite que una coll herede la estructura completa (grupos, frames, props y eventos) de otra coll declarada en el proyecto. Regla de precedencia: ante mismo `name`, **prevalece la hija**; los elementos no duplicados del padre se conservan.

```xml
<coll name="PantallaConcreta" inherits="groupsFixed" special="true" notab="false">
    ...
</coll>
```

**Reglas operativas:**
- Un solo padre por coll. No existe `inherits="A,B"`.
- Admite cadenas (A → B → C) — la resolución recorre toda la cadena aplicando hijo-gana en cada nivel.
- Los eventos duplicados también siguen hijo-gana (no hay `super()`).
- El padre puede estar en el mismo fichero `.xne` o en otro fichero `.xne` del proyecto; basta con referenciarlo por su `name`.

#### Patron recomendado: scaffolding visual compartido

Cuando el proyecto tiene varias pantallas con el mismo esqueleto (header fijo, footer de paginación, botones comunes, evento `<onback>` común), se crea una coll base `special="true"` que contenga ese scaffolding, y cada pantalla la hereda.

**Paso 1 — Crear la coll base** (fichero `layoutsFijos.xne` o similar):

```xml
<?xml version="1.0" encoding="iso-8859-15"?>
<coll name="layoutsFijos" title="" special="true">
    <!-- Header comun: logo, título, botón salir -->
    <group name="HEADER" id="999" class="groupfixed_header">
        <frame name="frmTitulo" class="frmsuperior">
            <prop name="BTSALIR" type="B" class="btvolversuper"
                  method="ExecuteNode(onback)" />
            <prop name="LBL_TITULO" type="L" class="tlsuper" title="App" />
        </frame>
    </group>
    <!-- Footer comun: paginador -->
    <group name="FOOTER" id="0" class="groupfixed_footer">
        <prop name="MAP_GROUP" type="N" visible="0" />
        <prop name="MAP_TOTAL_PAGES" type="N" visible="0" />
    </group>
    <!-- Evento de salida comun -->
    <onback show-wait-dialog="false">
        <action name="runscript">
            <script language="javascript">
                ui.getView(self).exit();
            </script>
        </action>
    </onback>
</coll>
```

**Paso 2 — Las pantallas concretas la heredan:**

```xml
<?xml version="1.0" encoding="iso-8859-15"?>
<coll name="PantallaA" inherits="layoutsFijos" special="true" notab="false">
    <!-- Solo sobreescribe el título del header -->
    <group name="HEADER" id="999">
        <frame name="frmTitulo" class="frmsuperior">
            <prop name="LBL_TITULO" type="L" class="tlsuper" title="Pantalla A" />
        </frame>
    </group>
    <!-- Contenido propio -->
    <group name="Group1" id="1">
        <prop name="MAP_CAMPO1" type="T" visible="1" />
    </group>
    <before-edit>
        <action name="runscript">
            <script language="javascript">
                self.MAP_GROUP = 1;
                self.MAP_TOTAL_PAGES = 1;
            </script>
        </action>
    </before-edit>
</coll>
```

**Decisión: cuando SI y cuando NO usar `inherits`**

| Escenario | Decisión |
|-----------|----------|
| 3+ pantallas con mismo header/footer/navegación | SI — extraer a coll base `special="true"` |
| 2 pantallas con estructura muy parecida y lógica distinta | SI — coll base común, override de eventos en la hija |
| 1-2 pantallas con algunas piezas comunes | Normalmente NO — duplicar es más claro |
| Colecciones de datos (con `objname`) | Raro — `inherits` es útil sobre todo entre colecciones `special="true"` |
| Pantallas con estructura totalmente distinta | NO — la herencia no aporta |

#### Nodo `<include-layout>` (composición por fragmentos)

Nodo hijo de `<coll>` que inyecta el contenido de un fichero XML externo. Útil para factorizar **botoneras, bloques de props recurrentes o eventos compartidos**.

```xml
<include-layout file="misBotones.xml" group="1" frame="todo" />
```

- `file`: ruta **relativa a la raiz del proyecto**
- `group`/`frame`: defaults para props del fichero incluido que no los declaren

**Formato del fichero incluido:**

```xml
<?xml version="1.0" encoding="utf-8"?>
<xml>
    <!-- Props, groups, frames y eventos al mismo nivel (plano) -->
    <prop name="MAP_SALIR" type="B" title="Salir" visible="1"
          method="ExecuteNode(salir)" width="100%" labelwidth="10" />
    <salir refresh="false">
        <action name="runscript">
            <script language="javascript">
                appData.exit();
            </script>
        </action>
    </salir>
</xml>
```

**Reglas clave:**
- Encoding del fichero incluido: **`utf-8`** (los `.xne` pueden ir en UTF-8 o iso-8859-15).
- Raiz: `<xml>` (NO `<coll>`).
- Estructura plana, no jerárquica.
- **No se pueden anidar `<include-layout>`**: el fichero incluido no puede contener a su vez otro `<include-layout>`.
- Los nombres (`name`) deben ser únicos en el ambito final tras la composición.

#### Checklist para el agente

- [ ] Si 3+ pantallas comparten estructura, extraer a coll base `special="true"` y usar `inherits`.
- [ ] La coll base va en su propio fichero `.xne` (PascalCase: `LayoutsFijos.xne`).
- [ ] Recordar: `inherits` admite cadena A→B→C pero NO herencia multiple.
- [ ] Si hay botoneras o bloques repetidos entre colls heredadas y no heredadas, factorizar con `<include-layout>` a fichero externo.
- [ ] En el fichero de `<include-layout>`: encoding `utf-8`, raiz `<xml>`, estructura plana, sin anidar otros `<include-layout>`.
- [ ] Nombres únicos en el ambito final tras herencia + composición.

### 6.6 Nodo `<contents>` — Coleccion embebida

Para mostrar una relación 1-N dentro de una coleccion, se usa un `prop type="Z"` con su `<contents>` asociado:

```xml
<!-- Dentro del group, el prop que muestra el contents -->
<prop name="@LineasPedido" type="Z" visible="1"
      contents="LineasPedido"
      width="100%" height="60%"
      locked="true" />

<!-- El nodo contents define el origen de datos del Z -->
<contents name="LineasPedido" src="ColeccionLineasPedido"
          filter="IDPEDIDO=##FLD_ID##" />
```

> El `filter` del `<contents>` usa `##FLD_CAMPO##` para referenciar campos del objeto padre.

### 6.7 Atributos de `<prop>` — Referencia de los más importantes

| Atributo | Descripción |
|----------|-------------|
| `name` | Nombre del campo. **SIEMPRE EN MAYUSCULAS** |
| `type` | Tipo del campo (ver sección 3.3) |
| `visible` | Bitmask de visibilidad. Estático — no cambia en tiempo de ejecución. Valores: 0=oculto, 1=edición, 2=lista, 3=edición+lista, 4=content, 7=edición+lista+content, 8=combo, 15=todos (ver sección 3.4) |
| `title` | Etiqueta/label a mostrar junto al campo |
| `width` | Ancho. Usar `%` o `p` (puntos). Ej: `"90%"`, `"200p"` |
| `height` | Alto. Usar `%` o `p`. Valor especial `-2` = altura automática según contenido |
| `fieldsize` | Tamaño máximo del campo de texto en BD |
| `size` | Tamaño visual del campo |
| `lines` | Número de lineas para campos de texto multilínea |
| `fixed-lines` | `true` el campo ocupa exactamente las lineas indicadas en `lines` |
| `newline` | Por defecto `true` — cada elemento ocupa su propia línea. Con `false` el elemento se coloca a la derecha del anterior. Funciona igual en `<frame>` y `<prop>`. Los anchos de los elementos en la misma fila deben sumar 100% o menos |
| `locked` | `true` el campo es solo lectura para el usuario |
| `labelwidth` | Proporcion de la etiqueta. `0` = sin etiqueta, solo el valor |
| `forecolor` | Color del texto de la etiqueta |
| `bgcolor` | Color de fondo del campo |
| `fontsize` | Tamaño de la fuente de la etiqueta |
| `textfont-size` | Tamaño de la fuente del valor del campo |
| `textfont-bold` | `true` el valor del campo en negrita |
| `text-forecolor` | Color del texto del valor del campo |
| `text-bgcolor` | Color de fondo del área de texto del campo |
| `text-align` | Alineacion del texto: `left`, `center`, `right`, `left\|center` |
| `text-border` | `true/false` borde alrededor del área de texto |
| `text-border-bottom` | `true/false` solo borde inferior |
| `lmargin` / `tmargin` / `rmargin` / `bmargin` | Margenes exteriores |
| `lpadding` / `tpadding` / `rpadding` / `bpadding` | Margenes interiores |
| `align` | Posición del elemento dentro de su contenedor (`<group>`, `<frame>` o `<prop>`). Mismo comportamiento en los tres nodos. Valores: `left`, `right`, `center`, `top`, `bottom` y combinaciones con `\|` como `center\|center`, `left\|top`, `left\|center`, `center\|top`. Ver tabla completa en 02-xml-ui-complete-guide sección 4.2 |
| `disablevisible` | Oculta el elemento en tiempo de ejecución si se cumple la condición. Aplica en `<group>`, `<frame>` y `<prop>`. Se reevalua al hacer `ui.refresh()` o cuando el campo referenciado tiene `onchange="refresh"`. Formato: `CAMPO=VALOR`, `CAMPO>VALOR`, `CAMPO<VALOR` |
| `disableedit` | **Bloquea edición del campo SI se cumple la condición**. Ej: `"ESTADO=2"` |
| `mapcol` | Coleccion a la que enlaza este campo (FK) |
| `mapfld` | Campo de la coleccion enlazada que devuelve el valor |
| `linkedto` | Campo de esta coleccion donde se guarda el valor seleccionado del enlace |
| `linkedfield` | Campo de la coleccion enlazada que se muestra al usuario |
| `showinline` | `true` abre las opciones del selector en un panel inferior |
| `showinline-keyboard` | `true` añade una caja de búsqueda en la cabecera del panel `showinline` para filtrar las opciones |
| `bgcolor-dialog` / `forecolor-dialog` / `fontsize-dialog` | Personalizan el panel `showinline` y los pickers `D`/`DT`/`TT`: fondo, color de texto/acento y tamaño |
| `floating-tooltip` | `true` muestra el `tooltip` como placeholder flotante sobre el campo |
| `tooltip` | Texto de ayuda o placeholder del campo |
| `method` | Método XOne a ejecutar al pulsar. Ej: `"ExecuteNode(guardar)"` |
| `onclick` | Script JavaScript inline al pulsar. Ej: `"javascript:miFuncion();"` |
| `onchange` | Acción al cambiar el valor. Ej: `"Refresh"` o `"javascript:calcular();"` |
| `img` | Imagen para botones (`type="B"`) |
| `imgsel` | Imagen al pulsar el botón |
| `keep-aspect-ratio` | `true` mantiene proporcion al redimensionar imágenes |
| `contents` | Nombre del contents asociado (para `type="Z"`) |
| `viewmode` | Modo de visualizacion del contents (ver sección 7.13) |
| `group` | ID del grupo al que pertenece este prop (forma alternativa de asignacion) |
| `info` | Metadato informativo sin efecto visual. Útil para documentar campos |
| `fixed-text` | `true` combinado con `size` impide introducir más caracteres del limite en UI |
| `floating` | `true` el prop se superpone al layout. Posicionar con `top` y `left` |
| `keep-aspect-ratio` | Ya documentado: `true` mantiene la proporcion original de la imagen |
| `updates` | Al cambiar este campo, propaga el cambio al campo indicado en la coleccion contents |
| `contextual-search` | `true` activa la busqueda en tiempo real sobre un contents |
| `contextual-target` | Nombre del `type="Z"` que se filtra con la busqueda contextual |
| `contextual-filter` | Clausula WHERE para el filtro contextual. `##VAL##` se sustituye por el texto escrito |
| `formula` | Calcula el valor con una SQL externa. Formato: `ext.[NOMBRE]`. Requiere nodo `<ext-formula>` |

### 6.8 Regla de Campos por Tipo de Dato

| Tipo de Campo | Atributo `fieldsize` | Notas |
|---------------|----------------------|-------|
| Texto corto (T) | `fieldsize="20"` a `"50"` | Códigos, estados, telefonos |
| Texto medio (T) | `fieldsize="100"` a `"150"` | Nombres, emails, títulos |
| Texto largo (T) | `fieldsize="255"` a `"500"` | Descripciones, direcciones, observaciones |
| Password (X) | `fieldsize="100"` | Siempre `visible="0"` |
| Numéricos (N, N2...) | No requiere fieldsize | IDs, cantidades, precios |
| Fechas (D, DT) | No requiere fieldsize | Fechas y timestamps |
| Booleanos (NC) | No requiere fieldsize | Flags 0/1 |
| ID campos FK | No requiere fieldsize | Convenir `IDLOQUESEA` todo junto en mayusculas |

---

### 6.8b Atributos especiales por tipo

**Radio button (type="NC" con check-type="radio"):**

```xml
<prop name="MAP_OPCION_A" type="NC" visible="1"
      title="Opción A" check-type="radio" radio-group="1"
      width="100%" height="120p" />
<prop name="MAP_OPCION_B" type="NC" visible="1"
      title="Opción B" check-type="radio" radio-group="1"
      width="100%" height="120p" />
<prop name="MAP_OPCION_C" type="NC" visible="1"
      title="Opción C" check-type="radio" radio-group="1"
      width="100%" height="120p" />
```

| Atributo | Descripción |
|----------|-------------|
| `check-type="radio"` | Convierte el NC en radio button en lugar de checkbox |
| `radio-group` | ID numérico del grupo. Solo puede estar activo uno del mismo grupo |
| `allow-radio-group-uncheck` | `true` permite deseleccionar el radio pulsandolo de nuevo |

**onchange — refresco al cambiar valor:**

```xml
<!-- Refrescar toda la pantalla al cambiar -->
<prop name="ESTADO" type="N" visible="1" onchange="refresh" />

<!-- Refrescar un prop específico -->
<prop name="TIPO" type="T" visible="1" onchange="refresh(MAP_SUBTIPO)" />

<!-- Ejecutar nodo custom -->
<prop name="IMPORTE" type="N2" visible="1" onchange="ExecuteNode(calcularTotal)" />
```

### 6.9 Relaciones entre Colecciones

XOne tiene tres tipos de relaciones entre colecciones:

| Tipo | Cuando usarlo |
|------|---------------|
| **1 a 1 — Lupa** | Relación con colecciones que tienen muchos datos. El usuario abre un buscador para seleccionar |
| **1 a 1 — Combo** | Relación con colecciones que tienen pocos datos. Se muestran como lista desplegable inline |
| **1 a 1 — Combo sin BD** | Valores fijos predefinidos en el propio XML, sin tabla auxiliar |
| **1 a N — Contents** | Relación maestro-detalle donde el número de registros es variable |

#### Relación 1 a 1: Lupa

El campo FK guarda el ID seleccionado. Campos `MAP_` adicionales muestran datos de la fila seleccionada sin grabarse en BD. La lupa aparece en el campo sin `locked="true"`.

```xml
<!-- Campo FK — se graba en BD, normalmente oculto -->
<prop name="IDCLIENTE" type="N" visible="0" mapcol="Clientes" mapfld="ID" />

<!-- Campo que muestra el valor — con lupa activa para buscar -->
<prop name="MAP_CLIENTE" type="T" visible="1"
      linkedto="IDCLIENTE" linkedfield="NOMBRE" onchange="Refresh" />

<!-- Campos adicionales de la misma fila — locked=true evita que salga la lupa -->
<prop name="MAP_TELEFONO" type="T" visible="1" locked="true"
      linkedto="IDCLIENTE" linkedfield="TELEFONO" onchange="Refresh" />
```

#### Relación 1 a 1: Combo (coleccion auxiliar)

Identica a la lupa pero con `showinline="true"`. Usar solo cuando la coleccion tiene pocos registros, ya que se carga completa en memoria al abrir la pantalla.

```xml
<!-- Campo FK — se graba en BD -->
<prop name="IDTIPO" type="N" visible="0" mapcol="TiposVisita" mapfld="ID" />

<!-- Campo combo — showinline="true" lo convierte en desplegable -->
<prop name="MAP_TIPO" type="T" visible="1"
      linkedto="IDTIPO" linkedfield="DESCRIPCION" showinline="true" />
```

#### Relación 1 a 1: Combo sin BD (valores fijos)

Cuando los valores son pocos y fijos. No necesita tabla auxiliar. El atributo `mapcol-values` define los valores separados por comas.

```xml
<!-- Campo con valores predefinidos — MAP_ porque no se graba directamente -->
<prop name="MAP_IDTIPO" type="N" visible="0"
      mapcol-values="COMERCIAL,TECNICO,ADMINISTRACION" />

<!-- Campo que se graba en BD — linkedfield siempre es DATA en este caso -->
<prop name="TIPO" type="T" visible="1"
      linkedto="MAP_IDTIPO" linkedfield="DATA" showinline="true" />
```

#### Relación 1 a N: Contents (maestro-detalle)

Para mostrar registros hijos dentro de un registro padre. La coleccion hija es independiente y se usa como contents filtrado por el ID del padre.

```xml
<!-- En la coleccion padre (Pedidos) -->
<prop name="@DETALLES" type="Z" visible="1"
      contents="Detalles" width="100%" height="60%" locked="true" />
<contents name="Detalles" src="ColDetalles"
          filter="IDPEDIDO=##ID##" />

<!-- Evento insert en el padre: enlaza los hijos al grabarse -->
<insert>
    <action name="link" coll="ColDetalles" field="IDPEDIDO" value="##ID##" />
</insert>

<!-- Evento delete en el padre: borra los hijos al borrar el padre -->
<delete>
    <action name="executesql"
            sql="DELETE FROM ##PREF##detalles WHERE IDPEDIDO=##ID##" />
</delete>
```

```xml
<!-- Coleccion hija (ColDetalles) — evento create: asigna el ID del padre al crearse -->
<create>
    <action name="setfldval" targetfld="IDPEDIDO" sourcefld="ID" />
</create>
```

> **REGLA:** Toda coleccion padre que tenga un `<contents>` debe tener un evento `<delete>` con `executesql` para borrar los registros hijos cuando se borre el padre.

#### Macro `##OWNERCOLL##` — Contents reutilizables

Cuando una misma coleccion hija puede usarse como contents para varias colecciones padre diferentes, se usa `##OWNERCOLL##` en el `mapcol` del campo FK de la coleccion hija. Sera sustituido automáticamente por el nombre de la coleccion padre que la use en cada caso.

```xml
<!-- Coleccion hija reutilizable -->
<coll name="Detalles" ...>
    <prop name="IDDOCUMENTO" type="N" visible="0"
          mapcol="##OWNERCOLL##" mapfld="ID" />
</coll>

<!-- Puede usarse desde Facturas Y desde Albaranes sin cambiar la definición -->
<coll name="Facturas" ...>
    <prop name="@DETALLES" type="Z" contents="Detalles" />
    <contents name="Detalles" src="Detalles" filter="IDDOCUMENTO=##ID##" />
</coll>

<coll name="Albaranes" ...>
    <prop name="@DETALLES" type="Z" contents="Detalles" />
    <contents name="Detalles" src="Detalles" filter="IDDOCUMENTO=##ID##" />
</coll>
```

---

### 6.10 Atributos del nodo `<contents>` y del `prop type="Z"`

#### Atributos del prop type="Z"

| Atributo | Descripción |
|----------|-------------|
| `contents` | Nombre del nodo `<contents>` asociado |
| `width` / `height` | Dimensiones del área del contents |
| `locked` | `true` impide la edición de registros |
| `edit-inrow` | `true` edita el registro en la misma fila del listado (por defecto `true`) |
| `editmodal` | `true` al hacer doble click abre el registro en una ventana separada |
| `forceonchange` | `true` fuerza el refresco al volver de la ventana de edición |
| `mask` | Bitmask de operaciones permitidas: 1=nuevo, 2=editar, 4=borrar, 8=filtro, 16=salir |
| `disableedit` | Deshabilita edición si se cumple la condición |
| `disablevisible` | Oculta el contents si se cumple la condición |
| `filter` | Filtro adicional aplicado al contents en tiempo de ejecución |
| `viewmode` | Modo de visualizacion (ver sección 7.13 para la lista completa) |

#### Atributos del nodo `<contents>`

| Atributo | Descripción |
|----------|-------------|
| `name` | Nombre del contents, debe coincidir con el atributo `contents` del prop Z |
| `src` | Nombre de la coleccion de datos que alimenta este contents |
| `filter` | Filtro de registros. Usar `##ID##` para el ID del objeto padre, `##FLD_CAMPO##` para campos del padre |
| `disableedit` | Deshabilita edición si se cumple la condición |
| `disablevisible` | Oculta el contents si se cumple la condición |
| `sort` | Ordenacion de los registros del contents |

---

### 6.11 Modos de Edición del Contents

#### Edición directa (por defecto)

Al tocar un elemento del contents, se abre el objeto en edición. Es el comportamiento por defecto.

```xml
<prop name="@content1" type="Z" contents="content1"
      height="96%" width="100%" bgcolor="#FFFFFF" />
<contents name="content1" src="MiColeccion" filter="IDPADRE=##ID##" />
```

#### Edición en la fila (`edit-inrow="true"`)

El registro se edita directamente en la misma fila del listado, sin abrir una ventana nueva.

```xml
<prop name="@content2" type="Z" contents="content2"
      edit-inrow="true" mask="0" height="75%" width="100%" />
<contents name="content2" src="MiColeccion" filter="IDPADRE=##ID##" />
```

#### Edición con `selecteditem`

Se programa lo que ocurre al seleccionar un elemento. Útil para lógica personalizada al seleccionar.

```xml
<!-- En la coleccion padre -->
<prop name="@content3" type="Z" contents="content3"
      disableedit="1=1" height="70%" width="100%" />
<contents name="content3" src="MiColeccion" filter="IDPADRE=##ID##" />

<!-- En la coleccion hija (MiColeccion) -->
<selecteditem refresh="false" show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            // self es el objeto seleccionado
            // getParent() devuelve el objeto padre
            self.getParent().MAP_SELECCIONADO = self.NOMBRE;
            ui.refresh("MAP_SELECCIONADO");
        </script>
    </action>
</selecteditem>
```

#### Filtro y multiseleccion

Para permitir filtrar el contents dinámicamente y seleccionar multiples registros:

```xml
<!-- Campo de texto para filtrar -->
<prop name="MAP_BUSCAR" type="T" visible="1" labelwidth="0"
      onchange="javascript:filtrarContent();" />

<!-- Contents con filtro dinámico usando ##FLD_MAP_BUSCAR## -->
<prop name="@contentFiltro" type="Z" contents="contentFiltro"
      edit-inrow="true" mask="0" forceonchange="true"
      onchange="Refresh" editmodal="true" />
<contents name="contentFiltro" src="MiColeccion"
          filter="NOMBRE LIKE ##FLD_MAP_BUSCAR##" />

<!-- En la coleccion hija: campo NC para multiseleccion -->
<prop name="MAP_SELECTED" type="NC" visible="4" labelwidth="0"
      width="10%" height="60p" newline="false" />
```

**JavaScript para recargar el contents al cambiar el filtro:**

```javascript
function filtrarContent() {
    var coll = self.getContents("contentFiltro");
    coll.clear();
    coll.loadAll();
    ui.refresh("@contentFiltro");
}
```

---

## 8. Fase 7: Generación de Pantallas

### 7.1 Objetivo

Crear todas las pantallas de la aplicación como archivos `.xne` individuales. Cada pantalla define su UI, eventos y lógica.

Antes de generar pantallas, el agente debe responder estas preguntas clave:

### 7.2 Preguntas de Decisión Previas a la Generación

#### Pregunta 1: ¿La app tiene autologin o requiere login?

| Escenario | Configuración en app.xml | Pantallas a generar |
|-----------|--------------------------|---------------------|
| **Con login** | `autologon="false"` + nodo `<login-coll>` apuntando a `LoginColl` | Generar `Login.xne` |
| **Sin login / autologin** | `autologon="true"` | NO generar `Login.xne` |

```xml
<!-- app.xml CON login -->
<app autologon="false" ...>
    <login-coll>
        <item name="LoginColl" conditions="" />
    </login-coll>
    <entry-point>
        <item name="EntradaApp" conditions="" />
    </entry-point>
</app>

<!-- app.xml SIN login (autologin) -->
<app autologon="true" ...>
    <entry-point>
        <item name="EntradaApp" conditions="" />
    </entry-point>
</app>
```

#### Pregunta 2: ¿Cual es el punto de entrada de la app?

El punto de entrada es la primera coleccion que se muestra al usuario tras el arranque (o tras el login si lo hay). Se configura en el nodo `<entry-point>` de `app.xml`.

| Nombre habitual | Cuando usarlo |
|-----------------|---------------|
| `EntradaApp` | **El más usado.** Pantalla de bienvenida que luego navega al menu |
| `MenuPrincipal` | Cuando la app arranca directamente en el menu sin pantalla de bienvenida |

> **REGLA:** Preguntar siempre al usuario cual prefiere. Si no especifica, usar `EntradaApp` por convencion.

#### Pregunta 3: ¿La app necesita consola de replica?

**Siempre si.** La `ConsolaReplica` es una pantalla técnica obligatoria en todo proyecto XOne. Proporciona información del dispositivo, estado de la replica y herramientas de diagnostico. No es visible para el usuario final en produccion — se accede típicamente desde un botón oculto o menu de administracion.

### 7.3 Orden de Generación de Pantallas

Generar las pantallas en este orden:

| Orden | Pantalla | Archivo | Obligatoria |
|-------|----------|---------|-------------|
| 1 | Login | `Login.xne` | Solo si `autologon="false"` |
| 2 | Punto de entrada | `EntradaApp.xne` o `MenuPrincipal.xne` | **Si** |
| 3 | Consola | `Consola.xne` | **Si (siempre)**. Si la app usa replica: incluir todos los grupos (info replica, dispositivo, ficheros). Si no usa replica: incluir solo el grupo de información del dispositivo |
| 4 | Menu principal | `MenuPrincipal.xne` (si EntradaApp es el entry-point) | Según proyecto |
| 5+ | Pantallas de negocio | `Lista[Entidad].xne`, `Detalle[Entidad].xne`, etc. | Según requisitos |

**Pantallas de negocio comunes:**

| Pantalla | Archivo | Proposito |
|----------|---------|-----------|
| Lista | `Lista[Entidad].xne` | Listado de registros |
| Detalle | `Detalle[Entidad].xne` | Formulario de edición |
| Mapa | `Mapa[Entidad].xne` | Visualizacion en mapa |
| Configuración | `Configuración.xne` | Ajustes de la app |
| Dashboard | `Dashboard.xne` | Panel con gráficos |

### 7.4 Plantilla: EntradaApp.xne (OBLIGATORIA)

```xml
<?xml version="1.0" encoding="utf-8"?>
<!--
    Pantalla de entrada de la aplicación
    Esta es la primera pantalla que ve el usuario
-->
<coll name="EntradaApp" title="Bienvenido"
      special="true" notab="true" show-toolbar="false">

    <!-- Inicialización (se ejecuta una sola vez) -->
    <create>
        <action name="runscript">
            <script language="javascript">
                // Inicialización de la aplicación
            </script>
        </action>
    </create>

    <!-- Al abrir la pantalla, antes de pintar la UI -->
    <before-edit>
        <action name="runscript">
            <script language="javascript">
                // Código al abrir la pantalla
            </script>
        </action>
    </before-edit>

    <group name="grpPrincipal" id="1" class="groupNoTab">
        <!-- Header con logo -->
        <frame name="frmHeader" class="frameHeader">
            <prop name="imgLogo" type="IMG" visible="7"
                  width="200p" height="80p" align="center"
                  path="./icons/app_icon.png" />
        </frame>

        <!-- Contenido principal -->
        <frame name="frmBody" class="frameBody">
            <prop name="lblNombreApp" type="L" visible="7"
                  width="100%" height="50p" align="center"
                  class="textoTitulo" title="Nombre de la App" />

            <prop name="lblDescripcion" type="L" visible="7"
                  width="80%" height="30p" align="center"
                  class="textoSubtitulo" title="Descripción breve" />

            <prop name="btnEntrar" type="B" visible="7"
                  width="80%" height="50p" align="center"
                  class="btnPrimario" title="Entrar" tmargin="30p"
                  onclick="ui.openEditView('MenuPrincipal');" />
        </frame>

        <!-- Versión -->
        <frame name="frmFooter" class="frameFooter">
            <prop name="lblVersion" type="L" visible="7"
                  width="100%" height="30p" align="center"
                  class="textoSubtitulo" title="v1.0.0" />
        </frame>
    </group>

    <!-- Manejo del botón atrás -->
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

### 7.5 Plantilla: MenuPrincipal.xne

```xml
<?xml version="1.0" encoding="utf-8"?>
<!--
    Menu principal de la aplicación
    Muestra las opciones de navegacion
-->
<coll name="MenuPrincipal" title="Menu"
      special="true" notab="true" show-toolbar="false">

    <create>
        <action name="runscript">
            <script language="javascript">
                // Inicialización del menu
            </script>
        </action>
    </create>

    <group name="grpMenu" id="1" class="groupNoTab">
        <!-- Header -->
        <frame name="frmHeader" width="100%" height="120p"
               bgcolor="#2196F3" align="center">
            <prop name="lblTitulo" type="L" visible="7"
                  width="100%" height="50p" align="center"
                  forecolor="#FFFFFF" fontsize="18"
                  title="Menu Principal" />
        </frame>

        <!-- Opciones del menu -->
        <frame name="frmOpciones" width="100%" height="100%"
               scroll="true" bgcolor="#FFFFFF">

            <!-- Opción 1 -->
            <frame name="frmOpcion1" width="90%" height="80p"
                   align="center" tmargin="15p"
                   bgcolor="#F5F5F5" border-corner-radius="10">
                <prop name="imgOpcion1" type="IMG" visible="7"
                      width="48p" height="48p" lmargin="15p"
                      path="./icons/ic_opcion1.png" />
                <prop name="lblOpcion1" type="L" visible="7"
                      width="70%" height="48p" lmargin="15p"
                      newline="false" fontsize="14"
                      title="Opción 1" />
                <prop name="btnOpcion1" type="B" visible="7"
                      width="100%" height="100%"
                      bgcolor="#00000000"
                      onclick="ui.openEditView('ListaEntidad');" />
            </frame>

            <!-- Repetir para cada opción del menu -->
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

### 7.6 Plantilla: Login.xne

```xml
<?xml version="1.0" encoding="utf-8"?>
<!--
    Pantalla de login
-->
<coll name="LoginColl" title="" special="true" notab="true"
      show-toolbar="false">

    <group name="grpLogin" id="1" class="groupNoTab">
        <frame name="frmLogin" width="100%" height="100%"
               bgcolor="#FFFFFF" align="center">

            <!-- Logo -->
            <prop name="imgLogo" type="IMG" visible="1"
                  width="200p" height="80p" align="center"
                  tmargin="150p" path="./icons/app_icon.png" />

            <!-- Campo usuario -->
            <prop name="MAP_USUARIO" type="T" visible="1"
                  width="80%" height="50p" align="center"
                  tmargin="80p" labelwidth="0"
                  floating-tooltip="true" tooltip="Usuario"
                  class="textoEditable" />

            <!-- Campo contraseña -->
            <prop name="MAP_PASSWORD" type="X" visible="1"
                  width="80%" height="50p" align="center"
                  tmargin="20p" labelwidth="0"
                  floating-tooltip="true" tooltip="Contraseña"
                  show-password-visibility-toggle="true"
                  class="textoEditable" />

            <!-- Botón login -->
            <prop name="btnLogin" type="B" visible="1"
                  width="80%" height="50p" align="center"
                  tmargin="40p" class="btnPrimario"
                  title="Iniciar Sesion"
                  method="executenode(aceptarLogin)" />
        </frame>
    </group>

    <!-- Evento de login -->
    <aceptarLogin>
        <action name="runscript">
            <script language="javascript">
                var sUsuario = cstr(self.MAP_USUARIO);
                var sPassword = cstr(self.MAP_PASSWORD);

                // Solo validamos el usuario: en XOne puede haber usuarios sin
                // contraseña (perfiles invitado, kiosco) y, si la contraseña es
                // incorrecta, el propio backend la rechaza vía onLoginFailed.
                if (isEmpty(sUsuario)) {
                    ui.showToast("Introduzca el usuario");
                    return;
                }

                appData.login({
                    userName: sUsuario,
                    password: sPassword,
                    entryPoint: "MenuPrincipal",
                    onLoginSuccessful: function() {
                        ui.showToast("Bienvenido!");
                    },
                    onLoginFailed: function() {
                        ui.showToast("Usuario o contraseña incorrectos");
                    }
                });
            </script>
        </action>
    </aceptarLogin>

    <onback>
        <action name="runscript">
            <script language="javascript">
                appData.exit();
            </script>
        </action>
    </onback>
</coll>
```

### 7.7 Plantilla: Consola.xne (OBLIGATORIA)

La consola es una pantalla técnica presente en **todos** los proyectos XOne. No es pantalla principal — se accede desde un botón secundario, un menu de ajustes o similar. Su función es dar al soporte técnico (call center) toda la información necesaria para resolver los problemas del usuario.

**Una sola coleccion: `MenuConsolaReplica`**, con los grupos que correspondan según el proyecto:

| Grupo | Siempre / Solo con replica |
|-------|---------------------------|
| Drawer lateral (id=99) + Header fijo (id=98) | Siempre |
| **Grupo 1** — Datos del dispositivo | Siempre |
| **Grupo 2** — Logs de replica | Solo si hay replica |
| **Grupo 3** — Replica de ficheros (lista pendientes recibir/enviar) | Solo si hay replica |
| **Grupo 4** — Control de ficheros (botones fotos/envio) | Solo si hay replica |
| **Grupo 5** — Utilidades (envio de logs y BD al soporte) | Siempre |

> El Drawer lateral lista solo los grupos presentes. Si no hay replica, aparecen solo "Datos del dispositivo" y "Utilidades".

---

#### Plantilla completa: MenuConsolaReplica

```xml
<?xml version="1.0" encoding="iso-8859-15"?>
<xml>
<coll name="MenuConsolaReplica" title="Consola"
      sql="SELECT t1.* FROM ##PREF##empresa t1"
      objname="empresa" updateobj="empresa"
      progid="ASData.CASBasicDataObj"
      notab="true" group-swipe="true" special="false">

    <prop name="MAP_CAPTUREIMG" type="T" visible="0" />
    <prop name="MAP_OS"         type="T" visible="0" />
    <prop name="MAP_TAB"        type="T" visible="0" />
    <prop name="MAP_GROUP"       type="N" visible="0" />
    <prop name="MAP_TOTAL_PAGES" type="N" visible="0" />

    <!-- ================================================================ -->
    <!-- DRAWER lateral (menu de navegacion entre grupos)                 -->
    <!-- ================================================================ -->
    <group name="Drawer" id="99" drawer-orientation="left" width="65%" height="100%">
        <frame name="barraLateral" bgcolor="#FFFFFF" framebox="false"
               height="100%" align="top|left">
            <prop name="MAP_BT_OPCION1_DR" title="1- Datos del dispositivo"
                  type="B" visible="1" method="ExecuteNode(irGrupo(1))" />
            <!-- Solo si la app tiene replica: -->
            <prop name="MAP_BT_OPCION2_DR" title="2- Logs de replica"
                  type="B" visible="1" method="ExecuteNode(irGrupo(2))" />
            <prop name="MAP_BT_OPCION3_DR" title="3- Replica de ficheros"
                  type="B" visible="1" method="ExecuteNode(irGrupo(3))" />
            <prop name="MAP_BT_OPCION4_DR" title="4- Control de ficheros"
                  type="B" visible="1" method="ExecuteNode(irGrupo(4))" />
            <!-- Siempre: -->
            <prop name="MAP_BT_OPCION5_DR" title="5- Utilidades"
                  type="B" visible="1" method="ExecuteNode(irGrupo(5))" />
        </frame>
    </group>

    <!-- ================================================================ -->
    <!-- HEADER fijo                                                       -->
    <!-- ================================================================ -->
    <group name="Menu" id="98" fixed="true" orientation="top" height="10%">
        <frame name="frmHeader" bgcolor="#93B359" align="left|center"
               width="100%" height="100%">
            <prop name="MAP_BTN_DRAWER" type="B" img="icon_drawer.png"
                  labelwidth="0" title=" " onclick="ui.toggleGroup('99');" />
            <prop name="MAP_BTN_ATRAS" type="B" img="atras.png"
                  labelwidth="0" title=" " method="ExecuteNode(onback)" newline="false" />
            <prop name="MAP_TAB" type="T" visible="1" width="60%" newline="false" />
        </frame>
    </group>

    <!-- ================================================================ -->
    <!-- GRUPO 1: Datos del dispositivo (SIEMPRE)                         -->
    <!-- ================================================================ -->
    <group name="Device" id="1" bgcolor="#E7E7E7" onfocus="ExecuteNode(irGrupo(1))">
        <frame name="frmDevice" width="100%" height="100%" scroll="true">
            <prop name="MAP_VERSIONAPP"         type="T" visible="1" title="Versión aplicación:" locked="true" />
            <prop name="MAP_VERSIONFRAME"       type="T" visible="1" title="Versión framework:"  locked="true" />
            <prop name="MAP_VERSIONCODE"        type="T" visible="1" title="Versión code:"       locked="true" />
            <prop name="MAP_MID"                type="T" visible="1" title="MID dispositivo:"    locked="true" />
            <prop name="MAP_IMEI"               type="T" visible="1" title="IMEI:"               locked="true" />
            <prop name="MAP_DISPOSITIVO"        type="T" visible="1" title="Modelo:"             locked="true" />
            <prop name="MAP_FABRICANTE"         type="T" visible="1" title="Fabricante:"         locked="true" />
            <prop name="MAP_DEVICE_TYPE"        type="T" visible="1" title="Tipo dispositivo:"   locked="true" />
            <prop name="MAP_OS"                 type="T" visible="1" title="Sistema operativo:"  locked="true" />
            <prop name="MAP_OS_VERSION"         type="T" visible="1" title="Versión SO:"         locked="true" />
            <prop name="MAP_ORIENTATION_SCREEN" type="T" visible="1" title="Orientación:"        locked="true" />
            <prop name="MAP_DENSITY"            type="T" visible="1" title="Tipo densidad:"      locked="true" />
            <prop name="MAP_DENSITY2"           type="T" visible="1" title="Densidad:"           locked="true" />
            <prop name="MAP_RESOLUTIONWIDTH"    type="T" visible="1" title="Resol. ancho:"       locked="true" />
            <prop name="MAP_RESOLUTIONHEIGHT"   type="T" visible="1" title="Resol. alto:"        locked="true" />
        </frame>
    </group>

    <!-- ================================================================ -->
    <!-- GRUPO 2: Logs de replica + cola de operaciones (SOLO REPLICA)    -->
    <!-- ================================================================ -->
    <group name="ReplicaDatos" id="2" bgcolor="#E7E7E7" onfocus="ExecuteNode(irGrupo(2))">
        <frame name="frmReplicaDatos" width="100%" height="450p" scroll="true">
            <prop name="MAP_CMDDATE"     type="T" visible="1" title="Fecha ultima conexión:"  locked="true" />
            <prop name="MAP_RECORDSRX"   type="T" visible="1" title="Operaciones recibidas:"  locked="true" />
            <prop name="MAP_RECORDSTX"   type="T" visible="1" title="Operaciones enviadas:"   locked="true" />
            <prop name="MAP_RECORDSPEND" type="T" visible="1" title="Operaciones pendientes:" locked="true" />
            <frame name="frmLog" width="98%" height="50%" lmargin="1%"
                   framebox="true" border-corner-radius="10" scroll="true">
                <prop name="MAP_LOG" type="T" visible="1" labelwidth="0"
                      locked="true" lines="5" text-border="false" />
            </frame>
        </frame>
        <!-- Cola de operaciones pendientes de replica -->
        <frame name="frmOperQueue" width="100%" height="650p">
            <prop name="MAP_TITLECOLA" type="L" title="Cola de operaciones pendientes:" />
            <prop name="@OperQueue" type="Z" visible="1" locked="true"
                  contents="OperQueue" width="96%" lmargin="2%" />
            <contents name="OperQueue" src="ContentOperQueue" />
        </frame>
        <frame name="frmBottomReplica" width="100%" height="13%" align="center|center">
            <prop name="MAP_BT_REPLICAR"  type="B" title="Replicar"
                  method="ExecuteNode(replicar)" width="40%" height="50%" />
            <prop name="MAP_BT_COMPARTIR" type="B" title="Compartir"
                  method="ExecuteNode(compartir)"
                  width="40%" height="50%" newline="false" lmargin="5%" />
        </frame>
    </group>

    <!-- ================================================================ -->
    <!-- GRUPO 3: Lista de ficheros pendientes (SOLO REPLICA)             -->
    <!-- ================================================================ -->
    <group name="ReplicaFicheros" id="3" bgcolor="#E7E7E7" onfocus="ExecuteNode(irGrupo(3))">
        <frame name="frmReplicaFicheros" height="87%">
            <prop name="MAP_TITLETOTAL" type="L" title="Ficheros pendientes recibir:"
                  visible="1" width="40%" />
            <prop name="MAP_TOTAL" type="N" visible="1" newline="false"
                  width="50%" locked="true" />
            <frame name="frmListaRecibir" width="100%" height="40%" scroll="true">
                <prop name="replicafile" type="Z" visible="1" contents="replicafile"
                      width="100%" height="100%" locked="true"
                      disablevisible="MAP_OS='ios'" />
                <contents name="replicafile" src="ContentReplicaFiles"
                          filter="STATUS!=201 AND REPLICATYPE=0" />
            </frame>
            <prop name="MAP_TITLETOTAL_ENV" type="L" title="Ficheros pendientes enviar:"
                  visible="1" width="40%" />
            <prop name="MAP_TOTAL_ENV" type="N" visible="1" newline="false"
                  width="50%" locked="true" />
            <frame name="frmListaEnviar" width="100%" height="40%" scroll="true">
                <prop name="replicafile_ENV" type="Z" visible="1" contents="replicafile_ENV"
                      width="100%" height="100%" locked="true"
                      disablevisible="MAP_OS='ios'" />
                <contents name="replicafile_ENV" src="ContentReplicaFiles"
                          filter="STATUS!=201 AND REPLICATYPE=1" />
            </frame>
        </frame>
        <frame name="frmBottomFicheros" width="100%" height="13%" align="center|center">
            <prop name="MAP_BT_REPLICAR2"  type="B" title="Replicar"
                  method="ExecuteNode(replicar)" width="40%" height="50%" />
            <prop name="MAP_BT_COMPARTIR2" type="B" title="Compartir"
                  method="ExecuteNode(compartir)"
                  width="40%" height="50%" newline="false" lmargin="5%" />
        </frame>
    </group>

    <!-- ================================================================ -->
    <!-- GRUPO 4: Control de ficheros con botones (SOLO REPLICA)          -->
    <!-- ================================================================ -->
    <group name="ControlFicheros" id="4" bgcolor="#E7E7E7" onfocus="ExecuteNode(irGrupo(4))">
        <frame name="frmCenter" width="100%" height="100%" align="top|center">
            <prop type="B" name="Ok99" img="hacer_foto.png"
                  title="HACER FOTO"
                  align="center" width="550p" height="150p" visible="1"
                  method="ExecuteNode(camera)" label-wrap="true" />
            <prop type="B" name="Ok3" img="archivos_nocomienza.png"
                  title="FOTOS SIN ENVIO INICIADO"
                  align="center" width="550p" height="150p" visible="1"
                  method="ExecuteNode(verFicheros(nocomienza))" label-wrap="true" />
            <prop type="B" name="Ok4" img="archivos_enproceso.png"
                  title="FOTOS EN PROCESO DE ENVIO"
                  align="center" width="550p" height="150p" visible="1"
                  method="ExecuteNode(verFicheros(enproceso))" label-wrap="true" />
            <prop type="B" name="Ok10" img="archivos_enviados.png"
                  title="FOTOS ENVIADAS A LA CENTRAL"
                  align="center" width="550p" height="150p" visible="1"
                  method="ExecuteNode(verFicheros(enviados))" label-wrap="true" />
            <prop type="B" name="Ok2" img="iniciar_replica.png"
                  title="INICIAR ENVIO DE FICHEROS"
                  align="center" width="550p" height="150p" visible="1"
                  method="ExecuteNode(replicar)" label-wrap="true" />
        </frame>
    </group>

    <!-- ================================================================ -->
    <!-- GRUPO 5: Utilidades - envio de diagnostico (SIEMPRE)             -->
    <!-- ================================================================ -->
    <group name="Utilidades" id="5" bgcolor="#E7E7E7" onfocus="ExecuteNode(irGrupo(5))">
        <frame name="frmUtilidades" align="top|center" height="100%">
            <!-- Enviar log Android (oculto en iOS) -->
            <prop name="MAP_BT_ENVIAR_LOG" type="B" visible="1"
                  title="Enviar log" width="90%" height="10%"
                  onclick="javascript:doDebugTools(0);"
                  disablevisible="MAP_OS='IOS' OR MAP_OS='ios'" />
            <!-- Enviar base de datos -->
            <prop name="MAP_BT_ENVIAR_BD" type="B" visible="1"
                  title="Enviar base de datos" width="90%" height="10%"
                  onclick="javascript:doDebugTools(1);" />
            <!-- Enviar BD debug replica (solo Android) -->
            <prop name="MAP_BT_ENVIAR_BD_REP" type="B" visible="1"
                  title="Enviar BD depuracion replica" width="90%" height="10%"
                  onclick="javascript:doDebugTools(2);"
                  disablevisible="MAP_OS='IOS' OR MAP_OS='ios'" />
            <!-- Enviar BD debug ficheros (solo Android) -->
            <prop name="MAP_BT_ENVIAR_BD_FIC" type="B" visible="1"
                  title="Enviar BD depuracion ficheros" width="90%" height="10%"
                  onclick="javascript:doDebugTools(3);"
                  disablevisible="MAP_OS='IOS' OR MAP_OS='ios'" />
        </frame>
    </group>

    <!-- ================================================================ -->
    <!-- before-edit: cargar macros del dispositivo e inicializar datos   -->
    <!-- ================================================================ -->
    <before-edit>
        <action name="setval" field="MAP_VERSIONAPP"          value="##VERSION##" />
        <action name="setval" field="MAP_VERSIONFRAME"        value="##FRAME_VERSION##" />
        <action name="setval" field="MAP_VERSIONCODE"         value="##FRAME_VERSION_CODE##" />
        <action name="setval" field="MAP_DISPOSITIVO"         value="##DEVICE_MODEL##" />
        <action name="setval" field="MAP_FABRICANTE"          value="##DEVICE_MANUFACTURER##" />
        <action name="setval" field="MAP_DEVICE_TYPE"         value="##DEVICE_TYPE##" />
        <action name="setval" field="MAP_IMEI"                value="##DEVICEID##" />
        <action name="setval" field="MAP_MID"                 value="##MID##" />
        <action name="setval" field="MAP_ORIENTATION_SCREEN"  value="##CURRENT_ORIENTATION##" />
        <action name="setval" field="MAP_OS"                  value="##DEVICE_OS##" />
        <action name="setval" field="MAP_OS_VERSION"          value="##DEVICE_OSVERSION##" />
        <action name="setval" field="MAP_DENSITY"             value="##CURRENT_DENSITY##" />
        <action name="setval" field="MAP_DENSITY2"            value="##CURRENT_DENSITY_VALUE##" />
        <action name="setval" field="MAP_RESOLUTIONWIDTH"     value="##SCREEN_RESOLUTION_WIDTH##" />
        <action name="setval" field="MAP_RESOLUTIONHEIGHT"    value="##SCREEN_RESOLUTION_HEIGHT##" />
        <action name="runscript">
            <script language="javascript">
                // Activar flag de consola abierta (para el auto-refresh)
                appData.getCurrentEnterprise().setVariable("ConsolaReplica", 1);

                if (self.MAP_VERSIONCODE === "##FRAME_VERSION_CODE##") {
                    self.MAP_VERSIONCODE = "No disponible";
                }

                // Cargar datos de replica y ficheros
                inicializarDatosReplica(self);
                inicializarDatosReplicaFicheros(self);

                // Iniciar auto-refresh cada 5 segundos
                ui.executeActionAfterDelay("refreshDatosReplica", 1);
            </script>
        </action>
    </before-edit>

    <!-- Navegar entre grupos y actualizar título del header -->
    <irGrupo refresh="false" show-wait-dialog="false">
        <action name="runscript">
            <param name="parametro" />
            <script language="javascript">
                irGrupoConsolaReplica(parametro, self);
            </script>
        </action>
    </irGrupo>

    <!-- Lanzar replica manual -->
    <replicar refresh="false" show-wait-dialog="false">
        <action name="runscript">
            <script language="javascript">
                replica.start();
                ui.showToast("Iniciando ciclo de replica");
            </script>
        </action>
    </replicar>

    <!-- Auto-refresh mientras la consola esta abierta -->
    <refreshDatosReplica refresh="false" show-wait-dialog="false">
        <action name="runscript">
            <script language="javascript">
                if (appData.getCurrentEnterprise().getVariable("ConsolaReplica") == 1) {
                    inicializarDatosReplica(self);
                    inicializarDatosReplicaFicheros(self);
                    ui.getView(self).refresh(
                        "MAP_RECORDSRX", "MAP_RECORDSTX", "MAP_RECORDSPEND",
                        "MAP_LOG", "MAP_CMDDATE",
                        "MAP_TOTAL", "MAP_TOTAL_ENV",
                        "replicafile", "replicafile_ENV"
                    );
                    ui.executeActionAfterDelay("refreshDatosReplica", 5);
                }
            </script>
        </action>
    </refreshDatosReplica>

    <!-- Capturar pantalla y compartir -->
    <compartir show-wait-dialog="false">
        <action name="runscript">
            <script language="javascript">
                try {
                    ui.captureImage("MAP_CAPTUREIMG");
                    ui.shareData("Compartir byXOne", "", self.MAP_CAPTUREIMG);
                } catch(ex) {}
            </script>
        </action>
    </compartir>

    <!-- Onback: desactivar flag y salir -->
    <onback show-wait-dialog="false">
        <action name="runscript">
            <script language="javascript">
                appData.getCurrentEnterprise().setVariable("ConsolaReplica", 0);
                exitCollection();
            </script>
        </action>
    </onback>

</coll>
</xml>
```

---

#### Coleccion ContentOperQueue — Cola de Operaciones Pendientes

Muestra las operaciones INSERT/UPDATE/DELETE pendientes en `master_replica_queue`. Se usa como contents en el Grupo 2.

```xml
<coll name="ContentOperQueue" title="OperQueue"
      sql="SELECT
           CASE WHEN t1.OPER=1 THEN 'INSERT'
                WHEN t1.OPER=2 THEN 'DELETE'
                WHEN t1.OPER=3 THEN 'UPDATE'
           END AS MAP_OPER,
           t1.SQL AS MAP_SQL
           FROM master_replica_queue t1"
      userawsql="true"
      objname="empresa" updateobj="empresa"
      progid="ASData.CASBasicDataObj"
      cell-odd-color="#FFFFFF" cell-even-color="#F2F2F2">
    <group name="General" id="1">
        <prop name="MAP_OPER" class="classgrid" width="30%" />
        <prop name="MAP_SQL"  class="classgrid" newline="false" width="68%" />
    </group>
</coll>
```

#### Coleccion ContentReplicaFiles — Ficheros con barra de progreso

Muestra los ficheros en proceso de envio con barra de progreso visual usando `##FLD_MAP_CALCULOBLOCK##` como ancho dinámico.

```xml
<coll name="ContentReplicaFiles" fontsize="8" title="ReplicaFiles"
      show-toolbar="false" notab="true"
      objname="master_replica_files" updateobj="master_replica_files"
      progid="ASData.CASBasicDataObj"
      sql="SELECT * FROM master_replica_files"
      connection="Info_ReplicaFiles"
      loadall="false" editmask="8"
      check-owner="false" dependent="false">
    <group name="General" id="1">
        <frame name="page_contact" width="100%" height="100%" bgcolor="#FFFFFF">
            <prop name="LICENSE"          type="T" visible="7" locked="true" labelwidth="0" title="Licencia:" />
            <prop name="FILENAME"         type="T" visible="7" locked="true" labelwidth="0" title="Nombre:" />
            <prop name="STATUS"           type="N" visible="7" locked="true" labelwidth="0" title="Status:" align="center" />
            <prop name="MAP_CALCULOBLOCK" type="N" visible="7" locked="true" labelwidth="0" title="Porciento:" align="center" newline="false" />
            <prop name="BLOCK"            type="N" visible="7" locked="true" labelwidth="0" title="B.Tras:" align="center" newline="false" />
            <prop name="BLOCKS"           type="N" visible="7" locked="true" labelwidth="0" title="Total:" align="center" newline="false" />
            <!-- Barra de progreso: ancho dinámico según porcentaje -->
            <frame name="progress_frame" width="100" height="30"
                   framebox="true" bgcolor="#505050" align="left|center">
                <frame name="progress_bar" width="##FLD_MAP_CALCULOBLOCK##" height="28"
                       framebox="true" bgcolor="#FF0000" align="left|center">
                    <prop name="MAP_TL" type="L" visible="0" labelwidth="1" locked="true" title="" />
                </frame>
            </frame>
        </frame>
    </group>
</coll>
```


> **NOTA:** `master_replica_files` y `master_replica_queue` son tablas internas del sistema XOne. No requieren definición en el modelo de datos del proyecto.

---

#### Funciones JavaScript requeridas en functions.js

```javascript
// Envia información de diagnostico al servidor de soporte
// método: 0=log Android, 1=BD, 2=BD replica debug, 3=BD ficheros debug
function doDebugTools(metodo) {
    var urlLog = "https://xoneisp.com/XoneLogRec/reclog.aspx";
    var debugTools = new DebugTools();
    if (typeof debugTools === "undefined") {
        ui.showToast("Funcion no implementada en IOS");
        return;
    }
    var message, result;
    switch (metodo) {
        case 0: message = "el log de android";
                result = debugTools.sendLog(urlLog); break;
        case 1: message = "la base de datos";
                result = debugTools.sendDatabase(urlLog); break;
        case 2: message = "la base de datos de depuracion";
                result = debugTools.sendReplicaDebugDatabase(urlLog); break;
        case 3: message = "la base de datos de depuracion de ficheros";
                result = debugTools.sendReplicaFilesDatabase(urlLog); break;
    }
    ui.showToast(result === -1 ? "No se pudo enviar " + message : "Enviado correctamente.");
    debugTools = null;
}

// Navega entre grupos de la consola y actualiza el título del header
function irGrupoConsolaReplica(parametro, objself) {
    try {
        switch (parametro) {
            case '1': objself.MAP_TAB = "Datos del dispositivo 1/5"; break;
            case '2': objself.MAP_TAB = "Logs de replica 2/5";       break;
            case '3': objself.MAP_TAB = "Replica de ficheros 3/5";   break;
            case '4': objself.MAP_TAB = "Control de ficheros 4/5";   break;
            case '5': objself.MAP_TAB = "Utilidades 5/5";            break;
        }
        ui.hideGroup('99');
        ui.showGroup(parametro);
        ui.getView(objself).refresh("MAP_TAB");
    } catch(e) {
        writelogExceptionJSv2("irGrupoConsolaReplica ERROR: " + e.message, "functions.js", false);
    }
}

// Carga los datos de replica en los campos MAP_ de la consola
function inicializarDatosReplica(coll) {
    if (appData.getGlobalMacro("##DEVICE_OS##") === "android") {
        coll.MAP_RECORDSRX   = replica.getRecordsRX() + "/" + replica.getTotalRecordsRX();
        coll.MAP_RECORDSTX   = replica.getRecordsTX() + "/" + replica.getTotalRecordsTX();
        coll.MAP_RECORDSPEND = replica.getRecordsPend();
        coll.MAP_LOG         = replica.getLog();
        var replicaCMDLOG = appData.getCollection("ReplicaCmdLog");
        replicaCMDLOG.loadAll();
        coll.MAP_CMDDATE = replicaCMDLOG.getCount() > 0
            ? replicaCMDLOG.getItem(0).CMDTIME
            : "Nunca";
    }
}

// Carga los contadores de ficheros pendientes de replica
function inicializarDatosReplicaFicheros(objself) {
    if (appData.getGlobalMacro("##DEVICE_OS##") === "android") {
        var fc = objself.getContents("replicafile");
        fc.loadAll();
        objself.MAP_TOTAL = fc.getCount();

        var fe = objself.getContents("replicafile_ENV");
        fe.loadAll();
        objself.MAP_TOTAL_ENV = fe.getCount();

        ui.getView(objself).refresh(
            "MAP_TOTAL", "MAP_TOTAL_ENV", "replicafile", "replicafile_ENV"
        );
    }
}

// Arranca la replica y cierra la consola
function exitCollection() {
    replica.start();
    ui.getView(self).exit();
}
```


### 7.8 Plantilla: Lista de Entidad

```xml
<?xml version="1.0" encoding="utf-8"?>
<!--
    Pantalla de lista de [Entidad]
-->
<coll name="Lista[Entidad]"
      sql="SELECT * FROM ##PREF##[Entidad]"
      loadall="true" objname="[Entidad]"
      notab="true" show-toolbar="false">

    <group name="grpLista" id="1" class="groupNoTab">
        <!-- Header -->
        <frame name="frmHeader" width="100%" height="80p"
               bgcolor="#2196F3" align="center">
            <prop name="btnAtras" type="B" visible="7"
                  width="48p" height="48p" lmargin="10p"
                  img="./icons/ic_arrow_back_white.png"
                  bgcolor="#00000000"
                  onclick="var w = ui.getView(self); if (w) w.exit();" />
            <prop name="lblTitulo" type="L" visible="7"
                  width="70%" height="48p" lmargin="10p"
                  newline="false" forecolor="#FFFFFF"
                  fontsize="16" title="Lista de [Entidad]" />
        </frame>

        <!-- Campos visibles en modo lista (visible="2" o "7") -->
        <prop name="NOMBRE" type="T" visible="7" title="Nombre" />
        <prop name="DESCRIPCION" type="T" visible="2" title="Descripción" />
    </group>

    <!-- Al seleccionar un item de la lista -->
    <selecteditem show-wait-dialog="false" refresh="false">
        <action name="runscript">
            <script language="javascript">
                ui.openEditView(self);
            </script>
        </action>
    </selecteditem>

    <onback show-wait-dialog="false" refresh="false">
        <action name="runscript">
            <script language="javascript">
                let window = ui.getView(self);
                if (window) window.exit();
            </script>
        </action>
    </onback>
</coll>
```

### 7.9 Plantilla: Detalle/Formulario de Entidad

```xml
<?xml version="1.0" encoding="utf-8"?>
<!--
    Pantalla de detalle/edicion de [Entidad]
-->
<coll name="Detalle[Entidad]" title="Detalle"
      notab="true" show-toolbar="false">

    <group name="grpDetalle" id="1" class="groupNoTab">
        <!-- Header -->
        <frame name="frmHeader" width="100%" height="80p"
               bgcolor="#2196F3" align="center">
            <prop name="btnAtras" type="B" visible="7"
                  width="48p" height="48p" lmargin="10p"
                  img="./icons/ic_arrow_back_white.png"
                  bgcolor="#00000000"
                  onclick="var w = ui.getView(self); if (w) w.exit();" />
            <prop name="lblTitulo" type="L" visible="7"
                  width="70%" height="48p" lmargin="10p"
                  newline="false" forecolor="#FFFFFF"
                  fontsize="16" title="Detalle" />
            <prop name="btnGuardar" type="B" visible="7"
                  width="48p" height="48p" rmargin="10p"
                  newline="false" img="./icons/ic_save_white.png"
                  bgcolor="#00000000"
                  method="executenode(guardar)" />
        </frame>

        <!-- Formulario -->
        <frame name="frmFormulario" width="100%" height="100%"
               scroll="true" bgcolor="#FFFFFF">
            <prop name="NOMBRE" type="T" visible="1"
                  width="90%" height="50p" align="center"
                  tmargin="15p" labelwidth="0"
                  floating-tooltip="true" tooltip="Nombre"
                  class="textoEditable" />
            <prop name="DESCRIPCION" type="T" visible="1"
                  width="90%" height="80p" align="center"
                  tmargin="15p" labelwidth="0" lines="3"
                  floating-tooltip="true" tooltip="Descripción"
                  class="textoEditable" />
            <!-- Agregar mas campos según el modelo de datos -->
        </frame>
    </group>

    <!-- Evento guardar -->
    <guardar>
        <action name="runscript">
            <script language="javascript">
                if (isEmpty(self.NOMBRE)) {
                    ui.showToast("El nombre es obligatorio");
                    return;
                }
                self.save();
                ui.showToast("Guardado correctamente");
                let window = ui.getView(self);
                if (window) window.exit();
            </script>
        </action>
    </guardar>

    <onback show-wait-dialog="false" refresh="false">
        <action name="runscript">
            <script language="javascript">
                let window = ui.getView(self);
                if (window) window.exit();
            </script>
        </action>
    </onback>
</coll>
```

### 7.10 Plantilla: Pantalla con Mapa

```xml
<?xml version="1.0" encoding="utf-8"?>
<!--
    Pantalla con mapa
-->
<coll name="Mapa[Entidad]" title="Mapa"
      notab="true" show-toolbar="false">

    <group name="grpMapa" id="1" class="groupNoTab">
        <frame name="frmHeader" width="100%" height="80p"
               bgcolor="#2196F3" align="center">
            <prop name="btnAtras" type="B" visible="7"
                  width="48p" height="48p" lmargin="10p"
                  img="./icons/ic_arrow_back_white.png"
                  bgcolor="#00000000"
                  onclick="var w = ui.getView(self); if (w) w.exit();" />
            <prop name="lblTitulo" type="L" visible="7"
                  width="70%" height="48p" lmargin="10p"
                  newline="false" forecolor="#FFFFFF"
                  fontsize="16" title="Mapa" />
        </frame>

        <!-- Mapa -->
        <prop name="MAP_MAPA" type="Z" visible="7"
              viewmode="mapview"
              contents="@Ubicaciones"
              width="100%" height="85%"
              show-user-location="true"
              zoom-to-pois="true"
              onmapclicked="onMapClicked(e);"
              onmapready="onMapReady(e);" />
    </group>

    <contents name="@Ubicaciones" src="UbicacionesColl" />

    <onback show-wait-dialog="false" refresh="false">
        <action name="runscript">
            <script language="javascript">
                let window = ui.getView(self);
                if (window) window.exit();
            </script>
        </action>
    </onback>
</coll>
```

### 7.11 Plantilla: Pantalla de Configuración

```xml
<?xml version="1.0" encoding="utf-8"?>
<!--
    Pantalla de configuración/ajustes
-->
<coll name="Configuración" title="Configuración"
      special="true" notab="true" show-toolbar="false">

    <group name="grpConfig" id="1" class="groupNoTab">
        <frame name="frmHeader" width="100%" height="80p"
               bgcolor="#2196F3" align="center">
            <prop name="btnAtras" type="B" visible="7"
                  width="48p" height="48p" lmargin="10p"
                  img="./icons/ic_arrow_back_white.png"
                  bgcolor="#00000000"
                  onclick="var w = ui.getView(self); if (w) w.exit();" />
            <prop name="lblTitulo" type="L" visible="7"
                  width="70%" height="48p" lmargin="10p"
                  newline="false" forecolor="#FFFFFF"
                  fontsize="16" title="Configuración" />
        </frame>

        <frame name="frmOpciones" width="100%" height="100%"
               scroll="true" bgcolor="#FFFFFF">

            <!-- Info del usuario -->
            <prop name="lblUsuario" type="L" visible="7"
                  width="90%" height="40p" align="center"
                  tmargin="20p" fontsize="14"
                  title="Usuario conectado" />

            <!-- Opciones -->
            <prop name="MAP_NOTIFICACIONES" type="NC" visible="7"
                  width="90%" height="50p" align="center"
                  tmargin="15p" title="Notificaciones"
                  check-type="toggle" />

            <!-- Botón cerrar sesion -->
            <prop name="btnCerrarSesion" type="B" visible="7"
                  width="80%" height="50p" align="center"
                  tmargin="40p" class="btnPeligro"
                  title="Cerrar Sesion"
                  onclick="if (confirmar('Desea cerrar sesion?', 'Cerrar Sesion')) { appData.logout(); };" />

            <!-- Versión -->
            <prop name="lblVersion" type="L" visible="7"
                  width="100%" height="30p" align="center"
                  tmargin="30p" class="textoSubtitulo"
                  title="Versión 1.0.0" />
        </frame>
    </group>

    <onback show-wait-dialog="false" refresh="false">
        <action name="runscript">
            <script language="javascript">
                let window = ui.getView(self);
                if (window) window.exit();
            </script>
        </action>
    </onback>
</coll>
```

### 7.12 Estructura de Pantalla Estándar

Toda pantalla debe seguir esta estructura básica:

```xml
<coll name="NombrePantalla" title="Título" class="xnCollBase">
    <!-- Eventos de ciclo de vida -->
    <create><!-- Se ejecuta una sola vez al crear un objeto nuevo --></create>
    <before-edit><!-- Se ejecuta al abrir el objeto para editar, antes de pintar la UI --></before-edit>
    <after-edit><!-- Se ejecuta al abrir el objeto para editar, una vez pintada la UI --></after-edit>

    <!-- Contenido visual -->
    <group name="grpPrincipal" id="1" class="groupNoTab">
        <frame name="frmHeader" class="frameHeader">...</frame>
        <frame name="frmBody" class="frameBody">...</frame>
        <frame name="frmFooter" class="frameFooter">...</frame>
    </group>

    <!-- Contents embebidos (si aplica) -->
    <contents name="@MiContenido" src="MiColeccion" />

    <!-- Eventos custom (invocados con ExecuteNode) -->
    <miEvento>
        <action name="runscript">
            <script language="javascript">
                // Lógica del evento
            </script>
        </action>
    </miEvento>

    <!-- Manejo del botón atrás -->
    <onback>
        <action name="runscript">
            <script language="javascript">
                let window = ui.getView(self);
                if (window) window.exit();
            </script>
        </action>
    </onback>
</coll>
```

### 7.12b Nodo GROUP — Pestanas y Grupos de Pantalla

El nodo `<group>` define las pestanas o áreas de contenido dentro de una coleccion. Cada group tiene un `id` único que lo identifica.

#### Atributos del nodo `<group>`

| Atributo | Descripción | Ejemplo |
|----------|-------------|---------|
| `name` | Caption que se muestra en la pestana | `"General"` |
| `id` | Identificador numérico único del grupo | `"1"` |
| `bgcolor` | Color de fondo del grupo | `"#FFFFFF"` |
| `imgbk` | Imagen de fondo del grupo | `"fondo.png"` |
| `disableedit` | Deshabilita edición de todos los campos SI se cumple la condición | `"ESTADO=2"` |
| `disablevisible` | Oculta el grupo entero SI se cumple la condición | `"TIPO=0"` |
| `align` | Alineacion del contenido dentro del group. Mismos valores y comportamiento que en `<frame>`: `center`, `left\|top`, `center\|center`, etc. | `"center\|top"` |
| `tab-width` | Ancho de la pestana. Por defecto `"33%"` | `"50%"` |
| `animation-in` | Animación al entrar al grupo | `"##ALPHA_IN##"` |
| `animation-out` | Animación al salir del grupo | `"##ALPHA_OUT##"` |
| `onfocus` | Evento que se ejecuta cuando el usuario selecciona el grupo | `"ExecuteNode(onfocusgrupo(1))"` |
| `below-drawer` | Si es `true`, el grupo queda por debajo del drawer. Usar en headers y footers fijos para que el drawer se superponga correctamente | `"true"` |
| `floating` | Si es `true`, el grupo se superpone sobre el contenido. Posicionar con `top` y `left` | `"true"` |

#### Grupo Fijo (Header/Footer)

Para crear cabeceras o pies fijos que no se desplazan con el scroll:

```xml
<!-- Header fijo en la parte superior -->
<group name="HEADER" id="10" fixed="true" orientation="top" width="100%" height="120p">
    <frame name="frmHeader" class="frmsuperior">
        <prop name="SALIR" type="B" class="btvolversuper" />
        <prop name="TITULO" type="L" class="tlsuper" title="MI PANTALLA" />
        <prop name="BTMENU" type="B" class="btmenuicon" method="ExecuteNode(onback)" />
    </frame>
</group>

<!-- Footer fijo en la parte inferior -->
<group name="FOOTER" id="0" fixed="true" orientation="bottom" width="100%" height="80p">
    <frame name="frmFooter">
        <prop name="BTN_CANCELAR" type="B" title="Cancelar" method="ExecuteNode(onback)"
              width="45%" height="80%" />
        <prop name="BTN_ACEPTAR" type="B" title="Aceptar" method="ExecuteNode(guardar)"
              width="45%" height="80%" newline="false" lmargin="6%" />
    </frame>
</group>

<!-- Contenido principal — ocupa el espacio restante tras los grupos fijos -->
<group name="General" id="1">
    <!-- ... -->
</group>
```

> **IMPORTANTE:** Una vez definidos los grupos fijos, el espacio restante se considera el 100% para los grupos de contenido. No hay que restar el alto de los grupos fijos.

#### Grupo Drawer (panel lateral deslizante)

```xml
<group name="Drawer" id="999" drawer-orientation="left" width="70%" height="100%">
    <prop name="MAP_BT_MENU1" type="B" title="Clientes" visible="1"
          onclick="javascript:ui.openEditView('ListaClientes'); ocultarGrupo(999);"
          class="xnTituloDrawerC" />
    <prop name="MAP_BT_MENU2" type="B" title="Pedidos" visible="1"
          onclick="javascript:ui.openEditView('ListaPedidos'); ocultarGrupo(999);"
          class="xnTituloDrawerC" />
    <prop name="MAP_BT_SALIR" type="B" title="Salir" visible="1"
          method="ExecuteNode(onback)" class="xnTituloDrawerC" />
</group>
```

**Métodos JavaScript para el Drawer:**

| Método | Descripción |
|--------|-------------|
| `ui.showGroup(id)` | Muestra el grupo |
| `ui.showGroup(id, animIn, durIn, animOut, durOut)` | Muestra el grupo con animación personalizada |
| `ui.hideGroup(id)` | Oculta el grupo |
| `ui.toggleGroup(id)` | Alterna entre mostrar y ocultar |
| `ui.lockGroup(id, close)` | Bloquea el grupo: `close=true` lo bloquea cerrado, `close=false` lo bloquea abierto |
| `ui.unlockGroup(id)` | Desbloquea el grupo para que vuelva a ser interactivo |

```javascript
// Abrir drawer con animacion
ui.showGroup(999, "##RIGHT_IN##", 300, "##LEFT_OUT##", 200);
// Cerrar
ui.hideGroup(999);
// Bloquear cerrado durante carga inicial
ui.lockGroup(999, true);
```

#### Macros de animación para grupos y frames

| Macro entrada | Macro salida | Efecto |
|---------------|--------------|--------|
| `##ALPHA_IN##` | `##ALPHA_OUT##` | Fundido de entrada/salida |
| `##RIGHT_IN##` | `##RIGHT_OUT##` | Desde/hacia la derecha |
| `##LEFT_IN##` | `##LEFT_OUT##` | Desde/hacia la izquierda |
| `##PUSH_IN##` | `##PUSH_OUT##` | Empuje desde abajo |
| `##PUSH_DOWN_IN##` | `##PUSH_DOWN_OUT##` | Empuje hacia abajo |
| `##ROTATE3D_IN##` | `##ROTATE3D_OUT##` | Rotación 3D |
| `##ZOOM_IN##` | `##ZOOM_OUT##` | Zoom de entrada/salida |

#### Atributos de COLL relacionados con grupos

| Atributo en coll | Descripción |
|------------------|-------------|
| `notab="true"` | Oculta las pestanas de los grupos |
| `group-swipe="true"` | Permite deslizar entre grupos con el dedo |
| `group-theme="material"` | Estilo Material Design para las pestanas |
| `tab-mode="fixed"` | Pestanas de ancho fijo distribuidas en pantalla |
| `tab-mode="scrollable"` | Pestanas con scroll si no caben en pantalla |

---

### 7.12c Nodo FRAME — Contenedores Visuales

El nodo `<frame>` es el equivalente al `<div>` de HTML. Permite organizar los props en áreas visuales dentro de un group. Los frames pueden anidarse sin limite.

> **REGLA CRITICA:** Un `<frame>` **solo se pinta si contiene al menos un `<prop>` visible**. Un frame vacio, o con todos sus props con `visible="0"`, no ocupa espacio ni se renderiza en pantalla. **No usar frames como espaciadores vacios** — no funcionan para crear espacio. Si se necesita separación visual, usar `tmargin`/`bmargin` en el prop anterior, o un `<prop type="L" title=" " height="20p" visible="1" />` como separador.

```xml
<frame name="frmContenido" width="100%" height="100%" scroll="true" bgcolor="#FFFFFF">
    <frame name="frmCabecera" width="100%" height="80p" bgcolor="#2196F3">
        <prop name="TITULO" type="L" title="Mi título" forecolor="#FFFFFF" labelwidth="0" />
    </frame>
    <frame name="frmCuerpo" width="90%" height="100%" lmargin="5%">
        <prop name="NOMBRE" type="T" visible="1" title="Nombre:" />
    </frame>
</frame>
```

#### Atributos del nodo `<frame>`

| Atributo | Descripción | Ejemplo |
|----------|-------------|---------|
| `name` | Identificador del frame | `"frmHeader"` |
| `width` | Ancho: `%`, `p` (puntos) o valor numérico DIP | `"100%"`, `"300p"` |
| `height` | Alto: `%`, `p` o DIP. `-2` = ajuste automático al contenido | `"120p"`, `-2` |
| `bgcolor` | Color de fondo | `"#2196F3"`, `"#00000000"` (transparente) |
| `imgbk` | Imagen de fondo | `"fondo.png"` |
| `framebox` | `false` oculta el borde del frame | `"false"` |
| `border-width` | Ancho del borde | `"1"` |
| `align` | Alineacion del contenido dentro del frame. Valores: `left`, `right`, `center`, `top`, `bottom`. Combinar horizontal y vertical con `\|`: `center\|center`, `left\|top`, `left\|center`, `center\|top`, `right\|center`. Mismo comportamiento en `<group>` y `<prop>` | `"center\|top"` |
| `newline` | Por defecto `true`. Con `false` el frame se coloca a la derecha del anterior en la misma línea. Los anchos deben sumar 100% o menos | `"false"` |
| `scroll` | `true` permite scroll si el contenido supera el alto | `"true"` |
| `lmargin`/`tmargin`/`rmargin`/`bmargin` | Margenes exteriores | `"5%"`, `"10p"` |
| `lpadding`/`tpadding`/`rpadding`/`bpadding` | Margenes interiores | `"15p"` |
| `disablevisible` | Oculta el frame SI se cumple la condición | `"ESTADO=0"` |
| `animation-in` | Animación de entrada | `"##ALPHA_IN##"` |
| `animation-out` | Animación de salida | `"##ALPHA_OUT##"` |
| `animation-in-delay` | Duración de la animación de entrada (ms) | `"300"` |
| `animation-out-delay` | Duración de la animación de salida (ms) | `"300"` |
| `elevation` | Elevacion / sombra Material Design. Valores de 1 a 24 | `"5"` |
| `border-corner-radius` | Radio de esquinas redondeadas | `"10"` |
| `ignore-touch-on-transparent-area` | En frames flotantes, los toques sobre áreas transparentes pasan al elemento que hay detras | `"true"` |

#### Frame Flotante

Un frame flotante se superpone sobre el resto de la pantalla sin afectar al layout de los demas elementos. Útil para FABs, menus contextuales, alertas:

```xml
<!-- Botón flotante en la esquina inferior derecha (FAB) -->
<frame name="frmFAB" floating="true" top="900p" left="610p" width="90p" height="90p">
    <prop name="BTN_ADD" type="B" visible="1" labelwidth="0"
          method="ExecuteNode(nuevo)" width="75p" img="add.png" imgsel="add_click.png" />
</frame>
```

| Atributo frame flotante | Descripción |
|------------------------|-------------|
| `floating="true"` | Activa el modo flotante |
| `top` | Coordenada Y en pixeles desde el borde superior |
| `left` | Coordenada X en pixeles desde el borde izquierdo |

> **NOTA:** En frames flotantes usar `p` (pixeles) para `top`, `left`, `width` y `height` para mejor funcionamiento. Evitar `%`.

#### Bottom Sheet (panel deslizante inferior)

```xml
<frame name="bottom_panel" floating="true" left="0" behavior="bottom-sheet"
       initial-state="collapsed" width="100%" height="50%">
    <prop name="TITULO" type="L" title="Panel inferior" labelwidth="0" width="100%" />
    <!-- contenido del panel -->
</frame>
```

| Estado `initial-state` | Descripción |
|------------------------|-------------|
| `expanded` | Aparece expandido al 100% de su tamaño |
| `collapsed` | Aparece minimizado mostrando solo una franja |
| `hidden` | Aparece oculto completamente |

**JavaScript:** `window.setBottomSheetState(sProp, "expanded")` para cambiar el estado.

#### Macros de animación disponibles

| Macro | Efecto |
|-------|--------|
| `##ALPHA_IN##` / `##ALPHA_OUT##` | Fade in / fade out |
| `##ZOOM_IN##` / `##ZOOM_OUT##` | Zoom in / zoom out |
| `##PUSH_IN##` / `##PUSH_OUT##` | Deslizar desde abajo / hacia abajo |
| `##PUSH_DOWN_IN##` / `##PUSH_DOWN_OUT##` | Deslizar desde arriba / hacia arriba |
| `##RIGHT_IN##` / `##LEFT_OUT##` | Entrar desde la derecha / salir hacia la izquierda |
| `##LEFT_IN##` / `##RIGHT_OUT##` | Entrar desde la izquierda / salir hacia la derecha |
| `##ROTATE3D_IN##` / `##ROTATE3D_OUT##` | Rotación 3D de entrada / salida |

---


### 7.13 ViewModes Disponibles para Generación

Al generar pantallas con contents (`<prop type="Z">`), el agente debe seleccionar el `viewmode` adecuado según el tipo de visualizacion requerida. Referencia completa:

#### Listas y Grids

| ViewMode | Descripción | Cuando usarlo |
|----------|-------------|---------------|
| `grid` | Cuadricula por defecto | Tablas simples sin necesidad de rendimiento alto |
| `recyclerview` | Lista con reciclaje de vistas | **Recomendado** para toda lista larga (>20 elementos) |
| `gridview` | Cuadricula de elementos | Catálogos visuales, galerías |
| `slideview` | Vista deslizable tipo carrusel | Banners promocionales, onboarding, galerías con swipe |
| `coverflow` | Variante de `slideview` con efecto Cover Flow estilo iTunes (cards laterales escaladas/atenuadas/rotadas en 3D) | Galerías destacadas en home, onboarding ilustrado, selectores visuales (plan/avatar), showcases con foco en una card y peek de adyacentes |
| `kanban` | Tablero estilo Trello/Jira con columnas verticales y drag&drop entre estados | Gestion de tareas (TODO/DOING/DONE), pipeline comercial (LEAD/QUOTE/WON/LOST), workflows de aprobacion, tableros de proyecto |
| `expanview` | Vista expandible/colapsable (acordeón) | Listas padre-hijo, árboles, FAQs, categorías agrupadas |
| `picturemap` | Mosaico de imágenes / catálogo visual | Catálogos de productos con foto, galerías |

#### Mapas

| ViewMode | Descripción | Cuando usarlo |
|----------|-------------|---------------|
| `mapview` | Mapa con marcadores (Google Maps) | Ubicaciones, rutas, tracking |
| `openstreetmap` | Mapa OpenStreetMap | Alternativa offline, sin dependencia de Google |

#### Gráficos (requieren `classid="XOneCharts"`)

| ViewMode | Descripción | Cuando usarlo |
|----------|-------------|---------------|
| `barchart` | Gráfico de barras | Comparaciones por categorías |
| `3dbarchart` | Gráfico de barras 3D | Comparaciones con efecto visual 3D |
| `piechart` | Gráfico circular (tarta) | Distribuciones porcentuales |
| `piechart2` | Gráfico circular alternativo | Variante visual de distribución |
| `linechart` | Gráfico de lineas | Tendencias y evoluciones temporales |
| `xylinechart` | Gráfico de lineas XY | Relaciones entre dos variables numéricas |
| `areachart` | Gráfico de área | Tendencias acumuladas, volúmenes |
| `timeserieschart` | Series temporales | Datos con eje temporal preciso (sensores, IoT) |
| `slidingbarchart` | Barras con navegación | Muchas categorías con scroll horizontal |

#### Calendario

| ViewMode | Descripción | Cuando usarlo |
|----------|-------------|---------------|
| `calendarview` | Vista de calendario | Agendas, citas, planificacion. Usar con `calendar-viewmode="week"` o `"month"` |

#### Controles Numéricos (para `<prop type="N">`, NO type="Z")

| ViewMode | Descripción | Cuando usarlo |
|----------|-------------|---------------|
| `seekbar` | Barra deslizante básica | Selección de valor numérico simple |
| `slider` | Deslizador Material Design | Ajustes de volumen, brillo, cantidades |
| `progress-bar` | Barra de progreso | Mostrar avance de proceso |
| `circular-progress-bar` | Progreso circular | Indicadores de carga, porcentajes |
| `range-slider` | Selector de rango (min-max) | Filtros de precio, edad, distancia |
| `stepper` | Control compacto `−` / `+` para valores enteros (auto-repite cada 80 ms en long-press; opcionalmente ciclico con `wrap="true"`) | Cantidades en carritos, spinners de configuración (zoom/volumen discreto), selectores ciclicos de hora/día, pasos de wizard |

> **Nota:** Los controles numéricos usan atributos adicionales: `min`, `max`, `step`/`step-size`, `orientation`. El `stepper` además acepta `wrap`, `bar-color`, `forecolor`.

#### Controles de Texto/Numéricos especiales (para `<prop type="T">` o `<prop type="N">`)

| ViewMode | Tipo base | Descripción | Cuando usarlo |
|----------|-----------|-------------|---------------|
| `otp` | `T` o `N` | Entrada de códigos de un solo uso con cajas individuales por digito, auto-avance, backspace inverso y paste distribuido. Valor concatenado sin separadores. Atributos `digits` (default 6), `secret`, `auto-submit`, `allow-letters`, `box-size`, `box-spacing`, `box-color`, `box-color-focus`. | Verificación SMS (`type="N"` `digits="6"`), 2FA, PIN de aplicación (`secret="true"`), códigos de invitacion (`allow-letters="true"`) |
| `markdown` | `T` | Renderiza el contenido del campo como Markdown CommonMark base (cabeceras, enfasis, listas, enlaces, imágenes, blockquotes, código). NO soporta tablas/strikethrough/task lists/HTML embebido. Sin atributos propios. | Mensajes formateados al usuario, descripciones servidas desde backend, plantillas dinámicas, cabeceras ricas, renderizado de respuestas de IA / chatbots |

> **Nota:** `markdown` aplica a `type="T"` y también a `type="L"` (y a su alias legacy `type="TL"`): el label-only también renderiza el contenido como Markdown vía el mismo mecanismo. En `type="T"`, para evitar el modo edición accidental, marcar el campo con `readonly="true"` o `locked="true"`.

#### Ejemplo de selección de viewmode en generación

```
Si el usuario pide:
- "lista de productos"         -> viewmode="recyclerview"
- "mapa de clientes"           -> viewmode="mapview" o "openstreetmap"
- "gráfico de ventas"          -> viewmode="barchart" + classid="XOneCharts"
- "agenda de citas"            -> viewmode="calendarview"
- "arbol de categorias"        -> viewmode="expanview" con filter="IDPADRE IS NULL"
- "carrusel de imagenes"       -> viewmode="slideview" con autoslide-delay="5"
- "galeria estilo iTunes"      -> viewmode="coverflow" con cover-flow-rotation="35"
- "tablero de tareas Kanban"   -> viewmode="kanban" con kanban-column-field y kanban-columns
- "selector de cantidad"       -> viewmode="slider" en prop type="N"
- "selector +/- de unidades"   -> viewmode="stepper" en prop type="N" con min/max/step-size
- "indicador de progreso"      -> viewmode="progress-bar" en prop type="N"
- "filtro de rango de precios" -> viewmode="range-slider" en prop type="N"
- "código SMS de 6 digitos"    -> viewmode="otp" en prop type="N" con digits="6"
- "PIN oculto de 4 caracteres" -> viewmode="otp" en prop type="T" con digits="4" secret="true" allow-letters="true"
- "texto con formato Markdown" -> viewmode="markdown" en prop type="T" (readonly="true" si es decorativo)
```

---

### 7.13a ViewMode: mapview / openstreetmap

**Cuando usarlo:** ubicaciones de clientes, rutas de trabajo, tracking de vehiculos, puntos de interes geolocalizados.

- `mapview` — Google Maps (Android e iOS). Requiere API Key de Google si se usan servicios avanzados.
- `openstreetmap` — OpenStreetMap, alternativa sin dependencia de Google, funciona offline.

#### Coleccion de datos para el mapa

La coleccion que alimenta el contents de mapa debe tener campos con atributos especiales que indican al framework que campo contiene cada dato geografico:

```xml
<coll name="ContentCoordenadas" title="coordenadas"
      sql="SELECT t1.* FROM ##PREF##clientes t1"
      objname="clientes" updateobj="clientes"
      progid="ASData.CASBasicDataObj" loadall="true">
    <group name="General" id="1">
        <prop name="NOMBRE" type="T" visible="4" />
        <!-- Atributo mapview-address: muestra la dirección en el popup del marcador -->
        <prop name="DIRECCION" type="T" visible="4" mapview-address="true" />
        <!-- Atributo mapview-latitude: indica que este campo es la latitud del POI -->
        <prop name="LATITUD" type="N6" visible="4" mapview-latitude="true" />
        <!-- Atributo mapview-longitude: indica que este campo es la longitud del POI -->
        <prop name="LONGITUD" type="N6" visible="4" mapview-longitude="true" />
        <!-- Atributo mapview-marker-icon: icono personalizado del marcador (fichero PNG en icons/) -->
        <prop name="MAP_ICONO" type="T" visible="4" mapview-marker-icon="true" />
    </group>
</coll>
```

#### Declaración del prop type="Z" con viewmode="mapview"

```xml
<prop name="@mapaClientes"
      type="Z"
      viewmode="mapview"
      mapview-embedded="true"
      contents="mapaClientes"
      width="100%"
      height="70%"
      map-type="normal"
      show-user-location="true"
      zoom-to-pois="true"
      show-zoom-buttons="true"
      show-google-buttons="true"
      onmapclicked="onMapClicked(e);"
      onmapready="onMapReady(e);" />
<contents name="mapaClientes" src="ContentCoordenadas" />
```

#### Atributos del prop mapview

| Atributo | Descripción |
|----------|-------------|
| `mapview-embedded="true"` | Embebe el mapa dentro de la coleccion. Sin este atributo abre la app de mapas del dispositivo |
| `map-type` | Tipo de mapa: `normal`, `satellite`, `terrain`, `hybrid` |
| `map-features="roads"` | Activa visualizacion de carreteras |
| `show-user-location="true"` | Muestra la posición del usuario en el mapa |
| `show-zoom-buttons="true"` | Muestra botones de zoom |
| `show-google-buttons="true"` | Muestra controles nativos de Google Maps |
| `zoom-to-pois="true"` | Ajusta el zoom para que entren todos los marcadores |
| `zoom-to-my-location="false"` | Hace zoom a la posición del usuario al cargar |
| `clear-lines-on-refresh="false"` | Mantiene las lineas dibujadas al refrescar |
| `restrict-map-to-bounds="lat1,lon1,lat2,lon2"` | Restringe el área visible del mapa a unas coordenadas |
| `cluster-markers="true"` | Agrupa marcadores cercanos en un cluster |
| `show-pois="true"` | Muestra los puntos de interes |

#### Atributos de la coleccion de datos mapview

| Atributo en prop | Descripción |
|------------------|-------------|
| `mapview-latitude="true"` | Este campo contiene la latitud del marcador |
| `mapview-longitude="true"` | Este campo contiene la longitud del marcador |
| `mapview-address="true"` | Este campo contiene la dirección a mostrar en el popup |
| `mapview-marker-icon="true"` | Este campo contiene el nombre del icono PNG del marcador |

#### Eventos del mapa (JavaScript)

| Evento | Cuando se dispara |
|--------|-------------------|
| `onmapready="onMapReady(e);"` | El mapa esta listo para usarse |
| `onmapclicked="onMapClicked(e);"` | El usuario toca el mapa (coordenadas en `e.latitude`, `e.longitude`) |
| `onmaplongclicked="onMapLongClicked(e);"` | Pulsacion larga sobre el mapa |
| `onmarkerdragend="onMarkerDraggedEnd(e);"` | Se suelta un marcador arrastrado |
| `onlocationready="onLocationReady(e);"` | La localización del usuario esta disponible |
| `onlocationchanged="onLocationChanged(e);"` | Cambia la localización del usuario |
| `onmapzoomchanged="onMapZoomChanged(e);"` | Cambia el nivel de zoom |
| `ondistancemeter="onDistanceMeter(e);"` | Resultado de medición de distancia |

#### Métodos JavaScript sobre el control de mapa

```javascript
// Obtener el control del mapa
var window = ui.getView(self);
var mapControl = window["@mapaClientes"];

// Zoom a coordenadas
mapControl.zoomTo(38.886546, -7.0043193);

// Zoom a todos los POIs
mapControl.zoomToBounds(["lat1,lon1", "lat2,lon2"]);

// Dibujar una línea entre dos puntos
mapControl.drawLine("miLinea", "#FF0000", "solid", 38.88, -7.00, 40.41, -3.70);

// Borrar todas las lineas
mapControl.clearAllLines();

// Cambiar tipo de mapa
mapControl.setMapType("satellite"); // normal, satellite, terrain, hybrid

// Activar seguimiento del usuario
mapControl.setFollowUserLocation(true);

// Medir distancia entre dos puntos (devuelve metros)
var nMetros = new GpsTools().distanceTo([
    { latitude: 38.8685452, longitude: -6.8170906 },
    { latitude: 40.4167747, longitude: -3.70379019 }
]);
```

#### OpenStreetMap — atributos adicionales

```xml
<prop name="@mapaOSM"
      type="Z"
      viewmode="openstreetmap"
      contents="mapaOSM"
      width="100%"
      height="70%"
      show-compass="true"
      show-minimap="true"
      show-scale="true"
      follow-location-on-background="true"
      tile-source="mapnik_hd"
      zoom-buttons-visibility="never"
      onmapclicked="onMapClicked(e);" />
```

| Atributo exclusivo OSM | Descripción |
|------------------------|-------------|
| `show-compass="true"` | Muestra la brujula en el mapa |
| `show-minimap="true"` | Muestra un minimapa de referencia |
| `show-scale="true"` | Muestra la escala del mapa |
| `follow-location-on-background="true"` | Sigue la localización aunque la app este en segundo plano |
| `tile-source="mapnik_hd"` | Fuente de tiles del mapa |
| `zoom-buttons-visibility` | `always`, `never`, `touch` |

---

### 7.13b ViewMode: calendarview

**Cuando usarlo:** agendas de citas, planificacion de tareas, calendarios de visitas, horarios.

El calendario se define como un `prop type="Z"` con `viewmode="calendarview"`. Puede mostrarse en vista mensual (por defecto) o semanal con `calendar-viewmode="week"`.

#### Declaración del prop tipo calendarview

```xml
<frame name="frmCalendario" width="100%" height="30%" bgcolor="#273238" align="center">
    <prop name="@MiCalendario" type="Z"
          viewmode="calendarview"
          calendar-viewmode="month"
          contents="MiCalendario"
          class="z_calendario"
          width="90%" height="100%" />
    <contents name="MiCalendario" src="ContentDatosCalendario" />
</frame>
```

#### Coleccion de datos del calendario

```xml
<coll name="ContentDatosCalendario" title="calendario"
      sql="SELECT t1.*,
           t1.FECHA AS MAP_FECHA,
           t1.DESCRIPCION AS MAP_DESCRIPCION,
           CASE WHEN t1.TIPO='Urgente' THEN '#FF5722'
                WHEN t1.TIPO='Normal'  THEN '#2196F3'
                ELSE '#4CAF50'
           END AS MAP_COLORVIEW
           FROM ##PREF##tareas t1"
      objname="tareas" updateobj="tareas"
      progid="ASData.CASBasicDataObj">
    <group name="General" id="1">
        <!-- Campos en modo grid/lista del calendario (visible="4") -->
        <frame name="frmgrid" width="100%">
            <prop name="MAP_FECHA" type="D" visible="4" labelwidth="0"
                  width="200p" text-align="center" textfont-size="8" />
            <prop name="MAP_DESCRIPCION" type="T" visible="4" labelwidth="0"
                  width="520p" text-align="center" textfont-size="8" newline="false" />
        </frame>
        <!-- Formulario de edicion (visible="1") -->
        <prop name="FECHA" type="D" visible="1"
              datefrom="true" dateto="true" title="Fecha:" />
        <prop name="HORAINI" type="TT" mask="Hh#:#Mm" visible="1"
              timefrom="true" title="Hora Inicio:" />
        <prop name="HORAFIN" type="TT" mask="Hh#:#Mm" visible="1"
              timeto="true" title="Hora Fin:" />
        <prop name="DESCRIPCION" type="T" visible="1" title="Descripción:" lines="3" />
        <!-- colorview=true: el valor de este campo se usa como color de la celda del dia -->
        <prop name="MAP_COLORVIEW" type="T" visible="0" colorview="true" />
    </group>
</coll>
```

> `colorview="true"` hace que el valor del campo se use como color de la celda del día en el calendario. `datefrom="true"` y `dateto="true"` en el campo `FECHA` definen el rango de días del evento.

#### Atributos de estilo del calendarview

| Atributo | Descripción |
|----------|-------------|
| `calendar-viewmode` | `"month"` (por defecto) o `"week"` para vista semanal |
| `page-swipe` | `true` permite deslizar entre meses/semanas con el dedo |
| `bgcolor` | Color de fondo general del calendario |
| `forecolor` | Color del texto general |
| `cell-bgcolor` | Color de fondo de las celdas de días |
| `cell-forecolor` | Color del texto de los días |
| `cell-border-width` | Grosor del borde de cada celda |
| `cell-border-color` | Color del borde de cada celda |
| `cell-align` | Alineacion del contenido de cada celda |
| `cell-selected-bgcolor` | Color de fondo del día seleccionado |
| `cell-selected-forecolor` | Color del texto del día seleccionado |
| `cell-selected-border-color` | Color del borde del día seleccionado |
| `cell-other-month-bgcolor` | Color de días de otros meses visibles en la vista actual |
| `weekdays-bgcolor` | Color de fondo de la fila de nombres de día |
| `weekdays-forecolor` | Color del texto de los nombres de día (admite 7 colores separados por comas: Dom,Lun,Mar,Mie,Jue,Vie,Sab) |
| `weekdays-fontsize` | Tamaño de fuente de los nombres de día |
| `weekdays-longname` | `true` nombre largo ("Lunes"), `false` nombre corto ("L") |
| `week-start-hour` | Hora de inicio en vista semanal (0-23) |
| `week-end-hour` | Hora de fin en vista semanal (0-23) |
| `border` | `false` elimina el borde exterior |
| `textfont-bold` | `true` texto en negrita |

#### Clase CSS de ejemplo

```css
.z_calendario {
    extends: prop;
    cell-border-width: 0;
    cell-align: center;
    align: center;
    fontsize: 11;
    forecolor: #FFFFFF;
    bgcolor: #273238;
    cell-forecolor: #FFFFFF;
    cell-bgcolor: #273238;
    cell-other-month-bgcolor: #777777;
    cell-selected-forecolor: #FABB00;
    cell-selected-bgcolor: #FFFFFF;
    cell-border-color: #273238;
    weekdays-bgcolor: #00000000;
    weekdays-forecolor: #FFFFFF;
    weekdays-fontsize: 5;
    weekdays-longname: false;
    weekdays-align: top|left;
    border-width: 3;
    textfont-bold: true;
    page-swipe: false;
    border: false;
    week-start-hour: 0;
    week-end-hour: 1;
}
```

#### Eventos del calendario (en la coleccion de datos)

| Evento | Parámetros | Cuando se dispara |
|--------|------------|-------------------|
| `ondateselected` | `DATEVALUE`, `TIMEVALUE`, `EVENTVALUE` | El usuario toca un día |
| `onpageselected` | `DATEVALUE`, `CURRENT`, `DATEFROM`, `TOTALDAYS` | El usuario cambia de mes o semana |
| `oncelldraw` | `CELLDATE` | Se pinta cada celda (usar con precaucion, puede ser lento) |

```xml
<ondateselected refresh="true" show-wait-dialog="false"
                refresh-owner="MAP_FECHA,MAP_MES,MAP_ANO">
    <action name="runscript">
        <param name="DATEVALUE" />
        <param name="TIMEVALUE" />
        <param name="EVENTVALUE" />
        <script language="javascript">
            var meses = ["Enero","Febrero","Marzo","Abril","Mayo","Junio",
                         "Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"];
            selfDataColl.getOwnerObject().MAP_FECHA = DATEVALUE;
            selfDataColl.getOwnerObject().MAP_MES = meses[DATEVALUE.getMonth()].toUpperCase();
            selfDataColl.getOwnerObject().MAP_ANO = DATEVALUE.getFullYear().toString();
        </script>
    </action>
</ondateselected>

<onpageselected refresh="true" show-wait-dialog="false"
                refresh-owner="MAP_FECHA,MAP_MES,MAP_ANO">
    <action name="runscript">
        <param name="DATEVALUE" />
        <param name="CURRENT" />
        <param name="DATEFROM" />
        <param name="TOTALDAYS" />
        <script language="javascript">
            var meses = ["Enero","Febrero","Marzo","Abril","Mayo","Junio",
                         "Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"];
            selfDataColl.getOwnerObject().MAP_FECHA = DATEVALUE;
            selfDataColl.getOwnerObject().MAP_MES = meses[DATEVALUE.getMonth()].toUpperCase();
            selfDataColl.getOwnerObject().MAP_ANO = DATEVALUE.getFullYear().toString();
        </script>
    </action>
</onpageselected>
```

#### Control por JavaScript

```javascript
// Navegar al mes anterior
self.getContents("MiCalendario").setVariable("moveto", "prev");

// Navegar al mes siguiente
self.getContents("MiCalendario").setVariable("moveto", "next");
```

---



```xml
<coll name="ListaProductos"
      sql="SELECT * FROM ##PREF##Productos"
      objname="Productos" loadall="true">

    <!-- Filtro de busqueda nativo -->
    <asfilter fontsize="8" left="12" sort="false">
        <field name="NOMBRE" fldname="NOMBRE"
               oper="##FLD## LIKE '##VAL##%'" width="15"
               tooltip="Buscar por nombre">NOMBRE</field>
        <field name="CODIGO" fldname="CODIGO"
               oper="##FLD## LIKE '##VAL##%'" width="10"
               tooltip="Buscar por código" newline="false">CODIGO</field>
    </asfilter>

    <group name="Lista" id="1">
        <!-- contenido de la lista -->
    </group>
</coll>
```

**Atributos del nodo `<asfilter>`:**

| Atributo | Descripción |
|----------|-------------|
| `fontsize` | Tamaño de fuente de los campos del filtro |
| `left` | Margen izquierdo del filtro |
| `sort` | Habilita ordenamiento (`true`/`false`) |

**Atributos de `<field>` dentro de `<asfilter>`:**

| Atributo | Descripción |
|----------|-------------|
| `name` | Nombre del campo de filtro |
| `fldname` | Nombre del campo real en la tabla |
| `oper` | Operador SQL. Usa `##FLD##` para el campo y `##VAL##` para el valor ingresado |
| `width` | Ancho del campo de filtro |
| `tooltip` | Texto de ayuda |
| `newline` | Si es `false`, se coloca en la misma linea que el anterior |

> **Regla de generación:** Usar `<asfilter>` cuando la lista tenga muchos registros y el usuario necesite busqueda rápida. Para busquedas más personalizadas (con botón y lógica JS), usar el patron de filtrado con `ontextchanged` y `coll.setFilter()` mostrado en la sección 7.7.

---

### 7.13c ViewMode: Gráficos (barchart, piechart, linechart...)

**Cuando usarlo:** dashboards con KPIs, estadisticas de ventas, distribución de datos por categorías, evoluciones temporales.

Los gráficos en XOne se implementan como un `prop type="Z"` con `viewmode` especificando el tipo de gráfico. Requieren que la coleccion de datos tenga un campo marcado con `classid="XOneCharts"` en el prop, o que el propio prop lo declare.

#### Tipos de gráfico disponibles

| viewmode | Tipo | Cuando usarlo |
|----------|------|---------------|
| `barchart` | Barras verticales | Comparacion de valores entre categorías |
| `3dbarchart` | Barras 3D | Igual que barchart con efecto visual 3D |
| `linechart` | Lineas | Evolución de valores en el tiempo |
| `xylinechart` | Lineas XY | Relación entre dos variables numéricas |
| `areachart` | Área rellena | Tendencias acumuladas, volúmenes |
| `piechart` | Tarta | Distribución porcentual de categorías |
| `piechart2` | Tarta alternativa | Variante visual del piechart |
| `timeserieschart` | Series temporales | Datos con eje temporal preciso (sensores, IoT) |
| `slidingbarchart` | Barras con scroll | Muchas categorías con navegación horizontal |

#### Estructura general — prop y contents

```xml
<!-- Prop que muestra el gráfico -->
<prop name="@GraficoVentas"
      type="Z"
      viewmode="barchart"
      classid="XOneCharts"
      contents="GraficoVentas"
      width="100%"
      height="300p"
      locked="true" />

<contents name="GraficoVentas" src="ContentGraficoVentas" />
```

#### Coleccion de datos del gráfico

La coleccion que alimenta el gráfico debe tener campos con atributos especiales que indican al framework que rol tiene cada campo:

```xml
<coll name="ContentGraficoVentas" title="gráfico ventas"
      sql="SELECT t1.MES, t1.TOTAL_VENTAS, t1.TOTAL_COSTES
           FROM ##PREF##ventas_mensuales t1"
      objname="ventas_mensuales" updateobj="ventas_mensuales"
      progid="ASData.CASBasicDataObj" loadall="true">
    <group name="General" id="1">
        <!-- chart-label=true: este campo es la etiqueta del eje X (categorias) -->
        <prop name="MES" type="T" visible="4" chart-label="true" />
        <!-- chart-value=true: este campo es el valor a graficar (eje Y) -->
        <prop name="TOTAL_VENTAS" type="N2" visible="4"
              chart-value="true" chart-series="Ventas" />
        <!-- Multiples series: un prop chart-value por cada serie -->
        <prop name="TOTAL_COSTES" type="N2" visible="4"
              chart-value="true" chart-series="Costes" />
    </group>
</coll>
```

#### Atributos clave de los props en la coleccion del gráfico

| Atributo | Descripción |
|----------|-------------|
| `chart-label="true"` | Este campo es la etiqueta del eje X (nombre de la categoría) |
| `chart-value="true"` | Este campo es el valor numérico a representar en el gráfico |
| `chart-series="NombreSerie"` | Nombre de la serie en el gráfico (aparece en la leyenda) |
| `chart-color="#RRGGBB"` | Color de la barra/linea/sector de esta serie |

#### Ejemplos por tipo de gráfico

**Barchart — comparacion de ventas por mes:**

```xml
<prop name="@GraficoBarras" type="Z" viewmode="barchart"
      classid="XOneCharts" contents="GraficoBarras"
      width="100%" height="350p" locked="true" />
<contents name="GraficoBarras" src="ContentVentasMes" />
```

**Piechart — distribución porcentual:**

```xml
<prop name="@GraficoPie" type="Z" viewmode="piechart"
      classid="XOneCharts" contents="GraficoPie"
      width="100%" height="300p" locked="true" />
<contents name="GraficoPie" src="ContentDistribucion" />
```

```xml
<!-- Coleccion para piechart: una fila por sector -->
<coll name="ContentDistribucion" title="distribucion"
      sql="SELECT CATEGORIA, TOTAL FROM ##PREF##distribucion"
      objname="distribucion" updateobj="distribucion"
      progid="ASData.CASBasicDataObj" loadall="true">
    <group name="General" id="1">
        <prop name="CATEGORIA" type="T" visible="4" chart-label="true" />
        <prop name="TOTAL" type="N2" visible="4" chart-value="true" />
    </group>
</coll>
```

**Linechart — evolución temporal:**

```xml
<prop name="@GraficoLinea" type="Z" viewmode="linechart"
      classid="XOneCharts" contents="GraficoLinea"
      width="100%" height="300p" locked="true" />
<contents name="GraficoLinea" src="ContentEvolucion" />
```

#### Regla de decisión para elegir tipo de gráfico

```
El usuario pide...                     -> Usar
"comparar ventas por categoría"        -> barchart o 3dbarchart
"ver evolucion en el tiempo"           -> linechart o timeserieschart
"distribucion porcentual"              -> piechart o piechart2
"comparar dos variables numericas"     -> xylinechart
"volumen acumulado"                    -> areachart
"muchas categorias con scroll"         -> slidingbarchart
```

---

### 7.13d ViewMode: picturemap

**Cuando usarlo:** planos de instalaciones, mapas de planta de un edificio, esquemas de infraestructura, cualquier imagen sobre la que se quieran colocar marcadores en coordenadas fijas.

A diferencia de `mapview` (que usa Google Maps o OpenStreetMap con coordenadas GPS), `picturemap` superpone marcadores sobre una **imagen estática** propia. Las coordenadas son en pixeles relativos a esa imagen, no coordenadas geograficas.

#### Declaración del prop tipo picturemap

```xml
<frame name="frmPictureMap" width="700p" height="700p"
       lmargin="10p" tmargin="20p" framebox="true">
    <prop name="@PictureMapData"
          type="Z"
          viewmode="picturemap"
          contents="PictureMapData"
          imgbk="mapa-planta.png"
          ignore-touch-in-transparent-area="true"
          width="100%"
          height="100%" />
    <contents name="PictureMapData" src="ContentPictureMapData" />
</frame>
```

#### Coleccion de datos del picturemap

Cada registro de la coleccion representa un marcador en el mapa. Los campos con atributos especiales indican al framework el rol de cada campo:

```xml
<coll name="ContentPictureMapData" title="PictureMapData"
      sql="SELECT t1.* FROM ##PREF##puntos_mapa t1"
      objname="puntos_mapa" updateobj="puntos_mapa"
      progid="ASData.CASBasicDataObj" loadall="true">
    <group name="General" id="1">
        <prop name="CODIGO" type="T" visible="0" />
        <!-- Texto mostrado en el popup al pulsar el marcador -->
        <prop name="TITULO" type="T" visible="4" />
        <prop name="DESCRIPCION" type="T" visible="4" />
        <prop name="ESTADO" type="T" visible="4" />
        <!-- xcoord=true: coordenada X del marcador en pixeles sobre la imagen -->
        <prop name="XCOORD" type="N" visible="4" xcoord="true" />
        <!-- ycoord=true: coordenada Y del marcador en pixeles sobre la imagen -->
        <prop name="YCOORD" type="N" visible="4" ycoord="true" />
        <!-- icon-big=true: icono grande que se muestra en el popup al seleccionar -->
        <prop name="ICONBIG" type="T" visible="4" icon-big="true"
              width="126" height="168" size="250" />
        <!-- circle-radius=true: radio del circulo de zona alrededor del marcador -->
        <prop name="RADIO" type="N" visible="4" circle-radius="true" />
        <!-- icon-mark=true: icono del marcador en estado normal (sin pulsar) -->
        <prop name="ICONOFF" type="T" visible="4" icon-mark="true"
              width="126" height="168" size="250" />
        <!-- icon-touch=true: icono del marcador al estar seleccionado/pulsado -->
        <prop name="ICONON" type="T" visible="4" icon-touch="true"
              width="126" height="168" size="250" />
    </group>

    <!-- Al seleccionar un marcador: pasar datos al objeto padre -->
    <selecteditem show-wait-dialog="false" refresh="false">
        <action name="runscript">
            <script language="javascript">
                var parent = self.getOwnerCollection().getOwnerObject();
                parent.MAP_ID = self.ID;
                parent.MAP_NOMBRE = self.TITULO;
                parent.MAP_DESCRIPCION = self.DESCRIPCION;
                ui.getView(parent).refresh("MAP_NOMBRE,MAP_DESCRIPCION");
            </script>
        </action>
    </selecteditem>
</coll>
```

#### Atributos del prop picturemap

| Atributo | Descripción |
|----------|-------------|
| `imgbk="archivo.png"` | Imagen de fondo sobre la que se colocan los marcadores |
| `ignore-touch-in-transparent-area="true"` | Ignora toques en zonas transparentes de la imagen |
| `viewmode="picturemap"` | Activa el modo mapa de imagen |

#### Atributos especiales en los props de la coleccion de datos

| Atributo en prop | Tipo de campo | Descripción |
|------------------|---------------|-------------|
| `xcoord="true"` | `N` | Coordenada X del marcador en pixeles sobre la imagen |
| `ycoord="true"` | `N` | Coordenada Y del marcador en pixeles sobre la imagen |
| `icon-mark="true"` | `T` | Nombre del fichero PNG del icono en estado normal |
| `icon-touch="true"` | `T` | Nombre del fichero PNG del icono al estar seleccionado |
| `icon-big="true"` | `T` | Nombre del fichero PNG del icono grande en el popup |
| `circle-radius="true"` | `N` | Radio en pixeles del circulo de zona alrededor del marcador |

> **NOTA:** Los valores de `XCOORD` e `YCOORD` son coordenadas en pixeles relativas a la imagen definida en `imgbk`. No son coordenadas GPS.

---

### 7.13e ViewMode: slideview

**Cuando usarlo:** carruseles de imágenes, banners promocionales, onboarding de la app, presentaciones de productos, galería de fotos navegable una a una.

El slideview muestra los registros de uno en uno y permite desplazarse entre ellos con un gesto horizontal (o vertical). Si el ancho del prop es menor que el ancho de pantalla, pueden verse varios registros a la vez.

#### Declaración del prop tipo slideview

```xml
<prop name="@MiSlider"
      type="Z"
      viewmode="slideview"
      contents="MiSlider"
      width="100%"
      height="400p"
      slide-circular="true"
      autoslide-delay="5"
      forceonchange="true"
      onchange="refresh(@MiSlider)" />
<contents name="MiSlider" src="ContentSlider" />
```

#### Coleccion de datos del slideview

Cada registro es una "diapositiva". Los campos con `visible="4"` se muestran en el slide. Los campos con `visible="1"` se muestran al editar el registro.

```xml
<coll name="ContentSlider" title="slider"
      sql="SELECT t1.* FROM ##PREF##banners t1"
      objname="banners" updateobj="banners"
      progid="ASData.CASBasicDataObj"
      loadall="true"
      notab="true">
    <group name="General" id="1">
        <!-- Contenido de cada slide -->
        <prop name="IMAGEN" type="IMG" visible="4"
              width="100%" height="400p" labelwidth="0" locked="true" />
        <prop name="TITULO" type="T" visible="4"
              labelwidth="0" locked="true"
              text-align="center" fontsize="16" />
        <prop name="DESCRIPCION" type="T" visible="4"
              labelwidth="0" locked="true" lines="2"
              text-align="center" fontsize="12" />
    </group>

    <!-- auto-selecteditem: se ejecuta en cada cambio automático de slide -->
    <auto-selecteditem refresh="false" show-wait-dialog="false">
        <action name="runscript">
            <script language="javascript">
                // self = objeto del slide que se esta mostrando
                // lógica al pasar al siguiente slide automaticamente
            </script>
        </action>
    </auto-selecteditem>

    <!-- selecteditem: se ejecuta cuando el usuario toca un slide -->
    <selecteditem refresh="false" show-wait-dialog="false">
        <action name="runscript">
            <script language="javascript">
                // Acción al pulsar un slide
                ui.showToast("Slide seleccionado: " + self.TITULO);
            </script>
        </action>
    </selecteditem>
</coll>
```

#### Atributos del prop slideview

| Atributo | Descripción |
|----------|-------------|
| `slide-circular="true"` | Al llegar al último slide vuelve al primero automáticamente |
| `autoslide-delay="N"` | Segundos entre cambios automáticos de slide. Sin este atributo no hay autoplay |
| `forceonchange="true"` | Fuerza el refresco al cambiar de slide |
| `orientation` | `horizontal` (por defecto) o `vertical` para desplazamiento vertical |

#### Eventos del slideview (en la coleccion de datos)

| Evento | Cuando se dispara |
|--------|-------------------|
| `selecteditem` | El usuario pulsa sobre un slide |
| `auto-selecteditem` | Cambia automáticamente al siguiente slide (solo con `autoslide-delay`) |

> **Diferencia clave entre eventos:** `selecteditem` requiere interaccion del usuario. `auto-selecteditem` se dispara con el autoplay sin interaccion.

#### Patron típico — Galería de imágenes con indicador de posición

```xml
<!-- En la coleccion padre -->
<prop name="MAP_SLIDE_ACTUAL" type="N" visible="0" />

<prop name="@Galeria" type="Z" viewmode="slideview"
      contents="Galeria" width="100%" height="300p"
      slide-circular="false" forceonchange="true"
      onchange="refresh(@Galeria)" />
<contents name="Galeria" src="ContentGaleria"
          filter="IDPRODUCTO=##FLD_ID##" />
```

```xml
<!-- En ContentGaleria: al seleccionar actualiza el indicador en el padre -->
<selecteditem refresh="false" show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            var idx = self.getOwnerCollection().getObjectIndex(self);
            var total = self.getOwnerCollection().count();
            self.getOwnerCollection().getOwnerObject().MAP_SLIDE_ACTUAL = (idx + 1);
        </script>
    </action>
</selecteditem>
```

---

### 7.13f ViewMode: expanview

**Cuando usarlo:** árboles de categorías, estructuras padre-hijo, FAQs expandibles, organigramas, menus jerarquicos, cualquier dato con niveles anidados.

El expanview muestra una lista donde cada elemento puede expandirse para mostrar sus hijos. Requiere dos colecciones: la **coleccion padre** (nivel raiz) y la **coleccion hija** (elementos anidados). La coleccion hija se define como un `contents` embebido dentro de la coleccion padre.

#### Estructura general

```
prop type="Z" viewmode="expanview"
    └── ContentPadre (coleccion raiz, filter="IDPADRE IS NULL")
            └── prop type="Z" contents="ContentHijo"  (embebido en ContentPadre)
                    └── ContentHijo (filter="IDPADRE=##FLD_ID##")
```

#### Paso 1 — Declarar el prop en la pantalla

```xml
<frame name="frmArbol" width="98%" height="90%"
       framebox="true" border-corner-radius="10" lmargin="1%">
    <prop name="@ContentPadre"
          type="Z"
          viewmode="expanview"
          contents="ContentPadre"
          height="90%"
          visible="1" />
    <contents name="ContentPadre" src="ContentPadre"
              autofocus="true"
              filter="IDPADRE IS NULL" />
</frame>
```

> `filter="IDPADRE IS NULL"` carga solo los nodos raiz. Los hijos se cargan dinámicamente al expandir cada nodo.

#### Paso 2 — Coleccion padre con contents hijo embebido

```xml
<coll name="ContentPadre" title="arbol padre"
      sql="SELECT t1.*,
           t1.ICONO AS MAP_ICON,
           (SELECT COUNT(ID) FROM ##PREF##categorias
            WHERE IDPADRE = t1.ID) AS MAP_NUM_HIJOS
           FROM ##PREF##categorias t1"
      objname="categorias" updateobj="categorias"
      progid="ASData.CASBasicDataObj"
      edit-inrow="false" loadall="true" notab="true">

    <group name="General" id="1">
        <frame name="frmNodoPadre" width="100%" bgcolor="#FFFFFF">
            <prop name="MAP_ICON" type="IMG" visible="4"
                  lmargin="20p" tmargin="20p" bmargin="20p"
                  width="80p" height="80p" />
            <prop name="NOMBRE" type="T" visible="4"
                  textfont-bold="true" class="classgrid"
                  align="left|center" width="490p" height="80p"
                  newline="false" tmargin="20p" bmargin="20p" />
            <prop name="MAP_NUM_HIJOS" type="T" visible="4"
                  text-forecolor="#666666" textfont-size="5"
                  class="classgrid" align="left|center"
                  width="110p" height="80p" newline="false"
                  tmargin="20p" bmargin="20p" />
        </frame>

        <!-- Contents hijo embebido dentro del padre -->
        <prop name="@ContentHijo" type="Z" visible="1"
              contents="ContentHijo" />
        <contents name="ContentHijo" src="ContentHijo"
                  filter="IDPADRE=##FLD_ID##" />
    </group>

    <!-- onexpand: se ejecuta al expandir un nodo padre -->
    <onexpand refresh="false">
        <action name="runscript">
            <script language="javascript">
                // Refrescar la fila del padre al expandir
                ui.refreshContentRow("ContentPadre",
                    self.getOwnerCollection().getObjectIndex(self));
            </script>
        </action>
    </onexpand>

    <!-- oncollapse: se ejecuta al colapsar un nodo padre -->
    <oncollapse refresh="false">
        <action name="runscript">
            <script language="javascript">
                ui.refreshContentRow("ContentPadre",
                    self.getOwnerCollection().getObjectIndex(self));
            </script>
        </action>
    </oncollapse>
</coll>
```

> **Los eventos `onexpand` y `oncollapse` son obligatorios** para que el árbol funcione correctamente y se actualice visualmente al abrir y cerrar nodos.

#### Paso 3 — Coleccion hija

La coleccion hija se define de forma independiente. El campo FK (`IDPADRE`) enlaza con el padre. El filter del `<contents>` usa `##FLD_ID##` para obtener el ID del nodo padre expandido.

```xml
<coll name="ContentHijo" title="arbol hijo"
      sql="SELECT t1.* FROM ##PREF##categorias t1"
      objname="categorias" updateobj="categorias"
      progid="ASData.CASBasicDataObj"
      loadall="true" notab="true">

    <group name="General" id="1">
        <frame name="frmNodoHijo" width="640p" lmargin="80p"
               bgcolor="#FFFFFF">
            <prop name="NOMBRE" type="T" visible="4"
                  textfont-bold="true" text-forecolor="#666666"
                  class="classgrid" lmargin="20p" tmargin="20p" />
            <prop name="DESCRIPCION" type="T" visible="4"
                  class="classgrid" lmargin="30p" bmargin="20p"
                  text-forecolor="#666666" textfont-size="5"
                  lines="2" fixed-lines="true" />
            <!-- FK al padre -->
            <prop name="IDPADRE" type="N" visible="0"
                  mapcol="ContentPadre" mapfld="ID" />
        </frame>
    </group>

    <!-- selecteditem: acción al pulsar un nodo hijo -->
    <selecteditem refresh="false" show-wait-dialog="false">
        <action name="runscript">
            <script language="javascript">
                // Navegar al detalle del elemento seleccionado
                ui.openEditView(self);
            </script>
        </action>
    </selecteditem>
</coll>
```

#### Atributos del prop expanview

| Atributo | Descripción |
|----------|-------------|
| `viewmode="expanview"` | Activa el modo árbol expandible |
| `autofocus="true"` | En el `<contents>` del nivel raiz — el primer nodo recibe el foco al cargar |
| `filter="IDPADRE IS NULL"` | En el `<contents>` del nivel raiz — carga solo los nodos sin padre |
| `filter="IDPADRE=##FLD_ID##"` | En el `<contents>` hijo — filtra los hijos del nodo padre expandido |

#### Eventos del expanview (en la coleccion padre)

| Evento | Cuando se dispara |
|--------|-------------------|
| `onexpand` | El usuario expande un nodo padre para ver sus hijos |
| `oncollapse` | El usuario colapsa un nodo padre ocultando sus hijos |

#### Regla: árboles de más de dos niveles

Para árboles de tres o más niveles, la coleccion hija puede a su vez contener otro `<contents>` con su propia coleccion nieta, siguiendo el mismo patron. Cada nivel usa `##FLD_ID##` para filtrar sus hijos respecto al nivel superior.

---

### 7.13g ViewMode: gridview

**Cuando usarlo:** galerías de fotos, catálogos de productos con imagen, colecciones de recursos visuales donde se quiere mostrar varios elementos por fila en cuadricula.

El `gridview` muestra los registros en una cuadricula de N columnas, similar a la galería de fotos del dispositivo. Se controla el número de columnas con `gallery-columns`.

#### Declaración del prop tipo gridview

```xml
<prop name="@ContentFotos"
      type="Z"
      viewmode="gridview"
      gallery-columns="4"
      contents="ContentFotos"
      width="90%"
      height="-2"
      lmargin="5%"
      locked="true"
      show-no-data="true"
      no-data-text="No hay fotos. Pulse + para añadir."
      no-data-fontsize="8"
      onchange="refresh" />
<contents name="ContentFotos" src="ContentFotosSrc"
          filter="IDSOLICITUD=##FLD_ID##" />
```

#### Coleccion de datos del gridview

Cada registro ocupa una celda de la cuadricula. Los campos con `visible="4"` se muestran en cada celda.

```xml
<coll name="ContentFotosSrc" title="fotos"
      sql="SELECT t1.* FROM ##PREF##fotos t1"
      objname="fotos" updateobj="fotos"
      progid="ASData.CASBasicDataObj"
      loadall="true" notab="true">
    <group name="General" id="1">
        <!-- Imagen que se muestra en la celda de la cuadricula -->
        <prop name="FOTO" type="IMG" visible="4"
              width="100%" height="100%"
              labelwidth="0" locked="true"
              keep-aspect-ratio="true" />
        <!-- Etiqueta opcional bajo la imagen -->
        <prop name="NOMBRE" type="T" visible="4"
              labelwidth="0" locked="true"
              text-align="center" textfont-size="5" />
    </group>
</coll>
```

#### Atributos del prop gridview

| Atributo | Descripción |
|----------|-------------|
| `gallery-columns` | Número de columnas de la cuadricula. Ej: `"3"`, `"4"` |
| `orientation` | `horizontal` (por defecto) o `vertical` |
| `show-no-data` | `true` muestra un mensaje cuando no hay datos |
| `no-data-text` | Texto a mostrar cuando el contents esta vacio |
| `no-data-fontsize` | Tamaño de fuente del texto de sin datos |

#### Patron típico — galería con FAB para añadir

```xml
<!-- Galeria -->
<prop name="@GaleriaFotos" type="Z" viewmode="gridview"
      gallery-columns="3" contents="GaleriaFotos"
      width="100%" height="-2" locked="true"
      show-no-data="true"
      no-data-text="Pulse + para añadir fotos" />
<contents name="GaleriaFotos" src="ContentFotosSrc"
          filter="IDREGISTRO=##FLD_ID##" />

<!-- Botón flotante para añadir fotos (FAB) -->
<frame name="frmFAB" floating="true" top="900p" left="610p"
       width="90p" height="90p">
    <prop name="BTN_ADD" type="B" visible="1" labelwidth="0"
          method="ExecuteNode(nuevaFoto)"
          width="75p" img="add.png" imgsel="add_click.png" />
</frame>
```

---

### 7.13h Patron: contentselitem (selecteditem sin navegación)

**Cuando usarlo:** listas donde al tocar un elemento se muestran sus datos en la misma pantalla sin abrir una ventana nueva. Útil para paneles maestro-detalle, selectores de elemento activo, listas con preview.

Este no es un `viewmode` distinto — es un **patron de uso** del contents normal (grid por defecto) combinado con `<selecteditem>` en la coleccion hija y `cell-selected-bgcolor` para resaltar la fila seleccionada.

#### Estructura del patron

```xml
<!-- En la coleccion padre: campos para mostrar el elemento seleccionado -->
<prop name="MAP_NOMBRESEL" type="T" visible="1"
      labelwidth="0" class="classTsinborde" />
<prop name="MAP_LINEASEPARAR" type="B" visible="1"
      disablevisible="MAP_NOMBRESEL=''"
      bgcolor="#333333" labelwidth="0"
      width="300p" height="5p" locked="true" />

<!-- Botones de acción flotantes — solo visibles cuando hay selección -->
<frame name="frmAcciones" floating="true"
       top="75p" left="550p" width="200p" height="120p"
       disablevisible="MAP_NOMBRESEL=''">
    <prop name="BTN_EDITAR" type="B" visible="1" labelwidth="0"
          method="ExecuteNode(editar)" width="75p"
          img="ok.png" imgsel="ok_click.png" />
    <prop name="BTN_BORRAR" type="B" visible="1" labelwidth="0"
          method="ExecuteNode(eliminar)" width="75p"
          img="delete.png" imgsel="delete_click.png"
          newline="false" lmargin="6p" />
</frame>

<!-- Contents con edicion desactivada — el selecteditem gestiona la selección -->
<prop name="@content" type="Z" contents="content"
      disableedit="1=1"
      height="70%" width="100%"
      bgcolor="#FFFFFF" />
<contents name="content" src="ContentDatosSelItem" />
<prop name="MAP_IDSELECCIONADO" visible="0" type="N" />
```

#### Coleccion hija con selecteditem y resaltado

```xml
<coll name="ContentDatosSelItem" title="lista"
      sql="SELECT t1.* FROM ##PREF##mapa_datos t1"
      objname="mapa_datos" updateobj="mapa_datos"
      progid="ASData.CASBasicDataObj"
      loadall="true" notab="true"
      cell-even-color="#FFFFFF"
      cell-odd-color="#F2F2F2"
      cell-selected-bgcolor="#C9E5EF">

    <group name="General" id="1">
        <prop name="IMAGEN" type="IMG" width="115p" height="118p"
              visible="4" tmargin="2p" lmargin="0" />
        <frame name="frm1" newline="false" width="600p"
               lmargin="5p" height="120p">
            <prop name="NOMBRE" type="T" class="classgrid"
                  visible="4" locked="true" />
            <prop name="DIRECCION" type="T" class="classgrid"
                  text-forecolor="#666666" textfont-size="5"
                  visible="4" locked="true"
                  lines="2" fixed-lines="true" />
        </frame>
    </group>

    <!-- selecteditem: en lugar de abrir el objeto, actualiza campos del padre -->
    <selecteditem
        refresh-owner="MAP_NOMBRESEL,MAP_LINEASEPARAR,frmAcciones"
        show-wait-dialog="false">
        <action name="runscript">
            <script language="javascript">
                // getOwnerCollection().getOwnerObject() = objeto padre
                var padre = self.getOwnerCollection().getOwnerObject();
                padre.MAP_NOMBRESEL = self.NOMBRE;
                padre.MAP_IDSELECCIONADO = self.ID;
                // Guardar el indice de la fila seleccionada
                padre.MAP_IDLINEA = self.getOwnerCollection()
                                        .getObjectIndex(self);
            </script>
        </action>
    </selecteditem>
</coll>
```

#### Atributos clave del patron contentselitem

| Atributo | Donde | Descripción |
|----------|-------|-------------|
| `cell-selected-bgcolor="#C9E5EF"` | En `<coll>` | Color de fondo de la fila seleccionada actualmente |
| `disableedit="1=1"` | En el `prop type="Z"` | Desactiva la apertura del objeto al tocar — el `selecteditem` lo gestiona todo |
| `refresh-owner="campo1,campo2"` | En `<selecteditem>` | Lista de campos del padre que se refrescan automáticamente tras la selección |
| `getOwnerCollection().getOwnerObject()` | En el script | Accede al objeto padre desde dentro del `selecteditem` |
| `getOwnerCollection().getObjectIndex(self)` | En el script | Obtiene el índice de la fila seleccionada |

#### Diferencia con edición directa

| Comportamiento | Edición directa (por defecto) | Patron contentselitem |
|----------------|-------------------------------|----------------------|
| Al tocar una fila | Abre el objeto en edición | Actualiza campos del padre |
| `disableedit` | No necesario | `disableedit="1=1"` en el prop Z |
| `selecteditem` | Opcional | **Obligatorio** con la lógica de actualización |
| Navegación | Abre nueva pantalla | Todo en la misma pantalla |

---

### 7.14 Filtros de Busqueda con `<asfilter>`

Para pantallas de lista que requieran busqueda nativa, se puede usar el nodo `<asfilter>` dentro de la coleccion. Este nodo genera automáticamente una barra de filtros en la parte superior de la lista.

```xml
<coll name="Productos"
      sql="SELECT * FROM ##PREF##Productos"
      objname="Productos" loadall="true">

    <asfilter fontsize="8" left="12" sort="false">
        <field name="NOMBRE" fldname="NOMBRE"
               oper="##FLD## LIKE '##VAL##%'" width="15"
               tooltip="Buscar por nombre">NOMBRE</field>
        <field name="CODIGO" fldname="CODIGO"
               oper="##FLD## LIKE '##VAL##%'" width="10"
               tooltip="Buscar por código" newline="false">CODIGO</field>
    </asfilter>

    <group name="Lista" id="1">
        <!-- contenido de la lista -->
    </group>
</coll>
```

| Atributo `<asfilter>` | Descripción |
|-----------------------|-------------|
| `fontsize` | Tamaño de fuente de los campos del filtro |
| `left` | Margen izquierdo del filtro |
| `sort` | Habilita ordenamiento (`true`/`false`) |

| Atributo `<field>` | Descripción |
|--------------------|-------------|
| `name` | Nombre del campo de filtro |
| `fldname` | Nombre del campo real en la tabla |
| `oper` | Operador SQL. `##FLD##` = campo, `##VAL##` = valor introducido |
| `width` | Ancho del campo de filtro |
| `tooltip` | Texto de ayuda |
| `newline` | `false` = mismo renglon que el anterior |

### 7.15 Objetos Complementarios como Opciones de Integración

Al analizar los requisitos del proyecto (Fase 1), el agente debe identificar si se necesitan integraciones con hardware o servicios externos. XOne proporciona objetos complementarios que se deben incorporar al proyecto según la funcionalidad requerida.

#### Tabla de Integraciones Disponibles

| Objeto | Tipo de App | Impacto en Generación |
|--------|-------------|----------------------|
| **FileManager** | Apps con descarga/subida de archivos, exportacion de datos, gestion documental | Incluir funciones en `functions.js` para `download()`, `uploadFile()`, `readFile()`, `saveFile()`. Creación: `new FileManager()` |
| **XOnePDF** | Apps con reportes, tickets, albaranes, facturas en PDF | Incluir funciones de generación PDF en `functions.js`. Creación: `new XOnePDF()`. Patron: `create()` > `open()` > contenido > `close()` > `launchPDF()` |
| **XOnePrinter** | Apps de campo con impresion de etiquetas/tickets via Bluetooth (Zebra) | Incluir funciones de impresion en `functions.js`. Agregar permisos Bluetooth en `app.xml`. Creación: `new XOnePrinter()` |
| **BarcodeGenerator** | Apps con generación de códigos QR/barras para etiquetas, identificación | Incluir funciones de generación en `functions.js`. Tipos: `qrcode`, `code128`, `ean13`, `pdf417`, etc. Creación: `new BarcodeGenerator()` |
| **Escaner QR/barras** | Apps con lectura de códigos QR/barras desde camara | Agregar permiso `camera` en `app.xml`. Declarar `<prop type="VD" code-type="qr" oncodescanned="...">` en el XML; en JS usar `control.setOnCodeScanned(callback)` sobre el control obtenido con `getControl("MAP_CAMERA")`. El callback recibe `evento.data` y `evento.type` |
| **XOneNFC** | Apps con lectura de tarjetas NFC, DNI electrónico, tags MIFARE | Agregar permisos NFC en `app.xml`. Creación: `new XOneNFC()`. Métodos: `readNdefMessageAsync()`, `enableDnieReader()` |
| **XOneOCR** | Apps con reconocimiento de texto en imágenes, lectura de matriculas | Creación: `new XOneOCR()`. Métodos: `scanLicensePlate()` (matrículas), `startScan({regex, onResult})` (validación por patrones). `scanText()` aún NO está implementado (lanza UnsupportedOperationException). Agregar permisos de camara |
| **BluetoothSerialPort** | Apps de campo con dispositivos Bluetooth (balanzas, sensores, terminales) | Singleton `bluetoothSerial`. Agregar permisos Bluetooth en `app.xml`. Métodos: `connect()`, `write()`, `read()` |
| **WifiManager** | Apps con configuración de redes WiFi, conexión a dispositivos | Creación: `new WifiManager()`. Agregar permisos WiFi en `app.xml`. Métodos: `scanAvailableNetworks()`, `connect()` |
| **GpsTools** | Apps con tracking GPS, calculo de distancias, geocodificacion | Creación: `new GpsTools()`. Métodos: `distanceTo()`, `getAddressFromPosition()`, `containsLocation()`, `getLastKnownLocation()` |
| **OAuth2** | Apps con autenticación externa (Google, Microsoft, SSO corporativo) | Creación: `new OAuth2()`. Configurar `authority`, `clientID`, `clientSecret`, `scope`, `redirectUri` en `functions.js` |
| **WebSocket** | Apps con comunicación en tiempo real (chat, notificaciones push, IoT) | Creación: `new WebSocket(request)`. Configurar callbacks: `onOpen`, `onMessage`, `onError`, `onClose`. Métodos: `send()`, `close()` |
| **fingerprintManager** | Apps con autenticación biometrica (huella dactilar, Face ID) | Singleton `fingerprintManager`. Configurar callbacks `onSuccess`/`onFailure`. Métodos: `listen()`, `stopListening()` |
| **Animation** | Apps con transiciones y animaciones personalizadas en controles | Creación: `new Animation()`. Configurar `setTarget()`, `setDuration()`, efectos (`setAlpha()`, `setRotation()`, `setX()`) |
| **ImageDrawing** | Apps con edición de imágenes, marca de agua, timestamps en fotos | Creación: `new ImageDrawing()`. Métodos: `create()`, `setBackground()`, `addTextSetXY()`, `save()` |

#### Regla de Decisión para Integraciones

```
Al analizar los requisitos del usuario:
1. Identificar funcionalidades que requieran hardware (GPS, camara, Bluetooth, NFC)
2. Identificar funcionalidades que requieran servicios (PDF, impresion, OAuth)
3. Para cada integracion identificada:
   a. Agregar las funciones necesarias en functions.js
   b. Agregar permisos requeridos en app.xml si aplica
   c. Incluir pantallas/botones que invoquen la funcionalidad
   d. Documentar la integracion en el README.md del proyecto
```

#### Ejemplo: Impacto de Integraciones en functions.js

```javascript
// === Si el proyecto necesita escaneo de codigos QR ===
// Requiere haber declarado en el XML:
//   <prop name="MAP_CAMERA" type="VD" code-type="qr" viewmode="camerapreview"
//         width="100%" height="300p"/>
function iniciarEscaneoQR() {
    let control = getControl("MAP_CAMERA");
    if (!control) {
        ui.showToast("Camara no disponible");
        return;
    }
    control.setOnCodeScanned(function(evento) {
        self.CODIGO_BARRAS = evento.data;
        ui.refresh("CODIGO_BARRAS");
        ui.showToast("Código leido: " + evento.data);
        return true; // true = parar escaneo; false = seguir leyendo
    });
}

// === Si el proyecto necesita generacion de PDF ===
function generarReportePDF(sNombreArchivo) {
    var pdf = new XOnePDF();
    pdf.create(sNombreArchivo);
    pdf.open();
    pdf.setFont("helvetica");
    pdf.setFontSize(14);
    pdf.setFontStyle("bold");
    pdf.addTextLine("Reporte generado: " + formatearFechaHora(new Date()));
    pdf.newLine();
    // ... contenido del reporte ...
    pdf.close();
    pdf.launchPDF();
}

// === Si el proyecto necesita autenticación biométrica ===
function activarBiometria() {
    var params = {
        onSuccess: function(result) {
            ui.showToast("Autenticación exitosa");
            abrirPantalla("MenuPrincipal");
        },
        onFailure: function(nError, sErrorMessage) {
            ui.showToast("Error: " + sErrorMessage);
        }
    };
    fingerprintManager.setCallback(params);
    fingerprintManager.listen();
}
```

---


## 9. Fase 8: Eventos y Reglas de Negocio

### 8.1 Objetivo

Los eventos son el mecanismo principal para dar vida a la aplicación. Permiten ejecutar lógica de negocio en respuesta a acciones del usuario o del sistema. A diferencia del JavaScript de organización (funciones generales), los eventos están ligados directamente al ciclo de vida de las colecciones, controles y la propia aplicación.

> **IMPORTANTE:** Los eventos pueden ocurrir por una acción ejecutada por el usuario en la interfaz visual o por un script creado por el programador.

### 8.2 Estructura General de un Evento

Todo evento en XOne sigue esta estructura XML:

```xml
<nombre-evento refresh="true|false" show-wait-dialog="true|false">
    <action name="runscript">
        <script language="javascript">
            // Código JavaScript aquí
        </script>
    </action>
</nombre-evento>
```

**Atributos comunes a todos los eventos:**

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `refresh` | `true` / `false` | Si se refresca la UI después de ejecutar el evento |
| `show-wait-dialog` | `true` / `false` | Si se muestra dialogo de espera durante la ejecución |

---

### 8.3 Eventos de Ciclo de Vida de Coleccion

Estos eventos se definen dentro de cualquier coleccion `.xne` y responden al ciclo de vida de sus objetos.

| Evento | Cuando se ejecuta |
|--------|-------------------|
| `create` | Cuando se crea un objeto nuevo (por acción del framework o por script) |
| `insert` | Cuando el usuario guarda un objeto (insercion nueva o actualización) |
| `before-edit` | Al ir a editar un objeto, **antes** de que se pinte la pantalla |
| `after-edit` | Al ir a editar un objeto, **una vez** que ya esta pintado el UI |
| `onchange` | Cuando cambia el valor de un campo monitoreado |
| `delete` | Cuando se va a borrar un objeto |

#### `create` — Inicializar valores al crear

```xml
<create refresh="false" show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            // Inicializar campos por defecto al crear un objeto nuevo
            self.FECHA = new Date();
            self.ESTADO = "PENDIENTE";
            self.ID_USUARIO = appData.getGlobalMacro("##USERID##");
        </script>
    </action>
</create>
```

#### `insert` — Validar antes de guardar

```xml
<insert refresh="false" show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            // Validar campos obligatorios antes de guardar
            if (!self.NOMBRE || self.NOMBRE.trim() === "") {
                appData.failWithMessage(-8100, "El campo NOMBRE es obligatorio.");
            }
            if (!self.FECHA) {
                appData.failWithMessage(-8100, "La fecha no puede estar vacia.");
            }
        </script>
    </action>
</insert>
```

#### `before-edit` — Preparar datos antes de mostrar pantalla

```xml
<before-edit refresh="false" show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            // Se ejecuta antes de pintar la UI
            // Util para cargar datos externos o calcular valores previos
            self.MAP_TITULO = "Editando: " + self.NOMBRE;
        </script>
    </action>
</before-edit>
```

#### Refresco de disablevisible por script

Cuando un campo referenciado en `disablevisible` cambia por código, hay que refrescar para que se reevalue:

```javascript
// Refrescar un prop específico
ui.refresh("MAP_CAMPO");

// Refrescar toda la pantalla
ui.refresh();

// Con referencia explicita a la vista
var view = ui.getView(self);
view.refresh("MAP_CAMPO");  // prop específico
view.refresh();              // toda la pantalla
```

#### `after-edit` — Inicializar UI tras pintar pantalla

```xml
<after-edit refresh="false" show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            // La pantalla ya esta pintada, se pueden refrescar controles
            ui.refresh("MAP_TITULO", "ESTADO");
            // Mostrar version de la app en campos de display
            self.MAP_VERSION = "v" + appData.getGlobalMacro("##VERSION##");
        </script>
    </action>
</after-edit>
```

#### `onchange` — Reaccionar al cambio de un campo

```xml
<onchange>
    <prop name="ESTADO">
        <action name="runscript">
            <script language="javascript">
                // Se ejecuta cuando cambia el campo ESTADO
                if (self.ESTADO === "CERRADO") {
                    self.FECHA_CIERRE = new Date();
                    ui.refresh("FECHA_CIERRE");
                }
            </script>
        </action>
    </prop>
    <prop name="CANTIDAD">
        <action name="runscript">
            <script language="javascript">
                // Recalcular total al cambiar cantidad
                self.TOTAL = self.CANTIDAD * self.PRECIO;
                ui.refresh("TOTAL");
            </script>
        </action>
    </prop>
</onchange>
```

#### `delete` — Validar o limpiar antes de borrar

```xml
<delete refresh="false" show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            // Impedir borrado si el objeto esta en estado activo
            if (self.ESTADO === "ACTIVO") {
                appData.failWithMessage(-8100, "No se puede eliminar un registro en estado ACTIVO.");
            }
        </script>
    </action>
</delete>
```

#### `load` — Procesamiento por cada registro al cargar un contents

> **Uso poco frecuente.** Se ejecuta una vez por cada registro en el momento en que la coleccion se carga como fuente de datos de un contents. **No tiene relación con la edición** — para eso se usan `before-edit` y `after-edit`. Útil para calcular campos visuales (`MAP_`) que dependen de lógica compleja que no puede resolverse en el SQL.

```xml
<load refresh="false" show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            // Se ejecuta para cada fila al cargar el contents
            // Util para calcular campos MAP_ de visualización
            if (self.STOCK <= self.STOCK_MINIMO) {
                self.MAP_COLOR_ALERTA = "#FFCCCC";
            } else {
                self.MAP_COLOR_ALERTA = "#FFFFFF";
            }
        </script>
    </action>
</load>
```

---

### 8.4 Eventos de Navegación

#### `onback` — Controlar el botón Atrás (solo Android)

Obligatorio en toda pantalla. Controla el comportamiento del botón físico/gesto de volver atrás del sistema.

```xml
<onback show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            ui.getView(self).exit();
        </script>
    </action>
</onback>
```

#### `selecteditem` — Selección en contents (subgrid)

Se ejecuta cuando se selecciona un elemento de un contents. Solo disponible en colecciones mostradas como contents.

```xml
<selecteditem refresh="false" show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            // self es el objeto seleccionado en el contents
            ui.openEditView(self);
        </script>
    </action>
</selecteditem>
```

#### `auto-selecteditem` — Paso automático de slides

Exclusivo para contents con `viewmode="slideview"`. Se ejecuta conforme van pasando automáticamente las presentaciones sin interaccion del usuario.

```xml
<auto-selecteditem refresh="false" show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            // Lógica al cambiar de slide automaticamente
        </script>
    </action>
</auto-selecteditem>
```

---

### 8.5 Eventos de la Coleccion Empresas

Estos eventos son **exclusivos de la coleccion Empresas** en `mappings.xne` y controlan el ciclo de vida global de la aplicación.

| Evento | Descripción |
|--------|-------------|
| `onlogon` | Cuando el usuario entra en la aplicación (login correcto) |
| `onlogoff` | Cuando el usuario sale de la aplicación |
| `maintenance` | Tareas programadas que se ejecutan en segundo plano periódicamente |
| `replica-ok` | Cuando se completa la replica de una tabla concreta de la BD |
| `sys-message` | Para recibir eventos de XOneLive |
| `onpushnotificationclick` | Cuando el usuario pulsa en una notificación PUSH |
| `onmessage` | Procesamiento de intents del sistema |
| `onrecovery` | Chequea si el usuario ya estaba validado (sesión recuperada) |
| `after-recovery-login` | Tras recuperar sesión de login |

```xml
<!-- En mappings.xne, dentro de la coleccion Empresas -->
<onlogon refresh="false" show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            // Inicializar variables globales al entrar en la app
            ui.showToast("Bienvenido, " + appData.getGlobalMacro("##USERNAME##"));
        </script>
    </action>
</onlogon>

<onlogoff refresh="false" show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            // Limpiar datos al salir
        </script>
    </action>
</onlogoff>

<maintenance interval="300000" refresh="false" show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            // Tarea que se ejecuta cada 5 minutos (300000 ms) en segundo plano
            replica.start();
        </script>
    </action>
</maintenance>

<replica-ok table="Pedidos" refresh="false" show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            // Se ejecuta cuando termina la replica de la tabla Pedidos
            ui.showToast("Pedidos sincronizados");
        </script>
    </action>
</replica-ok>
```

---

### 8.6 Eventos Especiales de Aplicación

Estos eventos controlan el comportamiento global de la app cuando cambia de estado en el sistema operativo.

#### `on-app-foreground` — App vuelve a primer plano

```xml
<on-app-foreground refresh="false" show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            // La app vuelve al primer plano
            // Comprobar inactividad y relanzar timer si procede
            let nTime = ui.getInactivityTime();
            if (nTime >= jsconst_oper.tiempoInactividad) {
                var objVisible = getLoginInStack();
                if (isNothing(objVisible)) {
                    let objCrear = new LoginColl_Inactivity();
                    ui.openEditView(objCrear);
                }
            }
            let inactividad = setInactivityTimer(jsconst_oper.tiempoInactividad);
        </script>
    </action>
</on-app-foreground>
```

#### `on-app-background` — App pasa a segundo plano

```xml
<on-app-background refresh="false" show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            // La app pasa a segundo plano
            // Detener el timer de inactividad
            ui.removeInactivityTimer();
        </script>
    </action>
</on-app-background>
```

---

### 8.7 Inactividad de Sesión

Para implementar bloqueo por inactividad, definir el código en el nodo `entryPoint` o en `onlogon`:

```javascript
// Lanzar el contador de inactividad
function setInactivityTimer(nValue) {
    ui.setInactivityTimer({
        timeout: nValue,  // Tiempo en milisegundos
        callback: function() {
            var objVisible = getLoginInStack();
            if (isNothing(objVisible)) {
                let objCrear = new LoginColl_Inactivity();
                ui.openEditView(objCrear);
            }
            return 3;
        }
    });
}

// Obtener tiempo de inactividad actual
let nTime = ui.getInactivityTime();

// Detener el timer
ui.removeInactivityTimer();
```

---

### 8.8 Eventos en Controles (bind)

Los eventos de controles especificos se definen como atributos en el prop o mediante `bind()` en JavaScript.

> Los eventos se nombran todo en **minuscula** cuando se definen como atributos XML, y es indiferente cuando se usa `bind()`.

**Propiedades comunes a todos los objetos de eventos:**

| Propiedad | Descripción |
|-----------|-------------|
| `target` | Propiedad objetivo que lanzo el evento |
| `objItem` | DataObject que lanzo el evento |
| `data` | Objeto JavaScript extra definido por el usuario al hacer `bind()` |

#### Eventos por tipo de control

| Control | Evento | Descripción |
|---------|--------|-------------|
| `prop type="B"` | `onclick` | Clic en botón. Parámetros: `x`, `y` (posición en pantalla) |
| `prop type="B"` | `onlongpress` | Pulsación larga en botón. Parámetros: `x`, `y` |
| `contents` | `onlongpressitem` | Pulsación larga en elemento de lista. Parámetro: `position` |
| `contents` | `onselecteditem` | Selección de elemento en lista. Parámetro: `position` |
| `prop type="T"` | `ontextchanged` | Cambio de texto. Parámetros: `target`, `keyPressed`, `oldText`, `newText` |
| `prop type="T"` | `ontextlengthchanged` | Cambio de longitud del texto. Parámetro: `length` |
| `prop type="T"` | `onfocuschanged` | Cambio de foco. Parámetro: `isFocused` |
| `prop type="T"` | `oneditoraction` | Pulsación de tecla intro/siguiente en teclado |
| `prop type="WEB"` | `onconsolemessage` | Errores del WebView. Parámetros: `messageLevel`, `message`, `lineNumber`, `sourceId` |
| `frame` | `onscroll` | Scroll en frame. Parámetros: `dx`, `dy`, `scrollX`, `scrollY`, `width`, `height` |
| `contents viewmode="picturemap"` | `ontouch` | Toque en mapa de imagen. Parámetros: `x`, `y`, `translateX`, `translateY`, `scale` |

**Ejemplo `ontextchanged`:**

```javascript
function eventoOnTextChanged(evento) {
    ui.showToast("Cambio en: " + evento.target +
        " | Tecla: " + evento.keyPressed +
        " | Texto anterior: " + evento.oldText +
        " | Texto nuevo: " + evento.newText);
}
```

**Ejemplo `onconsolemessage` para errores WebView:**

```xml
<prop type="WEB" onconsolemessage="handleError(e);" ... />
```
```javascript
function handleError(e) {
    if (e.messageLevel === "ERROR") {
        ui.msgBox("Nivel: " + e.messageLevel +
            "\nMensaje: " + e.message +
            "\nLinea: " + e.lineNumber, "Error WebView", 0);
    }
}
```

---

### 8.9 Permisos de la Aplicación (solo Android)

A partir de Android 6.x los permisos no se conceden al instalar la app sino en tiempo de ejecución (runtime). XOne solicita los permisos automáticamente antes de ejecutar `openEditView` si la coleccion tiene definido el nodo `<permissions>`.

**Regla:** Poner `<permissions>` en la coleccion `login-coll` o en el `entry-point` para que estén disponibles desde el inicio. Si un permiso ya fue concedido, no se vuelve a solicitar.

> Los permisos son **obligatorios**: si el usuario los deniega, no puede entrar en la coleccion donde se solicitaron.

#### Nodo `<permissions>` — lista de permisos disponibles

```xml
<permissions>
    <!-- Acceso a almacenamiento externo/SDCard. Necesario para replica y funcionamiento general -->
    <permission name="external-storage" />

    <!-- Acceso al hardware de telefonia: llamadas, IMEI y otros identificadores -->
    <permission name="phone" />

    <!-- Acceso a la camara. Necesario para foto, QR, OCR, etc. -->
    <permission name="camera" />

    <!-- GPS y localización por wifi. Permanece activo aunque la app este en segundo plano -->
    <permission name="location" />

    <!-- Solo coordenadas en primer plano (menos intrusivo que location) -->
    <permission name="location-foreground" />

    <!-- Leer y escribir eventos en el calendario del usuario -->
    <permission name="calendar" />

    <!-- Leer los contactos del dispositivo -->
    <permission name="contacts" />

    <!-- Acceso al microfono -->
    <permission name="microphone" />

    <!-- Recibir notificaciones push. OBLIGATORIO para Android >= 13 en instalaciones nuevas -->
    <permission name="notifications" />

    <!-- Bluetooth. OBLIGATORIO para Android >= 12 si se usan impresoras u otros dispositivos BT -->
    <permission name="bluetooth" />

    <!-- SMS: lectura y envio. CUIDADO: Google Play NO permite este permiso salvo causa justificada -->
    <!-- <permission name="sms" /> -->
</permissions>
```

#### Tabla de permisos y cuando usarlos

| Permiso | Cuando es necesario |
|---------|---------------------|
| `external-storage` | Siempre que haya replica o se gestionen ficheros |
| `phone` | Para obtener IMEI/identificador de dispositivo |
| `camera` | Fotos (`type="PH"`), lector QR (`type="VD" code-type="qr"`), OCR (`XOneOCR`) |
| `location` | GPS en segundo plano, tracking de posición |
| `location-foreground` | GPS solo mientras la app esta en pantalla |
| `calendar` | Integración con el calendario del dispositivo |
| `contacts` | Acceso a contactos del dispositivo. Necesario para la fuente de datos `Contacts` (ver §"Leer y escribir los contactos del teléfono") |
| `microphone` | Grabacion de audio/voz |
| `notifications` | Android >= 13, instalaciones nuevas |
| `bluetooth` | Android >= 12, impresoras BT (`XOnePrinter`), dispositivos serie |

#### Funciones JavaScript relacionadas con permisos y seguridad

**Desactivar optimización de batería** — necesario para apps que deben seguir ejecutandose en segundo plano (GPS, replica periódica, notificaciones):

```javascript
function requestIgnoreBatteryOptimizations() {
    var bResult = systemSettings.isIgnoringBatteryOptimizations();
    if (!bResult) {
        ui.showToast("Por favor desactive el ahorro de bateria para la aplicación");
        systemSettings.requestIgnoreBatteryOptimizations();
    }
}
```

**Comprobar estado del GPS** — verificar si el usuario tiene la localización activada antes de usarla:

```javascript
function comprobarEstadoGps() {
    var sDeviceOs = appData.getGlobalMacro("##DEVICE_OS##");
    if (sDeviceOs === "android") {
        var nStatus = ui.checkGpsStatus();
        switch (nStatus) {
            case 0:
                ui.showToast("No hay GPS, no se puede activar.");
                break;
            case 1:
                // Localización GPS activa — OK
                break;
            case 2:
                // Localización por redes wifi/telefonia activa — OK
                break;
            case 3:
                // Sin GPS ni redes: pedir al usuario que lo active
                ui.showToast("No esta activado el GPS ni la ubicación por redes. Activelo.");
                ui.askUserForGpsPermission();
                break;
            case 4:
                // GPS + redes activos — OK
                break;
            default:
                break;
        }
    }
}
```

| Valor `checkGpsStatus()` | Significado |
|--------------------------|-------------|
| `0` | Sin GPS en el dispositivo |
| `1` | GPS activo |
| `2` | Localización por wifi/redes activa |
| `3` | Sin localización activada → llamar a `askUserForGpsPermission()` |
| `4` | GPS + redes activos |
| `-1` | Error inesperado |

---

### 8.10 Referencia Rápida de Eventos por Ubicación

| Ubicación | Eventos disponibles |
|-----------|---------------------|
| **Cualquier coleccion** | `create`, `insert`, `before-edit`, `after-edit`, `onchange`, `delete`, `onback`, `selecteditem`, `load`, `auto-selecteditem` |
| **Solo coleccion Empresas** | `onlogon`, `onlogoff`, `maintenance`, `replica-ok`, `sys-message`, `onpushnotificationclick`, `onmessage`, `onrecovery`, `after-recovery-login` |
| **Solo Android (cualquier coll)** | `onback` |
| **Coleccion con entryPoint** | `on-app-foreground`, `on-app-background` |
| **Controles (atributo o bind)** | `onclick`, `onlongpress`, `ontextchanged`, `onfocuschanged`, `oneditoraction`, `onscroll`, `onconsolemessage`, `ontouch` |

---

## 10. Fase 9: Funciones JavaScript

### 9.1 Objetivo

Crear el archivo `functions.js` con las funciones JavaScript globales de la aplicación.

### 9.2 Reglas Obligatorias

1. **Solo usar API documentada**: `ui.*`, `appData.*`, `self.*`, `$http.*`, `crypto.*`
2. **NO usar APIs web del DOM**: `document.*`, `window.*`, `localStorage.*`, `XMLHttpRequest`, `navigator.*`
3. **Async**: el patrón XOne idiomático son callbacks. Si la situación lo requiere, también está disponible `Promise` (ES2024 completo) o `fetch`. `async`/`await` todavía NO es parseable.
4. **Objeto `self`**: Referencia al DataObject actual en el contexto del script

### 9.3 Plantilla: functions.js

```javascript
/**
 * Funciones globales del proyecto
 * NombreProyecto - v1.0.0
 */

// ============================================
// CONSTANTES DEL PROYECTO
// ============================================

var APP_VERSION = "1.0.0";
var COLOR_PRIMARIO = "#2196F3";
var COLOR_EXITO = "#4CAF50";
var COLOR_ERROR = "#F44336";

// ============================================
// UTILIDADES GENERALES
// ============================================

/**
 * Verifica si un valor esta vacio
 * @param {*} val - Valor a verificar
 * @returns {boolean}
 */
function isEmpty(val) {
    return val === undefined || val === null || val === "";
}

/**
 * Conversion segura a string
 * @param {*} val - Valor a convertir
 * @returns {string}
 */
function cstr(val) {
    if (val === undefined || val === null) return "";
    return val.toString();
}

/**
 * Conversion segura a numero
 * @param {*} val - Valor a convertir
 * @returns {number}
 */
function cnum(val) {
    if (val === undefined || val === null) return 0;
    var n = parseFloat(val);
    return isNaN(n) ? 0 : n;
}

// getControl(name, [dataObject]) es NATIVA del motor (Rhino y V8).
// NO declararla en functions.js. Firma:
//   getControl(name)             → control en la última ventana visible.
//   getControl(name, dataObject) → control en la ventana asociada a ese DataObject.
// Semántica estricta: lanza error si el nombre está vacío, el control no existe,
// no hay ventana destino, o el dataObject no es válido.
// Si un proyecto legacy ya tiene su propio "function getControl(...)", esa
// declaración sombrea a la nativa en su scope local sin tocar la global.

// ============================================
// NAVEGACION
// ============================================

/**
 * Abre una pantalla/colección
 * @param {string} sNombreColl - Nombre de la colección a abrir
 */
function abrirPantalla(sNombreColl) {
    ui.openEditView(sNombreColl);  // crea internamente el dataObject + AddItem y abre su EditView
}

/**
 * Cierra la pantalla actual
 */
function cerrarPantalla() {
    var window = ui.getView(self);
    if (window) {
        window.exit();
    }
}

/**
 * Muestra un grupo con animacion
 * @param {number} nGroup - Indice del grupo (base 0)
 * @param {string} sAnimIn - Animacion de entrada
 * @param {string} sAnimOut - Animacion de salida
 */
function mostrarGrupo(nGroup, sAnimIn, sAnimOut) {
    sAnimIn = sAnimIn || "##ALPHA_IN##";
    sAnimOut = sAnimOut || "##ALPHA_OUT##";
    ui.showGroup(nGroup, sAnimIn, 200, sAnimOut, 200);
}

// ============================================
// MENSAJES Y DIALOGOS
// ============================================

/**
 * Muestra un mensaje de confirmacion Si/No
 * @param {string} sMensaje - Mensaje a mostrar
 * @param {string} sTitulo - Titulo del dialogo
 * @returns {boolean} - true si el usuario acepto
 */
function confirmar(sMensaje, sTitulo) {
    sTitulo = sTitulo || "Confirmar";
    var nResult = ui.msgBox(sMensaje, sTitulo, 4);
    return nResult == 6; // 6=Si, 7=No
}

/**
 * Muestra un toast simple
 * @param {string} sMensaje - Mensaje a mostrar
 */
function mostrarToast(sMensaje) {
    ui.showToast(sMensaje);
}

/**
 * Muestra un mensaje informativo
 * @param {string} sMensaje - Mensaje a mostrar
 * @param {string} sTitulo - Titulo del dialogo
 */
function mostrarMensaje(sMensaje, sTitulo) {
    sTitulo = sTitulo || "Información";
    ui.msgBox(sMensaje, sTitulo, 0);
}

// ============================================
// COLECCIONES Y DATOS
// ============================================

/**
 * Obtiene una coleccion por nombre
 * @param {string} sNombreColl - Nombre de la coleccion
 * @returns {object}
 */
function obtenerColeccion(sNombreColl) {
    return appData.getCollection(sNombreColl);
}

/**
 * Crea un nuevo objeto en una coleccion
 * @param {string} sNombreColl - Nombre de la coleccion
 * @returns {object} - Nuevo objeto creado
 */
function crearObjeto(sNombreColl) {
    var coll = appData.getCollection(sNombreColl);
    var obj = coll.createObject();
    coll.addItem(obj);
    return obj;
}

/**
 * Busca un objeto en una coleccion
 * @param {string} sNombreColl - Nombre de la coleccion
 * @param {string} sFiltro - Condicion SQL de busqueda
 * @returns {object|null}
 */
function buscarObjeto(sNombreColl, sFiltro) {
    var coll = appData.getCollection(sNombreColl);
    return coll.findObject(sFiltro);
}

// ============================================
// VALIDACIONES
// ============================================

/**
 * Valida que los campos obligatorios no esten vacios
 * @param {object} obj - Objeto a validar
 * @param {array} aCampos - Array de nombres de campos
 * @returns {boolean} - true si todos tienen valor
 */
function validarObligatorios(obj, aCampos) {
    for (var i = 0; i < aCampos.length; i++) {
        if (isEmpty(obj[aCampos[i]])) {
            ui.showToast("El campo " + aCampos[i] + " es obligatorio");
            return false;
        }
    }
    return true;
}

/**
 * Valida formato de email basico
 * @param {string} sEmail - Email a validar
 * @returns {boolean}
 */
function validarEmail(sEmail) {
    if (isEmpty(sEmail)) return false;
    return sEmail.indexOf("@") > 0 && sEmail.indexOf(".") > 0;
}

// ============================================
// FORMATO DE FECHAS
// ============================================

/**
 * Formatea una fecha como DD/MM/YYYY
 * @param {Date} dFecha - Fecha a formatear
 * @returns {string}
 */
function formatearFecha(dFecha) {
    if (!dFecha) return "";
    var dd = dFecha.getDate();
    var mm = dFecha.getMonth() + 1;
    var yyyy = dFecha.getFullYear();
    if (dd < 10) dd = "0" + dd;
    if (mm < 10) mm = "0" + mm;
    return dd + "/" + mm + "/" + yyyy;
}

/**
 * Formatea una fecha como DD/MM/YYYY HH:MM
 * @param {Date} dFecha - Fecha a formatear
 * @returns {string}
 */
function formatearFechaHora(dFecha) {
    if (!dFecha) return "";
    var sFecha = formatearFecha(dFecha);
    var hh = dFecha.getHours();
    var mi = dFecha.getMinutes();
    if (hh < 10) hh = "0" + hh;
    if (mi < 10) mi = "0" + mi;
    return sFecha + " " + hh + ":" + mi;
}
```

### 9.4 Referencia Rápida de API JavaScript XOne

#### Objeto `ui` (Interfaz de Usuario)

| Función | Descripción |
|---------|-------------|
| `ui.msgBox(msg, título, tipo)` | Dialogo (tipo 4=Si/No, retorna 6=Si) |
| `ui.showToast(msg)` | Mensaje rápido |
| `ui.showWaitDialog(msg)` | Indicador de carga |
| `ui.hideWaitDialog()` | Ocultar indicador |
| `ui.getView(self)` | Obtener ventana actual |
| `ui.openEditView(obj)` | Abrir pantalla. Acepta un dataObject (lo abre en EditView) o un nombre de coll (crea internamente el objeto y abre su EditView). 2º arg `exit=true` cierra la vista origen. **Patrón principal de navegación**. |
| `ui.openMenu(coll, mask, 0)` | Caso especial: abrir directamente la LISTA (`MainListCollectionActivity`) de una coll en vez de su EditView. Constantes `mask`: ADD=0x01, EDIT=0x02, DELETE=0x04, VIEW=0x200, FULLMASK=0xFFFFFF |
| `ui.refresh()` | Refrescar UI |
| `ui.refresh("campo")` | Refrescar campo |
| `ui.showGroup(n)` | Mostrar grupo/tab |
| `ui.startGps(options)` | Iniciar GPS |
| `ui.showDatePicker(options)` | Selector de fecha |
| `ui.showTimePicker(options)` | Selector de hora |

#### Objeto `appData` (Datos de Aplicación)

| Función | Descripción |
|---------|-------------|
| `appData.getCollection(nombre)` | Obtener coleccion |
| `appData.login(options)` | Iniciar sesión |
| `appData.logout()` | Cerrar sesión |
| `appData.exit()` | Salir de la app |
| `appData.getAppPath()` | Ruta de la app |
| `appData.getFilesPath()` | Ruta de archivos |
| `appData.getGlobalMacro(macro)` | Obtener macro global |
| `appData.failWithMessage(code, msg)` | Fallo controlado |

#### Objeto `self` (Objeto de Datos Actual)

| Propiedad/Función | Descripción |
|-------------------|-------------|
| `self.CAMPO` | Leer/escribir campo |
| `self.save()` | Guardar cambios |
| `self.getOwnerCollection()` | Obtener coleccion |
| `self.getContents("@nombre")` | Obtener contents |
| `self.toJsonString()` | Convertir a JSON |

#### Colecciones

| Función | Descripción |
|---------|-------------|
| `coll.loadAll()` | Cargar todos los registros |
| `coll.getCount()` | Cantidad de registros |
| `coll.get(índice)` | Obtener por índice |
| `coll.findObject(filtro)` | Buscar objeto |
| `coll.createObject()` | Crear objeto (legacy; el patrón preferido es `new NombreColeccion({...})`) |
| `coll.addItem(obj)` | Agregar objeto |
| `coll.deleteItem(índice)` | Eliminar objeto |
| `coll.setFilter(filtro)` | Aplicar filtro |
| `coll.doSort(campo)` | Ordenar |
| `coll.lock()` / `coll.unlock()` | Bloquear/desbloquear |
| `coll.saveAll()` | Guardar todos |

---

## 11. Fase 10: Generación de READMEs

### 10.1 Objetivo

Crear un README.md en cada carpeta del proyecto y un README.md principal con el prompt detallado de generación.

### 10.2 READMEs por Carpeta

Cada carpeta obligatoria debe tener un README.md que describa:

- **bd/README.md**: Proposito de la carpeta, como se genera gestion.db con xone-db-tools create-db
- **icons/README.md**: Fuente de iconos (Google Material Icons), formato PNG, tamanios estándar, nomenclatura
- **files/README.md**: Proposito (archivos dinámicos), como acceder desde código (appData.getFilesPath())
- **fonts/README.md**: Fuentes incluidas, formatos soportados (TTF, OTF), uso en CSS y XML

### 10.3 README.md Principal (Raiz del Proyecto)

El README.md principal debe ser un **prompt detallado** que describe completamente como crear la aplicación. Debe contener:

1. **Descripción General** - Que hace la app, sector, plataformas
2. **Funcionalidades** - Lista detallada de funciones principales
3. **Modelo de Datos** - Todas las colecciones con sus campos, tipos y relaciones
4. **Pantallas** - Descripción de cada pantalla con su proposito y elementos
5. **Flujos de Usuario** - Pasos de interaccion para cada funcionalidad
6. **Reglas de Negocio** - Validaciones, calculos y restricciones
7. **Integraciones** - GPS, camara, firma digital, NFC, Bluetooth, etc.
8. **Paleta de Colores** - Colores hex del proyecto (primario, secundario, acento, estados)
9. **Iconos Requeridos** - Lista completa de iconos necesarios con nombre y pantalla
10. **Comandos de Generación** - Como generar BD, descargar iconos, convertir e insertar datos

---

## 12. Fase 11: Tareas Finales

### 11.1 Objetivo

Ejecutar las tareas finales de generación en el orden exacto especificado. Estas tareas se ejecutan DESPUES de generar todo el código fuente.

### 11.2 Orden de Ejecución (OBLIGATORIO)

1. Generar base de datos (xone-db-tools create-db)
2. Insertar datos iniciales (Empresa + Usuario admin)
3. Descargar iconos (Iconify API — PNG, JPG o SVG validos)

### 11.3 Tarea 1: Generar Base de Datos

Comando: xone-db-tools create-db NombreProyecto --overwrite

Verificación: sqlite3 .../bd/gestion.db ".tables"

Las tablas deben tener prefijo gen_ (ej: gen_Empresas, gen_Usuarios).

**Mapeo de Tipos XOne a SQLite:**

| Tipo XOne | SQLite | Descripción |
|-----------|--------|-------------|
| T, L, TL, X, PH | TEXT | Texto |
| D, DT | TEXT | Fechas |
| IMG, VD, F, M | TEXT | Rutas |
| N | INTEGER | Entero |
| NC, R | INTEGER | Boolean |
| N1-N6 | REAL | Decimales |
| C | TEXT | Combo |
| B, Z, L, S, P, O | NO SE CREA | UI |

### 11.4 Tarea 2: Insertar Datos Iniciales

Registros obligatorios:
- Empresa: CODIGO=1, NOMBRE="EMPRESA DE PRUEBA", ROWID=GUID_32_hex
- Usuario: CODIGO=1, NOMBRE="admin", LOGIN="admin", IDEMPRESA=1, ROWID=GUID_32_hex

GUID sin guiones: python3 -c "import uuid; print(uuid.uuid4().hex)"

### 11.5 Tarea 3: Descargar Iconos

Fuente: Google Material Icons via Iconify API
URL: https://api.iconify.design/ic/baseline-{nombre}.svg?color={color}

XOne soporta PNG, JPG y SVG — no es necesario convertir SVG a PNG.
Iconos comunes: home, search, arrow-back, save, settings, person, add, delete, edit, check, close, menu

### 11.6 Nota sobre formatos de iconos

XOne soporta PNG, JPG y SVG directamente — no es necesario convertir ni eliminar los SVG.
Si por preferencia del proyecto se quiere usar solo PNG, se puede convertir con cairosvg (pip install cairosvg), pero no es obligatorio.

**Anti-patrón a evitar — NO renderices un SVG con `type="WEB"`:** el soporte de SVG en XOne es nativo y completo. Un `.svg` es una imagen más; se refiere con `type="IMG"` (`path="dibujo.svg"`) o con los atributos `img`/`imgbk`, igual que un PNG. El control `WEB` (WebView) es solo para contenido web remoto (URLs `http`/`https`, vídeos embebidos); usarlo para mostrar una imagen local SVG/PNG/JPG es innecesario y rompe el escalado y la integración con el control.

---

## 13. Fase 12: Validación

### 12.1 Objetivo

Ejecutar el checklist completo de validación para asegurar que el proyecto esta completo y funcional.

### 12.2 Checklist Completo

#### Archivos raiz
- [ ] app.xml existe con `prefix="gen"` (o el especificado por el usuario)
- [ ] app.xml tiene `<connection>`, `<entry-point>`, `<style>` e `<include>`
- [ ] app.xml declara un encoding coherente con sus bytes (UTF-8 o iso-8859-15)
- [ ] app.ini existe con `name`, `icon`, `IconFolder=icons`, `FilesFolder=files`
- [ ] license.ini existe con `Connstring=bd/gestion.db`
- [ ] mappings.xne existe SOLO con Empresas y Usuarios
- [ ] mappings.xne declara un encoding coherente con sus bytes (UTF-8 o iso-8859-15)
- [ ] mappings.xne tiene `progid="ASGestion.CASEmpresa"` en Empresas y `progid="ASGestion.CASUser"` en Usuarios
- [ ] Usuarios tiene evento `<create>` con `setval field="IDEMPRESA" value="##ENTID##"`

#### Campos obligatorios en mappings.xne
- [ ] Empresas tiene: `CODIGO` (N), `NOMBRE` (T)
- [ ] Usuarios tiene: `IDEMPRESA` (N, FK a Empresas), `CODIGO` (T), `LOGIN` (T), `PWD` (X), `NOMBRE` (T)

#### Colecciones de negocio
- [ ] Cada coleccion adicional tiene su propio archivo `.xne` (NINGUNA en mappings.xne)
- [ ] Cada coleccion tiene `sql` con `##PREF##` y el campo `ID` en el SELECT
- [ ] Cada coleccion tiene `objname`, `updateobj` y `progid="ASData.CASBasicDataObj"`
- [ ] Tipos de campos validos: `T`, `N`, `N1`-`N6`, `X`, `D`, `DT`, `NC`, `IMG`, `PH`, `VD`, `AT`, `DR`, `TT` para datos; `L` (o su alias legacy `TL`), `THTML`, `B`, `Z` solo para UI
- [ ] Valores de `visible` usan bitmask correcto (0-7)
- [ ] Campos enlazados de JOINs llevan prefijo `MAP_` y están marcados como `locked="true"`
- [ ] Campos FK se nombran `IDLOQUESEA` (todo junto en mayusculas) y usan `mapcol`/`mapfld`
- [ ] Campos tipo Z llevan prefijo `@` en el name y tienen su `<contents>` asociado
- [ ] Filtros van en `filter`, ordenaciones en `sort` — NUNCA en el `sql`
- [ ] No se usan `px` en dimensiones — solo `p` o `%`

#### Pantallas
- [ ] Existe punto de entrada (`EntradaApp.xne` o `MenuPrincipal.xne`) declarado en `<entry-point>` del app.xml
- [ ] Si `autologon="false"`: existe `Login.xne` declarado en `<login-coll>` del app.xml
- [ ] Existe `Consola.xne` (siempre obligatoria)
- [ ] Pantallas con replica: Consola tiene todos los grupos (info replica, dispositivo, ficheros)
- [ ] Pantallas sin replica: Consola tiene solo el grupo de información del dispositivo
- [ ] Todas las colecciones-pantalla tienen `<onback>` definido
- [ ] Grupos fijos (header/footer) usan `fixed="true"` con `orientation="top|bottom"`
- [ ] Events usan sintaxis correcta: `<action name="runscript"><script language="javascript">`

#### Estilos CSS
- [ ] `default.css` existe en la raiz del proyecto
- [ ] No hay `compatibility-mode="true"` en app.xml (anularia los CSS)
- [ ] Unidades en `p` o `%` (NUNCA `px`, `em`, `rem`)
- [ ] `resolution-width` y `resolution-height` coinciden con el dispositivo físico de referencia
- [ ] Tamaños de UI usando los valores estándar documentados (TopBar=164p, Botón=124p, Campo=144p)
- [ ] Fuentes definidas en CSS con clases `.fontN` o con `fontsize` directo en el prop
- [ ] Colores en formato `#RRGGBB` o `#AARRGGBB` (alpha primero)
- [ ] Selectores validos: `coll`, `group`, `frame`, `prop`, `prop:TIPO`, `.clase`
- [ ] `extends:.clase` referencia clases existentes

#### JavaScript
- [ ] `functions.js` existe con funciones globales
- [ ] Solo usa API documentada: `ui.*`, `appData.*`, `self.*`, `replica.*`
- [ ] NO usa APIs del DOM: `document`, `document.getElementById`, `document.querySelector`, `window`, `localStorage`, `sessionStorage`, `XMLHttpRequest`, `navigator`, `history` (sí están disponibles `fetch`, `Promise`, `setTimeout`, `URL` con implementación custom).
- [ ] NO usa `async`/`await` (parse error). Para asincronía prefiere callbacks idiomáticos XOne; `Promise` está disponible si el caso lo justifica.

#### Unicidad de nombres (restricción crítica — AMBITO: la coll ENTERA, no el group/frame)

> **PASO OBLIGATORIO antes de entregar cada `.xne`:** extraer con regex `name="([^"]+)"` todos los `name=` declarados en nodos `<group>`, `<frame>` y `<prop>` (NO contar `<field name>` de `<onchange>`, ni `name=` de la propia `<coll>`, ni el valor del atributo `fontname=`). Verificar que la lista resultante **no contiene duplicados**. Si hay alguno, renombrar — la solución canónica para campos BD que aparecen en listado + detalle con estilos distintos es declararlos UNA SOLA VEZ en el grupo detalle y añadir aliases `MAP_LIST_*` en el `sql=` para el listado (ver fila "Caso típico" de la tabla `Naming y unicidad` en SKILL.md).

- [ ] No hay dos `<coll>` con el mismo `name` en el proyecto
- [ ] No hay dos `<group>` con el mismo `name` dentro de la misma `<coll>`
- [ ] No hay dos `<group>` con el mismo `id` dentro de la misma `<coll>`
- [ ] No hay dos `<frame>` con el mismo `name` dentro de la misma `<coll>` (ámbito coll, NO group — un mismo nombre de frame en dos grupos distintos también colisiona)
- [ ] No hay dos `<prop>` con el mismo `name` dentro de la misma `<coll>` — incluido el caso típico: campo BD declarado en `grpLista` (visible="2") y otra vez en `grpDetalle` (visible="1") con clase distinta. Si necesitas estilos distintos por modo, declarar el real solo en detalle y usar alias `MAP_LIST_*` en el SELECT para el listado
- [ ] No hay dos eventos del mismo tipo (ej. dos `<before-edit>`) en la misma `<coll>`

#### Estructura de carpetas
- [ ] `bd/` existe con `README.md`
- [ ] `icons/` existe con `README.md`
- [ ] `files/` existe con `README.md`
- [ ] `fonts/` existe (recomendado)

#### Base de Datos
- [ ] `gestion.db` generado con `xone-db-tools create-db`
- [ ] Tablas tienen prefijo `gen_` (o el especificado)
- [ ] Empresa inicial: `CODIGO=1`, `NOMBRE="EMPRESA DE PRUEBA"`
- [ ] Usuario admin: `CODIGO=1`, `LOGIN="admin"`, `IDEMPRESA=1`

#### Recursos gráficos
- [ ] Archivos de iconos en `icons/` en formato PNG, JPG o SVG
- [ ] Nomenclatura consistente: `ic_` (acciones), `app_` (icono app), `avatar_` (usuarios)

#### README
- [ ] `README.md` en la raiz con descripción del proyecto
- [ ] `README.md` en `bd/`, `icons/`, `files/`

---

## 14. Ejemplos por Sector

### 14.1 Logistica

**Colecciones típicas:** Almacenes, Productos, Ubicaciones, Movimientos, Inventarios, Lotes
**Pantallas típicas:** Escaneo QR/código barras, Mapa de almacen, Lista de productos, Detalle de movimiento
**Integraciones:** Camara (escaneo QR), GPS (ubicaciones), Firma digital (recepciones)

**Ejemplo de colecciones:**
- Productos.xne - Catálogo con CODIGO_BARRAS, NOMBRE, STOCK, UBICACION
- Movimientos.xne - Entradas/salidas con TIPO, ID_PRODUCTO (FK), CANTIDAD, FECHA
- Inventarios.xne - Conteos con FECHA, ESTADO, OBSERVACIONES

### 14.2 Energía

**Colecciones típicas:** Instalaciones, Contadores, Lecturas, OrdenesTrabajo, Materiales, Checklists
**Pantallas típicas:** Ruta de lecturas, Detalle de contador, Formulario OT, Checklist
**Integraciones:** Camara (foto contador), GPS (ubicación), NFC (identificación equipo)

**Ejemplo de colecciones:**
- Contadores.xne - Puntos de lectura con NUMERO_SERIE, TIPO, DIRECCION, LATITUD, LONGITUD
- Lecturas.xne - Lecturas con ID_CONTADOR (FK), VALOR, FOTO, FECHA, ANOMALIA
- OrdenesTrabajo.xne - Mantenimiento con DESCRIPCION, PRIORIDAD, ESTADO

### 14.3 Comercio

**Colecciones típicas:** Clientes, Productos, Pedidos, LineasPedido, Facturas, Rutas
**Pantallas típicas:** Lista de clientes, Catálogo, Crear pedido, Historial
**Integraciones:** GPS (visitas), Firma digital (aceptacion), Bluetooth (impresora tickets)

**Ejemplo de colecciones:**
- Clientes.xne - Cartera con NOMBRE, CIF, DIRECCION, TELEFONO, SALDO
- Pedidos.xne - Con ID_CLIENTE (FK), FECHA, TOTAL, ESTADO
- LineasPedido.xne - Detalle con ID_PEDIDO (FK), ID_PRODUCTO (FK), CANTIDAD, PRECIO

### 14.4 Salud

**Colecciones típicas:** Pacientes, Citas, HistorialClinico, Tratamientos, Medicamentos
**Pantallas típicas:** Agenda, Ficha paciente, Historial, Prescripcion
**Integraciones:** Camara (fotos clinicas), Firma (consentimiento), Bluetooth (dispositivos)

**Ejemplo de colecciones:**
- Pacientes.xne - Con NOMBRE, DNI, FECHA_NACIMIENTO, GRUPO_SANGUINEO, ALERGIAS
- Citas.xne - Con ID_PACIENTE (FK), FECHA, HORA, MOTIVO, ESTADO
- HistorialClinico.xne - Con ID_PACIENTE (FK), DIAGNOSTICO, TRATAMIENTO, FECHA

### 14.5 Servicios

**Colecciones típicas:** Clientes, Servicios, PartesTrabajo, Materiales, Incidencias
**Pantallas típicas:** Lista trabajos, Detalle servicio, Parte trabajo, Mapa visitas
**Integraciones:** GPS (ubicación), Camara (antes/después), Firma digital (conformidad)

**Ejemplo de colecciones:**
- PartesTrabajo.xne - Con ID_CLIENTE (FK), DESCRIPCION, FECHA_INICIO, FECHA_FIN, ESTADO
- Materiales.xne - Con ID_PARTE (FK), NOMBRE, CANTIDAD, PRECIO
- Incidencias.xne - Con ID_PARTE (FK), DESCRIPCION, PRIORIDAD, FOTO, RESOLUCION

---

## 15. Actualización del Skill

### 15.1 Cuando Actualizar

El skill de generación de proyectos XOne debe actualizarse cuando:

1. Se descubren nuevos patrones en los proyectos reales (templates/projects/)
2. Se documenta nueva funcionalidad en las knowledgebases
3. Se identifican errores o inconsistencias en las plantillas
4. Se agregan nuevos tipos de propiedades o atributos XML
5. Se actualizan las APIs de JavaScript

### 15.2 Que Actualizar

| Componente | Ubicación | Cuando |
|------------|-----------|--------|
| Plantillas XML colecciones | Este documento (sección 7) | Nuevos atributos de coll, prop, group, frame |
| Plantillas CSS | Este documento (sección 4) | Nuevos atributos CSS o nuevas clases base |
| Plantillas JS | Este documento (sección 10) | Nuevas funciones de la API XOne |
| Tipos de datos | Este documento (sección 3.3) | Nuevos tipos de prop documentados |
| Pantallas obligatorias | Este documento (sección 8) | Cambios en las pantallas base del proyecto |
| Eventos | Este documento (sección 9) | Nuevos eventos o cambios en la sintaxis |
| Checklist | Este documento (sección 13) | Nuevos requisitos de validación |
| Prohibiciones | Este documento (sección 16) | Nuevos anti-patrones identificados |

### 15.3 Fuentes de Actualización

1. **Knowledgebases** (knowledgebase/docs/) - Fuente primaria
2. **Proyectos reales** (templates/projects/) - 224 proyectos de referencia
3. **Proyectos generados** - Proyectos creados como referencia
4. **Ejemplo UseCars** (knowledgebase/examples/UseCars/) - Proyecto de referencia completo

---

## 16. Prohibiciones Explicitas

### 16.1 Lo que NO se debe hacer NUNCA

#### En mappings.xne — REGLA ABSOLUTA

> **mappings.xne contiene UNICA Y EXCLUSIVAMENTE las colecciones `Empresas` y `Usuarios`. Sin excepciones.**

- **NO** añadir ninguna otra coleccion de negocio en `mappings.xne`, aunque sea pequeña, auxiliar o de apoyo
- **NO** añadir colecciones de catálogos, configuración, parámetros u otras en `mappings.xne`
- **TODA** coleccion adicional va en su propio fichero `.xne` independiente con el nombre de la coleccion

```
CORRECTO:
  mappings.xne        → solo Empresas y Usuarios
  Clientes.xne        → coleccion Clientes
  Productos.xne       → coleccion Productos
  LineasPedido.xne    → coleccion LineasPedido

INCORRECTO:
  mappings.xne        → Empresas + Usuarios + Clientes + Productos  ← PROHIBIDO
```

#### En XML (.xne)
- **NO** inventar atributos XML que no estén en la knowledgebase
- **NO** usar nodos HTML (div, span, table)
- **NO** omitir `##PREF##` en queries SQL
- **NO** omitir `objname` si la coleccion debe persistirse en BD
- **NO** omitir campos obligatorios en Empresas: `CODIGO` (N), `NOMBRE` (T)
- **NO** omitir campos obligatorios en Usuarios: `IDEMPRESA` (N), `CODIGO` (T), `LOGIN` (T), `PWD` (X), `NOMBRE` (T)
- **NO** usar valores de `visible` fuera del rango 0-7
- **NO** usar tipos de propiedades no documentados (ver sección 3.3)
- **NO** usar `L`/`TL`, `THTML`, `B` o `Z` como tipos de datos en BD — son solo visuales
- **NO** omitir `progid="ASData.CASBasicDataObj"` en colecciones de negocio
- **NO** escribir la clausula WHERE en el atributo `sql` — usar `filter` para los filtros
- **NO** escribir ORDER BY en el atributo `sql` — usar `sort` para la ordenacion
- **NO** usar px en dimensiones de props o frames — usar `p` (puntos) o `%`
- **NO** olvidar `newline="false"` cuando se quieren elementos en horizontal — sin él, cada elemento ocupa su propia línea aunque los anchos sumen 100%
- **NO** usar frames vacios como espaciadores — un frame sin props visibles no se renderiza ni ocupa espacio
- **NO** omitir el prefijo `MAP_` en campos que provienen de tablas enlazadas mediante JOIN — son campos de solo lectura que no se graban en BD
- **NO** usar el prefijo `MAP_` en campos propios de la tabla principal que si deben grabarse
- **NO** repetir el mismo `name` en dos nodos dentro de una `<coll>` — es una restricción crítica de la plataforma. **El ambito de unicidad es la `<coll>` ENTERA**, no el `<group>` o `<frame>` inmediato: no pueden existir dos `<prop>`, dos `<group>`, dos `<frame>` ni dos eventos con el mismo `name` en cualquier parte de la misma coll, **aunque estén en `<group>` o `<frame>` distintos**. Razón: el `name` se publica a nivel de la coll (los `collprops`), por lo que actuaria como identificador único ambiguo si se repitiera. Excepción: dos `<coll>` distintas SI pueden tener contenido identico (mismos `name` internos) siempre que el atributo `name` de cada coll sea distinto
- **NO** usar el mismo `name` en dos `<coll>` del proyecto — cada coleccion debe tener nombre único (este es el único `name` que NO puede coincidir entre colecciones)
- **NO** declarar eventos de control como nodos XML: `onclick`, `ontextchanged`, `onfocuschanged`, `oneditoraction`, `onlongpress`, `onlongpressitem`, `onscroll`, `onconsolemessage`, `oncodescanned`, `ondateselected`, `onpageselected`, `ondraweropened`, `ondrawerclosed`, etc. son **siempre atributos** del `<prop>`/`<frame>`/`<coll>` con JS inline como valor. Construcciones tipo `<onconsolemessage>...</onconsolemessage>` u `<onclick>...</onclick>` son XML invalidos y XOne las ignora silenciosamente. Unica excepción: `onchange` admite ambas formas (atributo y nodo hijo del prop). Los nodos hijos de `<coll>` que SI existen son eventos de objeto/coleccion (`<create>`, `<load>`, `<before-edit>`, `<after-edit>`, `<onback>`, `<onrefresh>`, `<login-ok>`, `<login-fail>`), no eventos de control

#### En CSS
- **NO** usar unidades web: px, em, rem, vh, vw
- **NO** usar propiedades CSS web: font-size, margin-top, background-color, display, flex, grid
- **NO** usar selectores web: #id, elemento > hijo, :hover, :focus
- **NO** usar media queries (`@media`) ni gradientes / sombras / transformaciones / transiciones de CSS web
- **SÍ** se pueden usar variables CSS (`:root { --color: red; }` + `var(--color)`), `calc(...)` sobre números puros y `@import "ruta";` al inicio del archivo

#### En JavaScript
- **NO** usar APIs del DOM — XOne no es HTML y no tiene navegador. Estas funciones NO existen en XOne: `document`, `document.getElementById`, `document.querySelector`, `window`, `window.location`, `localStorage`, `sessionStorage`, `XMLHttpRequest`, `navigator`, `history`. Para HTTP idiomático usar `$http`; para navegación usar `ui.*`; para datos usar `self.*` y `appData.*`.
- **SÍ existen** con implementación custom de XOne y semántica spec-compatible: `Promise` (ES2024 con `all`/`allSettled`/`race`/`any`/`withResolvers`/`.then`/`.catch`/`.finally`), `fetch`, `setTimeout`/`setInterval`, `URL`, `Headers`, `AbortController`, `EventTarget`, `TextEncoder`/`TextDecoder`, `console`, `performance.now()`. Úsalos si el caso lo pide; los callbacks XOne idiomáticos siguen siendo la forma preferida para APIs nativas (`$http.get(url, req, ok, err)`, `ui.startGps(cb)`, etc.).
- **NO** usar `async`/`await` (parse error).
- **NO** usar módulos ES6 (`import`/`export`).
- **NO** asumir que `this` funciona igual que en web (usar `self`).
- **NO** mezclar sintaxis de React, Angular, Vue u otros frameworks.
- **SÍ** se puede usar `class` ES6+ (declaraciones, expresiones, `extends`/`super`/`static`/getters/setters/computed keys, **field declarations** `name = expr;` y `static name = expr;`, **generator methods** `*method()`). Los generadores con `yield` (con o sin `*`) usan runtime estilo SpiderMonkey legacy: `gen.next()` devuelve el valor directo y lanza `StopIteration` al terminar; `for...of` no los itera, usar `try { while (true) v = iter.next(); } catch (e) {}`. Limitaciones: no hay private fields `#name`, static blocks, ni `new.target`.

#### En Estructura de Proyecto
- **NO** usar un prefijo diferente a "gen" sin autorización del usuario
- Los formatos validos para `icons/` son PNG, JPG y SVG
- **NO** omitir la generación de la base de datos con xone-db-tools create-db
- **NO** omitir la insercion de datos iniciales (Empresa + Usuario admin)
- **NO** omitir los READMEs en las carpetas

### 16.2 Regla de Oro

> **Cuando hay duda, SIEMPRE consultar las knowledgebases del proyecto antes de tomar una decisión. Si no hay documentación suficiente, buscar en los proyectos de ejemplo. Si aún así no hay respuesta, PREGUNTAR al usuario.**

---

*Documento generado como guía operativa para agentes de IA en la generación de proyectos XOne. Basado en el análisis de 224 proyectos reales, 5 proyectos sinteticos y la documentación oficial del sistema.*
