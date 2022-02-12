# Estados de un `Deployment`

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `minikube`

## La aplicación

Para poder hacer este taller, es necesario haber realizado los talleres 
[Creación de un `Deployment`](../create/README_es.md),
[`Actualización de un `Deployment`](../update/README_es.md) y 
[ Actualización de un `Deployment`: _Rollback_ ](../rollback/README_es.md).

## `Namespace`

Utilizaremos el espacio de nombres `demo-deployment` creado en el taller 
[Creación de un `Deployment`](../create/README_es.md).

## Estado: _completed_

Para que un `Deployment` esté completado se tienen que cumplir las siguientes condiciones:
* Todas las réplicas tienen que estar actualizadas a la versión indicada en el `Deployment`
* Todas las réplicas tienen que estar disponibles
* Ninguna de las réplicas antiguas puede estar disponible

Podemos ver el estado de una actualización utilizando el comando `kubectl rollout status`:

```shell
$ kubectl rollout status deployment/foo-website -n demo-deployment
deployment "foo-website" successfully rolled out

$  echo $?
0
```

Este comnado devuelve 0 si la actualización terminó correctamente.

Podemos ver el estado utilizando `kubectl describe` o `kubectl get`:

```shell
$ kubectl get deployment foo-website -n demo-deployment -o json

...

    "status": {
        "availableReplicas": 3,
        "conditions": [
            {
                "lastTransitionTime": "2022-02-10T04:57:22Z",
                "lastUpdateTime": "2022-02-10T04:57:22Z",
                "message": "Deployment has minimum availability.",
                "reason": "MinimumReplicasAvailable",
                "status": "True",
                "type": "Available"
            },
            {
                "lastTransitionTime": "2022-02-10T04:57:07Z",
                "lastUpdateTime": "2022-02-10T18:11:05Z",
                "message": "ReplicaSet \"foo-website-6c9689f58d\" has successfully progressed.",
                "reason": "NewReplicaSetAvailable",
                "status": "True",
                "type": "Progressing"
            }
        ],
...
```

El `Deployment` terminado muestra dos estados:
* `Progressing` que se mantendrá en `True` hasta que se inicie una nueva actualización
* `Available` -> `True`

## Estado: _failed_

Una actualización puede quedarse atascada por varios motivos:
* Quota: no tenemos recursos para ejecutar nuestros `Pods`
* Fallo en los _readiness probes_
* Fallo al descargarse las imágenes
* No tenemos permisos para hacer el despliegue
* Fallo en la aplicación cuando esta se ejecuta

Se puede especficar un _time out_ para que un `Deployment` falle. Este tiempo se especifica en el parámetro
[`spec.progressDeadlineSeconds`](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#progress-deadline-seconds).
Su valor por defecto es de 10 minutos, aunque en el ejemplo que ejecutaremos a continuación lo cambiaremos a 60 segundos.

Cuando este tiempo se supera, el `Deployment` cambia su estado a:

```json
{
    "lastTransitionTime": "...",
    "lastUpdateTime": "...",
    "message": "...",
    "reason": "ProgressDeadlineExceeded",
    "status": "False",
    "type": "Progressing"
}
```

También puede ocurrir que el `Deployment` falle antes de superar este tiempo, por ejemplo porque la aplicación falle, no 
disponga de recursos, etc. En este caso, la razón para el fallo será:

```json
{
    "lastTransitionTime": "...",
    "lastUpdateTime": "...",
    "message": "...",
    "reason": "FailedCreate",
    "status": "True",
    "type": "ReplicaFailure"
}
```

Vamos a intentar actualizar nuestra aplicación a la versión 4.0. Digo _intentar_ porque esta versión no existe. Actualizamos
una vez más nuestro `Deployment` utilizando [`deployment-v4.0.yml`](./deployment-v4.0.yml):

```shell
$ kubectl appy -f deployment-v4.0.yml
deployment.apps/foo-website configured
```

Aparecerá una nueva revisión: 
```shell
$  kubectl rollout history deployment/foo-website -n demo-deployment
deployment.apps/foo-website 
REVISION  CHANGE-CAUSE
3         <none>
4         <none>
5         image updated to version 3.0
6         image updated to version 4.0
```

Con su correspondiente `ReplicaSet`:
```shell
$ kubectl get rs -n demo-deployment
NAME                     DESIRED   CURRENT   READY   AGE
foo-website-594b9cdf57   1         1         0       3m5s <---------------
foo-website-5f76c5545b   0         0         0       24h
foo-website-67f488cc85   0         0         0       24h
foo-website-6c9689f58d   3         3         3       11h  <---------------
```

Si miramos los `Pods`, veremos que no se pudo crear el nuevo `Pod` debido a un fallo al descargar
la imagen:

```shell
$ kubectl get pods -n demo-deployment
NAME                           READY   STATUS             RESTARTS   AGE
foo-website-594b9cdf57-4bk96   0/1     ImagePullBackOff   0          7m16s
foo-website-6c9689f58d-8srck   1/1     Running            0          11h
foo-website-6c9689f58d-dbr2h   1/1     Running            0          11h
foo-website-6c9689f58d-j2pq5   1/1     Running            0          11h
```

Si miramos el estado del `Deployment`:

```shell
$ kubectl rollout status deployment/foo-website -n demo-deployment
Waiting for deployment "foo-website" rollout to finish: 1 out of 3 new replicas have been updated...

(tras 5 minutos...)

error: deployment "foo-website" exceeded its progress deadline
```

Superados los 5 minutos de espera que configuramos en la especificación del `Deployment`, este será el estado 
de nuestro `Deployment`:

```shell
$ kubectl get deployment foo-website -n demo-deployment -o yaml

status:
  availableReplicas: 3
  conditions:
  - lastTransitionTime: "2022-02-10T04:57:22Z"
    lastUpdateTime: "2022-02-10T04:57:22Z"
    message: Deployment has minimum availability.
    reason: MinimumReplicasAvailable
    status: "True"
    type: Available
  - lastTransitionTime: "2022-02-11T05:32:52Z"
    lastUpdateTime: "2022-02-11T05:32:52Z"
    message: ReplicaSet "foo-website-594b9cdf57" has timed out progressing.
    reason: ProgressDeadlineExceeded
    status: "False"
    type: Progressing
```

Una vez se supera el tiempo de espera, el `Pod` fallido sigue apareciendo en el listado de `Pods`:

```shell
$ kubectl get pods -n demo-deployment
NAME                           READY   STATUS             RESTARTS   AGE
foo-website-594b9cdf57-4bk96   0/1     ImagePullBackOff   0          14m
foo-website-6c9689f58d-8srck   1/1     Running            0          11h
foo-website-6c9689f58d-dbr2h   1/1     Running            0          11h
foo-website-6c9689f58d-j2pq5   1/1     Running            0          11h
```

Deshacemos la operación haciendo rollback a la revisión anterior, que en nuestro caso sería la 5:

```shell
$ kubectl rollout undo deployment/foo-website -n demo-deployment --to-revision 5
deployment.apps/foo-website rolled back
```

## Estado: _progressing_ 

Kubernetes marcará el `Deployment` como _progressing_ si se cumple alguna de estas condiciones:

* Se crea un nuevo `ReplicaSet`
* Se está escalando el nuevo o el anterior `ReplicaSet`


El estado del `Pod` se muestra de la siguiente manera:

```json
{
    "lastTransitionTime": "...",
    "lastUpdateTime": "...",
    "message": "...",
    "reason": "NewReplicaSetCreated | FoundNewReplicaSet  | ReplicaSetUpdated",
    "status": "True",
    "type": "Progressing"
}
```

## Siguiente paso

En el [siguiente taller](../manual-scaling/README_es.md), aumentaremos y reduciremos el número de réplicas de forma manual.

## Limpieza

---

⚠️ No borres los objetos si vas a realizar el siguiente taller.

---

Para borrar todos los objetos, basta con borrar el espacio de nombres:

```shell
$ kubectl delete -f namespace.yml
namespace "demo-deployment" deleted
```