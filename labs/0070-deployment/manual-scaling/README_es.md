# Escalando horizontalmente de manera manual

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `minikube`

## La aplicación

Para poder hacer este taller, es necesario haber realizado los talleres 
[Creación de un `Deployment`](../create/README_es.md),
[`Actualización de un `Deployment`](../update/README_es.md)

## `Namespace`

Utilizaremos el espacio de nombres `demo-deployment` creado en el taller 
[Creación de un `Deployment`](../create/README_es.md).

## Aumentando el número de réplicas

Vamos a aumentar el número de réplicas a 10. Para ello utilizaremos el fichero [`deployment`](./deployment.yml) y
el comando  `kubectl apply`:

```shell
$ kubectl apply -f deployment.yml
```

Durante el proceso de creación, podemos ejecutar el script `../create/show_info.sh` que nos mostrará la salida de varios 
comandos.

Durante el proceso, el `Deployment` mostrará el estado `Available | False | MinimumReplicasUnavailable` mientras se va aumentando el número de réplicas:

```shell
$ kubectl describe deployment foo-website -n demo-deployment
Name:                   foo-website
Namespace:              demo-deployment
CreationTimestamp:      Thu, 10 Feb 2022 05:57:07 +0100
Labels:                 app=foo-website
Annotations:            deployment.kubernetes.io/revision: 11
                        kubernetes.io/change-cause: image updated to version 4.0
Selector:               app=foo-website-pod
Replicas:               10 desired | 10 updated | 10 total | 4 available | 6 unavailable
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
  Progressing    True    NewReplicaSetAvailable
  Available      False   MinimumReplicasUnavailable
OldReplicaSets:  <none>
NewReplicaSet:   foo-website-6c9689f58d (10/10 replicas created)
Events:
  Type    Reason             Age                    From                   Message
  ----    ------             ----                   ----                   -------
  Normal  ScalingReplicaSet  3m35s (x2 over 5m42s)  deployment-controller  Scaled up replica set foo-website-594b9cdf57 to 3
  Normal  ScalingReplicaSet  3m35s (x2 over 5m42s)  deployment-controller  Scaled up replica set foo-website-594b9cdf57 to 5
  Normal  ScalingReplicaSet  3m25s (x3 over 23h)    deployment-controller  Scaled down replica set foo-website-594b9cdf57 to 0
  Normal  ScalingReplicaSet  2m7s (x3 over 5m42s)   deployment-controller  Scaled down replica set foo-website-6c9689f58d to 8
  Normal  ScalingReplicaSet  97s (x2 over 18m)      deployment-controller  Scaled down replica set foo-website-6c9689f58d to 3
  Normal  ScalingReplicaSet  4s (x5 over 23h)       deployment-controller  Scaled up replica set foo-website-6c9689f58d to 10
```

Si listamos los `Pod` durante el proceso:

```shell
$ kubectl get pods -n demo-deployment
NAME                           READY   STATUS              RESTARTS   AGE
foo-website-6c9689f58d-6868p   1/1     Running             0          23h
foo-website-6c9689f58d-8td98   1/1     Running             0          23h
foo-website-6c9689f58d-dbr2h   1/1     Running             0          35h
foo-website-6c9689f58d-fvffs   0/1     ContainerCreating   0          3s
foo-website-6c9689f58d-grwqf   0/1     ContainerCreating   0          3s
foo-website-6c9689f58d-hfhjj   0/1     ContainerCreating   0          3s
foo-website-6c9689f58d-qntth   1/1     Running             0          3s
foo-website-6c9689f58d-skcs4   0/1     ContainerCreating   0          3s
foo-website-6c9689f58d-wcwgn   0/1     ContainerCreating   0          3s
foo-website-6c9689f58d-whfsv   0/1     ContainerCreating   0          3s
```

El estado del `ReplicaSet` nos permite saber cuántas réplicas se han desplegado ya:

```shell
$ kubectl get rs -n demo-deployment
NAME                     DESIRED   CURRENT   READY   AGE
foo-website-594b9cdf57   0         0         0       24h
foo-website-5f76c5545b   0         0         0       2d
foo-website-67f488cc85   0         0         0       2d
foo-website-6c9689f58d   10        10        4       35h
```

## Reduciendo el número de réplicas

Para reducir el número de réplicas, utilizaremos `kubectl scale`:

```shell
$ kubectl scale deployment/foo-website --replicas 3 -n demo-deployment
deployment.apps/foo-website scaled
```

Al final del proceso acabaremos con el número de réplicas solicitado:

```shell
$ kubectl get rs -n demo-deployment
NAME                     DESIRED   CURRENT   READY   AGE
foo-website-594b9cdf57   0         0         0       24h
foo-website-5f76c5545b   0         0         0       2d
foo-website-67f488cc85   0         0         0       2d
foo-website-6c9689f58d   3         3         3       35h

$ kubectl get pods -n demo-deployment

NAME                           READY   STATUS    RESTARTS   AGE
foo-website-6c9689f58d-6868p   1/1     Running   0          23h
foo-website-6c9689f58d-8td98   1/1     Running   0          23h
foo-website-6c9689f58d-dbr2h   1/1     Running   0          35h
```


## Limpieza

---

⚠️ No borres los objetos si vas a realizar el siguiente taller.

---

Para borrar todos los objetos, basta con borrar el espacio de nombres:

```shell
$ kubectl delete -f namespace.yml
namespace "demo-deployment" deleted
```