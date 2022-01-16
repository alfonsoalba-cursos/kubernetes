### _Ephemeral containers_

* No tienen recursos garantizados para su ejecución
* No se reinician automáticamente
* Una parte de la especificación no está disponible, por ejemplo `ports`, `livenessProbe`, `readinessProbe` 
* [Especificación](https://v1-20.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#ephemeralcontainer-v1-core)

^^^^^^

### _Ephemeral containers_

Uso

Depuración cuando `kubectl exec` no es suficiente para analizar / depurar un `Pod`

Muy útil cuando se utilizan [`distroless images`](https://github.com/GoogleContainerTools/distroless)

notes:

`distroless images` son imágenes para crear contenedores que no contienen muchas de las aplicaciones
que se incluyen en una distribución de linux como gestores de paquetes o shells. Estas imágenes están
pensadas para ser muy pequeñas y contener únicamente la aplicación y las librerías que esta requiere 
para funcionar.

Utilizar `kube exec` en un contenedor de este tipo es complicado... ¡ni siquiera tenemos un shell!

Aquí es donde un _ephemeral container_ nos puede ayudar. Para facilitar la depuración, es conveniente
activar la opción del `Pod` que permite compartir el espacio de procesos `shareProcessNamespace` 
(ver [Share Process Namespace between Containers in a Pod](https://kubernetes.io/docs/tasks/configure-pod-container/share-process-namespace/)).



^^^^^^
### _Ephemeral containers_

Más información:
* [Ephemeral Containers](https://kubernetes.io/docs/concepts/workloads/pods/ephemeral-containers/)
* [Especificación](https://v1-20.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#ephemeralcontainer-v1-core)
* [Debug Running `Pods`](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-running-pod/#ephemeral-container)