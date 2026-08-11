---
description: Valida un proyecto XOne con xone-simulator y corrige los errores encontrados
argument-hint: [ruta del proyecto]
allowed-tools: Bash(xone-simulator:*), Bash(npm list:*), Read, Edit, Grep, Glob
---

Valida el proyecto XOne que está en `$1` (si no se indica ruta, usa el directorio actual) y corrige lo que falle.

Procedimiento:

1. Comprueba que el CLI esté disponible con `command -v xone-simulator`. Si no lo está, indica al usuario que lo instale con `npm install -g xone-linter` y detente. **No uses `xone-simulator --version`: ese comando no existe** y el CLI responde «Comando desconocido».
2. Ejecuta `xone-simulator validate <ruta>`.
3. Si hay errores, agrúpalos por fichero y por código. Antes de tocar nada, lee el fichero afectado y consulta la referencia correspondiente del índice de `xone-development` (XML `.xne`, JavaScript, CSS, datos e integración, dispositivo) para confirmar la forma correcta. **No corrijas por intuición**: si un atributo o API no aparece en las referencias, dilo en vez de inventar un arreglo.
4. Aplica el cambio mínimo que resuelva cada error, sin refactorizar de paso.
5. Vuelve a ejecutar `validate` y repite hasta que pase o hasta que quede un error que no puedas resolver con evidencia.
6. Cuando la validación esté limpia, ejecuta `xone-simulator smoke <ruta> --json` y resume el resultado.

Al terminar informa de: errores corregidos con el fichero y la línea, errores que siguen abiertos y por qué, y qué no has podido verificar.

Si necesitas apuntar a una base de datos, usa `--db-path` sobre una **copia**: el simulador puede mutarla.
