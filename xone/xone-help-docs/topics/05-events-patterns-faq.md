# Eventos, Patrones de Diseño y FAQ de XOne

## Tabla de Contenidos

- [PARTE 1: CATALOGO COMPLETO DE EVENTOS](#parte-1-catalogo-completo-de-eventos)
  - [1. Sistema de Eventos en XOne](#1-sistema-de-eventos-en-xone)
  - [2. Eventos de Ciclo de Vida](#2-eventos-de-ciclo-de-vida)
  - [3. Eventos de Interaccion](#3-eventos-de-interaccion)
  - [3A. Eventos Adicionales de Interaccion](#3a-eventos-adicionales-de-interaccion)
  - [4. Eventos de Login](#4-eventos-de-login)
  - [5. Eventos del Sistema](#5-eventos-del-sistema)
  - [5A. Eventos de Ciclo de Aplicación](#5a-eventos-de-ciclo-de-aplicacion)
  - [5B. Gestion de Inactividad](#5b-gestion-de-inactividad)
  - [5D. Códigos sys-message detallados](#5d-codigos-sys-message-detallados)
  - [6. Eventos de Replica](#6-eventos-de-replica)
  - [7. Eventos Personalizados (Custom)](#7-eventos-personalizados-custom)
  - [8. Acciones dentro de Eventos](#8-acciones-dentro-de-eventos)
- [PARTE 2: PATRONES DE DISENO](#parte-2-patrones-de-diseno)
  - [9. Patrones de Navegación](#9-patrones-de-navegacion)
  - [10. Patrones de Datos](#10-patrones-de-datos)
  - [10A. Patrones Críticos de Código](#10a-patrones-criticos-de-codigo)
  - [11. Patrones de UI](#11-patrones-de-ui)
  - [11A. Patron Control por Voz (TTS + STT)](#11a-patron-control-por-voz-tts--stt)
  - [12. Patrones de Integración](#12-patrones-de-integracion)
  - [13. Patrones de Seguridad](#13-patrones-de-seguridad)
- [PARTE 3: FAQ - PREGUNTAS FRECUENTES](#parte-3-faq---preguntas-frecuentes)
  - [14. FAQ General](#14-faq-general)
  - [15. FAQ XML/UI](#15-faq-xmlui)
  - [16. FAQ JavaScript](#16-faq-javascript)
  - [17. FAQ CSS](#17-faq-css)
  - [18. FAQ Estructura](#18-faq-estructura)
  - [19. Troubleshooting](#19-troubleshooting)
  - [20. Glosario de Terminos XOne](#20-glosario-de-terminos-xone)

---

## PARTE 1: CATALOGO COMPLETO DE EVENTOS

## 1. Sistema de Eventos en XOne

### 1.1 Como funciona el sistema de eventos

XOne utiliza un sistema de eventos declarativo en XML. Los eventos se definen como nodos dentro de una coleccion (`<coll>`) y contienen acciones que se ejecutan cuando el evento se dispara.

El flujo básico es:

```
Evento disparado --> Nodo XML del evento --> Accion(es) --> Script JavaScript
```

Las acciones principales dentro de un evento son:

- **`runscript`** - Ejecuta código JavaScript
- **`setval`** - Establece un valor en un campo

Ejemplo básico de un evento con acción:

```xml
<create refresh="true" show-wait-dialog="false">
    <action name="setval" field="FECHA" value="##NOW_TIME##"/>
    <action name="runscript">
        <script language="javascript">
            inicializarFormulario();
        </script>
    </action>
</create>
```

> **Referencia cruzada:** Para la estructura XML de los nodos de eventos, consultar el tópico 02 sobre estructura XML.

### 1.2 Ambitos de eventos

Los eventos en XOne operan en cuatro ambitos distintos:

| Ambito | Descripción | Donde se declara | Ejemplos |
|--------|-------------|------------------|----------|
| **application** | Nivel de aplicación completa | Coleccion `Empresas` en `mappings.xne` | `onlogon`, `maintenance`, `onpushreceived`, `sys-message` |
| **collection** | Nivel de coleccion | Dentro del nodo `<coll>` | `selecteditem`, `onlongpressitem`, `login-ok`, `login-fail` |
| **object** | Nivel de objeto individual | Dentro del nodo `<coll>` | `create`, `load`, `before-edit`, `after-edit`, `onback`, `onrefresh` |
| **property** | Nivel de propiedad/campo | Como atributo en `<prop>` | `onclick`, `onchange`, `ontextchanged`, `onfocuschanged` |

### 1.3 Atributos comunes de eventos

Todos los nodos de evento soportan los siguientes atributos de configuración:

| Atributo | Tipo | Descripción | Valor por defecto |
|----------|------|-------------|-------------------|
| `refresh` | boolean | Refrescar la UI después de ejecutar el evento | `true` |
| `show-wait-dialog` | boolean | Mostrar un dialogo de espera mientras se ejecuta | `true` |
| `wait-dialog-text` | string | Texto personalizado del dialogo de espera | (vacio) |

Ejemplo con todos los atributos:

```xml
<GuardarDatos refresh="true" show-wait-dialog="true" wait-dialog-text="Guardando...">
    <action name="runscript">
        <script language="javascript">
            guardarFormulario();
        </script>
    </action>
</GuardarDatos>
```

**Buena práctica:** Establece `refresh="false"` y `show-wait-dialog="false"` en eventos que no modifican la UI para evitar parpadeos innecesarios.

---

## 2. Eventos de Ciclo de Vida

### 2.1 create - Al crear objeto nuevo

**Ambito:** object | **Tipo:** interno

Se dispara una única vez cuando se crea un nuevo objeto en la coleccion. Es ideal para inicializar valores por defecto.

```xml
<create refresh="true" show-wait-dialog="false">
    <action name="setval" field="FECHA" value="##NOW_TIME##"/>
    <action name="runscript">
        <script language="javascript">
            inicializarFormulario();
        </script>
    </action>
</create>
```

**Ejemplo real** (del proyecto EspecialCalendario):

```xml
<create>
    <action name="runscript">
        <script language="javascript">
            self.MAP_CTN_TITLE_FECHA = "FECHA";
            self.MAP_CTN_TITLE_TIPO = "TIPO";
            self.MAP_CTN_TITLE_DESCRIPCION = "DESCRIPCION";
        </script>
    </action>
</create>
```

**Ejemplo real** (del proyecto ContentCoordenadasGPS, con `setval` y `mapval`):

```xml
<create>
    <action name="setval" field="FECHA" value="##NOW_TIME##"/>
    <action name="mapval" field="USUARIO" coll="Usuarios"
            mapfld="ID" mapvalue="##USERID##" targetfld="LOGIN"/>
</create>
```

### 2.2 load - Al cargar cada DataObject

**Ambito:** object | **Tipo:** interno

Se dispara **por cada DataObject** al cargarse desde la base de datos (en `loadAll()`, `startBrowse()` o cuando se hidrata un item de `<contents>`). Se ejecuta después de `create` si el objeto es nuevo.

> **NUNCA usar `<load>` para inicializar una pantalla** — usar `<before-edit>`. En una pantalla `special="true"` sin coleccion de datos, `<load>` no se dispara nunca; en pantallas con coleccion, se dispara una vez por cada item cargado y penaliza rendimiento.

### 2.3 before-edit - Antes de entrar en edición

**Ambito:** object | **Tipo:** interno

Se dispara antes de que la vista entre en modo edición. Es el evento más utilizado para preparar la pantalla, inicializar variables MAP y configurar contents.

```xml
<before-edit refresh="false" show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            self.MAP_USER = self.getOwnerCollection().getVariable("##LOGIN_LASTUSER##");
        </script>
    </action>
</before-edit>
```

**Ejemplo real** (del proyecto EspecialContents):

```xml
<before-edit refresh="true">
    <action name="runscript">
        <script language="javascript">
            self.MAP_GROUP = 1;
            self.MAP_TOTAL_PAGES = 5;
            self.MAP_ORDEN = "ASC";
            self.MAP_BTORDEN = "sortAZ.png";
            self.MAP_BTORDENCLICK = "sortAZ_click.png";
            self.getContents("content4").sort = "NOMBRE ASC";
            self.getContents("content4").loadAll();
            self.getContents("content4").lock();

            self.getContents("content1").clear();
            self.getContents("content1").lock();

            ui.startGps();
            self.MAP_NOMBRESEL = "";
        </script>
    </action>
</before-edit>
```

**Ejemplo real** (del proyecto EspecialEventos, con `bind` para eventos por script):

```xml
<before-edit>
    <action name="runscript">
        <script language="javascript">
            var v = ui.getView(self);
            v.bind("MAP_ONTEXTCHANGED", "ontextchanged", eventoOnTextChanged);
            v.bind("MAP_ONFOCUSCHANGED01", "onfocuschanged", eventoOnFocusChanged);

            v.bind("SCJAVA", "onclick",
                {title:'valor desde fuera', msg:'LLamada inline'},
                function(e) {
                    ui.msgBox(e.target + ":" + e.data.msg, e.data.title, 0);
                });

            v.bind("SCJAVA1", "onclick", "EspecialcollTest1", jstestClick);
        </script>
    </action>
</before-edit>
```

### 2.4 after-edit - Después de entrar en edición

**Ambito:** object | **Tipo:** interno

Se dispara después de que la vista ha entrado en modo edición y se ha pintado la interfaz. Útil para operaciones que requieren que la UI ya este renderizada.

```xml
<after-edit show-wait-dialog="false" refresh="false">
    <action name="runscript">
        <script language="javascript">
            if (appData.getGlobalMacro("##DEVICE_OS##") == "android")
                requestIgnoreBatteryOptimizations();
        </script>
    </action>
</after-edit>
```

**Ejemplo real** (del proyecto EspecialChat):

```xml
<after-edit show-wait-dialog="false" refresh="false">
    <action name="runscript">
        <script language="javascript">
            lockContents(["Chat", "nUsuarios", "Chatear"]);
        </script>
    </action>
</after-edit>
```

### 2.5 Orden de ejecución de lifecycle

El orden de ejecución de los eventos de ciclo de vida es:

**Para un objeto nuevo:**
1. `create` - Se inicializa el objeto
2. `before-edit` - Se prepara la vista
3. (Se pinta la interfaz)
4. `after-edit` - La vista esta renderizada

**Para un objeto existente:**
1. `load` - Se carga desde BD
2. `before-edit` - Se prepara la vista
3. (Se pinta la interfaz)
4. `after-edit` - La vista esta renderizada

**Al salir:**
1. `onback` - El usuario pulsa atrás

---

## 3. Eventos de Interaccion

### 3.1 onclick (atributo) - Click/tap en elemento

**Ambito:** property | **Tipo:** atributo

Se dispara cuando el usuario hace click o tap en un elemento. Se declara como atributo en el nodo `<prop>`.

```xml
<prop type="B" name="BTN_LOGIN" title="Login"
      onclick="doLogin();"/>

<prop name="BTN_ACCION" type="B"
      onclick="self.MAP_QR=1; ui.refresh('frmCamera'); ui.sleep(0.1);"/>
```

**Ejemplo real** (del proyecto EspecialEventos, llamada inline con parámetros):

```xml
<prop name="ATTJAVA" title="No abre coleccion"
      onclick="javascript:(function(e, data) {
          ui.msgBox(e.target + ':' + data.msg, data.title, 0);
      })(e, {title:'valor desde fuera', msg:'LLamada inline'});"
      type="B" visible="1" width="300p" height="150p"
      labelwidth="1" bgcolor="#666666" forecolor="#F2F2F2"/>
```

**Ejemplo real** (del proyecto EspecialEventos, llamada a función con datos):

```xml
<prop name="ATTJAVA1" title="Abrir coleccion 1"
      onclick="javascript:jstestClickNode(e, 'EspecialcollTest1');"
      type="B" visible="1" width="300p" height="150p"/>

<prop name="ATTJAVA2" title="Abrir coleccion 2"
      onclick="javascript:jstestClickNode(e, {
          title:'valor desde fuera',
          msg:'Abre un nuevo objeto',
          collName: 'EspecialcollTest2'
      });"
      type="B" visible="1" width="300p" height="150p"/>
```

### 3.2 onchange (nodo y atributo) - Cambio de valor

**Ambito:** property/object | **Tipo:** interno/atributo

Se dispara cuando cambia el valor de una propiedad. Puede usarse de dos formas:

**Como nodo `<onchange>` con campos `<field>` especificos:**

```xml
<onchange show-wait-dialog="false" refresh="false">
    <field name="MAP_TIPO">
        <action name="runscript">
            <script language="javascript">
                actualizarPorTipo();
            </script>
        </action>
    </field>
</onchange>
```

**Ejemplo real** (del proyecto EspecialMacros, con multiples campos):

```xml
<onchange>
    <field name="MAP_TIPO">
        <action name="runscript">
            <script language="javascript">
                var coll = self.getContents("content1");
                if (self.TIPO == "TODOS") {
                    coll.setMacro("##TIPO##", "1=1");
                } else {
                    coll.setMacro("##TIPO##", "FILTRO='" + self.TIPO.toString() + "'");
                }
                ui.refresh();
            </script>
        </action>
    </field>
    <field name="MAP_TIPO1">
        <action name="runscript">
            <script language="javascript">
                var coll = self.getContents("content2");
                if (self.TIPO1 == "TODOS") {
                    coll.setMacro("##TIPO##",
                        "SELECT ID,TITULO,FILTRO FROM GEN_CONTROLES");
                } else {
                    coll.setMacro("##TIPO##",
                        "SELECT ID,TITULO,FILTRO FROM GEN_CONTROLES WHERE FILTRO='"
                        + self.TIPO1.toString() + "'");
                }
                ui.refresh();
            </script>
        </action>
    </field>
</onchange>
```

**Ejemplo real** (del proyecto EspecialChat, escuchando cambios en foto y adjunto):

```xml
<onchange>
    <field name="MAP_FOTO">
        <action name="runscript">
            <script language="javascript">
                AccionesChatEspecial('enviar');
            </script>
        </action>
    </field>
    <field name="MAP_ADJUNTO">
        <action name="runscript">
            <script language="javascript">
                AccionesChatEspecial('adjuntoguardar', e);
            </script>
        </action>
    </field>
</onchange>
```

**Como atributo en `<prop>` (forma simplificada):**

```xml
<prop name="CANTIDAD" type="N" onchange="Refresh"/>
<prop name="MAP_TEXT" type="T" onchange="ExecuteNode(oldvalue)"/>
<prop name="Calendario" type="Z" onchange="refresh" postonchange="refresh"/>
```

El valor `"Refresh"` o `"refresh"` hace un refresco automático de la pantalla. También puede usarse `"refresh(campo1,campo2)"` para refrescar campos especificos.

#### onvaluechanged (atributo) — Cambio de valor en la capa de datos

`onvaluechanged` se dispara cuando el valor de un campo cambia. Tiene dos características que lo distinguen:

1. **Su valor es JavaScript inline normal** (igual que `onclick`): escribes directamente el código a ejecutar.
2. **Se dispara desde la capa de datos**, así que salta siempre que el valor del campo cambie de verdad, **aunque no haya ninguna ventana abierta** (cambios provocados por scripts de fondo, réplica, tareas programadas, etc.).

Recibe un objeto de evento `e` con estas propiedades:

| Propiedad | Descripción |
|-----------|-------------|
| `e.value` | Nuevo valor del campo (después del cambio) |
| `e.oldValue` | Valor que tenía el campo antes del cambio |
| `e.target` | Nombre del campo que ha cambiado |
| `e.objItem` | Objeto de datos sobre el que se ha producido el cambio |
| `e.data` | Dato libre asociado al binding (normalmente vacío) |

```xml
<!-- Recalcular un total al cambiar la cantidad, haya o no pantalla abierta -->
<prop name="CANTIDAD" type="N" visible="1"
      onvaluechanged="self.TOTAL = e.value * self.PRECIO;" />

<!-- Registrar el cambio en una auditoría -->
<prop name="ESTADO" type="T" visible="1"
      onvaluechanged="registrarCambio(e.target, e.oldValue, e.value);" />
```

También se puede registrar dinámicamente desde JavaScript:

```javascript
self.bind("CANTIDAD", "onvaluechanged", function (e) {
    self.TOTAL = e.value * self.PRECIO;
});
```

**Solo JavaScript.** Se dispara únicamente cuando el valor cambia de verdad (reasignar el mismo valor no lo dispara) y nunca durante la carga del objeto desde la base de datos.

Es ideal para lógica que debe ejecutarse siempre que el dato cambie (recalcular campos, `Save()`, auditoría, sincronización), haya o no una pantalla abierta.

### 3.3 selecteditem - Selección en lista

**Ambito:** collection | **Tipo:** interno

Se dispara cuando el usuario selecciona un item de una lista o content.

```xml
<selecteditem refresh="false" show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            onSelectedItem(self);
        </script>
    </action>
</selecteditem>
```

> **Referencia cruzada:** Para ver como se implementa la selección en listas con contents, ver el tópico 02 sobre estructura XML y el patron maestro-detalle en la sección 10.2.

### 3.4 onlongpressitem - Pulsacion larga

**Ambito:** collection | **Tipo:** interno

Se dispara cuando el usuario hace una pulsacion larga sobre un item de una lista.

```xml
<onlongpressitem refresh="false" show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            mostrarMenuContextual(self);
        </script>
    </action>
</onlongpressitem>
```

### 3.5 onback - Botón retroceso

**Ambito:** object | **Tipo:** interno

Se dispara cuando el usuario presiona el botón de retroceso del dispositivo. Permite controlar la navegación hacia atrás.

```xml
<onback refresh="false" show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            if (hayDatosSinGuardar()) {
                confirmarSalida();
            } else {
                ui.closeApp();
            }
        </script>
    </action>
</onback>
```

**Ejemplo real** (patron estándar en todos los proyectos del wiki):

```xml
<onback show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            ui.getView(self).exit();
        </script>
    </action>
</onback>
```

**Ejemplo real** (del proyecto UseCars - EntradaApp, con confirmacion):

```xml
<onback>
    <script>
        if (confirmar("¿Desea salir de la aplicación?", "Salir")) {
            appData.exit();
        }
    </script>
</onback>
```

**Ejemplo real** (del proyecto EspecialChat, lógica condicional):

```xml
<onback show-wait-dialog="false" refresh="false">
    <action name="runscript">
        <script language="javascript">
            salir();
        </script>
    </action>
</onback>
```

### 3.6 onrefresh - Al refrescar vista

**Ambito:** object | **Tipo:** interno

Se dispara cuando se refresca la vista del objeto.

```xml
<onrefresh>
    <action name="runscript">
        <script language="javascript">
            actualizarContadores();
        </script>
    </action>
</onrefresh>
```

### 3.7 postonchange (atributo) - Post-cambio

**Ambito:** property | **Tipo:** atributo

Se ejecuta después de que cambia el valor de una propiedad. A diferencia de `onchange`, se ejecuta en un segundo paso, permitiendo realizar acciones de post-procesamiento como refrescar la UI o ejecutar otro nodo.

```xml
<prop name="FOTO" type="IMG"
      method="executenode(HacerFoto)"
      postonchange="actualizarGaleria();"/>

<prop name="BNew" type="B" img="nuevo.png"
      method="ExecuteNode(nuevo)"
      postonchange="refresh"/>

<prop name="EGECUTARYREFRES" type="B"
      method="executeNode(pulsaronchange('EspecialColeccionDePegaOnchange'))"
      postonchange="ExecuteNode(postpulsaronchange)"/>
```

### 3.8 ontextchanged - Cambio de texto en tiempo real

**Ambito:** property | **Tipo:** atributo

Se dispara cada vez que el usuario escribe o borra un carácter en un campo de texto. Recibe un objeto evento con información sobre el cambio.

```xml
<prop name="MAP_ONTEXTCHANGED" title="onTextChanged" type="T"
      ontextchanged="javascript:eventoOnTextChanged(e);"/>
```

**Ejemplo real** (del proyecto EspecialEventos - la función receptora en JS):

```javascript
function eventoOnTextChanged(evento) {
    self["MAP_DESCRIPCIONEVENTO"] = "onTextChanged! target: " + evento.target
        + "\nObjItem: " + evento.objItem
        + "\nTecla pulsada: " + evento.keyPressed
        + "\noldText: " + evento.oldText
        + "\nnewText: " + evento.newText;
    ui.getView(self).refresh("MAP_DESCRIPCIONEVENTO");
}
```

**Ejemplo real** (del proyecto EspecialContents, filtrado en tiempo real):

```xml
<prop name="MAP_BUSCAR_TEXT"
      ontextchanged="javascript:FiltraMarcados(e);"
      labelwidth="0" text-border="true" type="T"
      width="98%" height="60p" tooltip="Texto a buscar"/>
```

```javascript
function FiltraMarcados(e) {
    self.MAP_BUSCAR_TEXT = e.newText;
    self.executeNode("applyfilter");
}
```

**Propiedades del objeto evento (`e`):**

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `e.target` | string | Nombre del campo que disparo el evento |
| `e.objItem` | object | Referencia al objeto que contiene el campo |
| `e.keyPressed` | string | Tecla pulsada |
| `e.oldText` | string | Texto anterior al cambio |
| `e.newText` | string | Texto nuevo después del cambio |

### 3.9 onfocuschanged - Cambio de foco

**Ambito:** property | **Tipo:** atributo

Se dispara cuando un campo gana o pierde el foco.

```xml
<prop name="MAP_ONFOCUSCHANGED01"
      onfocuschanged="javascript:eventoOnFocusChanged(e);"
      title="Evento onFocus" type="T"/>
```

**Ejemplo real** (del proyecto EspecialEventos):

```javascript
function eventoOnFocusChanged(evento) {
    self.MAP_DESCRIPCIONEVENTO = "onFocusChanged! target: " + evento.target
        + "\nObjItem: " + evento.objItem
        + "\nTiene foco: " + evento.isFocused;
    ui.getView(self).refresh("MAP_DESCRIPCIONEVENTO");
}
```

**Ejemplo real** (del proyecto EspecialChat, en campo de texto del chat):

```xml
<prop name="MAP_TITLE"
      onfocuschanged="javascript:AccionesChatEspecial('foco', e);"
      ontextchanged="javascript:AccionesChatEspecial('textoChange', e);"
      type="T" visible="1" width="424p" height="80p"/>
```

**Propiedades del objeto evento (`e`):**

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `e.target` | string | Nombre del campo |
| `e.objItem` | object | Referencia al objeto |
| `e.isFocused` | boolean | `true` si gano el foco, `false` si lo perdio |

### 3.10 onscroll - Al hacer scroll

**Ambito:** frame | **Tipo:** atributo

Se dispara cuando el usuario hace scroll dentro de un frame con `scroll="true"`.

```xml
<frame name="atttop" align="top" height="100%" width="100%"
       scroll="true"
       onscroll="javascript:scrollArrow(e, '2');">
    <!-- contenido -->
</frame>
```

**Ejemplo real** (del proyecto EspecialEventos, mostrar/ocultar flecha de scroll):

```javascript
function scrollArrow(e, miparam) {
    if (miparam == 1) {
        if (e.dy <= 10 && self.MAP_VALORVER == 1) {
            self.MAP_VALORVER = 0;
            ui.getView(self).refresh("frmblotante");
        } else if (e.dy > 10 && self.MAP_VALORVER == 0) {
            self.MAP_VALORVER = 1;
            ui.getView(self).refresh("frmblotante");
        }
    }
}
```

**También se puede usar `bind` en `before-edit` para asignar el evento por script:**

```javascript
v.bind("sctop", "onscroll", function(e) {
    if (e.dy <= 10 && self.MAP_SCSHOWOVERSCROLL == 1) {
        self.MAP_SCSHOWOVERSCROLL = 0;
        ui.getView(self).refresh("scfroverscroll");
    } else if (e.dy > 10 && self.MAP_SCSHOWOVERSCROLL == 0) {
        self.MAP_SCSHOWOVERSCROLL = 1;
        ui.getView(self).refresh("scfroverscroll");
    }
});
```

**Propiedades del objeto evento (`e`):**

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `e.dy` | number | Desplazamiento vertical acumulado |

### 3.11 onfocus (grupo) - Al enfocar un grupo

**Ambito:** group | **Tipo:** atributo

Se dispara cuando un grupo (pestana) recibe el foco, típicamente al cambiar de tab con `group-swipe="true"`.

```xml
<group name="Group1" id="1" onfocus="ExecuteNode(onfocusgrupo(1))">
    <!-- contenido -->
</group>
<group name="Group2" id="2" onfocus="ExecuteNode(onfocusgrupo(2))">
    <!-- contenido -->
</group>
```

**Ejemplo real** (nodo custom asociado, presente en todos los proyectos del wiki):

```xml
<onfocusgrupo show-wait-dialog="false">
    <action name="runscript">
        <param name="index"/>
        <script language="javascript">
            self.MAP_GROUP = index;
        </script>
    </action>
</onfocusgrupo>
```

---

## 3A. Eventos Adicionales de Interaccion

### 3A.1 onlongpress - Pulsacion larga en un prop

**Ambito:** property | **Tipo:** atributo

Se dispara cuando el usuario mantiene pulsado un control individual (a diferencia de `onlongpressitem` que opera sobre items de lista).

```xml
<prop name="BTN_OPCIONES" type="B" title="Opciones"
      onlongpress="javascript:mostrarMenu();"/>
```

### 3A.2 onlongpressitem - Pulsacion larga en item de lista

**Ambito:** property | **Tipo:** atributo

Se dispara cuando el usuario mantiene pulsado un item dentro de un content/lista. Recibe la posición del item en `e.position`.

```xml
<prop name="@miLista" type="Z" contents="miLista"
      onlongpressitem="javascript:mostrarMenu(e.position);"/>
```

### 3A.3 oneditoraction - Acción de teclado (Done/Next)

**Ambito:** property | **Tipo:** atributo

Se dispara cuando el usuario pulsa la tecla Intro, Done o Siguiente en el teclado virtual. Útil para formularios de login o busqueda donde se quiere ejecutar una acción al confirmar.

```xml
<prop name="MAP_CONTRASENNA" type="X" title="Contraseña"
      oneditoraction="javascript:oneditoraction(self, 0, 'MAP_CONTRASENNA');"/>
```

```javascript
function oneditoraction(obj, action, fieldName) {
    if (fieldName == "MAP_CONTRASENNA") {
        obj.executeNode("doLogin");
    }
}
```

### 3A.4 oncodescanned - Código escaneado (QR/Barcode)

**Ambito:** property | **Tipo:** atributo

Se dispara cuando se completa el escaneo de un código QR o de barras.

```xml
<prop name="MAP_SCANNER" type="T"
      oncodescanned="procesarCodigo(e);"/>
```

```javascript
function procesarCodigo(e) {
    self.MAP_CODIGO = e.data;       // contenido del código (e.type indica el formato: qr, datamatrix, etc.)
    ui.refresh("MAP_CODIGO");
    ui.showToast("Código leído: " + e.data);
}
```

### 3A.5 ondateselected - Fecha seleccionada en calendario

**Ambito:** property (tipo Z con viewmode calendario) | **Tipo:** atributo

Se dispara cuando el usuario selecciona una fecha en un control de calendario. Recibe el parámetro `date`.

```xml
<prop name="MAP_CALENDARIO" type="Z" contents="contentCalendario"
      viewmode="calendarview"
      ondateselected="javascript:onFechaSeleccionada(e);"/>
```

**Ejemplo real** (del proyecto EspecialCalendario, como nodo):

```xml
<ondateselected show-wait-dialog="false">
    <action name="runscript">
        <param name="date"/>
        <script language="javascript">
            self.MAP_FECHA = date;
            cargarEventosFecha(date);
        </script>
    </action>
</ondateselected>
```

### 3A.6 onpageselected - Cambio de página (calendario/slideview/tabs)

**Ambito:** property (tipo Z con viewmode calendario o slideview) | **Tipo:** atributo

Se dispara cuando el usuario cambia de mes/página en un calendario o slideview. Recibe `startDate` y `endDate`.

```xml
<prop name="MAP_CALENDARIO" type="Z" contents="contentCalendario"
      viewmode="calendarview"
      onpageselected="javascript:onMesCambiado(e);"/>
```

**Ejemplo real** (del proyecto EspecialCalendario, como nodo):

```xml
<onpageselected show-wait-dialog="false">
    <action name="runscript">
        <param name="startDate"/>
        <param name="endDate"/>
        <script language="javascript">
            cargarEventosPeriodo(startDate, endDate);
        </script>
    </action>
</onpageselected>
```

### 3A.7 Eventos de mapa

Los props con `viewmode="mapview"` u `viewmode="openstreetmap"` soportan estos eventos:

| Evento | Descripción | Ejemplo |
|--------|-------------|---------|
| `onmapclicked` | Click en el mapa | `onmapclicked="onMapClicked(e);"` |
| `onmaplongclicked` | Click prolongado en el mapa | `onmaplongclicked="onMapLongClicked(e);"` |
| `onmarkerdragend` | Fin de arrastrar un marcador | `onmarkerdragend="onMarkerDraggedEnd(e);"` |
| `onmapready` | El mapa esta listo para usar | `onmapready="onMapReady(e);"` |
| `onlocationready` | Ubicación GPS lista | `onlocationready="handler(e);"` |
| `onlocationchanged` | Cambio de ubicación GPS | `onlocationchanged="handler(e);"` |

**Ejemplo real** (del proyecto EspecialMapa con OpenStreetMap):

```xml
<prop name="MAP_MAPA" show-compass="true" show-minimap="true"
      show-scale="true" zoom-to-pois="true"
      visible="1" type="Z"
      contents="ClientesCoord" viewmode="openstreetmap"
      width="100%" height="60%"
      onmapclicked="onMapClicked(e);"
      onmaplongclicked="onMapLongClicked(e);"
      onmarkerdragend="onMarkerDraggedEnd(e);"/>
```

### 3A.8 onscroll - Evento de scroll

**Ambito:** frame | **Tipo:** atributo

Se dispara cuando el usuario hace scroll dentro de un frame con `scroll="true"`. El objeto evento contiene `e.dy` (desplazamiento vertical acumulado).

```xml
<frame name="frmContenido" width="100%" height="100%"
       scroll="true"
       onscroll="javascript:scrollArrow(e, '2');">
    <!-- contenido scrollable -->
</frame>
```

```javascript
function scrollArrow(e, miparam) {
    if (e.dy <= 10 && self.MAP_VALORVER == 1) {
        self.MAP_VALORVER = 0;
        ui.getView(self).refresh("frmblotante");
    } else if (e.dy > 10 && self.MAP_VALORVER == 0) {
        self.MAP_VALORVER = 1;
        ui.getView(self).refresh("frmblotante");
    }
}
```

### 3A.9 Eventos del drawer lateral

**Ambito:** collection | **Tipo:** atributo

Hay cuatro eventos del drawer lateral, todos atributos del nodo `<coll>`. El objeto del evento llega en `e`:

| Evento | Cuándo se dispara | Propiedades de `e` |
|--------|-------------------|--------------------|
| `ondraweropened` | El drawer queda completamente abierto | `e.id` — id del grupo drawer |
| `ondrawerclosed` | El drawer queda completamente cerrado | `e.id` |
| `ondrawerslide` | Durante el deslizamiento (se llama repetidamente) | `e.id`, `e.slideOffset` (de `0.0` cerrado a `1.0` abierto) |
| `ondrawerstatechanged` | Cambia el estado de arrastre | `e.state`: `"idle"`, `"dragging"`, `"settling"` o `"unknown"` |

`e.id` permite distinguir qué drawer cambió cuando hay varios en la misma pantalla. `ondrawerstatechanged` no incluye `e.id`.

```xml
<coll name="PantallaConDrawer" notab="true"
      ondraweropened="onDrawerOpened(e);"
      ondrawerclosed="onDrawerClosed(e);"
      ondrawerslide="onDrawerSlide(e);"
      ondrawerstatechanged="onDrawerStateChanged(e);">
    <group name="Drawer" id="999"
           width="60%" drawer-orientation="left" bgcolor="#FFFFFF">
        <!-- Contenido del drawer -->
    </group>
    <group name="Contenido" id="1">
        <!-- Contenido principal -->
    </group>
</coll>
```

### 3A.10 onconsolemessage - Mensajes de consola del WebView

**Ambito:** property (`type="WEB"`) | **Tipo:** atributo

Se dispara con cada mensaje que el WebView reporta a su consola: errores JS, llamadas a `console.log`/`warn`/`error`, etc. Util para capturar fallos del contenido web sin tener que conectar el inspector remoto.

```xml
<prop name="MAP_WEB" type="WEB" visible="1"
      height="40%"
      title="Página Web"
      onconsolemessage="handleConsole(e);" />
```

```javascript
function handleConsole(e) {
    if (e.messageLevel === "ERROR") {
        ui.msgBox("Nivel: " + e.messageLevel +
            "\nMensaje: " + e.message +
            "\nLinea: " + e.lineNumber +
            "\nFuente: " + e.sourceId, "Error WebView", 0);
    }
}
```

**Propiedades del objeto evento (`e`):**

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `e.target` | string | Nombre del prop que disparo el evento |
| `e.objItem` | object | Referencia al DataObject que contiene el prop |
| `e.messageLevel` | string | Nivel del mensaje: `"LOG"`, `"DEBUG"`, `"WARNING"`, `"ERROR"`, `"TIP"` |
| `e.message` | string | Texto del mensaje |
| `e.lineNumber` | number | Linea del fuente donde se origino el mensaje |
| `e.sourceId` | string | URL/identificador del fuente que origino el mensaje |

---

### 3A.11 ontouchdown / ontouchup - Presionar y soltar un botón

**Ambito:** property (solo `type="B"`) | **Tipo:** atributo

Pareja de eventos táctiles de bajo nivel exclusivos de los botones (`type="B"`):

- **`ontouchdown`**: se dispara en el instante en que el dedo toca el botón (al presionar).
- **`ontouchup`**: se dispara al levantar el dedo o al cancelarse el gesto (al soltar).

A diferencia de `onclick` —que solo se dispara una vez completado el tap— estos eventos permiten **distinguir el momento de presionar del de soltar**, lo que habilita interacciones de tipo "mantener pulsado" (por ejemplo, iniciar una grabación mientras se mantiene el botón y detenerla al soltarlo). Su valor es JavaScript inline normal, igual que `onclick`.

```xml
<prop name="BTN_HABLAR" type="B" title="Mantener para hablar"
      ontouchdown="javascript:iniciarGrabacion();"
      ontouchup="javascript:detenerGrabacion();"/>
```

**Propiedades del objeto evento (`e`):**

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `e.target` | string | Nombre del prop (botón) que disparo el evento |
| `e.objItem` | object | Referencia al DataObject que contiene el prop |
| `e.x` | number | Coordenada X del toque, relativa al botón (px) |
| `e.y` | number | Coordenada Y del toque, relativa al botón (px) |

**Notas:**

- Conviven con `onclick`: si el botón define ambos, `onclick` se sigue disparando al soltar (después de `ontouchup`). Para un botón de tipo "mantener pulsado" lo habitual es no definir `onclick`.
- El botón debe estar habilitado y ser pulsable (es el caso normal de un botón con fondo). Sobre un botón deshabilitado no se disparan.

---

## 4. Eventos de Login

### 4.1 login-ok

**Ambito:** collection (login-coll) | **Tipo:** interno

Se dispara cuando el proceso de login es exitoso.

```xml
<login-ok refresh="false" show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            ui.showToast("Bienvenido!");
            cargarDatosUsuario();
        </script>
    </action>
</login-ok>
```

### 4.2 login-fail

**Ambito:** collection (login-coll) | **Tipo:** interno

Se dispara cuando el login falla. Permite acceder a la descripción del error.

```xml
<login-fail>
    <action name="runscript">
        <script language="javascript">
            var error = self.getVariable("##LOGIN_ERRORDESCRIPTION##");
            ui.showToast("Error: " + error);
        </script>
    </action>
</login-fail>
```

### 4.3 onlogon (nivel Empresas)

**Ambito:** application (Empresas) | **Tipo:** interno

Se dispara cuando el usuario inicia sesión en la aplicación. Se declara en la coleccion `Empresas` dentro de `mappings.xne`.

```xml
<onlogon>
    <action name="runscript">
        <script language="javascript">
            inicializarAplicacion();
        </script>
    </action>
</onlogon>
```

### 4.4 onlogoff (con replica)

**Ambito:** application (Empresas) | **Tipo:** interno

Se dispara cuando el usuario cierra sesión. Soporta atributos especiales para gestionar la replica de datos antes de salir.

```xml
<onlogoff with-replica="true" replica-retry="1" replica-fail-exit="true">
    <action name="runscript">
        <script language="javascript">
            limpiarDatosLocales();
        </script>
    </action>
</onlogoff>
```

**Atributos especiales de `onlogoff`:**

| Atributo | Tipo | Descripción |
|----------|------|-------------|
| `with-replica` | boolean | Ejecutar replica antes de cerrar sesión |
| `replica-retry` | number | Número de reintentos si la replica falla |
| `replica-fail-exit` | boolean | Salir igualmente si la replica falla |

---

## 5. Eventos del Sistema

### 5.1 onpushreceived - Notificación push recibida

**Ambito:** application (Empresas) | **Tipo:** interno

Se dispara cuando la aplicación recibe una notificación push.

```xml
<onpushreceived>
    <action name="runscript">
        <param name="message"/>
        <script language="javascript">
            ui.showToast("Push recibido: " + message.source);
            procesarNotificacion(message);
        </script>
    </action>
</onpushreceived>
```

### 5.2 onpushnotificationclick - Click en notificación

**Ambito:** application (Empresas) | **Tipo:** interno

Se dispara cuando el usuario hace click en una notificación push.

```xml
<onpushnotificationclick>
    <action name="runscript">
        <param name="message"/>
        <script language="javascript">
            if (ui.isInBackground()) {
                ui.returnToForeground();
            }
            abrirDetalle(message.data);
        </script>
    </action>
</onpushnotificationclick>
```

### 5.3 notification - Manejador general

**Ambito:** application | **Tipo:** interno

Manejador general de notificaciones locales. Recibe parámetros sobre la notificación disparada.

```xml
<notification refresh="false" show-wait-dialog="false">
    <action name="runscript">
        <param name="id_notificacion"/>
        <param name="sDirectReply"/>
        <param name="parameters"/>
        <script language="javascript">
            procesarNotificacion(id_notificacion, parameters);
        </script>
    </action>
</notification>
```

### 5.4 sys-message - Mensaje del sistema (códigos 1000-1003)

**Ambito:** application (Empresas) | **Tipo:** interno

Se dispara cuando se recibe un mensaje del sistema, típicamente relacionado con actualizaciones o provisionamiento.

```xml
<sys-message>
    <action name="runscript">
        <param name="codigo"/>
        <param name="message"/>
        <param name="liveResponse"/>
        <script language="javascript">
            procesarMensajeSistema(codigo, message);
        </script>
    </action>
</sys-message>
```

**Ejemplo real** (función `sysMessage` del proyecto wiki):

```javascript
function sysMessage(codigo, message) {
    var cadena = "";
    switch (codigo) {
        case 1000:
            cadena = " Actualizacion descargandose.";
            break;
        case 1001:
            cadena = " Actualizacion aplicada.";
            break;
        case 1002:
            cadena = " Se han aplicado todas las actualizaciones.";
            break;
        case 1003:
            // Provisionamiento seguro
            ui.msgBox("Se ha programado una actualizacion de base de datos.",
                "Mensaje", 0);
            var bResult = replica.processReplicatorQueue(liveResponse);
            if (bResult) {
                appData.exit();
            } else {
                ui.showToast("Error al procesar la cola de salida");
            }
            break;
    }
}
```

**Códigos del sistema:**

| Código | Descripción |
|--------|-------------|
| 1000 | Actualización descargandose (uno por cada actualización) |
| 1001 | Actualización aplicada (uno por cada actualización) |
| 1002 | Todas las actualizaciones aplicadas |
| 1003 | Provisionamiento seguro - requiere replica y cierre |

### 5.5 maintenance - Tareas programadas (period, frecuency)

**Ambito:** application (Empresas) | **Tipo:** contenedor

Contenedor para definir tareas periódicas que se ejecutan automáticamente.

```xml
<maintenance>
    <!-- Tarea cada 10 minutos -->
    <action name="SincronizarDatos" type="runscript"
            period="S" frecuency="600" auto="true" show="false">
        <script language="javascript">
            sincronizarConServidor();
        </script>
    </action>

    <!-- Replica automática -->
    <action name="Replica" type="replica"
            frecuency="400" period="X" synchronize="true"/>
</maintenance>
```

**Atributos de action en maintenance:**

| Atributo | Tipo | Descripción | Valores |
|----------|------|-------------|---------|
| `name` | string | Nombre identificativo de la tarea | Cualquier texto |
| `type` | string | Tipo de acción | `runscript`, `replica` |
| `period` | string | Unidad de tiempo | `S` (segundos), `X` (minutos) |
| `frecuency` | number | Frecuencia en la unidad especificada | Ej: `600` (cada 600 seg) |
| `auto` | boolean | Ejecución automática al iniciar | `true`/`false` |
| `show` | boolean | Mostrar en la interfaz | `true`/`false` |
| `synchronize` | boolean | Sincronizar al ejecutar | `true`/`false` |

**Ejemplo de mantenimiento cada 24 horas:**

```xml
<maintenance>
    <action name="LimpiezaDiaria" type="runscript"
            period="X" frecuency="1440" auto="true" show="false">
        <script language="javascript">
            // Tareas periodicas de mantenimiento (cada 24h = 1440 min)
            limpiarRegistrosAntiguos();
            compactarBaseDeDatos();
        </script>
    </action>
</maintenance>
```

### 5.6 onrecovery - Recuperación

**Ambito:** application | **Tipo:** interno

Se dispara cuando la aplicación se recupera de un cierre inesperado o de un estado previo.

```xml
<onrecovery>
    <action name="runscript">
        <script language="javascript">
            verificarEstadoPendiente();
        </script>
    </action>
</onrecovery>
```

### 5.7 after-recovery-login - Login tras recuperación

**Ambito:** application | **Tipo:** interno

Se dispara después de que el usuario inicia sesión tras una recuperación de la aplicación (por crash o kill del sistema operativo).

```xml
<after-recovery-login>
    <action name="runscript">
        <script language="javascript">
            restaurarSesionAnterior();
        </script>
    </action>
</after-recovery-login>
```

---

## 5A. Eventos de Ciclo de Aplicación

### 5A.1 on-app-foreground - App vuelve a primer plano

**Ambito:** application (Empresas) | **Tipo:** interno

Se dispara cuando la aplicación vuelve al primer plano después de estar en segundo plano. Es el lugar ideal para verificar inactividad y forzar re-login si es necesario.

```xml
<on-app-foreground>
    <action name="runscript">
        <script language="javascript">
            verificarConexion();
            actualizarDatos();
        </script>
    </action>
</on-app-foreground>
```

**Ejemplo real con verificación de inactividad:**

```xml
<on-app-foreground refresh="false">
    <action name="runscript">
        <script language="javascript">
            var nTime = ui.getInactivityTime();
            if (nTime >= jsconst_oper.tiempoInactividad) {
                var objCrear = new LoginColl_Inactivity();
                ui.openEditView(objCrear);
            }
        </script>
    </action>
</on-app-foreground>
```

### 5A.2 on-app-background - App pasa a segundo plano

**Ambito:** application (Empresas) | **Tipo:** interno

Se dispara cuando la aplicación pasa a segundo plano (el usuario cambia de app o pulsa Home).

```xml
<on-app-background>
    <action name="runscript">
        <script language="javascript">
            guardarEstadoActual();
        </script>
    </action>
</on-app-background>
```

---

## 5B. Gestion de Inactividad

XOne proporciona funciones JavaScript para gestionar la inactividad del usuario, útiles para forzar re-login por seguridad.

### 5B.1 ui.setInactivityTimer(segundos, acción)

Configura un temporizador de inactividad. Cuando el usuario no interactua durante el tiempo especificado, se ejecuta la acción indicada.

```javascript
ui.setInactivityTimer(300, "verificarSesion"); // 5 minutos
```

### 5B.2 ui.getInactivityTime()

Obtiene el tiempo en segundos transcurrido desde la última interaccion del usuario.

```javascript
var tiempo = ui.getInactivityTime();
if (tiempo > 1800) {
    // Mas de 30 minutos inactivo
    forzarReLogin();
}
```

### 5B.3 ui.removeInactivityTimer()

Elimina el temporizador de inactividad activo.

```javascript
ui.removeInactivityTimer();
```

### 5B.4 Patron completo: re-login por inactividad

Combinar `on-app-foreground` con `getInactivityTime()` para forzar re-login:

```xml
<!-- En Empresas (mappings.xne) -->
<on-app-foreground refresh="false">
    <action name="runscript">
        <script language="javascript">
            var nTime = ui.getInactivityTime();
            if (nTime >= 1800) {
                var objCrear = new LoginColl_Inactivity();
                ui.openEditView(objCrear);
            }
        </script>
    </action>
</on-app-foreground>
```

---

## 5D. Códigos sys-message detallados

El evento `sys-message` recibe un parámetro `código` que indica el tipo de mensaje del sistema. Estos son los códigos documentados:

| Código | Categoría | Descripción |
|--------|-----------|-------------|
| 1000 | Actualización | Actualización descargandose (uno por cada actualización individual) |
| 1001 | Actualización | Actualización aplicada exitosamente (uno por cada actualización) |
| 1002 | Actualización | Todas las actualizaciones han sido aplicadas |
| 1003 | Provisionamiento | Provisionamiento seguro - requiere procesar cola de replica y reiniciar |

**Ejemplo completo de manejo de sys-message:**

```javascript
function sysMessage(codigo, message) {
    var cadena = "";
    switch (codigo) {
        case 1000:
            cadena = "Actualizacion descargandose.";
            ui.showToast(cadena);
            break;
        case 1001:
            cadena = "Actualizacion aplicada.";
            ui.showToast(cadena);
            break;
        case 1002:
            cadena = "Se han aplicado todas las actualizaciones.";
            ui.showToast(cadena);
            break;
        case 1003:
            // Provisionamiento seguro: procesar cola y reiniciar
            ui.msgBox("Se ha programado una actualizacion de base de datos.",
                "Mensaje", 0);
            var bResult = replica.processReplicatorQueue(liveResponse);
            if (bResult) {
                appData.exit();
            } else {
                ui.showToast("Error al procesar la cola de salida");
            }
            break;
    }
}
```

> **Nota:** El parámetro `liveResponse` esta disponible como tercer parámetro del evento `sys-message`. Se usa exclusivamente con el código 1003 para el provisionamiento seguro.

---

## 6. Eventos de Replica

### 6.1 replica-ok-{tabla}

**Ambito:** application (Empresas) | **Tipo:** interno

Se dispara cuando la replica de una tabla especifica es exitosa. El nombre del evento incluye el nombre de la tabla con prefijo.

```xml
<replica-ok-gen_ot_cabecera>
    <action name="runscript">
        <script language="javascript">
            actualizarListadoOT();
            ui.showToast("OTs sincronizadas");
        </script>
    </action>
</replica-ok-gen_ot_cabecera>
```

---

## 7. Eventos Personalizados (Custom)

### 7.1 Definición de eventos custom

Los eventos personalizados se definen como nodos XML con cualquier nombre dentro de la coleccion. Son el mecanismo principal para organizar la lógica de la aplicación en bloques reutilizables.

```xml
<GuardarFormulario refresh="true" show-wait-dialog="true"
                   wait-dialog-text="Guardando...">
    <action name="runscript">
        <script language="javascript">
            validarYGuardar();
        </script>
    </action>
</GuardarFormulario>
```

### 7.2 Invocación con ExecuteNode(nombre)

Se invocan desde atributos `method` o `onclick` de un `<prop>`:

```xml
<prop name="BTN_GUARDAR" type="B"
      method="ExecuteNode(GuardarFormulario)"/>
```

También se pueden invocar desde JavaScript:

```javascript
self.executeNode("GuardarFormulario");
```

### 7.3 Paso de parámetros ExecuteNode(nombre(param))

Se pueden pasar parámetros directamente en la invocación:

```xml
<prop name="BTN_MENU" type="B"
      method="executenode(CambiarMenu(3))"/>

<prop name="BTBUSCAR" type="B"
      method="ExecuteNode(buscar(1))"/>

<prop name="BTORDENAR" type="B"
      method="ExecuteNode(buscar(2))"/>
```

### 7.4 Usando `<param name="..."/>`

Los parámetros se reciben en el evento con nodos `<param>`:

```xml
<CambiarMenu refresh="true">
    <action name="runscript">
        <param name="opcion"/>
        <script language="javascript">
            cambiarAOpcion(opcion);
        </script>
    </action>
</CambiarMenu>
```

**Ejemplo real** (del proyecto EspecialContents - busqueda y ordenacion):

```xml
<buscar show-wait-dialog="false" refresh="false">
    <action name="runscript">
        <param name="param"/>
        <script language="javascript">
            if (param == "1") {
                if (self.MAP_FILTRO.length == 0) {
                    self.getContents("content4").setFilter("");
                } else {
                    self.getContents("content4").setFilter(
                        "NOMBRE like '%" + self.MAP_FILTRO.toString() + "%' OR "
                        + "DIRECCION like '%" + self.MAP_FILTRO.toString() + "%'"
                    );
                }
            } else {
                if (self.MAP_ORDEN == "ASC") {
                    self.MAP_ORDEN = "DESC";
                    self.MAP_BTORDEN = "sortZA.png";
                    self.MAP_BTORDENCLICK = "sortZA_click.png";
                } else {
                    self.MAP_ORDEN = "ASC";
                    self.MAP_BTORDEN = "sortAZ.png";
                    self.MAP_BTORDENCLICK = "sortAZ_click.png";
                }
                self.getContents("content4").sort =
                    "NOMBRE " + self.MAP_ORDEN.toString();
            }
            self.getContents("content4").unlock();
            self.getContents("content4").loadAll();
            self.getContents("content4").lock();
            ui.getView(self).refresh("@content4,BTORDENAR");
        </script>
    </action>
</buscar>
```

**Ejemplo real** (del proyecto EspecialContents - multiples parámetros con checkAll):

```xml
<checkAll refresh="false">
    <action name="runscript">
        <param name="activo"/>
        <script language="javascript">
            var objContent = self.getContents("ContentDatosFiltroMultiseleccion");
            if (activo == 1) {
                var vres = userMsgBox("OPCIONES",
                    "Confirme que desea marcar todos los registros", "2");
            } else {
                var vres = userMsgBox("OPCIONES",
                    "Confirme que desea DESmarcar todos los registros", "2");
            }
            if (vres == 1) {
                for (var i = 0; i < objContent.count(); i++) {
                    var item = objContent.get(i);
                    if (activo == 1) {
                        if (item.MAP_SELECTED == 1 && item.REALIZADA == 0) {
                            ReportarTareaPendiente2(item);
                            item.MAP_SELECTED = 0;
                        }
                    } else {
                        if (item.MAP_SELECTED == 1 && item.REALIZADA == 1) {
                            DesregistrarPendiente2(item);
                            item.MAP_SELECTED = 0;
                        }
                    }
                }
            }
            self.executeNode("applyfilter");
        </script>
    </action>
</checkAll>
```

---

## 8. Acciones dentro de Eventos

### 8.1 runscript - Ejecutar JavaScript

La acción `runscript` ejecuta un bloque de código JavaScript.

```xml
<action name="runscript">
    <param name="parametro"/>
    <script language="javascript">
        // Código JavaScript con acceso a 'parametro'
        ui.showToast("Parametro: " + parametro);
    </script>
</action>
```

Un evento puede contener multiples acciones `runscript` que se ejecutan en orden:

```xml
<before-edit>
    <action name="runscript">
        <script language="javascript">
            ui.getView(self).bind("SCVB", "onclick", "testClick");
        </script>
    </action>
    <action name="runscript">
        <script language="javascript">
            self.MAP_GROUP = 1;
            self.MAP_TOTAL_PAGES = 3;
        </script>
    </action>
</before-edit>
```

### 8.2 setval - Establecer valor a campo

La acción `setval` asigna un valor a un campo del objeto actual sin necesidad de JavaScript.

```xml
<action name="setval" field="CAMPO" value="valor"/>
<action name="setval" field="FECHA" value="##NOW_TIME##"/>
<action name="setval" field="MAP_IDENTIFICADOR" value="##DEVICEID##"/>
```

**Ejemplo real** (del proyecto EspecialDatosOnline):

```xml
<before-edit show-wait-dialog="false">
    <action name="setval" field="MAP_IDENTIFICADOR" value="##DEVICEID##"/>
    <action name="runscript">
        <script language="javascript">
            if (ComprobarConexion() == 1) {
                // continuar...
            }
        </script>
    </action>
</before-edit>
```

### 8.3 Macros en setval: ##NOW_TIME##, ##NOW_DATE##

Las macros del sistema se pueden usar como valores en `setval`:

| Macro | Descripción | Ejemplo de valor |
|-------|-------------|------------------|
| `##NOW_TIME##` | Fecha y hora actual | `2024-01-15 14:30:00` |
| `##NOW_DATE##` | Fecha actual sin hora | `2024-01-15` |
| `##USERID##` | ID del usuario logueado | `1` |
| `##DEVICEID##` | ID único del dispositivo | `abc123def456` |
| `##MID##` | MID del dispositivo | `device_mid_value` |
| `##VERSION##` | Versión de la aplicación | `1.0.0` |
| `##FRAME_VERSION##` | Versión del framework XOne | `4.8.1.33` |
| `##DEVICE_OS##` | Sistema operativo | `android` o `ios` |
| `##DEVICE_MODEL##` | Modelo del dispositivo | `Pixel 6` |

> **Referencia cruzada:** Para la lista completa de macros del sistema, consultar el tópico 03 sobre la API JavaScript.

---

## PARTE 2: PATRONES DE DISENO

## 9. Patrones de Navegación

### 9.1 Pantalla de Login

Plantilla mínima de coll de login (el framework la muestra automáticamente al arrancar la app cuando no hay sesión activa; tras un `appData.logout()` también vuelve a esta pantalla).

```xml
<coll name="Login" title="Iniciar Sesion"
      notab="true" show-toolbar="false">

    <create>
        <script>
            self.MAP_EMAIL = "";
            self.MAP_PASSWORD = "";
        </script>
    </create>

    <group name="grpPrincipal" id="1" class="groupNoTab">
        <frame name="frmFormulario" width="100%" bgcolor="#FFFFFF">
            <prop name="MAP_EMAIL" type="T" visible="7"
                  width="90%" height="56p" align="center"
                  hint="tu@email.com"/>
            <prop name="MAP_PASSWORD" type="X" visible="7"
                  width="90%" height="56p" align="center"
                  hint="Tu contraseña"/>
            <prop name="btnLogin" type="B" visible="7"
                  width="90%" height="56p" align="center" tmargin="30p"
                  title="Iniciar Sesion"
                  onclick="realizarLogin();" />
        </frame>
    </group>

    <onback>
        <script>
            cerrarPantalla();
        </script>
    </onback>
</coll>
```

### 9.2 Lista -> Detalle (maestro-detalle)

Patron para navegar de una lista a los detalles de un registro seleccionado.

**Coleccion lista con selecteditem:**

```xml
<coll name="ListaProductos" sql="SELECT * FROM ##PREF##Productos"
      loadall="true">
    <group name="General" id="1">
        <prop name="MAP_NOMBRE" type="T" visible="4"/>
        <prop name="MAP_PRECIO" type="N2" visible="4"/>
    </group>

    <selecteditem refresh="false" show-wait-dialog="false">
        <action name="runscript">
            <script language="javascript">
                ui.openEditView(self);
            </script>
        </action>
    </selecteditem>
</coll>
```

**Content embebido en la pantalla padre:**

```xml
<prop name="@listaProductos" type="Z" contents="listaProductos"
      width="100%" height="70%" viewmode="recyclerview"/>
<contents name="listaProductos" src="ListaProductos"/>
```

### 9.3 Menu con tarjetas

Patron de menu principal con tarjetas de acceso rápido.

```xml
<coll name="MenuPrincipal" special="true" notab="true">
    <group name="grpPrincipal" id="1" class="groupNoTab">
        <frame name="frmHeader" width="100%" height="120p" bgcolor="#1565C0">
            <prop name="lblTitulo" type="L" visible="7"
                  width="100%" height="40p" align="center"
                  forecolor="#FFFFFF" fontsize="20" title="Menu Principal"/>
        </frame>

        <frame name="frmTarjetas" width="100%" scroll="true" tmargin="10p">
            <!-- Tarjeta 1 -->
            <frame name="frmTarjeta1" width="47%" height="150p"
                   lmargin="2%" tmargin="10p" bgcolor="#FFFFFF"
                   border-corner-radius="12" framebox="true"
                   onclick="javascript:abrirModulo('Inventario');">
                <prop name="imgTarjeta1" type="IMG" visible="7"
                      width="48p" height="48p" align="center" tmargin="20p"
                      src="./icons/ic_inventory.png"/>
                <prop name="lblTarjeta1" type="L" visible="7"
                      width="100%" height="30p" align="center" tmargin="10p"
                      fontsize="14" title="Inventario"/>
            </frame>

            <!-- Tarjeta 2 -->
            <frame name="frmTarjeta2" width="47%" height="150p"
                   lmargin="2%" tmargin="10p" newline="false"
                   bgcolor="#FFFFFF" border-corner-radius="12" framebox="true"
                   onclick="javascript:abrirModulo('Pedidos');">
                <prop name="imgTarjeta2" type="IMG" visible="7"
                      width="48p" height="48p" align="center" tmargin="20p"
                      src="./icons/ic_orders.png"/>
                <prop name="lblTarjeta2" type="L" visible="7"
                      width="100%" height="30p" align="center" tmargin="10p"
                      fontsize="14" title="Pedidos"/>
            </frame>
        </frame>
    </group>
</coll>
```

### 9.4 Navegación con pestanas (group-swipe)

```xml
<coll name="PantallaConTabs" special="true" group-swipe="true">
    <group name="HEADER" id="10" class="groupfixed_header">
        <frame name="frmtitulo" class="frmsuperior">
            <prop name="MENU" type="L" title="MI PANTALLA"/>
        </frame>
    </group>

    <group name="Tab1" id="1" onfocus="ExecuteNode(onfocusgrupo(1))">
        <!-- Contenido pestana 1 -->
    </group>

    <group name="Tab2" id="2" onfocus="ExecuteNode(onfocusgrupo(2))">
        <!-- Contenido pestana 2 -->
    </group>

    <group name="Tab3" id="3" onfocus="ExecuteNode(onfocusgrupo(3))">
        <!-- Contenido pestana 3 -->
    </group>

    <onfocusgrupo show-wait-dialog="false">
        <action name="runscript">
            <param name="index"/>
            <script language="javascript">
                self.MAP_GROUP = index;
            </script>
        </action>
    </onfocusgrupo>

    <before-edit>
        <action name="runscript">
            <script language="javascript">
                self.MAP_GROUP = 1;
                self.MAP_TOTAL_PAGES = 3;
            </script>
        </action>
    </before-edit>
</coll>
```

### 9.5 Drawer lateral

```xml
<coll name="PantallaConDrawer" notab="true"
      ondraweropened="onDrawerOpened(e);"
      ondrawerclosed="onDrawerClosed(e);">

    <group name="Drawer" id="999"
           width="60%" drawer-orientation="left" bgcolor="#FFFFFF">
        <frame name="header_drawer" width="100%" height="25%"
               bgcolor="#2B3E51" align="bottom">
            <prop name="lblUsuario" type="L" visible="7"
                  forecolor="#FFFFFF" title="Nombre Usuario"/>
        </frame>
        <prop name="btnOpcion1" type="B" visible="7"
              width="100%" height="60p" title="Inventario"
              onclick="javascript:abrirModulo('Inventario');"/>
        <prop name="btnOpcion2" type="B" visible="7"
              width="100%" height="60p" title="Pedidos"
              onclick="javascript:abrirModulo('Pedidos');"/>
    </group>

    <group name="Contenido" id="1">
        <!-- Contenido principal -->
    </group>
</coll>
```

### 9.6 Volver atrás con confirmacion

```xml
<onback show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            var ok = ui.msgBox("Desea salir sin guardar?", "Confirmar", 4);
            if (ok == 6) {
                ui.getView(self).exit();
            }
        </script>
    </action>
</onback>
```

---

## 10. Patrones de Datos

### 10.1 CRUD completo (crear, leer, actualizar, eliminar)

**Crear:**

```javascript
var coll = appData.getCollection("Productos");
var obj = new Productos({
    NOMBRE: "Producto nuevo",
    PRECIO: 29.99,
    ACTIVO: 1,
    FECHA_ALTA: new Date()
});
coll.addItem(obj);
obj.save();
ui.openEditView(obj); // Abrir en edición
```

**Leer (lista con selecteditem + openEditView):**

```xml
<selecteditem refresh="false" show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            ui.openEditView(self);
        </script>
    </action>
</selecteditem>
```

**Actualizar (formulario con save):**

```javascript
// Dentro de un evento custom "guardar"
self.NOMBRE = self.MAP_NOMBRE;
self.PRECIO = self.MAP_PRECIO;
self.FECHA_MOD = new Date();
self.save();
ui.showToast("Guardado correctamente");
ui.getView(self).exit();
```

**Eliminar (confirmar + deleteItem):**

```xml
<eliminar show-wait-dialog="false" refresh="true">
    <action name="runscript">
        <script language="javascript">
            var ok = ui.msgBox("Desea eliminar el registro seleccionado?",
                "Aviso", 4);
            if (ok === 6) {
                var CollCal = appData.getCollection("ContentdatosCalendario");
                CollCal.deleteItem(self.MAP_IDTAREASELECTED.toString());
                self.MAP_IDTAREASELECTED = 0;
                CollCal = null;
                ui.showToast("Elemento borrado correctamente.");
            } else {
                ui.showToast("Se ha cancelado la acción.");
            }
        </script>
    </action>
</eliminar>
```

### 10.2 Maestro-detalle con contents

**XML del maestro con content embebido:**

```xml
<frame name="c1" width="98%" height="78%"
       framebox="true" border-corner-radius="10" lmargin="1%">
    <prop name="MAP_content1" height="96%" type="Z"
          contents="content1" forceonchange="true" bgcolor="#FFFFFF"
          onchange="refresh(@content1)"/>
    <contents name="content1" src="ContentDatos"/>
</frame>
```

**Agregar item al content (ejemplo real de EspecialContents):**

```xml
<nuevo show-wait-dialog="false" refresh="false">
    <action name="runscript">
        <script language="javascript">
            var coll = self.getContents("content1");
            var obj = coll.createObject();
            obj.setValue("ID", MAP_COUNTER_EXT);
            obj.NOMBRE = "Hola " + MAP_COUNTER_EXT.toString();
            obj.DIRECCION = "dirección " + MAP_COUNTER_EXT.toString();
            obj.IMAGEN = "campanon.jpg";
            MAP_COUNTER_EXT = MAP_COUNTER_EXT + 1;
            let view = ui.getView(self);
            view.MAP_content1.addItem(obj);
        </script>
    </action>
</nuevo>
```

### 10.3 Filtrado dinámico de listas

**Ejemplo real** (del proyecto EspecialContents):

```xml
<buscar show-wait-dialog="false" refresh="false">
    <action name="runscript">
        <param name="param"/>
        <script language="javascript">
            if (param == "1") {
                if (self.MAP_FILTRO.length == 0) {
                    self.getContents("content4").setFilter("");
                } else {
                    self.getContents("content4").setFilter(
                        "NOMBRE like '%" + self.MAP_FILTRO.toString()
                        + "%' OR DIRECCION like '%"
                        + self.MAP_FILTRO.toString() + "%'"
                    );
                }
            }
            self.getContents("content4").unlock();
            self.getContents("content4").loadAll();
            self.getContents("content4").lock();
            ui.getView(self).refresh("@content4");
        </script>
    </action>
</buscar>
```

**Filtro en XML con macros de campo:**

```xml
<contents name="ContentDatosFiltroMultiseleccion"
          src="ContentDatosFiltroMultiseleccion"
          filter="((t1.MARCADO=1 AND 1=##FLD_MAP_BUSCAR_MARCADOS##)
                  OR (t1.MARCADO=0 AND 1=##FLD_MAP_BUSCAR_NOMARCADOS##))
                  AND (ifnull(t1.NOMBRE,'') LIKE ##FLD_MAP_BUSCAR_TEXT##
                  OR ifnull(t1.DIRECCION,'') LIKE ##FLD_MAP_BUSCAR_TEXT##)"/>
```

### 10.4 Busqueda en tiempo real con ontextchanged

```xml
<prop name="MAP_BUSCAR_TEXT"
      ontextchanged="javascript:FiltraMarcados(e);"
      labelwidth="0" text-border="true" type="T"
      width="98%" height="60p" tooltip="Texto a buscar"/>
```

```javascript
function FiltraMarcados(e) {
    self.MAP_BUSCAR_TEXT = e.newText;
    self.executeNode("applyfilter");
}
```

```xml
<applyfilter>
    <action name="runscript">
        <script language="javascript">
            self.getContents("ContentDatosFiltroMultiseleccion").clear();
            self.getContents("ContentDatosFiltroMultiseleccion").loadAll();
            ui.refresh("@ContentDatosFiltroMultiseleccion");
        </script>
    </action>
</applyfilter>
```

### 10.5 Ordenamiento ASC/DESC

```javascript
if (self.MAP_ORDEN == "ASC") {
    self.MAP_ORDEN = "DESC";
    self.MAP_BTORDEN = "sortZA.png";
    self.MAP_BTORDENCLICK = "sortZA_click.png";
} else {
    self.MAP_ORDEN = "ASC";
    self.MAP_BTORDEN = "sortAZ.png";
    self.MAP_BTORDENCLICK = "sortAZ_click.png";
}
self.getContents("content4").sort = "NOMBRE " + self.MAP_ORDEN.toString();
self.getContents("content4").unlock();
self.getContents("content4").loadAll();
self.getContents("content4").lock();
ui.getView(self).refresh("@content4,BTORDENAR");
```

### 10.6 Multiseleccion en lista

**XML con checkbox en cada fila:**

```xml
<prop name="MAP_BUSCAR_MARCADOS" title="Done" labelwidth="5"
      type="NC" width="49%" height="60p"/>
<prop name="MAP_BUSCAR_NOMARCADOS" title="Not done" labelwidth="8"
      type="NC" width="49%" height="60p" newline="false"/>

<prop name="MAP_DONE_PENDIENTES_BT" title="Marcar seleccionados"
      method="Executenode(checkAll(1))" type="B" width="48%"/>
<prop name="MAP_NOTDONE_PENDIENTES_BT" title="Desmarcar seleccionados"
      method="Executenode(checkAll(0))" type="B" width="48%" newline="false"/>
```

### 10.7 Paginación

XOne carga datos de forma paginada por defecto. Para controlar la paginación:

```xml
<!-- Desactivar paginacion (cargar todo) -->
<coll name="MiColeccion" page-limit-off="1" loadall="true">

<!-- O usar loadAll desde script -->
```

```javascript
var coll = self.getContents("miContent");
coll.clear();
coll.loadAll();
```

---

## 10A. Patrones Críticos de Código

### 10A.1 Patron lock/unlock para escritura en colecciones

**Regla fundamental:** Siempre usar `unlock()` antes de modificar y `lock()` en un bloque `finally` para garantizar que la coleccion se bloquea incluso si hay error.

```javascript
function agregarItem(nombreColeccion, datos) {
    var coll = appData.getCollection(nombreColeccion);
    try {
        coll.unlock();
        var newObj = coll.createObject();
        for (var key in datos) {
            if (datos.hasOwnProperty(key)) {
                newObj[key] = datos[key];
            }
        }
        coll.addItem(newObj);
        newObj.save();
        return true;
    } catch(error) {
        ui.showToast("Error: " + error.message);
        return false;
    } finally {
        coll.lock();
    }
}
```

**Para contents embebidos:**

```javascript
var content = self.getContents("content4");
try {
    content.unlock();
    content.loadAll();
    // ... modificar datos ...
} finally {
    content.lock();
}
ui.getView(self).refresh("@content4");
```

### 10A.2 Patron startBrowse/endBrowse para iteracion

**Regla:** `startBrowse()`/`endBrowse()` solo son necesarios cuando vas a **iterar** la coleccion (recorrer registros con `moveNext()`/`movePrevious()`). Abren un cursor en BD que hay que cerrar siempre en un `finally`.

**Cómo se itera correctamente:**

- `startBrowse()` ya deja el cursor en el **primer** item — no hace falta `moveFirst()` después.
- `getCurrentItem()` devuelve el `dataobject` de la fila actual.
- `moveNext()` devuelve `boolean`: `true` si pudo avanzar, `false` cuando ya no hay más filas. **No existe `coll.eof()`** en el JS API.
- **El objeto devuelto por `getCurrentItem()` es efímero**: el mismo objeto se reutiliza en el siguiente `moveNext()`, su contenido se reemplaza. No guardes la referencia en una variable para usarla más tarde; lee lo que necesites en la iteración o haz una copia (p.ej. con `JSON.stringify`/`JSON.parse` o copiando campo a campo en un objeto plano).
- `coll.MAP_XXX` **no** lee del item actual: las colecciones no exponen campos del objeto; siempre acceder vía `coll.getCurrentItem().MAP_XXX`.

```javascript
function listarUsuariosActivos() {
    var coll = appData.getCollection("Usuarios");
    var lista = [];
    coll.startBrowse();
    try {
        var obj = coll.getCurrentItem();
        while (obj != null) {
            // Copia el campo (no guardes obj — se reutiliza en el siguiente moveNext)
            lista.push(obj.MAP_LOGIN);
            if (!coll.moveNext()) break;
            obj = coll.getCurrentItem();
        }
    } finally {
        coll.endBrowse();
    }
    return lista;
}
```

**No requieren `startBrowse`:**

- `findObject(criteria)` y `findAllObjects(criteria)` — ejecutan su propia SQL independiente del cursor.
- `get(index)` / `getItem(index)` / `getItem(field, value)` — acceso directo sin cursor.
- `loadAll()` seguido de `getCount()` + `get(i)` — `loadAll` carga la lista en memoria y se accede por índice.

```javascript
// CORRECTO: findObject NO necesita startBrowse/endBrowse
function obtenerUsuario(userId) {
    var coll = appData.getCollection("Usuarios");
    var escapado = cstr(userId).replace(/'/g, "''");
    return coll.findObject("LOGIN='" + escapado + "'");
}
```

### 10A.3 Patron filtro con restauracion

Siempre guardar y restaurar el filtro original en un bloque `finally`:

```javascript
function procesarDatosFiltrados(coll, filtro) {
    var filtroOriginal = coll.getFilter();
    try {
        coll.setFilter(filtro);
        coll.loadAll();
        var count = coll.count();
        // ... procesar datos filtrados ...
        return count;
    } finally {
        coll.setFilter(filtroOriginal);
    }
}
```

### 10A.4 Patron GPS: iniciar, leer, detener

```javascript
function obtenerPosicionGPS() {
    ui.startGps();

    var lat = ui.getGpsLatitude();
    var lng = ui.getGpsLongitude();

    if (lat != 0 && lng != 0) {
        self.MAP_LATITUD = lat;
        self.MAP_LONGITUD = lng;
        ui.refresh("MAP_LATITUD,MAP_LONGITUD");
    }
}
```

**GPS con callback para tracking continuo:**

```javascript
function iniciarTracking() {
    var jsParams = {
        nodeName: "callbackgps",
        timeBetweenUpdates: 10000,
        minimumMetersDistanceRange: 10,
        foreground: true,
        title: "Mi App GPS",
        text: "Rastreando ubicación..."
    };
    ui.startGps(jsParams);
}

function detenerTracking() {
    ui.stopGps();
}
```

**GPS con variables de empresa para compartir coordenadas:**

```javascript
function GetPosGPS(tipo, auxcollobj) {
    var latitud = 0, longitud = 0;
    ui.startGps();

    var collGPS = appData.getCollection("ContentConectarGPS");
    collGPS.startBrowse();
    var x = collGPS.getCurrentItem();
    if (typeof x !== "undefined" && x !== null) {
        if (x.STATUS == 1 && x.HGPS.length > 0) {
            if (x.LATITUD !== "") latitud = parseFloat(x.LATITUD);
            if (x.LONGITUD.length > 0) longitud = parseFloat(x.LONGITUD);
        }
    }

    // Guardar en variable global
    appData.getCurrentEnterprise().setVariable("LATITUD", latitud);
    appData.getCurrentEnterprise().setVariable("LONGITUD", longitud);
}
```

### 10A.5 Patron de chat/mensajeria (resumen)

El chat en XOne se implementa con 4 colecciones: pantalla principal, lista de conversaciones, usuarios y mensajes. Patron clave:

```javascript
function enviarMensaje(obj, tipo) {
    if (obj.MAP_MENSAJE.length > 0 || tipo > 0) {
        var contentChatear = obj.getContents("ContentChatear");
        try {
            contentChatear.lock();
            var msgObj = contentChatear.createObject();
            contentChatear.addItem(msgObj);
            msgObj.IDCHAT = obj.MAP_IDCHAT;
            msgObj.USUARIO = appData.getGlobalMacro("##MACRO##");
            msgObj.TIPO = tipo;
            msgObj.FECHA = new Date();
            if (tipo === 0) {
                msgObj.MENSAJE = obj.MAP_MENSAJE;
                obj.MAP_MENSAJE = "";
            }
            msgObj.save();
        } finally {
            contentChatear.unlock();
        }
        ui.refresh("ContentChatear", "MAP_MENSAJE");
    }
}
```

**Atributo clave para chat:** `start-from-bottom="true"` en el prop del content para que los mensajes se muestren desde abajo (estilo WhatsApp).

### 10A.6 Patron de dialogo modal (coleccion como modal)

Abrir una coleccion como dialogo modal usando `ui.openEditView()`:

```javascript
function abrirDialogoModal() {
    var coll = appData.getCollection("MiDialogo");
    var obj = new MiDialogo({ MAP_TITULO: "Titulo del dialogo", MAP_MENSAJE: "Contenido" });
    coll.addItem(obj);
    ui.openEditView(obj);
}
```

**Alternativa con frame flotante y modal:**

```xml
<frame name="frmModal"
       animation-in-delay="250" animation-out-delay="250"
       animation-in="##RIGHT_IN##" animation-out="##LEFT_OUT##"
       disablevisible="MAP_VERMODAL=0"
       bgcolor="#ffffff" modal="true" floating="true"
       top="0" left="0" width="100%" height="100%">
    <!-- Contenido del modal -->
    <prop name="btnCerrar" type="B" title="Cerrar"
          onclick="self.MAP_VERMODAL=0; ui.refresh('frmModal');"/>
</frame>
```

### 10A.7 Patron custom msgbox (coleccion como msgbox)

Usar una coleccion como cuadro de dialogo personalizado en lugar del `ui.msgBox()` nativo:

```javascript
function userMsgBox(title, msg, type) {
    var collMsgBox = appData.getCollection("EspecialMsgbox").createClone();
    var objMsgBox = collMsgBox.createObject();
    collMsgBox.addItem(objMsgBox);
    objMsgBox.MAP_TITULO = title;
    objMsgBox.MAP_MENSAJE = msg;
    objMsgBox.MAP_TIPO = type;
    var nResult = ui.msgBox(objMsgBox);
    return nResult;
}
```

**La coleccion del msgbox usa atributos especiales:**
- `cancelable="false"` - No se puede cerrar pulsando fuera
- `cancelable-outside="false"` - No se puede cerrar tocando fuera
- `button-option="10"` en el botón OK, `button-option="1"` en SI, `button-option="2"` en NO
- `height="-2"` para altura automática basada en contenido

### 10A.8 Patron wizard (formulario multi-paso con groups)

Usar `group-swipe="true"` y grupos numerados para crear un asistente paso a paso:

```xml
<coll name="FormularioWizard" special="true" group-swipe="true">
    <group name="HEADER" id="10" class="groupfixed_header">
        <frame name="frmtitulo" class="frmsuperior">
            <prop name="MENU" type="L" title="Formulario"/>
            <prop name="MAP_LAST" type="B" img="atras.png"
                  method="ExecuteNode(ir(-1))"
                  disablevisible="MAP_GROUP=1"/>
            <prop name="MAP_NEXT" type="B" img="siguiente.png"
                  method="ExecuteNode(ir(1))"
                  disablevisible="MAP_GROUP=MAP_TOTAL_PAGES"
                  newline="false"/>
        </frame>
    </group>

    <group name="Paso1" id="1" onfocus="ExecuteNode(onfocusgrupo(1))">
        <!-- Datos personales -->
    </group>
    <group name="Paso2" id="2" onfocus="ExecuteNode(onfocusgrupo(2))">
        <!-- Dirección -->
    </group>
    <group name="Paso3" id="3" onfocus="ExecuteNode(onfocusgrupo(3))">
        <!-- Confirmación -->
    </group>

    <before-edit>
        <action name="runscript">
            <script language="javascript">
                self.MAP_GROUP = 1;
                self.MAP_TOTAL_PAGES = 3;
            </script>
        </action>
    </before-edit>

    <onfocusgrupo show-wait-dialog="false">
        <action name="runscript">
            <param name="index"/>
            <script language="javascript">
                self.MAP_GROUP = index;
            </script>
        </action>
    </onfocusgrupo>

    <ir show-wait-dialog="false">
        <action name="runscript">
            <param name="direccion"/>
            <script language="javascript">
                let nuevo = parseInt(self.MAP_GROUP) + parseInt(direccion);
                if (nuevo >= 1 && nuevo <= self.MAP_TOTAL_PAGES) {
                    ui.showGroup(nuevo);
                }
            </script>
        </action>
    </ir>
</coll>
```

**Elementos clave del patron wizard:**
- `group-swipe="true"` habilita deslizar entre pasos
- `MAP_GROUP` rastrea el paso actual
- `MAP_TOTAL_PAGES` almacena el número total de pasos
- `disablevisible="MAP_GROUP=1"` oculta el botón "Atrás" en el primer paso
- `disablevisible="MAP_GROUP=MAP_TOTAL_PAGES"` oculta "Siguiente" en el último paso

---

## 11. Patrones de UI

### 11.1 Formulario con validación

```javascript
function validarFormulario() {
    if (!self.MAP_NOMBRE || self.MAP_NOMBRE.length == 0) {
        ui.showToast("El nombre es obligatorio");
        return false;
    }
    if (!self.MAP_EMAIL || self.MAP_EMAIL.length == 0) {
        ui.showToast("El email es obligatorio");
        return false;
    }
    return true;
}

function guardarFormulario() {
    if (!validarFormulario()) return;
    self.save();
    ui.showToast("Guardado correctamente");
    ui.getView(self).exit();
}
```

### 11.2 Tarjeta de información (Card)

```xml
<frame name="frmCard" width="96%" height="auto" lmargin="2%"
       tmargin="10p" bgcolor="#FFFFFF" border-corner-radius="12"
       framebox="true" forecolor="#E0E0E0" border-width="1">
    <frame name="frmCardHeader" width="100%" height="48p" bgcolor="#F5F5F5">
        <prop name="lblCardTitulo" type="L" visible="7"
              width="100%" height="48p" lmargin="16p"
              fontsize="16" fontbold="true" forecolor="#212121"
              title="Título de la Tarjeta"/>
    </frame>
    <prop name="lblCardContenido" type="L" visible="7"
          width="96%" lmargin="2%" tmargin="12p" bmargin="12p"
          forecolor="#757575" fontsize="14" label-wrap="true"
          title="Contenido de la tarjeta con descripción detallada"/>
</frame>
```

### 11.3 Dashboard con estadisticas

```xml
<frame name="frmDashboard" width="100%" scroll="true">
    <!-- Fila de estadisticas -->
    <frame name="frmStats" width="96%" lmargin="2%" tmargin="10p">
        <frame name="frmStat1" width="31%" height="100p"
               bgcolor="#E3F2FD" border-corner-radius="8">
            <prop name="lblStatNum1" type="L" visible="7"
                  width="100%" align="center" tmargin="15p"
                  fontsize="24" fontbold="true" forecolor="#1565C0"
                  title="##FLD_MAP_TOTAL_PENDIENTES##"/>
            <prop name="lblStatLabel1" type="L" visible="7"
                  width="100%" align="center"
                  fontsize="12" forecolor="#1565C0"
                  title="Pendientes"/>
        </frame>
        <frame name="frmStat2" width="31%" height="100p"
               lmargin="3%" newline="false"
               bgcolor="#E8F5E9" border-corner-radius="8">
            <prop name="lblStatNum2" type="L" visible="7"
                  width="100%" align="center" tmargin="15p"
                  fontsize="24" fontbold="true" forecolor="#2E7D32"
                  title="##FLD_MAP_TOTAL_COMPLETADOS##"/>
            <prop name="lblStatLabel2" type="L" visible="7"
                  width="100%" align="center"
                  fontsize="12" forecolor="#2E7D32"
                  title="Completados"/>
        </frame>
    </frame>
</frame>
```

### 11.4 Item de lista con icono + textos

```xml
<!-- Dentro de la coleccion del content (visible="4" para modo lista) -->
<group name="General" id="1">
    <prop name="IMAGEN" type="IMG" width="115p" height="118p"
          visible="4" tmargin="2p" lmargin="0"/>
    <frame name="frm1" newline="false" width="600p" lmargin="5p" height="120p">
        <prop name="MAP_NOMBRE_GRID" type="T" class="classgrid"/>
        <prop name="MAP_DIRECCION_GRID" class="classgrid" type="T"
              text-forecolor="#666666" textfont-size="5"
              lines="2" fixed-lines="true"/>
    </frame>
</group>
```

### 11.5 Botón flotante (FAB)

```xml
<frame name="floatadd1" top="920p" left="510p"
       width="290p" height="90p" floating="true">
    <prop name="BTADD1" type="B" visible="1" labelwidth="0"
          method="ExecuteNode(nuevo)" width="75p"
          img="add.png" imgsel="add_click.png"/>
</frame>
```

### 11.6 Modal/Overlay

```xml
<frame name="frmnuevochat"
       animation-in-delay="250" animation-out-delay="250"
       animation-in="##RIGHT_IN##" animation-out="##LEFT_OUT##"
       disablevisible="MAP_VERFLOTANTE=0"
       bgcolor="#ffffff" modal="true" floating="true"
       top="0" left="0" width="100%" height="100%">
    <!-- Contenido del modal -->
    <prop name="MAP_BUSCAR_USUARIO"
          ontextchanged="javascript:AccionesChatEspecial('textoU', e);"
          type="T" visible="1"/>
    <prop name="@nUsuarios" contents="nUsuarios" viewmode="recyclerview"
          type="Z" visible="1" width="100%" height="1061p"/>
    <contents name="nUsuarios" src="UsuariosChat"/>
</frame>
```

### 11.7 Barra de busqueda

```xml
<frame name="frmBuscador" width="98%" lmargin="1%" height="150p"
       tmargin="1%" framebox="true">
    <prop name="MAP_BUSCAR_TEXT"
          ontextchanged="javascript:FiltraMarcados(e);"
          labelwidth="0" text-border="true" type="T"
          lpadding="10p" rpadding="10p"
          width="98%" tmargin="10p" lmargin="1%" height="60p"
          tooltip="Texto a buscar"/>
</frame>
```

### 11.8 Badge de notificación

```xml
<!-- Usar un L con fondo circular como badge -->
<frame name="frmBadge" floating="true" top="10p" left="80p"
       width="24p" height="24p" disablevisible="MAP_NOTIF_COUNT=0">
    <prop name="lblBadge" type="L" visible="7"
          width="24p" height="24p" align="center"
          bgcolor="#FF0000" forecolor="#FFFFFF" fontsize="10"
          border-corner-radius="12"
          title="##FLD_MAP_NOTIF_COUNT##"/>
</frame>
```

### 11.9 Slider de imágenes

```xml
<prop name="ContentsDatosSlide" viewmode="slideview"
      autoslide-delay="5" type="Z"
      width="100%" lmargin="0" height="1160p"
      contents="ContentsDatosSlide"
      onchange="refresh255" forceonchange="true"/>
<contents name="ContentsDatosSlide" src="ContentsDatosSlide"/>
```

### 11.10 Vista de chat (burbujas)

**Ejemplo real** (del proyecto EspecialChat):

```xml
<frame name="frmChatear" tmargin="0" width="100%" height="937p"
       imgbk="##FLD_MAP_FOTO_FONDO##">
    <frame name="frmContent" tmargin="0" width="100%" height="937p">
        <prop name="Chatear" bgcolor="#00000000" contents="Chatear"
              edit-inrow="true" type="Z" width="100%" height="100%"/>
        <contents name="Chatear" src="Chatear"
                  filter="IDCHAT=##FLD_MAP_CHATSEL##"/>
    </frame>
</frame>

<!-- Barra inferior con input y botones -->
<frame name="frmMenuW" bgcolor="#ffffff" align="center"
       width="100%" height="100p">
    <prop name="MAP_ADDOTHER" img="icon_more.png" type="B"
          width="100p" height="100p"/>
    <prop name="MAP_TITLE"
          onfocuschanged="javascript:AccionesChatEspecial('foco', e);"
          ontextchanged="javascript:AccionesChatEspecial('textoChange', e);"
          type="T" visible="1" newline="false"
          width="424p" height="80p" tmargin="10p"/>
    <prop name="MAP_ADDTEXT"
          method="executenode(AccionesChatEspecial('enviar'))"
          img="icon_send.png" type="B" width="100p" height="100p"
          newline="false" disablevisible="MAP_SHOWADDTEXT=0"/>
</frame>
```

---

## 11A. Patron Control por Voz (TTS + STT)

XOne soporta síntesis de voz (Text-to-Speech) y reconocimiento de voz (Speech-to-Text) nativamente a traves del objeto global `ui`, combinando dos métodos:

- `ui.speak({...})` — el dispositivo "habla" un texto.
- `ui.recognizeSpeech({...})` — el dispositivo "escucha" y te entrega el texto reconocido.

El patron más potente es **encadenar ambos**: hablar primero (pregunta al usuario) y, cuando termine la síntesis, arrancar la escucha (respuesta del usuario). Así se evita que el reconocedor capte la propia voz sintetizada.

### 11A.1 Anatomia de los parámetros

**`ui.speak(params)`**

| Parámetro | Descripción |
| --- | --- |
| `language` | Idioma: `"es"`, `"en"`, ... |
| `text` | Texto que se va a pronunciar. |
| `speechRate` | Ritmo de habla en milisegundos. |
| `onCompleted` | Callback `function()` al terminar de hablar. |

**`ui.recognizeSpeech(params)`**

| Parámetro | Descripción |
| --- | --- |
| `language` | Idioma del reconocedor. |
| `timeoutAfterSilence` | Milisegundos de silencio antes de cerrar la escucha. |
| `characterLimit` | *(Opcional)* Número máximo de caracteres a reconocer. |
| `onRecognize` | `function(sText)` con el texto reconocido. |
| `onError` | `function(nErrorCode, sError)` si hubo error. |
| `onPartialResults` | *(Opcional)* `function(extras)` con resultados parciales. |
| `onEndOfSpeech` | *(Opcional)* `function()` al terminar la locucion del usuario. |

### 11A.2 Patron "preguntar y escuchar" (flujo completo)

```xml
<!-- Botón que lanza la interacción por voz -->
<prop name="MAP_BT_VOZ" type="B" visible="1" title="Preguntar por voz"
      onclick="doSpeakYRecoger('es', '¿Que opción quieres?', self, null);" />

<!-- Icono del micrófono (cambia según el estado) -->
<prop name="MAP_IMGLISTENING" type="IMG" visible="1" width="64p" height="64p"/>
```

```javascript
// Funcion 1: habla la pregunta y encadena la escucha cuando termina el TTS
function doSpeakYRecoger(sLanguage, strText, objSource, objAR) {
    ui.speak({
        language   : sLanguage,
        text       : strText,
        speechRate : 120,
        onCompleted: function() {
            // Cuando el dispositivo ha terminado de hablar, arrancamos el reconocedor.
            // Así el microfono no capta la propia voz sintetizada.
            objSource.MAP_IMGLISTENING = "microRojo.png";   // indicar "escuchando"
            ui.refresh("MAP_IMGLISTENING");
            doRecognize(sLanguage, objSource, objAR);
        }
    });
}

// Funcion 2: escucha, procesa, actualiza UI
function doRecognize(sLanguage, objSource, objAR) {
    ui.recognizeSpeech({
        language: sLanguage,
        timeoutAfterSilence: 10000,

        onRecognize: function(sText) {
            sText = (sText || "").toUpperCase();

            // Caso A: comparar contra opciones predefinidas
            if (objSource.MAP_INITAR == 1 && objAR != null) {
                let idx = 100;
                if      (objAR.MAP_TITLE0.toUpperCase() == sText) idx = 0;
                else if (objAR.MAP_TITLE1.toUpperCase() == sText) idx = 1;
                else if (objAR.MAP_TITLE2.toUpperCase() == sText) idx = 2;
                // ...aquí harias algo con idx...
            } else {
                // Caso B: volcar el texto reconocido en una propiedad
                objSource.MAP_TEXT = sText;
                ui.refreshValue("MAP_TEXT");
            }
        },

        onError: function(nErrorCode, sError) {
            objSource.MAP_IMGLISTENING = "microGris.png";   // restaurar icono
            ui.refresh("MAP_IMGLISTENING");
            // ui.msgBox("Error " + nErrorCode + ": " + sError, "Voz", 0);
        },

        onEndOfSpeech: function() {
            // Restaurar icono al terminar la locucion (aunque el reconocedor
            // aún este procesando). onRecognize se llama después.
            objSource.MAP_IMGLISTENING = "microGris.png";
            ui.refresh("MAP_IMGLISTENING");
        }
    });
}
```

### 11A.3 Solo escuchar (sin TTS previo)

Si solo quieres dictado, se puede usar `recognizeSpeech` directamente, sin `speak`:

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

### 11A.4 Buenas prácticas

- **Siempre** lanzar `recognizeSpeech` desde `onCompleted` de `speak`, nunca antes — evita que el reconocedor oiga la síntesis.
- Gestionar el icono del microfono con una propiedad tipo `MAP_IMGLISTENING` y refrescarla en cada transición de estado (hablando / escuchando / inactivo).
- Para comparar lo dictado con opciones predefinidas, normalizar siempre con `.toUpperCase()` (o `.toLowerCase()`) antes de comparar.
- `timeoutAfterSilence` en ms — valores típicos 5000-10000. Más bajo corta frases largas; más alto introduce latencia.
- El `onError` **siempre** debe restaurar el estado visual del microfono.

### 11A.5 Referencias

- Doc del wiki: `2.-desarrollo-app/2.5.-controles-by-xone/control_por_voz/start.md`
- Referencia de los métodos (objetos complementarios): `ui.speak` y `ui.recognizeSpeech` en la documentación del objeto global `ui`.

---

## 12. Patrones de Integración

### 12.1 Conexión con API REST

```javascript
function consultarAPI(endpoint) {
    var miObjeto = self; // Guardar contexto
    ui.showWaitDialog("Consultando...");

    var request = {
        parameters: {
            connectTimeout: 120000,
            readTimeout: 120000
        },
        headers: {
            "Authorization": "Bearer " + appData.getGlobalMacro("##TOKEN##"),
            "Accept": "application/json"
        }
    };

    $http.get("https://api.ejemplo.com/" + endpoint, request,
        function(sData, headers, nHttpStatusCode) {
            var json = JSON.parse(sData);
            miObjeto.MAP_RESULTADO = json.resultado;
            ui.refresh("MAP_RESULTADO");
            ui.hideWaitDialog();
        },
        function(nError, sErrorDesc) {
            ui.showToast("Error " + nError + ": " + sErrorDesc);
            ui.hideWaitDialog();
        }
    );
}
```

> **Referencia cruzada:** Para la API HTTP completa (`$http`), consultar el tópico 03 sobre la API JavaScript.

### 12.2 GPS y seguimiento en tiempo real

**Iniciar GPS (ejemplo real de EspecialMapa):**

```javascript
var ok = ui.msgBox("Desea acceder al Geoposicionamiento?", "Aviso", 4);
if (ok == 6) {
    appData.getCurrentEnterprise().setVariable("MIUBICACION", 1);
}
if (appData.getCurrentEnterprise().getVariable("MIUBICACION") == 1) {
    ui.startGps();
    PosicionamientoGPS();
}
```

**GPS con callback:**

```javascript
ui.startGps({
    nodeName: "callbackGPS",
    timeBetweenUpdates: 10000,
    minimumMetersDistanceRange: 10,
    foreground: true,
    title: "Mi App GPS",
    text: "Rastreando ubicación..."
});
```

### 12.3 Camara: captura de fotos

```xml
<prop name="MAP_FOTO" type="PH" img-width="48p" img-height="48p"
      height="40%" title="Foto" lmargin="2%"/>
```

La captura se lanza automáticamente al tocar el control `PH`. Para foto de solo lectura:

```xml
<prop name="MAP_FOTOVER" type="PH" locked="true"
      height="40%" title="foto" lmargin="2%"/>
```

### 12.4 Escaneo QR/Barcode

```javascript
ui.scanBarCode({
    onScanned: function(sCode) {
        self.MAP_CODIGO_QR = sCode;
        ui.refresh("MAP_CODIGO_QR");
        ui.showToast("Código: " + sCode);
    },
    onCancelled: function() {
        ui.showToast("Escaneo cancelado");
    }
});
```

### 12.5 Firma digital

```xml
<prop name="MAP_SIGNATURE" img-width="48p" img-height="48p"
      type="DR" readonly="false" height="40%" title="Firma"
      stroke-width="##FLD_MAP_TAMANO_TRAZO##"
      stroke-color="##FLD_MAP_COLOR_TRAZO##"
      bgcolor="##FLD_MAP_COLOR_FONDO##"
      apply-format-to-file="true"
      onchange="refresh(MAP_SIGNATURE)"/>
```

### 12.6 Calendario con eventos

**Ejemplo real** (del proyecto EspecialCalendario):

```xml
<frame name="calendario" width="100%" height="350p">
    <prop name="Calendario" type="Z" calendar-viewmode="week"
          contents="calendario" width="100%" height="100%"
          viewmode="calendarview"
          onchange="refresh" postonchange="refresh"/>
    <contents name="calendario" src="ContentdatosCalendario"/>
</frame>

<!-- Lista de eventos del mes -->
<frame name="calendario2" width="100%" height="360p">
    <prop name="Calendariodatos" type="Z" contents="Calendariodatos"
          width="100%" height="300p"/>
    <contents name="Calendariodatos" src="ContentdatosCalendariolista"
              filter="strftime('%m',##FLD_MAP_FECHA##)=strftime('%m',FECHA)
                      and strftime('%Y',##FLD_MAP_FECHA##)=strftime('%Y',FECHA)"/>
</frame>
```

### 12.7 Gráficos (pie, bar, line)

**Ejemplo real** (del proyecto EspecialGraficos):

```xml
<!-- Gráfico de barras -->
<prop name="@GraficosBarrasDatos" classid="XOneCharts"
      viewmode="barchart" type="Z" contents="GraficosBarrasDatos"
      width="692p" height="500p"/>
<contents name="GraficosBarrasDatos" src="ContentGraficosBarrasDatos"/>

<!-- Gráfico circular -->
<prop name="@GraficosPastelDatos" classid="XOneCharts"
      viewmode="piechart" type="Z" contents="GraficosPastelDatos"
      width="692p" height="500p"/>

<!-- Gráfico de línea de tiempo -->
<prop name="@GraficosLineasTiempoDatos" classid="XOneCharts"
      viewmode="timeserieschart" type="Z"
      contents="GraficosLineasTiempoDatos"
      width="692p" height="500p"/>

<!-- Gráfico de lineas -->
<prop name="@GraficosLineasDatos" classid="XOneCharts"
      viewmode="linechart" type="Z" contents="GraficosLineasDatos"
      width="692p" height="500p"/>
<contents name="GraficosLineasDatos" src="ContentGraficosLineasDatos"
          sort="CATEGORIA,VALOR1,VALOR2,VALOR3"/>

<!-- Gráfico XY -->
<prop name="@GraficosLineasXYDatos" classid="XOneCharts"
      viewmode="xylinechart" type="Z" contents="GraficosLineasXYDatos"
      width="692p" height="500p"/>
```

**ViewModes de gráficos disponibles:**

| viewmode | Descripción |
|----------|-------------|
| `barchart` | Gráfico de barras |
| `3dbarchart` | Gráfico de barras 3D |
| `piechart` | Gráfico circular tipo 1 |
| `piechart2` | Gráfico circular tipo 2 |
| `linechart` | Gráfico de lineas |
| `timeserieschart` | Gráfico de series temporales |
| `xylinechart` | Gráfico de lineas XY |

### 12.8 Mapas con marcadores

**Ejemplo real** (del proyecto EspecialMapa):

```xml
<prop name="MAP_mapa" width="100%" title="Mapa" height="80%"
      type="Z" visible="1" viewmode="mapview"
      mapview-embedded="true" contents="mapaDatos"/>
<contents name="mapaDatos" src="ContentmapaDatos"/>

<prop name="boton0it" type="B" title="showStreetView"
      onclick="javascript:showStreetView('MAP_mapa');"/>
<prop name="boton1it" type="B" title="showMap"
      onclick="javascript:showMap('MAP_mapa');" newline="false"/>
```

### 12.9 Notificaciones push

**Crear notificación local (ejemplo real de EspecialNotificaciones):**

```javascript
ui.showNotification(1, "Titulo", "Esto es una notificación",
    "Aviso de recepcion de datos");

// Eliminar notificación
ui.dismissNotification("1");
```

**Notificación avanzada con botones:**

```javascript
ui.showNotification({
    id: 5000,
    title: "Nueva tarea asignada",
    text: "Tiene una nueva tarea pendiente",
    icon: "app_icon1",
    backgroundColor: "#1976D2",
    sound: "notification.wav",
    cancelable: true,
    dataObject: self,
    nodeName: "callbackNotificacion",
    parameters: '{ "tareaId": "123" }',
    buttons: [{
        id: 5001,
        title: "Responder",
        directReply: true,
        directReplyLabel: "Escriba su respuesta...",
        dataObject: self,
        nodeName: "respuestaCallback"
    }]
});
```

### 12.10 Sincronización con servidor

La sincronización se configura en el nodo `maintenance` de `Empresas`:

```xml
<maintenance>
    <action name="Replica" type="replica"
            frecuency="400" period="X" synchronize="true"/>
    <action name="SincronizarDatos" type="runscript"
            period="S" frecuency="600" auto="true" show="false">
        <script language="javascript">
            sincronizarConServidor();
        </script>
    </action>
</maintenance>
```

---

## 13. Patrones de Seguridad

### 13.1 Login seguro

```javascript
function realizarLogin() {
    if (!validarRequerido(self.MAP_EMAIL, "Email")) return;
    if (!validarRequerido(self.MAP_PASSWORD, "Contraseña")) return;

    ui.showWaitDialog("Iniciando sesion...");

    var collUsuarios = appData.getCollection("Usuarios");
    var usuario = collUsuarios.findObject(
        "LOGIN = '" + self.MAP_EMAIL + "'"
    );

    ui.hideWaitDialog();

    if (usuario) {
        // Verificar contraseña (idealmente hasheada)
        if (usuario.PWD == self.MAP_PASSWORD) {
            appData.setGlobalMacro("##USERID##", usuario.ID);
            appData.setGlobalMacro("##USERNAME##", usuario.NOMBRE);
            ui.showToast("Bienvenido, " + usuario.NOMBRE);
            ui.openEditView("MenuPrincipal");
        } else {
            ui.showToast("Credenciales incorrectas");
        }
    } else {
        ui.showToast("Usuario no encontrado");
    }
}
```

### 13.2 Validación de entrada

```javascript
function validarRequerido(valor, nombre) {
    if (!valor || valor.toString().length == 0) {
        ui.showToast("El campo " + nombre + " es obligatorio");
        return false;
    }
    return true;
}

function validarEmail(email) {
    if (!email) return false;
    return email.indexOf("@") > 0 && email.indexOf(".") > 0;
}

function validarNumeroPositivo(valor, nombre) {
    if (isNaN(valor) || valor <= 0) {
        ui.showToast(nombre + " debe ser un número positivo");
        return false;
    }
    return true;
}
```

### 13.3 SQL parameterizado

Para evitar inyeccion SQL al construir filtros:

```javascript
// INCORRECTO - vulnerable a inyeccion SQL
coll.setFilter("NOMBRE = '" + self.MAP_BUSCAR + "'");

// MEJOR - sanitizar la entrada
var busqueda = self.MAP_BUSCAR.toString().replace(/'/g, "''");
coll.setFilter("NOMBRE LIKE '%" + busqueda + "%'");
```

### 13.4 Encriptación de datos sensibles

```javascript
// Hashear con SHA-256
var hash = crypto.sha256("texto a hashear");

// Cifrar con AES
var cifrado = crypto.encrypt("texto", "clave_secreta", "AES");

// Descifrar
var original = crypto.decrypt(cifrado, "clave_secreta", "AES");

// Base64
var encoded = crypto.encodeBase64("texto");
var decoded = crypto.decodeBase64(encoded);
```

### 13.5 Timeout de sesión

```javascript
// Configurar timeout usando maintenance
// En Empresas (mappings.xne):
// <maintenance>
//     <action name="VerificarSesion" type="runscript"
//             period="S" frecuency="300" auto="true" show="false">
//         <script language="javascript">
//             verificarTimeoutSesion();
//         </script>
//     </action>
// </maintenance>

function verificarTimeoutSesion() {
    var ultimaActividad = appData.getGlobalMacro("##ULTIMA_ACTIVIDAD##");
    var ahora = new Date().getTime();
    var diferencia = ahora - parseInt(ultimaActividad);
    // 30 minutos = 1800000 ms
    if (diferencia > 1800000) {
        ui.showToast("Sesion expirada");
        appData.logout();
    }
}
```

---

## PARTE 3: FAQ - PREGUNTAS FRECUENTES

## 14. FAQ General

### Que es XOne?

XOne es una plataforma de desarrollo de aplicaciones móviles que permite crear apps nativas para Android e iOS desde un único código base. Utiliza archivos XML (.xne) para definir la interfaz, JavaScript para la lógica de negocio y un CSS propietario para los estilos.

### Es XOne multiplataforma?

Si. XOne genera aplicaciones nativas para Android e iOS a partir del mismo código XML, JavaScript y CSS. No es una solución hibrida basada en WebView - genera UIs nativas.

### Necesito saber Java/Swift?

No. XOne abstrae la capa nativa mediante su propio sistema de XML + JavaScript + CSS. Solo necesitas conocer estos tres lenguajes en su variante XOne. Sin embargo, se pueden crear extensiones nativas en la carpeta `native/` si se necesita funcionalidad especifica de la plataforma.

### Como funciona la sincronización?

XOne incluye un sistema de replica integrado que sincroniza datos entre el dispositivo móvil y un servidor. Se configura en el nodo `<maintenance>` de la coleccion `Empresas` en `mappings.xne`. Los datos locales se almacenan en SQLite y se sincronizan según la frecuencia configurada.

### Que base de datos usa XOne?

XOne usa SQLite como base de datos local en el dispositivo. El archivo de base de datos (`gestion.db`) se almacena en la carpeta `bd/` del proyecto. Las tablas se generan automáticamente a partir de las definiciones en los archivos `.xne`.

---

## 15. FAQ XML/UI

### Como hago un layout responsive?

Usa porcentajes para anchos y altos, y puntos (`p`) para margenes y tamaños fijos:

```xml
<frame name="frmResponsive" width="100%" height="auto">
    <prop name="campo1" type="T" width="48%" height="56p"/>
    <prop name="campo2" type="T" width="48%" height="56p" newline="false"/>
</frame>
```

### Como creo un menu con tarjetas?

Ver la sección [9.3 Menu con tarjetas](#93-menu-con-tarjetas) en los patrones de navegación.

### Como oculto/muestro elementos condicionalmente?

Usa el atributo `disablevisible`:

```xml
<!-- Se oculta cuando MAP_MOSTRAR vale 0 -->
<prop name="lblInfo" type="L" disablevisible="MAP_MOSTRAR=0" title="Info"/>

<!-- Se oculta cuando MAP_ESTADO no es ACTIVO -->
<frame name="frmActivo" disablevisible="MAP_ESTADO<>'ACTIVO'">
    <!-- contenido -->
</frame>
```

### Como creo una lista con recyclerview?

```xml
<prop name="@miLista" type="Z" contents="miLista"
      viewmode="recyclerview" width="100%" height="70%"/>
<contents name="miLista" src="MiColeccionDatos"/>
```

### Como hago un combo/selector?

```xml
<!-- Con valores estaticos -->
<prop name="MAP_COMBO_ID" type="T" visible="0"
      mapcol-values="Opcion1, Opcion2, Opcion3" mapfld="DATA"/>
<prop name="COMBO" type="T" visible="1" title="Seleccionar"
      showinline="true" linkedto="MAP_COMBO_ID" linkedfield="DATA"/>

<!-- Con datos de coleccion -->
<prop name="MAP_COMBO_ID2" type="N" visible="0"
      mapcol="MiColeccion" mapfld="ID"/>
<prop name="COMBO2" type="T" visible="1" title="Seleccionar"
      linkedto="MAP_COMBO_ID2" linkedfield="NOMBRE"/>
```

> **Referencia cruzada:** Para más detalles sobre combos y selectores, consultar el tópico 02 sobre estructura XML.

### Como pongo dos elementos en la misma linea?

Usa `newline="false"` en el segundo elemento:

```xml
<prop name="campo1" type="T" width="48%" height="56p"/>
<prop name="campo2" type="T" width="48%" height="56p" newline="false"/>
```

### Como creo un header fijo?

Usa un `<group>` con `class="groupfixed_header"` y `id="10"` (o un id alto):

```xml
<group name="HEADER" id="10" class="groupfixed_header">
    <frame name="frmtitulo" class="frmsuperior">
        <prop name="SALIR" type="B" class="btvolversuper"/>
        <prop name="MENU" type="L" class="tlsuper" title="MI PANTALLA"/>
    </frame>
</group>
```

### Que es visible="7" y por que no visible="true"?

El atributo `visible` usa un bitmask (mascara de bits):

| Valor | Significado |
|-------|-------------|
| `0` | Oculto en todos los modos |
| `1` | Solo en modo edición |
| `2` | Solo en modo lista |
| `4` | Solo en contents (filas) |
| `7` | Visible en todos los modos (1+2+4) |

Por eso `visible="7"` equivale a "siempre visible" y no se usa `true`/`false`.

> **Referencia cruzada:** Para la tabla completa de visibilidad, consultar el tópico 02.

### Como hago un campo de solo lectura?

```xml
<prop name="MAP_NOMBRE" type="T" locked="true" title="Nombre"/>
```

### Diferencia entre onclick y method?

- **`onclick`**: Ejecuta JavaScript directamente. Accede al objeto evento `e`.
- **`method`**: Invoca un nodo de evento definido en la coleccion mediante `ExecuteNode()`.

```xml
<!-- onclick: JS directo -->
<prop name="btn1" type="B" onclick="javascript:miFuncion();"/>

<!-- method: invoca nodo -->
<prop name="btn2" type="B" method="ExecuteNode(miNodo)"/>
```

---

## 16. FAQ JavaScript

### Como accedo a un campo del formulario?

```javascript
// Leer
var nombre = self.MAP_NOMBRE;
var precio = self.MAP_PRECIO;

// Escribir
self.MAP_NOMBRE = "Nuevo valor";
self.MAP_PRECIO = 29.99;

// Acceso dinámico
var campo = "MAP_NOMBRE";
var valor = self[campo];
```

### Como navego a otra pantalla?

```javascript
// Abrir una pantalla (la forma habitual — abre el EditView de un objeto nuevo
// de la coll destino: XOne hace createObject + addItem internamente)
ui.openEditView("NombreColeccion");

// Abrir un objeto EXISTENTE (o uno preparado con propiedades) en edicion
ui.openEditView(objeto);

// Cerrar pantalla actual
ui.getView(self).exit();

// Salir de la app
appData.exit();
```

### Como paso datos entre pantallas?

**Patrón canónico — dataObject + `ui.openEditView()`:** preparar el objeto de la coll destino con los valores deseados y abrirlo en edición.

```javascript
var coll = appData.getCollection("OtraPantalla");
var obj = new OtraPantalla({ MAP_DATO_RECIBIDO: "valor" });
coll.addItem(obj);
ui.openEditView(obj);
```

**Alternativas para datos globales / de sesión** (no para "abrir pantalla con datos"):

```javascript
// Variables en la empresa actual
appData.getCurrentEnterprise().setVariable("MI_DATO", "valor");
var dato = appData.getCurrentEnterprise().getVariable("MI_DATO");

// Macros globales (clave-valor de toda la app)
appData.setGlobalMacro("##MI_MACRO##", "valor");
var dato = appData.getGlobalMacro("##MI_MACRO##");
```

> **Referencia cruzada:** Para la API completa de navegación, consultar el tópico 03.

### Como filtro una coleccion?

```javascript
var coll = self.getContents("miContent");
coll.setFilter("ACTIVO = 1 AND TIPO = 'A'");
coll.clear();
coll.loadAll();
ui.refresh("@miContent");
```

### Como recorro los items de una coleccion?

```javascript
var coll = appData.getCollection("MiColeccion");
coll.loadAll();
var total = coll.getCount();
for (var i = 0; i < total; i++) {
    var item = coll.get(i);
    console.log(item.NOMBRE + " - " + item.PRECIO);
}
```

### Como hago una llamada HTTP?

```javascript
var miObjeto = self; // Guardar contexto
var request = {
    headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer " + token
    },
    data: {
        nombre: "Juan",
        email: "juan@ejemplo.com"
    }
};

$http.post("https://api.ejemplo.com/usuarios", request,
    function(sData, headers, nHttpStatusCode) {
        var resultado = JSON.parse(sData);
        miObjeto.MAP_RESULTADO = resultado.id;
        ui.refresh("MAP_RESULTADO");
    },
    function(nError, sErrorDesc) {
        ui.showToast("Error: " + sErrorDesc);
    }
);
```

### Como obtengo la ubicación GPS?

```javascript
ui.startGps();
var lat = ui.getGpsLatitude();
var lng = ui.getGpsLongitude();
```

O con callback:

```javascript
ui.startGps({
    nodeName: "callbackGPS",
    timeBetweenUpdates: 10000
});
```

### Como tomo una foto?

Usa un `<prop>` de tipo `PH`:

```xml
<prop name="MAP_FOTO" type="PH" height="40%" title="Foto"/>
```

La foto se captura automáticamente al tocar el control. El valor del campo sera el nombre del archivo generado.

### Como ejecuto un evento custom?

```javascript
// Desde JavaScript
self.executeNode("miEvento");

// Con parametros
self.executeNode("miEvento", "parametro1");
```

### Como refresco la pantalla?

```javascript
// Refrescar todo
ui.refresh();

// Refrescar campos especificos
ui.refresh("MAP_NOMBRE,MAP_PRECIO");

// Refrescar solo el valor (sin reconstruir)
ui.refreshValue("MAP_CAMPO");

// Refrescar un content
ui.refresh("@miContent");

// Refrescar un frame y sus hijos
ui.getView(self).refreshAll("frmMiFrame");

// Refrescar fila de content
ui.refreshContentRow("CONTENT_PROP", indice);
```

### Como muestro un mensaje al usuario?

```javascript
// Toast simple
ui.showToast("Mensaje rápido");

// Dialogo OK
ui.msgBox("Mensaje", "Título", 0);

// Dialogo Si/No
var respuesta = ui.msgBox("Desea continuar?", "Confirmar", 4);
if (respuesta == 6) {
    // Pulso Si
}

// Toast personalizado
ui.showToast({
    color: "#4CAF50",
    text: "Exito!",
    textColor: "#FFFFFF",
    duration: "short"
});
```

---

## 17. FAQ CSS

### Por que no funcionan px, em, rem?

El CSS de XOne no es CSS web estándar. Usa su propio sistema de unidades y no reconoce `px`, `em`, `rem`, `vh`, `vw` ni ninguna unidad CSS web.

### Que unidades uso?

| Unidad | Descripción | Ejemplo |
|--------|-------------|---------|
| `p` | Puntos (unidad fija) | `width:200p;` |
| `%` | Porcentaje del contenedor padre | `width:50%;` |
| (sin unidad) | Número entero para ciertos atributos | `fontsize:14;` |

> **Referencia cruzada:** Para la guía completa de CSS XOne, consultar el tópico 04.

### Como aplico multiples clases?

Separar con espacios:

```xml
<prop name="campo" type="T" class="mClassT alineacion color"/>
```

```css
.mClassT {
    width:90%;
    height:50p;
}
.alineacion {
    text-align:center;
}
.color {
    forecolor:#FF0000;
}
```

### Como hago herencia CSS con extends?

```css
.clasePadre {
    width:90%;
    height:50p;
    fontsize:14;
}

.claseHija {
    extends:.clasePadre;
    forecolor:#FF0000;
}
```

### Como reutilizo el header/footer en varias pantallas?

Con el atributo `inherits` a nivel de `<coll>`. Defines una coll `special="true"` que contenga la estructura común (grupos `HEADER` y `FOOTER`, eventos `<onback>`, etc.), y cada pantalla concreta la hereda.

```xml
<!-- Coll padre reutilizable -->
<coll name="layoutsFijos" special="true">
    <group name="HEADER" id="999" class="groupfixed_header">
        <!-- Header comun a todas las pantallas -->
    </group>
    <group name="FOOTER" id="0" class="groupfixed_footer">
        <!-- Footer comun -->
    </group>
</coll>

<!-- Pantalla concreta que hereda -->
<coll name="MiPantalla" inherits="layoutsFijos" special="true">
    <!-- HEADER y FOOTER se heredan automaticamente.
         Solo se declara lo específico de esta pantalla -->
    <group name="Group1" id="1">
        <!-- Contenido propio de MiPantalla -->
    </group>
</coll>
```

La hija puede sobrescribir grupos/frames/props del padre declarandolos con el mismo `name`. Todo lo que no declare se hereda tal cual.

### Como incluyo un fragmento XML desde otro fichero?

Con el nodo `<include-layout>`. Útil para factorizar botoneras, bloques de props o eventos que se repiten.

```xml
<!-- Dentro de una coll -->
<coll name="MiPantalla" ...>
    <group name="General" id="1" />
    <frame name="todo" width="100%" height="100%" />

    <prop group="1" frame="todo" name="MAP_CAMPO1" type="T" visible="1" />
    <include-layout file="MisBotones.xml" group="1" frame="todo" />
    <prop group="1" frame="todo" name="MAP_CAMPO2" type="T" visible="1" />
</coll>
```

El fichero `MisBotones.xml` debe tener raiz `<xml>` y estructura plana:

```xml
<?xml version="1.0" encoding="utf-8"?>
<xml>
    <prop name="MAP_SALIR" type="B" title="Salir"
          method="ExecuteNode(salir)" width="100%" />
    <salir refresh="false">
        <action name="runscript">
            <script language="javascript">
                appData.exit();
            </script>
        </action>
    </salir>
</xml>
```

Los atributos `group` y `frame` del `<include-layout>` actuan como defaults para los props del fichero incluido que no los declaren. La ruta del `file` es relativa a la raiz del proyecto.

### Que diferencia hay entre `extends` (CSS) e `inherits` (coll)?

Actuan en niveles completamente distintos:

- **`extends`** (CSS) vive en archivos `.css` y hace que una clase herede atributos visuales de otra. Solo afecta a estilos.
- **`inherits`** (XML) es un atributo de `<coll>` en un `.xne` y hace que una coleccion herede la estructura completa (groups, frames, props y eventos) de otra coleccion.

Son compatibles: puedes usar los dos al mismo tiempo — una coll puede hacer `inherits` de otra, y sus props usar clases CSS que a su vez hacen `extends`.

### Como pongo transparencia en colores?

Usa el formato `#AARRGGBB` donde `AA` es el valor alfa (00=transparente, FF=opaco):

```css
.fondoSemiTransparente {
    bgcolor:#80000000;  /* Negro con 50% de transparencia */
}

.fondoTransparente {
    bgcolor:#00000000;  /* Completamente transparente */
}
```

---

## 18. FAQ Estructura

### Que va en mappings.xne?

Solo las colecciones `Empresas` y `Usuarios`. Todas las demas colecciones van en archivos `.xne` separados.

```xml
<!-- mappings.xne - SOLO Empresas y Usuarios -->
<coll name="Empresas">
    <prop name="CODIGO" type="N"/>
    <prop name="NOMBRE" type="T" fieldsize="100"/>

    <onlogon>...</onlogon>
    <maintenance>...</maintenance>
</coll>

<coll name="Usuarios">
    <prop name="CODIGO" type="N"/>
    <prop name="NOMBRE" type="T" fieldsize="100"/>
    <prop name="IDEMPRESA" type="N" mapcol="Empresas" mapfld="ID"/>
    <prop name="LOGIN" type="T" fieldsize="50"/>
    <prop name="PWD" type="X" fieldsize="100"/>
</coll>
```

### Donde pongo mis colecciones adicionales?

Cada coleccion adicional va en su propio archivo `.xne` en la raiz del proyecto:

```
MiProyecto/
  mappings.xne          <- Solo Empresas y Usuarios
  EntradaApp.xne        <- Pantalla de entrada
  MenuPrincipal.xne     <- Menu principal
  Productos.xne         <- Coleccion de productos
  DetalleProducto.xne   <- Pantalla de detalle
  ...
```

### Este proyecto tiene ficheros `.xml` además de los `.xne`, ¿los toco?

**No.** Los ficheros `.xml` de colecciones/pantallas son **artefactos generados automáticamente por XOneStudio** a partir del `.xne` correspondiente. Existen porque algunos motores de ejecución del framework aún leen `.xml`, pero se regeneran solos cada vez que XOneStudio procesa el proyecto.

Regla operativa: **solo se trabaja con `.xne`**. Si editas un `.xml` a mano, tu cambio se perdera la proxima vez que XOneStudio regenere el proyecto. Si quieres modificar el comportamiento, modifica el `.xne` correspondiente.

Excepciones:
- `app.xml` (configuración global de la aplicación) SI es fuente: el programador lo edita directamente. No tiene un `.xne` que lo genere.

Horizonte de futuro: el plan es que los `.xml` generados desaparezcan y todo el proyecto quede solo en `.xne`. El trabajo con IA ya se comporta como si esos `.xml` no existieran.

### Por que necesito ROWID en Empresas y Usuarios?

El campo `ROWID` almacena un GUID (identificador único global) de 32 caracteres sin guiones. Es necesario para el sistema de replica/sincronización de XOne, que identifica cada registro de forma única entre dispositivos.

```xml
```

### Como se genera la base de datos?

La base de datos se genera con la herramienta `xone-db-tools`:

```bash
xone-db-tools create-db templates/synthetic_samples/MiProyecto --overwrite
```

Esto analiza todos los archivos `.xne` y crea las tablas correspondientes en `bd/gestion.db` con prefijo `gen_`.

### Donde pongo las imágenes?

- **`icons/`** - Iconos y recursos estáticos (PNG, JPG, SVG)
- **`files/`** - Archivos dinámicos generados por la app (fotos, firmas, documentos)

### Que formato de iconos usa XOne?

**PNG, JPG y SVG**. XOne soporta los tres formatos para iconos y recursos gráficos. El soporte de SVG es **nativo y completo**.

### Como muestro un SVG? Necesito un WebView (`type="WEB"`)?

**No.** Un SVG es una imagen como cualquier otra: se renderiza de forma nativa. Refiérelo con `type="IMG"` (`path="dibujo.svg"`) o con los atributos `img`/`imgbk` de cualquier control, exactamente igual que un PNG. **Nunca** lo metas dentro de un `type="WEB"` ni lo conviertas a PNG: el control `WEB` es solo para contenido web remoto (URLs), y usarlo para una imagen local rompe el escalado y la integración con el control.

---

## 19. Troubleshooting

### 19.1 La pantalla no muestra datos

**Diagnostico:** Los datos existen en BD pero la pantalla aparece vacia.

**Posibles causas y soluciones:**

1. **Falta `loadAll()`** - Los contents no cargan automáticamente:
```javascript
self.getContents("miContent").loadAll();
```

2. **Falta `visible="7"` o `visible="4"`** - Los campos no son visibles en el modo actual.

3. **El content esta bloqueado** - Desbloquear antes de cargar:
```javascript
self.getContents("miContent").unlock();
self.getContents("miContent").loadAll();
self.getContents("miContent").lock();
```

4. **Falta `ui.refresh()`** - Después de modificar datos, refrescar la vista.

### 19.2 El botón no hace nada

**Diagnostico:** El botón no responde al toque.

**Posibles causas y soluciones:**

1. **Falta `visible="1"` o `visible="7"`** - El botón necesita ser visible en modo edición.

2. **Error en el atributo `method` o `onclick`** - Verificar sintaxis:
```xml
<!-- Correcto -->
<prop name="btn" type="B" method="ExecuteNode(miNodo)"/>
<!-- Incorrecto (falta ExecuteNode) -->
<prop name="btn" type="B" method="miNodo"/>
```

3. **Botón bloqueado por `disableedit`** - Verificar la condición:
```xml
<prop name="btn" type="B" disableedit="MAP_ESTADO=0"/>
```

4. **Solapamiento con otro elemento** - Un frame flotante puede estar encima.

### 19.3 Los estilos no se aplican

**Diagnostico:** La clase CSS no tiene efecto.

**Posibles causas y soluciones:**

1. **Usar unidades incorrectas** - No usar `px`, `em`, `rem`:
```css
/* Incorrecto */
.miClase { width:200px; }
/* Correcto */
.miClase { width:200p; }
```

2. **Nombre de clase incorrecto** - Verificar que coincida exactamente.

3. **Atributo inline sobreescribe la clase** - Los atributos en el XML tienen prioridad sobre el CSS.

4. **Archivo CSS no cargado** - El archivo debe llamarse `default.css` y estar en la raiz del proyecto.

### 19.4 La coleccion no carga datos

**Diagnostico:** `getCount()` retorna 0 después de `loadAll()`.

**Posibles causas y soluciones:**

1. **SQL incorrecto** - Verificar la consulta SQL en el atributo `sql` del `<coll>`.

2. **Tabla no existe** - Regenerar la base de datos:
```bash
xone-db-tools create-db mi_proyecto --overwrite
```

3. **Filtro demasiado restrictivo** - Verificar el `filter` del `<contents>`.

4. **Falta prefijo `##PREF##`** en la SQL:
```xml
<!-- Correcto -->
sql="SELECT * FROM ##PREF##MiTabla t1"
<!-- Incorrecto -->
sql="SELECT * FROM MiTabla t1"
```

### 19.5 Error de tabla no encontrada

**Diagnostico:** Error "no such table" al cargar datos.

**Solución:** Regenerar la base de datos. La tabla puede no haberse generado si:
- La coleccion no tiene `objname` o `updateobj`
- El archivo `.xne` no fue procesado por el generador
- El nombre de la tabla no coincide (recordar el prefijo `gen_`)

### 19.6 El GPS no funciona

**Diagnostico:** Las coordenadas siempre son 0 o null.

**Posibles causas y soluciones:**

1. **Falta `ui.startGps()`** - Iniciar el GPS antes de pedir coordenadas.

2. **Permisos no concedidos** - Verificar con:
```javascript
var status = ui.checkGpsStatus();
if (status == 0 || status == 3) {
    ui.askUserForGpsPermission({
        onEnabled: function() { ui.startGps(); },
        onDenied: function() { ui.showToast("Active el GPS"); }
    });
}
```

3. **Emulador sin GPS** - Probar en dispositivo físico.

### 19.7 La replica falla

**Diagnostico:** La sincronización con el servidor no se completa.

**Posibles causas:**
- Sin conexión a internet
- URL del servidor incorrecta
- Timeout en la conexión
- Datos corruptos en la cola de replica

**Solución:** Verificar la configuración de replica en `Empresas` y los logs del dispositivo.

### 19.8 La imagen no se muestra

**Diagnostico:** El espacio de la imagen aparece vacio.

**Posibles causas y soluciones:**

1. **Archivo no existe** - Verificar que el archivo esta en `icons/` o `files/`.

2. **Formato incorrecto** - XOne solo soporta PNG en produccion.

3. **Ruta incorrecta** - Usar `##APP##\icons\` para rutas absolutas:
```xml
<prop name="img" type="IMG" path="##APP##\icons\mi_icono.png"/>
```

4. **El campo esta vacio** - Verificar que el valor del campo contiene el nombre del archivo.

### 19.9 El contents esta vacio

**Diagnostico:** El área del content se muestra sin items.

**Posibles causas y soluciones:**

1. **Falta cargar los datos:**
```javascript
self.getContents("miContent").loadAll();
```

2. **Filtro incorrecto** en el `<contents>`:
```xml
<contents name="miContent" src="MiColeccion"
          filter="ID_PADRE=##FLD_MAP_ID##"/>
```
Verificar que `MAP_ID` tiene un valor valido.

3. **La coleccion fuente (`src`) no existe** - Verificar el nombre.

4. **El `<prop type="Z">` no referencia al content correcto:**
```xml
<prop name="@miContent" type="Z" contents="miContent"/>
<contents name="miContent" src="MiColeccion"/>
```

### 19.10 El onchange no se dispara

**Diagnostico:** Cambiar un campo no ejecuta el evento onchange.

**Posibles causas y soluciones:**

1. **Para campos tipo T (texto)**, el `onchange` del nodo se dispara al perder el foco, no en cada tecla. Para tiempo real usar `ontextchanged`:
```xml
<prop name="campo" type="T"
      ontextchanged="javascript:miFuncion(e);"/>
```

2. **El nombre del campo no coincide** en el `<field>`:
```xml
<onchange>
    <field name="MAP_CAMPO"> <!-- Debe coincidir exactamente -->
        <action name="runscript">
            <script language="javascript">
                // Código
            </script>
        </action>
    </field>
</onchange>
```

3. **Usando `onchange` como atributo** con valor incorrecto:
```xml
<!-- Correcto -->
<prop name="campo" type="N" onchange="Refresh"/>
<prop name="campo" type="N" onchange="refresh(campo1,campo2)"/>
<prop name="campo" type="N" onchange="ExecuteNode(miNodo)"/>

<!-- Incorrecto -->
<prop name="campo" type="N" onchange="true"/>
```

### 19.11 El refresh no funciona

**Diagnostico:** Se cambian datos desde JavaScript pero la pantalla no se actualiza.

**Posibles causas y soluciones:**

1. **Nombre del campo incorrecto** - Verificar que el nombre pasado a `ui.refresh()` coincida exactamente con el `name` del `<prop>`:
```javascript
// Si el campo se llama MAP_NOMBRE (no nombre, no NOMBRE)
ui.refresh("MAP_NOMBRE");
```

2. **Falta obtener la vista** - En callbacks asincranos, usar `ui.getView(self)`:
```javascript
var v = ui.getView(self);
if (v) {
    v.refresh("MAP_CAMPO");
}
```

3. **Contexto `self` perdido** - En callbacks de `$http` o eventos diferidos, `self` puede ser null. Guardar referencia antes:
```javascript
var miObjeto = self; // Guardar antes del callback
$http.get(url, request,
    function(sData) {
        miObjeto.MAP_RESULTADO = sData;
        ui.refresh("MAP_RESULTADO");
    }
);
```

### 19.12 self es null en callback

**Diagnostico:** Al acceder a `self` dentro de un callback, da error porque `self` es null o undefined.

**Solución:** Guardar la referencia a `self` en una variable local antes del callback:

```javascript
var contexto = self; // Guardar referencia
$http.get(url, request,
    function(sData) {
        // contexto funciona, self podria no funcionar aqui
        contexto.MAP_DATO = JSON.parse(sData).valor;
        ui.refresh("MAP_DATO");
    }
);
```

### 19.13 Coleccion vacia después de loadAll

**Diagnostico:** `coll.count()` retorna 0 después de llamar a `loadAll()`.

**Posibles causas y soluciones:**

1. **Filtro activo demasiado restrictivo** - Verificar y limpiar el filtro:
```javascript
coll.setFilter(""); // Limpiar filtro
coll.loadAll();
```

2. **Falta usar startBrowse/endBrowse** para colecciones accedidas externamente:
```javascript
var coll = appData.getCollection("MiColeccion");
try {
    coll.startBrowse();
    coll.loadAll();
    var count = coll.count();
    // ... usar datos ...
} finally {
    coll.endBrowse();
}
```

3. **La tabla no existe** en la base de datos. Regenerar con `xone-db-tools create-db`.

### 19.14 lock/unlock no funciona

**Diagnostico:** Se obtiene error al intentar modificar una coleccion bloqueada.

**Solución:** Verificar que se usa el patron try/finally correctamente:

```javascript
// INCORRECTO - si hay error, nunca se ejecuta lock()
coll.unlock();
var obj = coll.createObject();
coll.addItem(obj);
obj.save();
coll.lock();

// CORRECTO - lock() siempre se ejecuta en finally
try {
    coll.unlock();
    var obj = coll.createObject();
    coll.addItem(obj);
    obj.save();
} finally {
    coll.lock();
}
```

### 19.15 Evento no se dispara

**Diagnostico:** Un evento definido en XML no se ejecuta.

**Posibles causas y soluciones:**

1. **Nombre del evento incorrecto** - Los nombres de evento son case-sensitive. Verificar que coincida exactamente con el nodo XML.

2. **Atributo `refresh` impide ver el efecto** - Si el evento modifica datos pero `refresh="false"`, la UI no se actualiza:
```xml
<!-- Probar con refresh="true" para diagnosticar -->
<miEvento refresh="true" show-wait-dialog="false">
```

3. **El `method` no usa ExecuteNode** correctamente:
```xml
<!-- Incorrecto -->
<prop name="btn" type="B" method="miNodo"/>
<!-- Correcto -->
<prop name="btn" type="B" method="ExecuteNode(miNodo)"/>
```

4. **Error JavaScript silencioso** - Agregar `show-wait-dialog="true"` temporalmente para ver errores.

### 19.16 Campos MAP_ no se guardan

**Diagnostico:** Los campos con prefijo `MAP_` pierden su valor al cerrar y volver a abrir la pantalla.

**Explicacion:** Los campos `MAP_` son **transitorios** (campos calculados/virtuales). No se persisten en la base de datos. Solo existen en memoria mientras el objeto esta cargado.

**Solución:** Si necesitas persistir el dato, usa un campo sin prefijo `MAP_` que tenga su correspondiente columna en la tabla de la base de datos.

### 19.17 Error -8100

**Diagnostico:** Al intentar guardar un objeto, se obtiene el error `-8100`.

**Causa:** Campos obligatorios no completados. El framework valida que todos los campos marcados como obligatorios (`mandatory="true"` o equivalente) tengan valor.

**Solución:** Verificar que todos los campos obligatorios tienen un valor antes de llamar a `save()`.

### 19.18 Cerrar pantalla / cerrar app desde JavaScript

**Forma correcta:**

```javascript
// Cerrar pantalla actual (vuelve a la anterior)
ui.getView(self).exit();

// Cerrar toda la aplicación
appData.exit();
```

**Nota sobre código heredado:** En proyectos antiguos puede aparecer el patrón `appData.failWithMessage(-11888, "##EXIT##")` para cerrar la pantalla. Sigue funcionando (el código `-11888` con `##EXIT##` es interpretado por el framework como una orden de cierre, no como un error real), pero la forma preferida es `ui.getView(self).exit()`.

---

## 20. Glosario de Terminos XOne

| Termino | Descripción |
|---------|-------------|
| **action** | Bloque de ejecución dentro de un evento. Puede ser `runscript` (JavaScript) o `setval` (asignacion). |
| **appData** | Objeto global JavaScript para acceder a datos de la aplicación, colecciones y configuración. |
| **before-edit** | Evento de ciclo de vida que se ejecuta antes de entrar en modo edición. El más usado para inicialización. |
| **bind** | Método de `ui.getView()` para asignar eventos a controles por script en lugar de por atributo XML. |
| **coll** | Nodo raiz XML que define una coleccion. Puede representar una tabla de BD, una pantalla o un formulario. |
| **contents** | Nodo XML que define una relación padre-hijo entre colecciones, para embeber listas dentro de formularios. |
| **create** | Evento de ciclo de vida que se ejecuta al crear un nuevo objeto. |
| **CSS (XOne)** | Sistema de estilos propietario similar a CSS web pero con atributos y unidades propios (`p`, `%`). |
| **DataObject** | Objeto que representa un registro de datos en XOne. Se accede via `self` en scripts. |
| **disablevisible** | Atributo XML que condiciona la visibilidad de un elemento según el valor de un campo. |
| **Empresas** | Coleccion obligatoria en `mappings.xne`. Representa la configuración global de la aplicación. |
| **ExecuteNode** | Función para invocar un evento personalizado desde `method` o `onclick`. |
| **frame** | Contenedor visual XML para agrupar propiedades y otros frames en el layout. |
| **functions.js** | Archivo JavaScript global cuyas funciones están disponibles en todos los scripts del proyecto. |
| **gestion.db** | Archivo de base de datos SQLite local generado en la carpeta `bd/`. |
| **group** | Nodo XML que agrupa elementos. Se usa para pestanas, secciones y el header/footer fijo. |
| **group-swipe** | Atributo de `<coll>` que habilita la navegación entre grupos deslizando horizontalmente. |
| **loadAll()** | Método de coleccion que carga todos los registros desde la base de datos. |
| **lock/unlock** | Patron obligatorio para modificar contenidos de una coleccion o content. |
| **maintenance** | Nodo en `Empresas` para definir tareas programadas periódicas (replica, sincronización). |
| **MAP_** | Prefijo convencional para campos calculados/temporales que no se persisten en BD. |
| **mapcol** | Atributo para vincular un campo con una coleccion de datos (combo/selector). |
| **mappings.xne** | Archivo XML que contiene las colecciones `Empresas` y `Usuarios`. |
| **method** | Atributo de `<prop>` para vincular un botón con un evento custom via `ExecuteNode()`. |
| **notab** | Atributo de `<coll>` que oculta las pestanas de navegación. |
| **onback** | Evento que se dispara al presionar el botón de retroceso del dispositivo. |
| **onchange** | Evento que se dispara cuando cambia el valor de una propiedad. Como nodo permite `<field>`. |
| **onclick** | Atributo de evento que ejecuta JavaScript al hacer click/tap en un elemento. |
| **ontextchanged** | Atributo de evento que se dispara en tiempo real al escribir en un campo de texto. |
| **postonchange** | Atributo que ejecuta una acción después de un cambio de valor, en un segundo paso. |
| **prop** | Nodo XML que define una propiedad (campo de datos o control de UI). |
| **recyclerview** | ViewMode recomendado para listas con reciclaje de vistas, mejorando rendimiento. |
| **refresh** | Función/atributo para actualizar la interfaz de usuario después de cambiar datos. |
| **replica** | Sistema de sincronización bidireccional entre el dispositivo y el servidor. |
| **ROWID** | Campo interno de la plataforma (existe a nivel BD en toda coll persistida como GUID hex de 32 caracteres). NO se declara como `<prop>` ni se incluye en el SELECT del `sql=`. XOne lo gestiona automáticamente. |
| **runscript** | Tipo de acción dentro de un evento que ejecuta código JavaScript. |
| **self** | Objeto global JavaScript que referencia al DataObject actual en el contexto del script. |
| **setval** | Tipo de acción dentro de un evento que asigna un valor a un campo sin JavaScript. |
| **special** | Atributo de `<coll>` que marca una coleccion como pantalla de entrada de la aplicación. |
| **sql** | Atributo de `<coll>` con la consulta SQL para cargar datos de la tabla. |
| **type** | Atributo de `<prop>` que define el tipo de dato/control (T, N, B, D, IMG, PH, Z, etc.). |
| **ui** | Objeto global JavaScript para interfaz de usuario: dialogos, navegación, GPS, camara. |
| **Usuarios** | Coleccion obligatoria en `mappings.xne` para la gestion de usuarios de la aplicación. |
| **viewmode** | Atributo de `<prop type="Z">` que define como se visualiza un content (recyclerview, mapview, etc.). |
| **visible** | Atributo bitmask (0-7) que controla en que modos se muestra una propiedad. |
| **xne** | Extensión de los archivos XML de XOne que definen colecciones y pantallas. |
| **##FLD_CAMPO##** | Macro que referencia el valor de un campo en filtros SQL de contents. |
| **##NOW_TIME##** | Macro del sistema que retorna la fecha y hora actual. |
| **##PREF##** | Macro que se reemplaza por el prefijo de tabla configurado (típicamente `gen_`). |
| **##USERID##** | Macro del sistema que retorna el ID del usuario logueado. |
