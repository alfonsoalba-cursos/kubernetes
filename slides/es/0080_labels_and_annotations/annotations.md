### Anotaciones (`Annotations`)

Añadir información arbitraria a un objeto.

También son parejas clave/valor, como las etiquetas

**⛔ No se utilizan para seleccionar objetos ⛔**

^^^^^^

### Formato

Igual que el de las etiquetas.

Note:

Todo lo que mostramos en la sección anterior sobre el formato de la clave
y el valor de las etiquetas se aplica a la anotaciones.

Al igual que las etiquetas, también se pueden añadir en cualquier momento a un
objeto.

^^^^^^

### Ejemplos

* Información del _build_ o del _release_: rama de git, ID del _pull request_, _commit_, etc
* Nombre y forma de contacto de la persona que puede dar soporte sobre ese objeto
* Información sobre versiones
* Información sobre el ID del ticket relacionado con una _release_ (ticket the Jira)

^^^^^^

```yaml []

apiVersion: v1
kind: Deployment
metadata:
  name: demo
  annotations:
    jira-epic: "https://myjira.atlassian.net/browse/PROJ-17347"
    release: "v1.1.4-build234"
    commit: "812A43CBEF78"
spec:
...
```