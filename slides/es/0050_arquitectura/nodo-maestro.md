### El nodo maestro

<img src="../../images/master_node_architecture.png" alt="Master node architecture" class="r-stretch">

^^^^^^ 

### `etcd`
* [`etcd`](https://etcd.io/) es una base datos clave valor, simple, distribuida y confiable
* Almacena la información del cluster (número de nodos, estado,  `Namespaces`, etc) y objetos de la API
* Solo es accesible desde el <em>API Server</em>
* [ℹ️ Más información](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd)

^^^^^^

### `kube-apiserver`
* *Entidad principal de la gestión del cluster
* Es el _frontend_ del cluster
* Se comunica con `etcd` y se asegura de la consistencia de los datos
* [ℹ️ Más información](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/) 

notes: 

Recibe todas las peticiones REST (por ejemplo a través de `kubectl`)
para gestionar los recursos de Kubernetes (Pods, Deployments, Services...). Por eso se dice
que es el _frontend_ del cluster.

_kube-apiserver_ se encarga, cuando escribe en la base de datos `etcd` de que la información
que se almacena es congruente con los que hay en los nodos del cluster.

^^^^^^
### `kube-controller-manager`

* Ejecutar procesos de control en segundo plano
* Consta de varios controladores que se encargan de que el cluster esté en el estado que se desea que esté
* Por simplicidad: un ejecutable que lanza varios procesos
* [ℹ️ Más información](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/)

notes:

En Kubernetes, los controladores ejecutan ciclos de control que miran el estado en el que queremos que nuestro cluster esté
(almacenado en el `api-server`) y entonces hacen los cambios necesarios para alcanzar ese estado. Cada controlador intenta mover
el cluster a un estado cada vez más próximo al estado final.


Ejemplos de tareas que esta capa de controladores se encarga de controlar:
* número de réplicas es el que tiene que se
* si se actualiza la imagen de un pod, modifica los nodos para que se despliegue la nueva imagen

^^^^^^

### `kube-controller-manager`

* Node controller: responsable de levantar un nuevo nodo si un nodo muere
* Job controller: mira los objetos `Job` y se encarga de que ejecuten
* Endpoints controller: crea los objetos `Endpoint` (conectando `Servicios` y `Pods`)
* Service Account & Token controllers: rea cuentas por defecto y _API access tokens_ para los `Namespaces`
* Replication controller: controla que el número de replicas de cada `Pod` es el deseado

notes:

Aquí tenemos varios ejemplos de controladores que tenemos en un cluster.

^^^^^^

### Controladores personalizados

Los cluster de kubernetes se pueden extender con controladores personalizados que se ejecutan fuera de `kube-controller-manager`

Veremos un ejemplo de ello cuando hablemos de `Ingress`

[ℹ️ Kubernetes controllers](https://kubernetes.io/docs/concepts/architecture/controller/)

^^^^^^

### `cloud-controller-manager`

* Controladores específicos de los proveedores de cloud
* Permite enlazar el cluster con la API del proveedor de servicios en la nube
* [ℹ️ Más información](https://kubernetes.io/docs/concepts/overview/components/#cloud-controller-manager)

^^^^^^

### `cloud-controller-manager`

* Node controller
* Route controller
* Service controller

notes:

Algunos de los controladores que se implementan en el `cloud-controller-manager`.

Es posible ejecutar este controlador de dos formas:
* como un _addon_
* como parte del plano de control

**Node controller**: cuando se crea un nuevo nodo en el proveedor cloud, este controlador se encarga de asignarle un identificador,
etiquetarlo (añadir `Labels` y  `Annotations`), obtener la dirección IP del nodo y su nombre de host (para poder enrutarle tráfico) y
verificar el estado del nodo.

**Route controller**: crea las rutas y los bloque de direcciones IP en la infraestructura de red del proveedor cloud para que
los contenedores de los `Pods` se puedan comunicar entre si.

**Service controller**: Por ejemplo, es el encargado de crear los balanceadores de carga en la infraestructura del proveedor cloud

^^^^^^

### `kube-scheduler`

* Ayuda a programar los pods y desplegarlos en los nodos teniendo en cuenta:
  * los recursos disponibles de memoria y procesador de los nodos
  * los requisitos de cada pod.

notes:

Por ejemplo, si queremos desplegar un Pod que requiere 2G de memoria RAM y 3 CPUs,
esta componente es la que se encarga de encontrar el nodo adecuado para desplegar
ese Pod.

Por este motivo, esta componente debe saber cuáles son los recursos del cluster disponibles 
tanto en el cluster como en cada uno de los nodos.

Hablaremos mucho del `kube-scheduler` cuando hablemos de autoescalado, `Taints` y `Tolerations`

^^^^^^ 

### Plano de control

Todas las componentes mencionadas en esta sección conforman lo que se llama el Plano de control
(_control plane_) del cluster

Estas componentes pueden ejecutarse en cualquier nodo del cluster, aunque la configuración típica
es que se ejecuten en un nodo maestro

notes:

El nodo maestro es responsable de ejecutar únicamente el plano de control y no se
programan `Pods` de usuarios para que se ejecuten en él. 