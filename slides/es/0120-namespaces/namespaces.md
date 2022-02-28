<!-- Este conjunto de diapositivas se utiliza en la sección Introducción a al administración de Kubernetes -->

### `Namespace`

Mecanismo para aislar grupos de recursos dentro de un mismo cluster.

Los nombres de los recursos tienen que ser únicos dentro un `Namespace`

^^^^^^

### ¿Cuándo utilizarlos?

✅ Organizar los recursos de un cluster en equipos o proyectos

✅ Asignar [quotas de recursos](https://kubernetes.io/docs/concepts/policy/resource-quotas/) a diferentes proyectos / equipos / clientes

✅ Aislar mediante el uso de políticas a qué puede acceder un usuario

⛔ Diferenciar versiones de una aplicación

notes:

En [este enlace](https://kubernetes.io/docs/tasks/administer-cluster/namespaces/#understanding-the-motivation-for-using-namespaces)
se explica cuál es la motivación para usar `Namespaces`

Durante el curso los estamos utilizado para aislar los direrentes proyectos (talleres) que realizamos.

^^^^^^

### `Namespaces`

```shell [3-6]
$ kubectl get namespaces
NAME                   STATUS   AGE
default                Active   82d
kube-node-lease        Active   82d
kube-public            Active   82d
kube-system            Active   82d
kubernetes-dashboard   Active   4d19h
demo-clusterip         Active   11h
demo-externalname      Active   3d23h
demo-healthchecks      Active   23h
demo-loadbalancer      Active   4d
demo-nodeport          Active   4d11h
demo-nodeselector      Active   12h
demo-statefulsets      Active   25d
```

* `default`: objetos sin `Namespace`
* `kube-system`: Objetos creados por el sistema
* `kube-public`: Permiso de lectura por parte de todos los usuarios (incluidos
  usuarios no autenticados). Usado por el sistema
* `kube-node-lease`: saber si un nodo está respondiendo o no

notes:

* `public`: Este espacio de nombres es utilizado por kubernetes para poder
  compartir recursos / objetos que necesiten permiso de lectura en todo el cluster.
  Que este `Namespace` sea público es un convenio, no es un requisito del
  cluster.
* `kube-node-lease`: Los objetos [`Lease`](https://kubernetes.io/docs/reference/kubernetes-api/cluster-resources/lease-v1/) 
  permiten al _control plane_ del cluster
  enviar los [_hearbeats_](https://kubernetes.io/docs/concepts/architecture/nodes/#heartbeats)
  de control para saber si un nodo sigue activo o se ha caído

^^^^^^

### `Namespaces`

Uso: opción `-n` o `--namespace` del comando `kubectl`

```shell
$ kubectl get pods -n <NAMESPACE>
```


^^^^^^

### `Namespaces`

Cambiar el `Namespace` utilizado por `kubectl`

```shell
$ kubectl config set-context --current --namespace=<NAMESPACE>
```

^^^^^^

### `Namespaces` y _service discovery_

Cuando se crea un servicio dentro de un espacio de nombres, el nombre del servicio será:

`<service-name>.<namespace-name>.svc.<cluter-name>`

Para poder acceder a un servicio en otro `Namespace` debemos utilizar el nombre de dominio 
cualificado (FQDN)

notes:

Veremos más información sobre _service discovery_ en una sección posterior del curso

^^^^^^

#### No todos los objetos tienen un `Namespace`

```shell
$ kubectl api-resources --namespaced=false
```

notes:

Hay ciertos objetos de Kubernetes que no pertenecen a ningún espacio de nombres, por ejemplo
los nodeos, `StorageClasses`, los propios `Namespaces`, `PersistentVolumes` o
`CustomResourceDefinitions` por nombrar algunos.

^^^^^^

### Crear un `Namespace`

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: nombre-del-namespace
```
El nombre de cumplir con estos requisitos:
* Máximo 63 caracteres
* `[a-zA-Z0-9]` y `-`
* empezar y acabar con una letra o un número

notes:

También se puede crear usando el comando `kubectl create namespace nombre-del-namespace`

El nombre tiene que ser un [nombre DNS válido](https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#dns-label-names)

