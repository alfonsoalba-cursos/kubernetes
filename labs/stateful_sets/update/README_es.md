# Actualizar un `StatefulSet` usando `RollingUpdates`

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `managed`

## Requisitos previos

Para poder seguir los pasos de este taller, es necesario tener los recursos creados en el taller
anterior: [Crear un StatefulSet](../create). Si estos recursos ya existen en el cluster, puedes
omitir los siguientes comandos y pasar a la siguiente sección:

```shell
$ kubectl create -f ../create/namespace.yml
$ kubectl apply -f ../create/headless-service.yml
$ kubectl apply -f ../create/statefulset.yml
```

## Actualizar la versión la imagen

Nuestros `Pods` están utilizando la versión `k8s.gcr.io/nginx-slim:0.7` de la imagen
y en esta sección vamos a actualizarlos para que utilicen la versión
`k8s.gcr.io/nginx-slim:0.8`.

Como ya hemos hecho en laboratorios anteriores de esta sección, vamos a utilizar una
terminal para observar la salida del siguiente comando:

```shell
$ kubectl get pods -w -n demo-statefulsets
NAME    READY   STATUS    RESTARTS   AGE
web-0   1/1     Running   0          10m
web-1   1/1     Running   0          10m
web-2   1/1     Running   0          11m
```

En una segunda terminal, iniciamos la actualización:

```shell
$ kubectl apply -f statefulset-rollout-version-0-8.yml
statefulset.apps/web configured
```

Esto hará que los `Pods` de nuestro `StatefulSet` se actualicen uno a uno, empezando
con el de índice mayor (`web-2`) y acabando por el de índice menor.

Podemos ejecutar el siguiente comando para ver en qué estado se encuentra el
`RollOut` de nuestro `StatefullSet`:

```shell
kubectl rollout status statefulset/web -n demo-statefulsets -w
Waiting for 1 pods to be ready...
Waiting for 1 pods to be ready...
Waiting for partitioned roll out to finish: 1 out of 3 new pods have been updated...
Waiting for 1 pods to be ready...
Waiting for 1 pods to be ready...
Waiting for partitioned roll out to finish: 2 out of 3 new pods have been updated...
Waiting for 1 pods to be ready...
Waiting for 1 pods to be ready...
partitioned roll out complete: 3 new pods have been updated...
```

Tambien podemos ver cómo se va realizando la actualización usando la salida del
comando que estábamos observando en la primera terminal:

```shell
$ kubectl get pods -w -n demo-statefulsetsNAME    READY   STATUS    RESTARTS   AGE
web-0   1/1     Running   0          13m
web-1   1/1     Running   0          13m
web-2   1/1     Running   0          14m
web-2   1/1     Terminating   0          18m
web-2   1/1     Terminating   0          18m
web-2   0/1     Terminating   0          18m
web-2   0/1     Terminating   0          19m
web-2   0/1     Terminating   0          19m
web-2   0/1     Pending       0          0s
web-2   0/1     Pending       0          0s
web-2   0/1     ContainerCreating   0          0s
web-2   0/1     ContainerCreating   0          0s
web-2   0/1     ContainerCreating   0          33s
web-2   1/1     Running             0          34s
web-1   1/1     Terminating         0          19m
web-1   1/1     Terminating         0          19m
web-1   0/1     Terminating         0          19m
web-1   0/1     Terminating         0          19m
web-1   0/1     Terminating         0          19m
web-1   0/1     Pending             0          0s
web-1   0/1     Pending             0          0s
web-1   0/1     ContainerCreating   0          0s
web-1   0/1     ContainerCreating   0          5s
web-1   1/1     Running             0          6s
web-0   1/1     Terminating         0          18m
web-0   1/1     Terminating         0          18m
web-0   0/1     Terminating         0          18m
web-0   0/1     Terminating         0          19m
web-0   0/1     Terminating         0          19m
web-0   0/1     Pending             0          0s
web-0   0/1     Pending             0          0s
web-0   0/1     ContainerCreating   0          0s
web-0   0/1     ContainerCreating   0          3s
web-0   1/1     Running             0          4s
```

Hasta que el `Pod` `web-2` no se ha actualizado, y el nuevo `Pod` `web-2` no
está `Ready`, no se comienza con la actualización del `Pod` `web-1`.

Podemos verificar la versión de la imagen que se está ejecutando utilizando el
siguiente script:

```shell
$ for I in $(seq 0 2); do echo web-$I: $(kubectl get pod web-$I -n demo-statefulsets -o jsonpath="{..spec.containers[0].image}"); done
web-0: k8s.gcr.io/nginx-slim:0.8
web-1: k8s.gcr.io/nginx-slim:0.8
web-2: k8s.gcr.io/nginx-slim:0.8
```

