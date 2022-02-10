# Actualización de un `Deployment`

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `minikube`

## La aplicación

Para poder hacer este taller, es necesario que la versión 1.0 de la imagen
`kubernetescourse/foo-website` esté desplegada en Minikube.

Para desplegar esta imagen, sigue los pasos del taller 
[Creación de un `Deployment`](../create/README_es.md)

## `Namespace`

Utilizaremos el espacio de nombres `demo-deployment` creado en el taller 
[Creación de un `Deployment`](../create/README_es.md).

## Actualización de la imagen

En Minikube tenemos el siguiente `Deployment` desplegado:

```shell
$ kubectl get deployments -o wide -n demo-deployment
NAME          READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS    IMAGES                             SELECTOR
foo-website   3/3     3            3           36m   foo-website   kubernetescourse/foo-website:1.0   app=foo-website-pod
```

Nuestros `Pods` tienen actualmente la imagen `kubernetescourse/foo-website:1.0`.

Podemos pasar a la versión 2.0 de tres maneras:
* Editando el fichero [`deployment.yml`](./deployment-v2.0.yml#L12), cambiando la imagen y aplican
  el nuevo estado con `kubectl apply -f deployment.yml`
* Con el comando `kubectl set image deployment/foo-website foo-website=kubernetescourse/foo-website:2.0 -n demo-deployment`
* Con el comando `kubectl edit deployment/foo-website -n demo-deployment`

_Nota: puedes ejecutar el script `show_info.sh` para ver la salida de los siguientes comandos durante la actualización._

Para llevar a cabo la actualización, el objeto `Deployment` hace lo siguiente:
* Crea un nuevo `ReplicaSet`
* Escala el nuevo `ReplicaSet` a 1 réplica y el antiguo a 2 réplicas. De esta forma, se asegura que como máximo tenemos
  4 `Pods` creados (número de réplicas más uno)
* Cuando este `Pod` esta _ready_, escala el nuevo `ReplicaSet`a dos réplicas y el viejo a una réplica
* Sigue este proceso hasta que todos los `Pods` han sido sustituidos

Podemos ver el estado de la actualización utilizando el comando `kubectl rollout`

```shell
$ kubectl rollout status deployment/foo-website -n demo-website
Waiting for deployment "foo-website" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "foo-website" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "foo-website" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "foo-website" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "foo-website" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "foo-website" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "foo-website" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "foo-website" rollout to finish: 1 old replicas are pending termination...
deployment "foo-website" successfully rolled out
```

Si durante el proceso miramos los `Pods`, veremos cómo se van creando los nuevos y eliminando los antiguos:

```shell
$ kubectl get pods -n demo-deployment
NAME                           READY   STATUS        RESTARTS   AGE
foo-website-5f76c5545b-bbpgl   1/1     Terminating   0          5m22s
foo-website-67f488cc85-tsg44   1/1     Running       0          6s
foo-website-67f488cc85-txt7n   1/1     Running       0          3s
foo-website-67f488cc85-w2rcl   1/1     Running       0          2s
```

Si vemos los objetos `ReplicaSet`, veremos el antiguo y el nuevo:

```shell
$ kubectl get rs -n demo-deployment
NAME                     DESIRED   CURRENT   READY   AGE
foo-website-5f76c5545b   0         0         0       5m22s
foo-website-67f488cc85   3         3         3       6s
```

Podemos ver el procesmo que hemos descrito arriba de creación y destrucción de réplicas usando `kubectl describe`

```shell
$ kubectl describe deployment foo-website -n demo-deployment
Name:                   foo-website
Namespace:              demo-deployment
CreationTimestamp:      Thu, 10 Feb 2022 05:57:07 +0100
Labels:                 app=foo-website
Annotations:            deployment.kubernetes.io/revision: 2
Selector:               app=foo-website-pod
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=foo-website-pod
  Containers:
   foo-website:
    Image:        kubernetescourse/foo-website:2.0
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   foo-website-67f488cc85 (3/3 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  5m23s  deployment-controller  Scaled up replica set foo-website-5f76c5545b to 3
  Normal  ScalingReplicaSet  7s     deployment-controller  Scaled up replica set foo-website-67f488cc85 to 1
  Normal  ScalingReplicaSet  4s     deployment-controller  Scaled down replica set foo-website-5f76c5545b to 2
  Normal  ScalingReplicaSet  4s     deployment-controller  Scaled up replica set foo-website-67f488cc85 to 2
  Normal  ScalingReplicaSet  3s     deployment-controller  Scaled down replica set foo-website-5f76c5545b to 1
  Normal  ScalingReplicaSet  3s     deployment-controller  Scaled up replica set foo-website-67f488cc85 to 3
  Normal  ScalingReplicaSet  1s     deployment-controller  Scaled down replica set foo-website-5f76c5545b to 0
```


## Siguiente paso

En el [siguiente taller](../rollback/README_es.md), veremos cómo podemos deshacer una actualización de un `Deployment`.

## Limpieza

---

⚠️ No borres los objetos si vas a realizar el siguiente taller.

---

Para borrar todos los objetos, basta con borrar el espacio de nombres:

```shell
$ kubectl delete -f namespace.yml
namespace "demo-deployment" deleted
```