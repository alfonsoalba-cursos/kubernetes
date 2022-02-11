# Actualización de un `Deployment`: _Rollback_ 

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `minikube`

## La aplicación

Para poder hacer este taller, es necesario haber realizado los talleres 
[Creación de un `Deployment`](../create/README_es.md) y 
[`Actualización de un `Deployment`](../update/README_es.md)
para poder dar marcha atrás.

## `Namespace`

Utilizaremos el espacio de nombres `demo-deployment` creado en el taller 
[Creación de un `Deployment`](../create/README_es.md).

## Dar marcha atrás

Lo primero que vamos a hacer es mirar cuántas revisiones tenemos almacenadas en el histórico de
nuestro `Deployment`:

```shell
$ kubectl rollout history deployment/foo-website -n demo-deployment
deployment.apps/foo-website 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
```

La columna `CHANGE_CAUSE` se lee de la anotación `kubernetes.io/change-cause`. No nos aparece nada porque 
no la hemos usado cuando actualizamos la página a la versión 2.0.

Podemos ver los detalles de una revisión usando el siguiente comando:

```shell
$ kubectl rollout history deployment/foo-website -n demo-deployment --revision 2

deployment.apps/foo-website with revision #2
Pod Template:
  Labels:       app=foo-website-pod
        pod-template-hash=67f488cc85
  Containers:
   foo-website:
    Image:      kubernetescourse/foo-website:2.0
    Port:       80/TCP
    Host Port:  0/TCP
    Environment:        <none>
    Mounts:     <none>
  Volumes:      <none>
```

Para ir a la versión anterior, ejecutamos

```shell
$ kubectl rollout undo deployment/foo-website -n demo-deployment
```

Mientras este comando se ejecuta, puedes ver lo que está ocurriendo. Para ello puedes
ejecutar el script `../update/show_info.sh`

Al ejecutar el comando, se aumentará el número de réplicas del `ReplicaSet` de la revisión 1 a la vez que
se reduce el número de réplicas del `ReplicaSet` de la revisión 2. En este caso no se crea un nuevo `ReplicaSet`.
El estado final de los objetos `ReplicaSet` es el siguiente:

```shell
$ kubectl get rs -n demo-deployment
NAME                     DESIRED   CURRENT   READY   AGE
foo-website-5f76c5545b   3         3         3       12h
foo-website-67f488cc85   0         0         0       12h
```

Si listamos las revisiones, veremos que se ha creado una nueva revisión:

```shell
$ kubectl rollout history deployment/foo-website -n demo-deployment             
deployment.apps/foo-website 
REVISION  CHANGE-CAUSE
2         <none>
3         <none>
```
En este momento estamos viendo la versión 1.0 de la imagen, información que podemos ver utilizando el comando:

```shell
kubectl rollout history deployment/foo-website -n demo-deployment --revision 3 
deployment.apps/foo-website with revision #3
Pod Template:
  Labels:       app=foo-website-pod
        pod-template-hash=5f76c5545b
  Containers:
   foo-website:
    Image:      kubernetescourse/foo-website:1.0
    Port:       80/TCP
    Host Port:  0/TCP
    Environment:        <none>
    Mounts:     <none>
  Volumes:      <none>
```

Volvamos a la revisión 2:

```shell
$ kubectl rollout undo deployment/foo-website --to-revision=2 -n demo-deployment
deployment.apps/foo-website rolled back
```


<details>
<summary>Salida del script <code>show_info.sh</code></summary>

En el primer comando se observa muy bien cómo se aumentan y disminuyen las réplicas de los dos `ReplicaSets`
del `Deployment`. 

```shell
$ kubectl get rs -n demo-deployment
NAME                     DESIRED   CURRENT   READY   AGE
foo-website-5f76c5545b   2         2         2       12h
foo-website-67f488cc85   2         2         1       12h


$ kubectl get pods -n demo-deployment
NAME                           READY   STATUS    RESTARTS   AGE
foo-website-5f76c5545b-g4f8k   1/1     Running   0          11m
foo-website-5f76c5545b-t7z7n   1/1     Running   0          11m
foo-website-67f488cc85-c7sv6   1/1     Running   0          1s
foo-website-67f488cc85-hb984   1/1     Running   0          3s


$ kubectl describe deployment foo-website -n demo-deployment
Name:                   foo-website
Namespace:              demo-deployment
CreationTimestamp:      Thu, 10 Feb 2022 05:57:07 +0100
Labels:                 app=foo-website
Annotations:            deployment.kubernetes.io/revision: 4
Selector:               app=foo-website-pod
Replicas:               3 desired | 3 updated | 4 total | 3 available | 1 unavailable
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
  Progressing    True    ReplicaSetUpdated
OldReplicaSets:  foo-website-5f76c5545b (1/1 replicas created)
NewReplicaSet:   foo-website-67f488cc85 (3/3 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  11m   deployment-controller  Scaled up replica set foo-website-5f76c5545b to 1
  Normal  ScalingReplicaSet  11m   deployment-controller  Scaled down replica set foo-website-67f488cc85 to 2
  Normal  ScalingReplicaSet  11m   deployment-controller  Scaled up replica set foo-website-5f76c5545b to 2
  Normal  ScalingReplicaSet  11m   deployment-controller  Scaled down replica set foo-website-67f488cc85 to 1
  Normal  ScalingReplicaSet  11m   deployment-controller  Scaled up replica set foo-website-5f76c5545b to 3
  Normal  ScalingReplicaSet  11m   deployment-controller  Scaled down replica set foo-website-67f488cc85 to 0
  Normal  ScalingReplicaSet  2s    deployment-controller  Scaled up replica set foo-website-67f488cc85 to 1
  Normal  ScalingReplicaSet  0s    deployment-controller  Scaled down replica set foo-website-5f76c5545b to 2
  Normal  ScalingReplicaSet  0s    deployment-controller  Scaled up replica set foo-website-67f488cc85 to 2
  Normal  ScalingReplicaSet  0s    deployment-controller  Scaled down replica set foo-website-5f76c5545b to 1
  Normal  ScalingReplicaSet  0s    deployment-controller  Scaled up replica set foo-website-67f488cc85 to 3
```
</details>

## Actualización a la versión 3.0

Hacemos una última actulización a la versión 3.0. Para ello, utilizamos fichero [`deployment-v3.0.yml`](./deployment-v3.0.yml):

```shell
$ kubectl apply -f deployment-v3.0.yml
```

Al igual que en ocasiones anteriores, podemos ver el progreso utilizando el script `../update/show_info.sh`.

<details>
<summary>Salida del script <code>show_info.sh</code></summary>

```shell
$ kubectl get rs
NAME                     DESIRED   CURRENT   READY   AGE
foo-website-5f76c5545b   0         0         0       13h
foo-website-67f488cc85   3         3         3       13h
foo-website-6c9689f58d   1         1         0       1s


$ kubectl get pods
NAME                           READY   STATUS              RESTARTS   AGE
foo-website-67f488cc85-c7sv6   1/1     Running             0          28m
foo-website-67f488cc85-hb984   1/1     Running             0          28m
foo-website-67f488cc85-x295k   1/1     Running             0          28m
foo-website-6c9689f58d-dbr2h   0/1     ContainerCreating   0          2s


$ kubectl describe deployment foo-website -n demo-deployment
Name:                   foo-website
Namespace:              demo-deployment
CreationTimestamp:      Thu, 10 Feb 2022 05:57:07 +0100
Labels:                 app=foo-website
Annotations:            deployment.kubernetes.io/revision: 5
                        kubernetes.io/change-cause: image updated to version 3.0
Selector:               app=foo-website-pod
Replicas:               3 desired | 1 updated | 4 total | 3 available | 1 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=foo-website-pod
  Containers:
   foo-website:
    Image:        kubernetescourse/foo-website:3.0
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    ReplicaSetUpdated
OldReplicaSets:  foo-website-67f488cc85 (3/3 replicas created)
NewReplicaSet:   foo-website-6c9689f58d (1/1 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  39m   deployment-controller  Scaled up replica set foo-website-5f76c5545b to 1
  Normal  ScalingReplicaSet  39m   deployment-controller  Scaled down replica set foo-website-67f488cc85 to 2
  Normal  ScalingReplicaSet  39m   deployment-controller  Scaled up replica set foo-website-5f76c5545b to 2
  Normal  ScalingReplicaSet  39m   deployment-controller  Scaled down replica set foo-website-67f488cc85 to 1
  Normal  ScalingReplicaSet  39m   deployment-controller  Scaled up replica set foo-website-5f76c5545b to 3
  Normal  ScalingReplicaSet  39m   deployment-controller  Scaled down replica set foo-website-67f488cc85 to 0
  Normal  ScalingReplicaSet  28m   deployment-controller  Scaled up replica set foo-website-67f488cc85 to 1
  Normal  ScalingReplicaSet  28m   deployment-controller  Scaled down replica set foo-website-5f76c5545b to 2
  Normal  ScalingReplicaSet  28m   deployment-controller  Scaled up replica set foo-website-67f488cc85 to 2
  Normal  ScalingReplicaSet  28m   deployment-controller  Scaled down replica set foo-website-5f76c5545b to 1
  Normal  ScalingReplicaSet  28m   deployment-controller  Scaled up replica set foo-website-67f488cc85 to 3
  Normal  ScalingReplicaSet  28m   deployment-controller  Scaled down replica set foo-website-5f76c5545b to 0
  Normal  ScalingReplicaSet  1s    deployment-controller  Scaled up replica set foo-website-6c9689f58d to 1
```

</details>


Si miramos las revisiones, veremos una nueva:

```shell
$  kubectl rollout history deployment/foo-website -n demo-deployment
deployment.apps/foo-website 
REVISION  CHANGE-CAUSE
3         <none>
4         <none>
5         image updated to version 3.0
```

que en este caso nos muestra información en la columna `CHANGE-CAUSE` gracias a la anotación que hemos hecho en el
fichero [`deployment-v3.0.yml`](./deployment-v3.0.yml)

Esta actualización genera un nuevo objeto `ReplicaSet`:

```shell
$ kubectl get rs -n demo-deployment
NAME                     DESIRED   CURRENT   READY   AGE
foo-website-5f76c5545b   0         0         0       13h
foo-website-67f488cc85   0         0         0       13h
foo-website-6c9689f58d   3         3         3       12m
```

## Siguiente paso

En el siguiente taller, veremos los estados de un `Deployment` y revertiremos una actualización fallida.

## Limpieza

---

⚠️ No borres los objetos si vas a realizar el siguiente taller.

---

Para borrar todos los objetos, basta con borrar el espacio de nombres:

```shell
$ kubectl delete -f namespace.yml
namespace "demo-deployment" deleted
```