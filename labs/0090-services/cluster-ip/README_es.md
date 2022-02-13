# `ClusterIP`

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `minikube`

## La aplicación

Levantaremos una aplicación sin estado utilizando la imagen `gcr.io/google-samples/node-hello:1.0`

## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-clusterip`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-clusterip created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                STATUS   AGE
default             Active   34d
demo-clusterip      Active   14s
kube-node-lease     Active   34d
kube-public         Active   34d
kube-system         Active   34d
```

Puedes seleccionar este espacio de nombres por defecto ejecutando:

```shell
$ kubectl config set-context --current --namespace demo-clusterip
Context "minikube" modified.
```

## `Deployment`

Utilizaremos [este `Deployment`](./deployment.yml), que levantará 5 réplicas de la aplicación
`gcr.io/google-samples/node-hello:1.0`


```shell
$ kubectl apply -f deployment.yml
```

Podemos ver los `Pods` creaándose usando el comando `kubectl get pods`:

```shell
$ kubectl get pods -n demo-clusterip
NAME                              READY   STATUS              RESTARTS   AGE
demo-clusterip-7dd7bdf686-2kw8z   0/1     ContainerCreating   0          33s
demo-clusterip-7dd7bdf686-hzpdd   1/1     Running             0          33s
demo-clusterip-7dd7bdf686-k7jhg   1/1     Running             0          33s
demo-clusterip-7dd7bdf686-khfkn   0/1     ContainerCreating   0          33s
demo-clusterip-7dd7bdf686-rcr8g   0/1     ContainerCreating   0          33s
```

## `Service`

Creamos un [servicio de tipo `ClusterIP`](./service.yml):

```shell
$ kubectl apply -f service.yml
```

Vemos los servicios que tenemos disponibles utlizando `kubectl get services`:

```shell
$  kubectl get services -n demo-clusterip
NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
demo-clusterip   ClusterIP   10.233.39.152   <none>        5555/TCP   14s
```


## Accediendo al servicio

Sólo podemos acceder a este servicio desde dentro del cluster. Por ello, crearemos un 
`Pod` dentro del espacio de nombres con una imagen de `busybox` y nos conectaremos
al servicio desde ese  `Pod`:

```shell
$ kubectl run busybox -ti --image busybox -n demo-clusterip
If you don't see a command prompt, try pressing enter.

/ #
```

Dentro del `Pod` usamos `wget` para acceder al servicio:

```shell
/ # wget -q  -O - 10.233.39.152:5555
Hello Kubernetes!/ # 
```

También podemos acceder usando el nombre del servicio (veremos más información sobre
esto en la sección dedicada a _service discovery_):

```shell
/ # wget -q  -O - demo-clusterip:5555
Hello Kubernetes!/ # 
```

## Objetos

Estos son los objetos creados en Kubernetes en este taller:

```shell
$ kubectl get all -n demo-clusterip
NAME                                  READY   STATUS    RESTARTS   AGE
pod/busybox                           1/1     Running   1          5m32s
pod/demo-clusterip-7dd7bdf686-2kw8z   1/1     Running   0          15m
pod/demo-clusterip-7dd7bdf686-hzpdd   1/1     Running   0          15m
pod/demo-clusterip-7dd7bdf686-k7jhg   1/1     Running   0          15m
pod/demo-clusterip-7dd7bdf686-khfkn   1/1     Running   0          15m
pod/demo-clusterip-7dd7bdf686-rcr8g   1/1     Running   0          15m

NAME                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/demo-clusterip   ClusterIP   10.233.39.152   <none>        5555/TCP   11m

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/demo-clusterip   5/5     5            5           15m

NAME                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/demo-clusterip-7dd7bdf686   5         5         5       15m
```

## Limpieza

Volvemos a poner `default` como espacio de nombres por defecto:

```shell
$ kubectl config set-context --current --namespace default
Context "minikube" modified.
```


Para borrar todos los objetos, basta con borrar el espacio de nombres:

```shell
$ kubectl delete -f namespace.yml
namespace "demo-clusterip" deleted
```