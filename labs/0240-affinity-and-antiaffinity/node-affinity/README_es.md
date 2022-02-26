# Usando `NodeAffinity` para seleccionar los nodos de un `Deployment`

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `managed`

## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-nodeaffinity`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-nodeaffinity created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                        STATUS   AGE
default                     Active   34d
demo-nodeaffinity           Active   12s
kube-node-lease             Active   34d
kube-public                 Active   34d
kube-system                 Active   34d
```

Puedes seleccionar este espacio de nombres por defecto ejecutando:

```shell
$ kubectl config set-context --current --namespace demo-nodeaffinity
Context "managed" modified.
```

## Etiquetamos los nodos

Listamos los nodos usando `kubectl`:

```shell
NAME                       STATUS   ROLES   AGE     VERSION
standardnodes-paka7v2imr   Ready    node    5d17h   v1.21.4
standardnodes-wypldyeewy   Ready    node    5d17h   v1.21.4
standardnodes-zuf5eywgar   Ready    node    5d17h   v1.21.4
```

Asignamos a cada nodo una etiqueta `size=small`, `size=medium` y `size=big`

```shell
$ kubectl label nodes standardnodes-paka7v2imr size=small
node/standardnodes-paka7v2imr labeled

$ kubectl label nodes standardnodes-wypldyeewy size=medium
node/standardnodes-wypldyeewy labeled

$ kubectl label nodes standardnodes-zuf5eywgar size=big   
node/standardnodes-zuf5eywgar labeled
```

## `NodeAffinity`

Utilizando el fichero [`deployment.yml`](./deployment.yml), desplegamos 8 copias de nuestra
aplicación Foo Corporation Website:

```shell
$ kubectl apply -f deployment.yml
deployment.apps/foo-website created
```

Los `Pods` se desplegarán únicamente en dos de los nodos, en el ejemplo que nos ocupa serán
`standardnodes-paka7v2imr` y `standardnodes-wypldyeewy`, que son los que tienen las etiquetas
`size=small` y `size=medium`:

```shell
$ kubectl get pods -o wide
NAME                       READY   STATUS    RESTARTS   AGE   IP              NODE                       NOMINATED NODE   READINESS GATES
cpu-app-6ccd7c9d49-7rrlz   1/1     Running   0          49s   10.223.58.101   standardnodes-paka7v2imr   <none>           <none>
cpu-app-6ccd7c9d49-cwvrb   1/1     Running   0          49s   10.212.142.29   standardnodes-wypldyeewy   <none>           <none>
cpu-app-6ccd7c9d49-gslf7   1/1     Running   0          49s   10.223.58.103   standardnodes-paka7v2imr   <none>           <none>
cpu-app-6ccd7c9d49-mx42k   1/1     Running   0          49s   10.212.142.21   standardnodes-wypldyeewy   <none>           <none>
cpu-app-6ccd7c9d49-ng62c   1/1     Running   0          49s   10.212.142.20   standardnodes-wypldyeewy   <none>           <none>
cpu-app-6ccd7c9d49-qr27d   1/1     Running   0          49s   10.223.58.100   standardnodes-paka7v2imr   <none>           <none>
cpu-app-6ccd7c9d49-swwlk   1/1     Running   0          49s   10.223.58.102   standardnodes-paka7v2imr   <none>           <none>
cpu-app-6ccd7c9d49-tzp4c   1/1     Running   0          49s   10.212.142.9    standardnodes-wypldyeewy   <none>           <none>
```

## Uso de múltiples `nodeSelectorTerms`

Eliminamos el `Deployment` anterior:

```shell
$ kubectl delete deployment foo-website -n demo-nodeaffinity    
deployment.apps "foo-website" deleted
```

Vamos a conseguir el mismo efecto utilizando un `Deployment` que ilustra el uso 
de múltiples `spec.affinity-nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms`:

```yaml
...
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: size
                operator: In
                values:
                - small
            - matchExpressions:
              - key: size
                operator: In
                values:
                - medium   
...
```

Aplicamos el `Deployment` ['deployment-multiple-nodeselectorterms.yml'](./deployment-multiple-nodeselectorterms.yml):

```shell
$ kubectl apply -f deployment-multiple-nodeselectorterms.yml
deployment.apps/foo-website created
```

Si esperamos unos segundos a que los `Pods` se ejecuten, veremos que estos se ejecutan
en los mismos dos nodos:

```shell
$ kubectl get pods -o wide -n demo-nodeaffinity
NAME                           READY   STATUS    RESTARTS   AGE   IP              NODE                       NOMINATED NODE   READINESS GATES
foo-website-5fd5d59d94-2jzd8   1/1     Running   0          41s   10.212.142.31   standardnodes-wypldyeewy   <none>           <none>
foo-website-5fd5d59d94-7plzq   1/1     Running   0          41s   10.223.58.105   standardnodes-paka7v2imr   <none>           <none>
foo-website-5fd5d59d94-b2tvt   1/1     Running   0          41s   10.212.142.26   standardnodes-wypldyeewy   <none>           <none>
foo-website-5fd5d59d94-ffw2x   1/1     Running   0          41s   10.212.142.30   standardnodes-wypldyeewy   <none>           <none>
foo-website-5fd5d59d94-mj7v6   1/1     Running   0          41s   10.223.58.104   standardnodes-paka7v2imr   <none>           <none>
foo-website-5fd5d59d94-s7gvv   1/1     Running   0          41s   10.223.58.107   standardnodes-paka7v2imr   <none>           <none>
foo-website-5fd5d59d94-tgz2k   1/1     Running   0          41s   10.223.58.106   standardnodes-paka7v2imr   <none>           <none>
foo-website-5fd5d59d94-vj74j   1/1     Running   0          41s   10.212.142.27   standardnodes-wypldyeewy   <none>           <none>
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
namespace "demo-nodeaffinity" deleted
```

Por último, quitamos las etiquetas de los nodos:

```shell
$ kubectl label nodes standardnodes-paka7v2imr size-
$ kubectl label nodes standardnodes-wypldyeewy size-
$ kubectl label nodes standardnodes-zuf5eywgar size-
```