# Demostración de cómo funciona `ReplicaSet`

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `minikube`

## La aplicación

Con el objetivo de ilustrar los diferentes conceptos relacionados con los `ReplicaSet`,
levantaremos una aplicación sin estado utilizando la imagen 
`gcr.io/google_samples/gb-frontend:v3`

## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-replicaset`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-replicaset created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                STATUS   AGE
default             Active   34d
demo-replicaset     Active   29s
kube-node-lease     Active   34d
kube-public         Active   34d
kube-system         Active   34d
```

## `ReplicaSet`

Creamos el [`ReplicaSet`](./replica-set.yml):

```shell
$ kubectl apply -f .\replica-set.yml
replicaset.apps/frontend created
```

Listamos los objetos `ReplicaSet` dentro del espacio de nombres:

```shell
kubectl get replicaset -n demo-replicaset 
NAME       DESIRED   CURRENT   READY   AGE
frontend   3         3         3       23s
```

Obtenemos los detalles de nuestro `ReplicaSet` usando `kubectl describe`:

```shell
$ kubectl describe replicaset  frontend -n demo-replicaset
Name:         frontend
Namespace:    demo-replicaset
Selector:     tier=frontend
Labels:       app=guestbook
              tier=frontend
Annotations:  <none>
Replicas:     3 current / 3 desired
Pods Status:  3 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  tier=frontend
  Containers:
   php-redis:
    Image:        gcr.io/google_samples/gb-frontend:v3
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age    From                   Message
  ----    ------            ----   ----                   -------
  Normal  SuccessfulCreate  2m18s  replicaset-controller  Created pod: frontend-mrlbz
  Normal  SuccessfulCreate  2m18s  replicaset-controller  Created pod: frontend-ktzw2
  Normal  SuccessfulCreate  2m18s  replicaset-controller  Created pod: frontend-7898w
```

Por último, listemos los `Pods` dentro de nuestro espacio de nombres:

```shell
$ kubectl get pods -n demo-replicaset                     
NAME             READY   STATUS    RESTARTS   AGE
frontend-7898w   1/1     Running   0          4m18s
frontend-ktzw2   1/1     Running   0          4m18s
frontend-mrlbz   1/1     Running   0          4m18s
```

## Aumentar el número de réplicas

Podemos aumentar el número de réplicas utilizando el comando `kubectl scale`>

```shell
$ kubectl scale --replicas=4 rs/frontend -n demo-replicaset
replicaset.apps/frontend scaled

kubectl get pods -n demo-replicaset
NAME             READY   STATUS    RESTARTS   AGE
frontend-7898w   1/1     Running   0          6m27s
frontend-c4z52   1/1     Running   0          34s
frontend-ktzw2   1/1     Running   0          6m27s
frontend-mrlbz   1/1     Running   0          6m27s
```

También podemos escalarlo editando el fichero `replica-set.yml`, modificando
`spec.replicas: 5` y usar `kubectl apply`:

```shell
$ kubectl apply -f .\replica-set.yml
replicaset.apps/frontend configured

$ kubectl get pods -n demo-replicaset
NAME             READY   STATUS    RESTARTS   AGE
frontend-7898w   1/1     Running   0          7m57s
frontend-c4z52   1/1     Running   0          2m4s
frontend-ktzw2   1/1     Running   0          7m57s
frontend-l7ftz   1/1     Running   0          5s
frontend-mrlbz   1/1     Running   0          7m57s
```

## Disminuir el número de réplicas

Al igual que hicimos en el caso anterior, podemos usar `kubectl scale` o `kubectl apply`:

```shell
$ kubectl scale --replicas=3 rs/frontend -n demo-replicaset
replicaset.apps/frontend scaled

$ kubectl get pods -n demo-replicaset
NAME             READY   STATUS    RESTARTS   AGE
frontend-7898w   1/1     Running   0          9m44s
frontend-ktzw2   1/1     Running   0          9m44s
frontend-mrlbz   1/1     Running   0          9m44s
```

## _Capturando_ `Pods`

Creamos un [`Pod`](./pod.yml) con la etiqueta `ties: frontend` y al que llamaremos `frontend-pod` . Como este nuevo `Pod` coincide con el `MatchSelector` de nuestro 
`ReplicaSet`, este último se encargará de gestionar el `Pod`. Como el `ReplicaSet`
ya tiene todas las réplicas que necesita, borrará el `Pod`. Vamos a verlo.

Creamos el `Pod`

```shell
$ kubectl apply -f pod.yml
pod/frontend-pod created
```

Si listamos los `Pods` veremos que `frontend-pod` no está:

```shell
$ kubectl get pods -n demo-replicaset
NAME             READY   STATUS    RESTARTS   AGE
frontend-7898w   1/1     Running   0          20m
frontend-ktzw2   1/1     Running   0          20m
frontend-mrlbz   1/1     Running   0          20m
```

Miramos el estado de nuestro objeto `ReplicaSet` y veremos que el `Pod` fue borrado:

```shell
$ kubectl describe replicaset frontend -n demo-replicaset
Name:         frontend
Namespace:    demo-replicaset
Selector:     tier=frontend
Labels:       app=guestbook
              tier=frontend
Annotations:  <none>
Replicas:     3 current / 3 desired
Pods Status:  3 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  tier=frontend
  Containers:
   php-redis:
    Image:        gcr.io/google_samples/gb-frontend:v3
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age    From                   Message
  ----    ------            ----   ----                   -------
  Normal  SuccessfulCreate  14m    replicaset-controller  Created pod: frontend-mrlbz
  Normal  SuccessfulCreate  14m    replicaset-controller  Created pod: frontend-ktzw2
  Normal  SuccessfulCreate  14m    replicaset-controller  Created pod: frontend-7898w
  Normal  SuccessfulCreate  8m57s  replicaset-controller  Created pod: frontend-c4z52
  Normal  SuccessfulCreate  6m58s  replicaset-controller  Created pod: frontend-l7ftz
  Normal  SuccessfulDelete  5m11s  replicaset-controller  Deleted pod: frontend-c4z52
  Normal  SuccessfulDelete  5m11s  replicaset-controller  Deleted pod: frontend-l7ftz
  Normal  SuccessfulDelete  62s    replicaset-controller  Deleted pod: frontend-pod
```

## Limpieza

Para borrar todos los objetos, basta con borrar el espacio de nombres:

```shell
$ kubectl delete -f .\namespace.yml
namespace "demo-replicaset" deleted
```