### ¿Qué son los objetos `StatefulSets`?

Como los `Deployments`, son objetos que gestionan el despliegue y escalado de un 
conjunto de `Pods`...

...garantizando ciertos requisitos de orden y unicidad de los `Pods`

^^^^^^

### ¿Qué son los objetos `StatefulSets`?

Como los `Deployments`, gestionan `Pods` que comparten la definición de los contendores

^^^^^^ 

### ¿En qué se diferencian?

_sticky identity_

Los `Pods` de un `StatefulSet` tienen una identidad que se mantiene cuando un `Pod`
se reprograma

notes:

Si un `Pod` de un `StatefulSet` se borra y se vuelve a crear, mantendrá la misma
identidad. Es decir, tendrá el mismo nombre y tendrá acceso a los mismos volúmenes
que tenía el `Pod` anterior.

^^^^^^

### Motivación ¿cuándo usarlos?

* Estabilidad de los nombres de red de los servicios
* Volúmenes de almacenamiento estables
* Escalado ordenado
* Actualizaciones ordenadas

notes:

Los `StatefulSets` son una buena opción para aplicaciones que necesitan algunos
de estos requisitos:

* Estabilidad de los nombres de red de los servicios: si montamos un nodo de elasticsearch,
  el nodo 3 del cluster, tiene que llamarse siempre de la misma manera (y 
  contener los datos del nodo 3) independientemente de que el `Pod` se tenga que reiniciar.
  Los `StatefulSets` garantizan que el nombre será siempre el mismo.
* Volúmenes de almacenamiento estables: la aplicación necesita tener acceso siempre a la misma
  información almacenada en disco
* Escalado ordenado: cuando añadimos / borramos nodos a la aplicación, estos deben añadirse o 
  quitarse en un orden determinado
* Actualizaciones ordenadas: la actualización de versión de la aplicación debe realizarse 
  también de una manera ordenada.

^^^^^^

### Limitaciones

* El almacenamiento sólo se puede proveer mediante el uso de `PersistentVolume Provisioner`
* Borrado manual de los volúmenes, para garantizar la seguridad de los datos
* Requieren el uso de un `Headless Service` que gestione los nombres de red de los `Pods`
* Cuando se borra un `StatefulSet`, no hay garantía sobre el orden en el que los `Pods`
  se borran
note:

* `PersistentVolume Provisioner`: se puede definir un `Storage Class` para seleccionar un
  proveedor o utilizar almacenamiento aprovisionado previamente por el administrador del cluster
* Borrado de volúmenes: se da prioridad a la integridad/seguridad de los datos sobre
  la comodidad del borrado automático
* `Headless Service`: este servicio se encargará de añadir los nombres de los `Pods`
  al servicio DNS. Si, además, necesitamos acceder a los `Pods` desde dentro o fuera
  del cluster, necesitaremos crear los correspondientes `Services` para poder hacerlo.
  **A día de hoy, este servicio tenemos que crearlo nosotros**, no se crea solo
* Borrado: si queremos que los `Pods` se borren en orden, la forma de proceder es 
  escalar el objeto a 0 replicas y después borrarlo
