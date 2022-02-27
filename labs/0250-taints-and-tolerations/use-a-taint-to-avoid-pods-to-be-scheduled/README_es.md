# Usando `taints` para evitar que se desplieguen los `Pods` en un nodo.

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `managed`

## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-taints`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-taints created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                        STATUS   AGE
default                     Active   34d
demo-taints                 Active   23s
kube-node-lease             Active   34d
kube-public                 Active   34d
kube-system                 Active   34d
```

Puedes seleccionar este espacio de nombres por defecto ejecutando:

```shell
$ kubectl config set-context --current --namespace demo-taints
Context "managed" modified.
```

## Añadir `taint` a dos nodos

Del listado de nodos de nuestro cluster:

```shell
NAME                       STATUS   ROLES   AGE     VERSION
standardnodes-paka7v2imr   Ready    node    6d12h   v1.21.4
standardnodes-wypldyeewy   Ready    node    6d12h   v1.21.4
standardnodes-zuf5eywgar   Ready    node    6d12h   v1.21.4
```

Seleccionamos dos de ellos, en nuestro ejemplo serán `standardnodes-zuf5eywgar` y `standardnodes-wypldyeewy`, y les
añadiremos el `taint` `memory-optimized=true:NoSchedule`:

```shell
$ kubectl taint nodes standardnodes-zuf5eywgar standardnodes-wypldyeewy memory-optimized=true:NoSchedule
node/standardnodes-zuf5eywgar tainted
node/standardnodes-wypldyeewy tainted
```

Podemos ver los  `taints` que acabamos de añadir usando el comando `kubectl describe`:

```shell
$ kubectl describe node standardnodes-zuf5eywgar
...
Taints:             memory-optimized=true:NoSchedule
...
```

También podemos verlos usando el comando `kubectl get node`:

```shell
$ kubectl get node standardnodes-zuf5eywgar -o jsonpath='{ $.spec.taints }' | jq
[
  {
    "effect": "NoSchedule",
    "key": "memory-optimized",
    "value": "true"
  }
]
```

## `Deployment` sin `tolerations`

Creamos un `Deployment` que desplegará 5 réplicas de la página web de Foo Corporation en nuestro cluster.
El `Deployment` está definido en el fichero [`deployment-without-tolerations.yml`](./deployment-without-tolerations.yml). Este objeto
no define ningún tipo de `Affinity` ni the `tolerations` para los `Pods`:

```shell
$ kubectl apply -f deployment.yml
deployment.apps/foo-website created
```

Tras unos segundos, veremos nuestros `Pods` desplegados en un único nodo, aquel al que no le hemos añadido el `taint`:

```shell
$ kubectl get pods -n demo-taints -o wides
NAME                           READY   STATUS    RESTARTS   AGE   IP              NODE                       NOMINATED NODE   READINESS GATES
foo-website-679fc766c5-bhdf4   1/1     Running   0          14s   10.223.58.119   standardnodes-paka7v2imr   <none>           <none>
foo-website-679fc766c5-rxchn   1/1     Running   0          14s   10.223.58.121   standardnodes-paka7v2imr   <none>           <none>
foo-website-679fc766c5-sm7nk   1/1     Running   0          14s   10.223.58.122   standardnodes-paka7v2imr   <none>           <none>
foo-website-679fc766c5-zgmhb   1/1     Running   0          14s   10.223.58.120   standardnodes-paka7v2imr   <none>           <none>
foo-website-679fc766c5-zsw2z   1/1     Running   0          14s   10.223.58.123   standardnodes-paka7v2imr   <none>           <none>
```

## `Deployment` con `tolerations`

Hagamos una actualización del `Deployment`. Vamos a añadir un `toleration` que sea compatible con el `taint` de los dos nodos.
Usaremos el fichero [`deployment-with-tolerations.yml`](./deployment-with-tolerations.yml). Además de los `tolerations`,
aumentamos el número de réplicas a 10:

```shell
$ kubectl apply -f deployment-with-tolerations.yml
```

Pasados unos segundos que se redesplieguen los `Pods`, veremos que las 10 réplicas que hemos solicitado se han distribuido
por todos los nodos:

```shell
$ kubectl get pods -n demo-taints -o wide
NAME                           READY   STATUS    RESTARTS   AGE   IP              NODE                       NOMINATED NODE   READINESS GATES
foo-website-68d74f84c7-257hf   1/1     Running   0          20s   10.216.183.20   standardnodes-zuf5eywgar   <none>           <none>
foo-website-68d74f84c7-4bqtq   1/1     Running   0          23s   10.212.142.39   standardnodes-wypldyeewy   <none>           <none>
foo-website-68d74f84c7-6ggx5   1/1     Running   0          24s   10.212.142.37   standardnodes-wypldyeewy   <none>           <none>
foo-website-68d74f84c7-6zf2n   1/1     Running   0          28s   10.216.183.17   standardnodes-zuf5eywgar   <none>           <none>
foo-website-68d74f84c7-9bxhd   1/1     Running   0          28s   10.216.183.18   standardnodes-zuf5eywgar   <none>           <none>
foo-website-68d74f84c7-kp4g8   1/1     Running   0          27s   10.223.58.127   standardnodes-paka7v2imr   <none>           <none>
foo-website-68d74f84c7-n4xgg   1/1     Running   0          28s   10.212.142.36   standardnodes-wypldyeewy   <none>           <none>
foo-website-68d74f84c7-ppdjq   1/1     Running   0          23s   10.223.58.73    standardnodes-paka7v2imr   <none>           <none>
foo-website-68d74f84c7-rckx2   1/1     Running   0          27s   10.216.183.22   standardnodes-zuf5eywgar   <none>           <none>
foo-website-68d74f84c7-w5x6r   1/1     Running   0          20s   10.216.183.21   standardnodes-zuf5eywgar   <none>           <none>
```

**El uso de `taint` en dos de los nodos no ha impedido que parte de los `Pods` se desplieguen en aquel que no tiene el `taint` definido**.
Si queremos que los `Pods` sólo se desplieguen en los dos nodos con el `taint`, tendríamos que combinar el `toleration` con
`nodeAffinity`. Como vimos en las diapositivas, el uso de `taint` nos permite confirgurar los nodos para que no acepten 
ciertos `Pods`. Si queremos que un `Pod` se despliegue en uno o varios nodos en particular, debemos usar `NodeAffinity` y/o
`PodAffinity`

El hecho de haber añadido `tolerations` a nuestro `Deployment` y haber realizado una actualización, nos ha generado una nueva versión:

```shell
kubectl rollout history deployment/foo-website -n demo-taints
deployment.apps/foo-website 
REVISION  CHANGE-CAUSE
1         Deploy version without tolerations
2         Deploy version with tolerations
```

Podemos volver a la versión anteriour usando `kubectk rollout undo`

```shell
kubectl rollout undo deployment/foo-website -n demo-taints
deployment.apps/foo-website rolled back
```

Si esperamos unos segundos, veremos de nuevo todos los `Pods` en el nodo en el que no pusimos el `taint`:

```shell
$ kubectl get pods -n demo-taints -o wide
NAME                           READY   STATUS    RESTARTS   AGE   IP             NODE                       NOMINATED NODE   READINESS GATES
foo-website-679fc766c5-542qv   1/1     Running   0          19s   10.223.58.80   standardnodes-paka7v2imr   <none>           <none>
foo-website-679fc766c5-82lm2   1/1     Running   0          18s   10.223.58.70   standardnodes-paka7v2imr   <none>           <none>
foo-website-679fc766c5-h7px9   1/1     Running   0          24s   10.223.58.76   standardnodes-paka7v2imr   <none>           <none>
foo-website-679fc766c5-qh2r8   1/1     Running   0          24s   10.223.58.78   standardnodes-paka7v2imr   <none>           <none>
foo-website-679fc766c5-qwhhg   1/1     Running   0          24s   10.223.58.71   standardnodes-paka7v2imr   <none>           <none>
foo-website-679fc766c5-rg9kz   1/1     Running   0          24s   10.223.58.77   standardnodes-paka7v2imr   <none>           <none>
foo-website-679fc766c5-rz6t7   1/1     Running   0          20s   10.223.58.68   standardnodes-paka7v2imr   <none>           <none>
foo-website-679fc766c5-tcpws   1/1     Running   0          16s   10.223.58.81   standardnodes-paka7v2imr   <none>           <none>
foo-website-679fc766c5-wz2jr   1/1     Running   0          24s   10.223.58.72   standardnodes-paka7v2imr   <none>           <none>
foo-website-679fc766c5-wznrd   1/1     Running   0          15s   10.223.58.82   standardnodes-paka7v2imr   <none>           <none>
```

## Limpieza

Volvemos a poner `default` como espacio de nombres por defecto:

```shell
$ kubectl config set-context --current --namespace default
Context "managed" modified.
```

Para borrar todos los objetos, basta con borrar el espacio de nombres:

```shell
$ kubectl delete -f namespace.yml
namespace "demo-taints" deleted
```

Por último, quitamos el taint del nodo:

```shell
$  kubectl taint node standardnodes-zuf5eywgar standardnodes-wypldyeewy memory-optimized=true:NoSchedule-
node/standardnodes-zuf5eywgar untainted
node/standardnodes-wypldyeewy untainted
```




