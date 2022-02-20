# Arsys: Encuentra el error (`PersistentVolume` y `PersistentVolumeClaim`)

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `managed`

## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-ts-pvandpvc`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-ts-pvandpvc created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                STATUS   AGE
default             Active   34d
demo-ts-pvandpvc       Active   16s
kube-node-lease     Active   34d
kube-public         Active   34d
kube-system         Active   34d
```

Puedes seleccionar este espacio de nombres por defecto ejecutando:

```shell
$ kubectl config set-context --current --namespace demo-ts-pvandpvc
Context "managed" modified.
```

## Creación del volumen físico


Siguiendo los mismos pasos que dimos en el taller 
[# Arsys: Uso de `PersistentVolume` y `PersistentVolumeClaim`](../arsys-pv-and-pvc/README_es.md) creamos un disco HDD de 10GB al que llamaremos `data-ts-hdd`.

Una vez creado el disco, creamos el fichero [`persistent-volume.yml`](./persistent-volume.yml). Necesitarás adaptar los parámetros de ese fichero e incluir los valores de tu
disco.

## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-ts-pvandpvc`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-ts-pvandpvc created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                STATUS   AGE
default             Active   34d
demo-ts-pvandpvc    Active   16s
kube-node-lease     Active   34d
kube-public         Active   34d
kube-system         Active   34d
```

Puedes seleccionar este espacio de nombres por defecto ejecutando:

```shell
$ kubectl config set-context --current --namespace demo-ts-pvandpvc
Context "managed" modified.
```

## Crear los objetos

Creamos todos los objetos:

```shell
$ kubectl apply -f persistent-volume.yml -f persistent-volume-claim.yml -f pod.yml
persistentvolume/shared-data-ts-volume created
persistentvolumeclaim/shared-data-claim created
pod/test-pod created
```

## ¿Cuál es el problema?

Si miramos el listado de `Pods`, veremos que el `Pod` `test-pod` se queda en estado
`Pending`.

```shell
$ kubectl get pods -n demo-ts-pvandpvc
NAME       READY   STATUS    RESTARTS   AGE
test-pod   0/1     Pending   0          2m13s
```

¿Cuál es el problema?

## Limpieza

Volvemos a poner `default` como espacio de nombres por defecto:

```shell
$ kubectl config set-context --current --namespace default
Context "managed" modified.
```


Para borrar todos los objetos, basta con borrar el espacio de nombres:

```shell
$ kubectl delete -f namespace.yml
namespace "demo-ts-pvandpvc" deleted

$ kubectl delete -f persistent-volume.yml
```

Una vez borrados los objetos de Kubernetes, debemos borrar el volumen en el DCD.