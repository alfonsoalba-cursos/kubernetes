# Creación de un `Deployment`

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `minikube`

## La aplicación

Con el objetivo de ilustrar los diferentes conceptos relacionados con los `Deployments`,
levantaremos una aplicación sin estado utilizando la imagen 
`kubernetescourse/foo-website`

## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-deployment`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-deployment created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                STATUS   AGE
default             Active   34d
demo-deployment     Active   14s
kube-node-lease     Active   34d
kube-public         Active   34d
kube-system         Active   34d
```

## `Deployment`

Creamos el [`Deployment`](./deployment.yml):

```shell
$ kubectl apply -f deployment.yml
replicaset.apps/frontend created
```

Listamos los objetos `Deployment` dentro del espacio de nombres:

```shell
$ kubectl get deployment -n demo-deployment
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
foo-website   3/3     3            3           13s
```

Obtenemos los detalles de nuestro `ReplicaSet` usando `kubectl describe`:

```shell
$ > kubectl describe deployment foo-website -n demo-deployment
Name:                   foo-website
Namespace:              demo-deployment
CreationTimestamp:      Wed, 09 Feb 2022 05:06:30 +0100
Labels:                 app=foo-website
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=foo-website-pod
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=foo-website-pod
  Containers:
   foo-website:
    Image:        kubernetescourse/foo-website
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
NewReplicaSet:   foo-website-679fc766c5 (3/3 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  67s   deployment-controller  Scaled up replica set foo-website-679fc766c5 to 3
```

Como podemos ver en la descripción del `Deployment`, se ha creado un `ReplicaSet`.
Este ha sido el responsable de levantar las tres réplicas de nuestra aplicación. Podemos
utilizar el comando `kubectl` para ver este objeto `ReplicaSet`:

```shell
$ kubectl get replicasets -o wide -n demo-deployment
NAME                     DESIRED   CURRENT   READY   AGE     CONTAINERS    IMAGES                         SELECTOR
foo-website-679fc766c5   3         3         3       3m23s   foo-website   kubernetescourse/foo-website   app=foo-website-pod,pod-template-hash=679fc766c5
```

Por último, listemos los `Pods` dentro de nuestro espacio de nombres:

```shell
$ kubectl get pods -n demo-deployment                     
NAME             READY   STATUS    RESTARTS   AGE
NAME                           READY   STATUS    RESTARTS   AGE
foo-website-679fc766c5-2hsrw   1/1     Running   0          4m10s
foo-website-679fc766c5-m5wnm   1/1     Running   0          4m10s
foo-website-679fc766c5-skkpm   1/1     Running   0          4m10s
```

## Ver la página web

Para poder acceder a la página web, creamos un `Service` a través del comando `kubectl expose`:

```shell
$ kubectl expose deployment foo-website --type=NodePort -n demo-deployment 
service/foo-website exposed

$ kubectl get services -n demo-deployment
NAME          TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
foo-website   NodePort   10.98.174.63   <none>        80:30112/TCP   46s
```

Utilizamos `minikube service` para obtener la dirección en la que podemos ver la página web:

```shell
$ minikube service foo-website -n demo-deployment --url
http://192.168.1.155:30112
```

Si abrimos esta URL con el navegador veremos la página web.

## Siguiente paso

En el [siguiente taller](../update/README_es.md), veremos cómo podemos actualizar la versión de la imagen desplegada
por nuestro `Deployment`.
## Limpieza

---

⚠️ No borres los objetos si vas a realizar el siguiente taller.

---

Para borrar todos los objetos, basta con borrar el espacio de nombres:

```shell
$ kubectl delete -f namespace.yml
namespace "demo-deployment" deleted
```