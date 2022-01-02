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

## Actualizar la versión de la imagen usando particiones

En el siguiente paso, vamos a dar marcha atrás y vamos a volver a instalar la versión 0.7
de nuestra imagen. Utilizaremos el parámetro `spec.UpdateStrategy.RollingUpdate.partition=2`
(en el `Rollout` de la anterior sección se uso el valor por defecto, que es cero).

Si ponemos una partición con un valor N, los `Pods` cuyo ordinal sea menor que la
partición, no se modificarán. En este caso, `web-0` y `web-1` mantendrán la versión
0.8 y `web-2` se bajará a la versión 0.7.

Como ya hemos hecho en laboratorios anteriores de esta sección, vamos a utilizar una
terminal para observar la salida del siguiente comando:

```shell
$ kubectl get pods -w -n demo-statefulsets
NAME    READY   STATUS    RESTARTS   AGE
web-0   1/1     Running   0          10m
web-1   1/1     Running   0          10m
web-2   1/1     Running   0          11m
```

Aplicamos el siguiente manifiesto 
[`statefulset-rollback-to-version-0-7-with-partition.yml`](./statefulset-rollback-to-version-0-7-with-partition.yml):

```shell
$ kubectl apply -f statefulset-rollback-to-version-0-7-with-partition.yml statefulset-rollback-to-version-0-7-with-partition.yml
statefulset.apps/web
```

Si miramos la salida del comando en la primera terminal:

```shell
kubectl get pods -w -n demo-statefulsets
NAME    READY   STATUS    RESTARTS   AGE
web-0   1/1     Running   0          13h
web-1   1/1     Running   0          13h
web-2   1/1     Running   0          13h
web-2   1/1     Terminating   0          13h
web-2   1/1     Terminating   0          13h
web-2   0/1     Terminating   0          13h
web-2   0/1     Terminating   0          13h
web-2   0/1     Terminating   0          13h
web-2   0/1     Pending       0          0s
web-2   0/1     Pending       0          0s
web-2   0/1     ContainerCreating   0          0s
web-2   0/1     ContainerCreating   0          10s
web-2   1/1     Running             0          10s
```

vemos que sólo se ha cambiado el `Pod` `web-2`. Si miramos qué imagen tiene cada uno de los `Pods`:

```shell
$ for I in $(seq 0 2); do echo web-$I: $(kubectl get pod web-$I -n demo-statefulsets -o jsonpath="{..spec.containers[0].image}"); done
web-0: k8s.gcr.io/nginx-slim:0.8
web-1: k8s.gcr.io/nginx-slim:0.8
web-2: k8s.gcr.io/nginx-slim:0.7
```

Ahora vamos a ejecutar el comando `kubectl patch` para cambiar el parámetro partition
y volver hacia atrás, por este orden, `web-1` y `web-0`. Empecemos con `web-1`:

```shell
$ kubectl patch statefulset web -n demo-statefulsets -p '{"spec":{"updateStrategy":{"type":"RollingUpdate","rollingUpdate":{"partition":1}}}}'
statefulset.apps/web patched
```

Tras unos segundos (podemos ver la primera consola para saber cuándo el `Pod` vuelve a
estar ejecutándose), `web-1` estará ejecutando la versión `0.7`:

```shell
$ for I in $(seq 0 2); do echo web-$I: $(kubectl get pod web-$I -n demo-statefulsets -o jsonpath="{..spec.containers[0].image}"); done
web-0: k8s.gcr.io/nginx-slim:0.8
web-1: k8s.gcr.io/nginx-slim:0.7
web-2: k8s.gcr.io/nginx-slim:0.7
```

Cambiemos por último la versión de `web-0`:

```shell
$ kubectl patch statefulset web -n demo-statefulsets -p '{"spec":{"updateStrategy":{"type":"RollingUpdate","rollingUpdate":{"partition":0}}}}'
statefulset.apps/web patched

$ for I in $(seq 0 2); do echo web-$I: $(kubectl get pod web-$I -n demo-statefulsets -o jsonpath="{..spec.containers[0].image}"); done
web-0: k8s.gcr.io/nginx-slim:0.7
web-1: k8s.gcr.io/nginx-slim:0.7
web-2: k8s.gcr.io/nginx-slim:0.7
```

## Actualizando los Pods con la estrategia `OnDelete`

En el último paso de este taller, vamos a actualizar de nuevo a la versión 0.8 de nuestra imagen
pero utilizando la estrategia `OnDelete`.

Utilizamos la primera terminal para observar la salida del siguiente comando:

```shell
$ kubectl get pods -w -n demo-statefulsets
NAME    READY   STATUS    RESTARTS   AGE
web-0   1/1     Running   0          10m
web-1   1/1     Running   0          10m
web-2   1/1     Running   0          11m
```

Aplicamos el manifiesto 
[`statefulset-rollout-version-0-8-using-on-delete.yml`](./statefulset-rollout-version-0-8-using-on-delete.yml):

```shell
 $ kubectl apply -f .\statefulset-rollout-version-0-8-using-on-delete.yml
 statefulset.apps/web configured
 ```

 No se actualizará ninguna imagen, todos los `Pods` continúan en la versión 0.7:

 ```shell
 $ for I in $(seq 0 2); do echo web-$I: $(kubectl get pod web-$I -n demo-statefulsets -o jsonpath="{..spec.containers[0].image}"); done
web-0: k8s.gcr.io/nginx-slim:0.7
web-1: k8s.gcr.io/nginx-slim:0.7
web-2: k8s.gcr.io/nginx-slim:0.7
```

Borremos el `Pod` `web-2`:

```shell
$ kubectl delete pod web-2 -n demo-statefulsets
pod "web-2" deleted
```

En la primera terminal podemos ver cómo evoluciona el proceso:

```shell
$ kubectl get pods -w -n demo-statefulsets
NAME    READY   STATUS    RESTARTS   AGE
web-0   1/1     Running   0          10m
web-1   1/1     Running   0          10m
web-2   1/1     Running   0          11m
web-2   1/1     Terminating         0          20m
web-2   1/1     Terminating         0          20m
web-2   0/1     Terminating         0          20m
web-2   0/1     Pending             0          0s
web-2   0/1     Pending             0          0s
web-2   0/1     ContainerCreating   0          0s
web-2   0/1     ContainerCreating   0          24s
web-2   0/1     ContainerCreating   0          34s
web-2   1/1     Running             0          36s
```

Una vez `web-2` está arriba, podemos verificar que versión está ejecutando es
la 0.8:

```shell
$ for I in $(seq 0 2); do echo web-$I: $(kubectl get pod web-$I -n demo-statefulsets -o jsonpath="{..spec.containers[0].image}"); done
web-0: k8s.gcr.io/nginx-slim:0.7
web-1: k8s.gcr.io/nginx-slim:0.7
web-2: k8s.gcr.io/nginx-slim:0.8
```

Repetimos el proceso con `web-1` y `web-0`:

```shell
$ kubectl delete pod web-1 -n demo-statefulsets
pod "web-1" deleted

(... esperar a que está levantado de nuevo...)

$ kubectl delete pod web-0 -n demo-statefulsets
pod "web-0" deleted
```

Al final del proceso, volveremos a tener todos los `Pods` usando la versión 
0.8:

```shell
$ for I in $(seq 0 2); do echo web-$I: $(kubectl get pod web-$I -n demo-statefulsets -o jsonpath="{..spec.containers[0].image}"); done
web-0: k8s.gcr.io/nginx-slim:0.8
web-1: k8s.gcr.io/nginx-slim:0.8
web-2: k8s.gcr.io/nginx-slim:0.8
```

## Limpieza

Para terminar el taller, dejamos el cluster en el estado inicial, con todos los
`Pods` en la versión 0.7:

```shell
$ kubectl apply -f ../create/statefulset.yml
statefulset.apps/web configured
```

Tras unos minutos, los `Pods` volverán a crearse con la versión 0.7 y estarán
configurados para con un el `updateStrategy` de tipo `RollingUpdate`.

