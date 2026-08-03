# XML/UI Referencia — Patrones de pantalla, mappings y colecciones adicionales

Sub-archivo de [xone-xml-ui-reference.md](xone-xml-ui-reference.md). Cubre 8 patrones de pantalla completos (menú, login con huella, lista RecyclerView, formulario con validación, dashboard con tabs y gráficos, mapa con marcadores, calendario, drawer), la estructura obligatoria de `mappings.xne` (Empresas + Usuarios) y la convención de colecciones adicionales en archivos separados.

## Tabla de Contenidos

- [11. Patrones de Pantalla Comunes](#11-patrones-de-pantalla-comunes)
- [12. mappings.xne - Estructura Obligatoria](#12-mappingsxne---estructura-obligatoria)
- [13. Colecciones Adicionales - Archivos Separados](#13-colecciones-adicionales---archivos-separados)

---

## 11. Patrones de Pantalla Comunes

### Patron 1: Menu Principal con Botones

```xml
<?xml version="1.0" encoding="utf-8"?>
<coll name="MenuPrincipal" title="Menu"
    special="true" notab="true" show-toolbar="false"
    group-theme="material">

    <group name="grpMenu" id="1" class="groupNoTab" align="center">
        <frame name="frmHeader" class="frameHeader">
            <prop name="MAP_LOGO" type="IMG" visible="1"
                width="200p" height="80p"
                path="logo.png"
                keep-aspect-ratio="true" align="center" />
            <prop name="MAP_TITULO" type="L" visible="1"
                width="100%" text-align="center"
                forecolor="#FFFFFF" fontsize="18"
                title="Mi Aplicación" />
        </frame>

        <frame name="frmBody" class="frameBody" scroll="true">
            <prop name="MAP_BTN_PRODUCTOS" type="B" visible="1"
                title="Productos" width="90%" height="60p"
                tmargin="20p" class="btnPrimario"
                img="ic_inventory.png"
                onclick="ui.openEditView('ListaProductos');" />
            <prop name="MAP_BTN_PEDIDOS" type="B" visible="1"
                title="Pedidos" width="90%" height="60p"
                tmargin="10p" class="btnPrimario"
                img="ic_receipt.png"
                onclick="ui.openEditView('ListaPedidos');" />
        </frame>
    </group>

    <onback show-wait-dialog="false" refresh="false">
        <action name="runscript">
            <script language="javascript">
                appData.exit();
            </script>
        </action>
    </onback>
</coll>
```

### Patron 2: Login con Huella Dactilar

```xml
<?xml version="1.0" encoding="utf-8"?>
<coll name="LoginColl" title="" special="true" notab="true"
    show-toolbar="false">

    <group name="Login" id="1" class="groupNoTab">
        <frame name="frmLogin" width="100%" height="100%"
            bgcolor="#F7F7F7" align="center">

            <frame name="frmLogo" tmargin="100p" align="center">
                <prop name="MAP_LOGO" type="IMG" visible="1"
                    width="200p" height="100p" path="logo.png"
                    keep-aspect-ratio="true" />
            </frame>

            <frame name="frmError" disablevisible="MAP_ERROR=''"
                floating="true" width="100%" align="center|top">
                <prop name="MAP_ERROR" type="L" visible="1"
                    tmargin="55p" forecolor="#F44336"
                    text-align="center" fontsize="12" />
            </frame>

            <prop name="MAP_USUARIO" type="T" visible="1"
                width="80%" tmargin="94p"
                floating-tooltip="true" tooltip="Usuario"
                labelwidth="0" text-border-bottom="true" />

            <prop name="MAP_PASSWORD" type="X" visible="1"
                width="80%" tmargin="55p"
                floating-tooltip="true" tooltip="Contraseña"
                show-password-visibility-toggle="true"
                labelwidth="0" text-border-bottom="true" />

            <prop name="MAP_BTN_CANCELAR" type="B" visible="1"
                method="executenode(onback)"
                tmargin="80p" width="35%" height="50p"
                title="Cancelar" class="btnSecundario" />

            <frame name="frmHuella" disablevisible="MAP_HUELLA=0"
                tmargin="80p" lmargin="10p" bgcolor="#F7F7F7"
                width="50p" height="50p" newline="false"
                border-corner-radius="25">
                <prop name="MAP_BTN_HUELLA" type="B"
                    method="executenode(loginHuella)"
                    width="96%" height="96%"
                    img="ic_fingerprint.png" labelwidth="0" />
            </frame>

            <prop name="MAP_BTN_ACEPTAR" type="B" visible="1"
                method="executenode(aceptar)"
                tmargin="80p" lmargin="10p" width="35%"
                height="50p" title="Aceptar" newline="false"
                class="btnPrimario" />

            <prop name="MAP_VERSION" type="L" visible="1"
                tmargin="40p" width="100%" text-align="center"
                fontsize="9" forecolor="#9E9E9E" />
        </frame>
    </group>

    <prop name="MAP_HUELLA" visible="0" type="N" />
    <prop name="MAP_ERROR" visible="0" type="T" />

    <create>
        <action name="setval" field="MAP_VERSION"
            value="Versión ##VERSION## - Framework ##FRAME_VERSION##" />
        <action name="runscript">
            <script language="javascript">
                self.MAP_HUELLA = 0;
                self.MAP_ERROR = "";
                if (fingerprintManager.isHardwareAvailable()) {
                    if (fingerprintManager.hasEnrolledFingerprints()) {
                        self.MAP_HUELLA = 1;
                    }
                }
            </script>
        </action>
    </create>

    <aceptar>
        <action name="runscript">
            <script language="javascript">
                // Validamos solo el usuario: en XOne puede haber cuentas sin
                // contraseña (invitado, kiosco). Si la contraseña es incorrecta
                // o falta cuando hace falta, el backend lo rechaza vía onLoginFailed.
                if (!self.MAP_USUARIO) {
                    self.MAP_ERROR = "Introduzca el usuario";
                    ui.refresh("MAP_ERROR");
                    return;
                }
                appData.login({
                    userName: self.MAP_USUARIO,
                    password: self.MAP_PASSWORD,
                    entryPoint: "MenuPrincipal",
                    onLoginSuccessful: function() {
                        ui.showToast("Bienvenido!");
                    },
                    onLoginFailed: function() {
                        self.MAP_ERROR = "Usuario o contraseña incorrectos";
                        ui.refresh("MAP_ERROR");
                    }
                });
            </script>
        </action>
    </aceptar>

    <loginHuella>
        <action name="runscript">
            <script language="javascript">
                biometricsManager.setCallback({
                    title: "Autenticacion biométrica",
                    subtitle: "Login",
                    description: "Coloque su dedo en el sensor",
                    negativeButtonText: "Cancelar",
                    onSuccess: function(result) {
                        ui.showToast("Autenticado correctamente");
                    },
                    onFailure: function(nError, sMsg) {
                        self.MAP_ERROR = "Error biométrico: " + sMsg;
                        ui.refresh("MAP_ERROR");
                    }
                });
                biometricsManager.launch();
            </script>
        </action>
    </loginHuella>

    <onback show-wait-dialog="false" refresh="false">
        <action name="runscript">
            <script language="javascript">
                appData.exit();
            </script>
        </action>
    </onback>
</coll>
```

### Patron 3: Lista con RecyclerView

```xml
<?xml version="1.0" encoding="utf-8"?>
<coll name="ListaProductos"
    sql="SELECT * FROM ##PREF##Productos WHERE ACTIVO=1"
    objname="Productos" loadall="true"
    notab="true" show-toolbar="false"
    cell-bgcolor="#FFFFFF"
    cell-selected-bgcolor="#E3F2FD">

    <group name="grpLista" id="1" class="groupNoTab">
        <frame name="frmHeader" class="frameHeader">
            <prop name="MAP_TITULO" type="L" visible="1"
                width="70%" title="Productos"
                forecolor="#FFFFFF" fontsize="16" fontbold="true" />
            <prop name="MAP_BTN_BUSCAR" type="B" visible="1"
                width="15%" img="ic_search_white.png"
                newline="false" onclick="abrirBusqueda();" />
            <prop name="MAP_BTN_AGREGAR" type="B" visible="1"
                width="15%" img="ic_add_white.png"
                newline="false" onclick="nuevoProducto();" />
        </frame>

        <prop name="NOMBRE" type="T" visible="7"
            title="Nombre" width="60%" />
        <prop name="PRECIO" type="N2" visible="7"
            title="Precio" width="30%" text-align="right" />
        <prop name="STOCK" type="N" visible="7"
            title="Stock" width="10%" text-align="center" />
    </group>

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

### Patron 4: Formulario con Validación

```xml
<?xml version="1.0" encoding="utf-8"?>
<coll name="DetalleProducto"
    sql="SELECT * FROM ##PREF##Productos WHERE ID=##FLD_ID##"
    objname="Productos" updateobj="Productos"
    notab="true" show-toolbar="false">

    <group name="grpDetalle" id="1" class="groupNoTab" scroll="true">
        <frame name="frmHeader" class="frameHeader">
            <prop name="MAP_BTN_VOLVER" type="B" visible="1"
                width="50p" img="ic_arrow_back_white.png"
                method="executenode(onback)" />
            <prop name="MAP_TITULO" type="L" visible="1"
                width="80%" title="Detalle Producto"
                forecolor="#FFFFFF" fontsize="16" newline="false" />
        </frame>

        <frame name="frmBody" width="100%" scroll="true"
            bgcolor="#FFFFFF" tmargin="10p">
            <prop name="NOMBRE" type="T" visible="7"
                title="Nombre" width="90%" tmargin="20p"
                floating-tooltip="true" tooltip="Nombre..."
                labelwidth="0" />
            <prop name="PRECIO" type="N2" visible="7"
                title="Precio" width="45%" tmargin="15p"
                floating-tooltip="true" tooltip="Precio..."
                labelwidth="0" />
            <prop name="STOCK" type="N" visible="7"
                title="Stock" width="45%" tmargin="15p"
                newline="false" floating-tooltip="true"
                tooltip="Cantidad..." labelwidth="0" />
            <prop name="ACTIVO" type="NC" visible="7"
                title="Activo" width="90%" tmargin="15p"
                check-type="switch" />
        </frame>

        <frame name="frmFooter" class="frameFooter">
            <prop name="MAP_BTN_GUARDAR" type="B" visible="1"
                title="Guardar" width="45%" height="50p"
                class="btnPrimario" method="executenode(guardar)" />
            <prop name="MAP_BTN_ELIMINAR" type="B" visible="1"
                title="Eliminar" width="45%" height="50p"
                newline="false" class="btnPeligro"
                method="executenode(eliminar)" />
        </frame>
    </group>


    <guardar>
        <action name="runscript">
            <script language="javascript">
                if (!self.NOMBRE || self.NOMBRE == "") {
                    ui.showToast("El nombre es obligatorio");
                    return;
                }
                self.save();
                ui.showToast("Producto guardado");
                let window = ui.getView(self);
                if (window) window.exit();
            </script>
        </action>
    </guardar>

    <eliminar>
        <action name="runscript">
            <script language="javascript">
                let nResult = ui.msgBox(
                    "Esta seguro de eliminar?",
                    "Confirmar", 4);
                if (nResult == 6) {
                    let coll = self.getOwnerCollection();
                    coll.deleteItem(self);
                    ui.showToast("Eliminado");
                    let window = ui.getView(self);
                    if (window) window.exit();
                }
            </script>
        </action>
    </eliminar>

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

### Patron 5: Dashboard con Tabs y Gráficos

```xml
<?xml version="1.0" encoding="utf-8"?>
<coll name="Dashboard" special="true"
    notab="false" group-theme="material"
    tab-mode="scrollable" show-toolbar="false">

    <group name="Resumen" id="1" align="center" scroll="true">
        <prop name="MAP_CHART_VENTAS" type="Z"
            classid="XOneCharts" viewmode="barchart"
            contents="@DatosVentas" width="95%" height="300p"
            tmargin="10p" />
        <prop name="MAP_CHART_CATEGORIAS" type="Z"
            classid="XOneCharts" viewmode="piechart"
            contents="@DatosCategorias" width="95%" height="300p"
            tmargin="20p" />
    </group>

    <group name="Productos" id="2" align="center">
        <prop name="MAP_BUSCAR" type="T" visible="1"
            width="90%" tmargin="10p"
            floating-tooltip="true"
            tooltip="Buscar producto..." labelwidth="0" />
        <prop name="MAP_LISTA_PRODUCTOS" type="Z"
            contents="@ProductosList" viewmode="recyclerview"
            width="100%" height="80%" edit-inrow="true"
            show-no-data="true" show-loading="true" />
    </group>

    <group name="Mapa" id="3" align="center">
        <prop name="MAP_MAPA_TIENDAS" type="Z"
            contents="@TiendasMap" viewmode="mapview"
            width="100%" height="100%"
            show-user-location="true" zoom-to-pois="true"
            onmapclicked="onMapClicked(e);" />
    </group>

    <contents name="@DatosVentas" src="ChartVentasColl" />
    <contents name="@DatosCategorias" src="ChartCategoriasColl" />
    <contents name="@ProductosList" src="Productos" />
    <contents name="@TiendasMap" src="TiendasColl" />

    <onback show-wait-dialog="false" refresh="false">
        <action name="runscript">
            <script language="javascript">
                appData.exit();
            </script>
        </action>
    </onback>
</coll>
```

### Patron 6: Mapa con Marcadores

```xml
<?xml version="1.0" encoding="utf-8"?>
<coll name="MapaEntregas" notab="true" show-toolbar="false">
    <group name="grpMapa" id="1" class="groupNoTab">
        <frame name="frmHeader" class="frameHeader">
            <prop name="MAP_BTN_VOLVER" type="B" visible="1"
                width="50p" img="ic_arrow_back_white.png"
                method="executenode(onback)" />
            <prop name="MAP_TITULO" type="L" visible="1"
                width="80%" title="Mapa de Entregas"
                forecolor="#FFFFFF" fontsize="16" newline="false" />
        </frame>
        <prop name="MAP_MAPA" type="Z"
            contents="@PuntosEntrega" viewmode="mapview"
            width="100%" height="70%"
            show-user-location="true" zoom-to-pois="true"
            onmapclicked="onMapClicked(e);"
            onmapready="onMapReady(e);" />
        <prop name="MAP_LISTA_ENTREGAS" type="Z"
            contents="@Entregas" viewmode="recyclerview"
            width="100%" height="30%" edit-inrow="true"
            show-no-data="true" />
    </group>

    <contents name="@PuntosEntrega" src="PuntosEntregaColl" />
    <contents name="@Entregas" src="EntregasColl" />

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

### Patron 7: Calendario con Eventos

```xml
<?xml version="1.0" encoding="iso-8859-15"?>
<coll name="PantallaCalendario" special="true" notab="true"
    show-toolbar="false"
    progid="ASData.CASBasicDataObj"
    sql="SELECT t1.* FROM ##PREF##empresa t1"
    objname="empresa" updateobj="empresa">

    <group name="Calendario" id="1">
        <frame name="frmCalendario" width="94%" height="40%" lmargin="3%">
            <prop name="Calendario" type="Z" visible="1"
                  calendar-viewmode="week"
                  contents="@calendario"
                  viewmode="calendarview"
                  width="100%" height="100%" />
            <contents name="@calendario" src="ContentCalendario" />
        </frame>

        <frame name="frmEventos" width="94%" height="50%"
               lmargin="3%" tmargin="10p">
            <prop name="MAP_EVENTOSDELDIA" type="Z" visible="1"
                  contents="@eventosDelDia"
                  viewmode="recyclerview"
                  width="100%" height="100%"
                  bgcolor="#FFFFFF" show-no-data="true" />
            <contents name="@eventosDelDia" src="ContentEventosDia"
                      filter="strftime('%Y-%m-%d',FECHA)=##FLD_MAP_FECHA_SEL##" />
        </frame>
    </group>

    <prop name="MAP_FECHA_SEL" type="T" visible="0" />

    <!-- CORRECTO: ondateselected (sin guion). El parametro es DATEVALUE, no e.selectedDate -->
    <ondateselected>
        <action name="runscript">
            <param name="DATEVALUE" />
            <script language="javascript">
                self.MAP_FECHA_SEL = DATEVALUE;
                ui.refresh("MAP_EVENTOSDELDIA");
            </script>
        </action>
    </ondateselected>

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

### Patron 8: Drawer Lateral

```xml
<?xml version="1.0" encoding="utf-8"?>
<coll name="AppConDrawer" notab="true" show-toolbar="false"
    ondraweropened="onDrawerOpened(e);"
    ondrawerclosed="onDrawerClosed(e);">

    <group name="Principal" id="1" class="groupNoTab">
        <frame name="frmHeader" class="frameHeader">
            <prop name="MAP_BTN_MENU" type="B" visible="1"
                width="50p" img="ic_menu_white.png"
                onclick="abrirDrawer();" />
            <prop name="MAP_TITULO" type="L" visible="1"
                width="80%" title="Mi Aplicación"
                forecolor="#FFFFFF" fontsize="16" newline="false" />
        </frame>
        <frame name="frmBody" class="frameBody" scroll="true">
            <prop name="MAP_BIENVENIDA" type="L" visible="1"
                width="100%" tmargin="20p" text-align="center"
                title="Bienvenido" fontsize="16" />
        </frame>
    </group>

    <group name="Drawer" id="999" width="70%"
        drawer-orientation="left" bgcolor="#FFFFFF">
        <frame name="frmDrawerHeader" width="100%"
            height="180p" bgcolor="#1976D2" align="bottom|left">
            <prop name="MAP_AVATAR" type="IMG" visible="1"
                width="64p" height="64p" path="avatar_default.png"
                lmargin="20p" bmargin="10p" />
            <prop name="MAP_NOMBRE_USUARIO" type="L" visible="1"
                width="80%" forecolor="#FFFFFF" fontsize="14"
                fontbold="true" lmargin="20p" />
        </frame>
        <prop name="MAP_BTN_INICIO" type="B" visible="1"
            title="Inicio" width="100%" height="48p"
            img="ic_home.png" tmargin="10p"
            onclick="irAInicio();" />
        <prop name="MAP_BTN_PERFIL" type="B" visible="1"
            title="Mi Perfil" width="100%" height="48p"
            img="ic_person.png" onclick="irAPerfil();" />
        <prop name="MAP_BTN_CERRAR_SESION" type="B" visible="1"
            title="Cerrar Sesion" width="100%" height="48p"
            img="ic_logout.png" tmargin="10p"
            onclick="cerrarSesion();" />
    </group>

    <onback show-wait-dialog="false" refresh="false">
        <action name="runscript">
            <script language="javascript">
                let window = ui.getView(self);
                if (window.isGroupOpen(999)) {
                    window.hideGroup(999);
                } else {
                    appData.exit();
                }
            </script>
        </action>
    </onback>
</coll>
```

---

## 12. mappings.xne - Estructura Obligatoria

### Regla Fundamental

> **IMPORTANTE:** El archivo `mappings.xne` SOLO debe contener las colecciones base **Empresas** y **Usuarios**. Todas las demas colecciones deben definirse en archivos `.xne` separados.

### Campos Mínimos Obligatorios

| Coleccion | Campos Obligatorios |
|-----------|---------------------|
| **Empresas** | `CODIGO` (N), `NOMBRE` (T) |
| **Usuarios** | `CODIGO` (N), `NOMBRE` (T), `IDEMPRESA` (N, mapcol="Empresas"), `LOGIN` (T), `PWD` (X) |

> No hace falta declarar `ID` ni `ROWID` como `<prop>`: son columnas de plataforma que XOne gestiona automáticamente (el `ROWID` es el GUID de 32 hex de sincronización que el framework autogenera). Declararlas es válido pero redundante. El campo de empresa en Usuarios es `IDEMPRESA` (sin guion bajo).

### Plantilla Completa

```xml
<?xml version="1.0" encoding="iso-8859-15"?>
<xml>
    <app prefix="gen" version="1.0.0" debug="true"
        default-language="javascript">
        <style url="default.css" />
    </app>

    <coll name="Empresas"
          sql="SELECT t1.* FROM ##PREF##empresa t1"
          objname="empresa" updateobj="empresa"
          progid="ASGestion.CASEmpresa"
          loadall="true">
        <group name="General" id="1">
            <prop name="CODIGO" type="N" visible="7" />
            <prop name="NOMBRE" type="T" visible="7" fieldsize="150" />
        </group>
    </coll>

    <coll name="Usuarios"
          sql="SELECT t1.* FROM ##PREF##usuario t1"
          objname="usuario" updateobj="usuario"
          progid="ASGestion.CASUser"
          loadall="true">
        <group name="General" id="1">
            <prop name="CODIGO" type="N" visible="7" />
            <prop name="NOMBRE" type="T" visible="7" fieldsize="100" />
            <prop name="IDEMPRESA" type="N" visible="7"
                mapcol="Empresas" mapfld="ID" />
            <prop name="LOGIN" type="T" visible="7" fieldsize="50" />
            <prop name="PWD" type="X" visible="0" fieldsize="100" />
        </group>
        <create>
            <action name="setval" field="IDEMPRESA"
                value="##ENTID##" />
        </create>
    </coll>
</xml>
```

> **CRITICO:** El nodo raiz es `<xml>` y las colecciones van **directamente dentro de `<xml>`**, sin ningún nodo contenedor intermedio como `<collprops>`. El encoding puede ser UTF-8 o `iso-8859-15` (coherente con los bytes del fichero). El campo de empresa en Usuarios se llama `IDEMPRESA` (sin guion bajo). En `mappings.xne`, Empresas usa `progid="ASGestion.CASEmpresa"` y Usuarios `progid="ASGestion.CASUser"`.

### Convencion de Nombres en BD

Con `prefix="gen"`:
- Tabla Empresas: `gen_empresa`, Tabla Usuarios: `gen_usuario`
- Campos siempre en MAYUSCULAS: `NOMBRE`, `CODIGO`, `IDEMPRESA`

---

## 13. Colecciones Adicionales - Archivos Separados

### Regla

Cada coleccion que NO sea Empresas o Usuarios se define en su propio archivo `.xne`.

### Plantilla

```xml
<?xml version="1.0" encoding="iso-8859-15"?>
<coll name="[NombreColeccion]"
      sql="SELECT t1.* FROM ##PREF##[NombreColeccion] t1"
      objname="[NombreColeccion]"
      updateobj="[NombreColeccion]"
      progid="ASData.CASBasicDataObj"
      loadall="true">
    <group name="General" id="1">
        <!-- Campos de la coleccion -->
    </group>
</coll>
```

### Ejemplo: Productos.xne

```xml
<?xml version="1.0" encoding="iso-8859-15"?>
<coll name="Productos"
      sql="SELECT t1.* FROM ##PREF##Productos t1"
      objname="Productos" updateobj="Productos"
      progid="ASData.CASBasicDataObj"
      loadall="true">
    <group name="General" id="1">
        <prop name="CODIGO" type="T" visible="7" fieldsize="20" />
        <prop name="NOMBRE" type="T" visible="7" fieldsize="150" />
        <prop name="DESCRIPCION" type="T" visible="7" fieldsize="500" />
        <prop name="PRECIO" type="N2" visible="7" />
        <prop name="STOCK" type="N" visible="7" />
        <prop name="ACTIVO" type="NC" visible="7" />
    </group>
</coll>
```

### Ejemplo: Pedidos.xne

```xml
<?xml version="1.0" encoding="iso-8859-15"?>
<coll name="Pedidos"
      sql="SELECT t1.* FROM ##PREF##Pedidos t1"
      objname="Pedidos" updateobj="Pedidos"
      progid="ASData.CASBasicDataObj"
      loadall="true">
    <group name="General" id="1">
        <prop name="IDUSUARIO" type="N" visible="7"
            mapcol="Usuarios" mapfld="ID" />
        <prop name="FECHA" type="DT" visible="7" />
        <prop name="ESTADO" type="T" visible="7" fieldsize="20" />
        <prop name="TOTAL" type="N2" visible="7" />
    </group>
</coll>
```

### Estructura Correcta vs Incorrecta

```
INCORRECTO:
mappings.xne contiene: Empresas, Usuarios, Productos, Pedidos

CORRECTO:
mappings.xne    -> Solo Empresas y Usuarios
Productos.xne   -> Coleccion Productos
Pedidos.xne     -> Coleccion Pedidos
```

---


**Anterior:** [c - Contents y eventos](xone-xml-ui-c-contents-eventos.md) · **Siguiente:** [e - Mapas y errores](xone-xml-ui-e-mapas-errores.md) · **Índice:** [xone-xml-ui-reference.md](xone-xml-ui-reference.md)