# `NodePort` y _canary deployment_

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `managed`

_Nota: este taller también puede ejecutarse en `minikube` cambiando ligeramente la manera en la que
accedemos al `Service` de tipo `NodePort` que crearemos. En el texto indicaremos cómo hacerlo_

## La aplicación

Con el objetivo de ilustrar los diferentes conceptos relacionados con `NodePort`,
levantaremos una aplicación sin estado utilizando la imagen 
`kubernetescourse/foo-website:1.0`. Configuraremos un `Service` de tipo
`NodePort` para acceder a la aplicación.

Después, llevaremos a cabo una actualización gradual a la versión 2.0 de la web
utlizando el patrón conocido como [_canary deployment_](https://semaphoreci.com/blog/what-is-canary-deployment).

## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-nodeport`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-nodeport created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                STATUS   AGE
default             Active   34d
demo-nodeport       Active   14s
kube-node-lease     Active   34d
kube-public         Active   34d
kube-system         Active   34d
```

Puedes seleccionar este espacio de nombres por defecto ejecutando:

```shell
$ kubectl config set-context --current --namespace demo-nodeport
Context "managed" modified.
```

## `Deployment`

Creamos el [`Deployment`](./deployment.yml):

```shell
$ kubectl apply -f deployment.yml
deployment/foo-website created
```

Listamos los objetos `Deployment` dentro del espacio de nombres:

```shell
$ kubectl get deployment -n demo-nodeport
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
foo-website   5/5     5            5           12s
```

Vemos que las cinco réplicas están ya disponibles.

## Acceder a la página web

### contexto `managed`
Para poder acceder a la página web, creamos un [`Service`](./service.yml) a través 
del comando `kubectl apply`:

```shell
$  kubectl apply -f service.yml
service/foo-website created
```

Listamos los servicios disponibles en nuestro espacio de nombres usando el comando `kubectl get services`

```shell
kubectl get service -n demo-nodeport
NAME          TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
foo-website   NodePort   10.233.21.38   <none>        80:32751/TCP     62s
```

Para acceder a la página web, obtenemos la dirección IP de cualquiera de los nodos
y apuntamos el navegador a la URL `http://<IP>:32751`. Utilizamos el comando
`kubectl get nodes` para ver las direcciones de los nodos:

```shell
$ kubectl get nodes -o wide
NAME                       STATUS   ROLES   AGE     VERSION   INTERNAL-IP   EXTERNAL-IP     OS-IMAGE           
  KERNEL-VERSION     CONTAINER-RUNTIME
standardnodes-dujzurkh2h   Ready    node    6d18h   v1.21.4   <none>        93.93.115.60    Ubuntu 20.04.3 LTS   5.4.0-88-generic   containerd://1.4.11
standardnodes-kmcoj6rtxw   Ready    node    6d18h   v1.21.4   <none>        93.93.115.62    Ubuntu 20.04.3 LTS   5.4.0-88-generic   containerd://1.4.11
standardnodes-pne5yslqsg   Ready    node    6d18h   v1.21.4   <none>        93.93.114.119   Ubuntu 20.04.3 LTS   5.4.0-88-generic   containerd://1.4.11
```

El objeto `Service` balancerá la carga entre los `Pods` que coincidan con el selector definido en 
el servicio:

```yaml
spec:
  selector:
    app: foo-website-pod
```

En [este enlace](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1/#ServiceSpec)
podemos ver el formato de selector que podemos utilizar.

### contexto `minikube`

Si estás haciendo el taller utilizando `minikube`, para poder ver la web utilizaremos el comando `minikube service --url`, que nos
indicará la URL que debemos utilizar:

```shell
$ minikube service foo-website --url -n demo-nodeport
http://192.168.1.162:31795
```

## _Canary deployment_: paso 1

Vamos a actualizar a la versión 2.0 de nuestra web utilizando un _canary deployment_.

Creamos un nuevo `Service` que llamaremos `foo-website-canary` y que guardaremos en el fichero
[`deployment-v 2.0-step1.yml`](./deployment-v 2.0-step1.yml):
* Los `Pods` tendrán las etiquetas siguientes:
  * `app: foo-website-pod`: que hará que el servicio de tipo `NodePort` que ya tenemos active
    envíe tráfico a estos nuevos `Pods`
  * `env: canary`: nos permitirá diferenciar estos `Pods` de los que ya teníamos creados, y que 
    tienen la etiqueta `env: production`

Este nuevo `Deployment` desplegará dos réplicas de la versión 2.0:

```shell
$ kubectl apply -f deployment-v2.0-step1.yml
deployment.apps/foo-website-canary created
```

Veamos los `Deployments` y los `Pods` que tenemos desplegados:

```shell
$  kubectl get deployments -n demo-nodeport
NAME                 READY   UP-TO-DATE   AVAILABLE   AGE
foo-website          5/5     5            5           6m40s
foo-website-canary   2/2     2            2           28s

kubectl get pods -n demo-nodeport        
NAME                                  READY   STATUS    RESTARTS   AGE
foo-website-54fb9c98b4-27n5t          1/1     Running   0          7m53s
foo-website-54fb9c98b4-4qw2t          1/1     Running   0          7m53s
foo-website-54fb9c98b4-8rhs2          1/1     Running   0          7m53s
foo-website-54fb9c98b4-dgql8          1/1     Running   0          7m53s
foo-website-54fb9c98b4-fdtkx          1/1     Running   0          7m53s
foo-website-canary-6bd675c4f8-69cpr   1/1     Running   0          102s
foo-website-canary-6bd675c4f8-ngcnc   1/1     Running   0          102s
```

Si accedemos a la URL `http://<IP>:32751` tenemos una probabilidad de 2/7 de que el objeto
`Service` nos envíe a un `Pod` con la versión 2.0 de nuestra web. 

```shell
$ curl -s 93.93.115.60:32751 | grep VERSION
      <h1 class="display-4 fw-normal">Foo Corporation Services VERSION 2</h1>

$ curl -s 93.93.115.60:32751 | grep VERSION
      <h1 class="display-4 fw-normal">Foo Corporation Services VERSION 1</h1>
```

## _Canary deployment_: paso 2

En el segundo paso, reduciremos el número de replicas del `Deployment` `foo-website` a 3 y aumentaremos 
las del `Deployment` `foo-website-canary` a 3. Para hacerlo, creamos el fichero [`deployment-v2.0-step2.yml`](./deployment-v2.0-step2.yml)

```shell
$ kubectl apply -f .\deployment-v2.0-step2.yml
deployment.apps/foo-website configured
deployment.apps/foo-website-canary configured
```

Si miramos los  `Pods` después de aplicar los cambios a la configuración:

```shell
$ kubectl get pods -n demo-nodeport
NAME                                  READY   STATUS        RESTARTS   AGE
foo-website-54fb9c98b4-4qw2t          1/1     Running       0          32m
foo-website-54fb9c98b4-599gg          0/1     Terminating   0          3m18s
foo-website-54fb9c98b4-8rhs2          1/1     Running       0          32m
foo-website-54fb9c98b4-fdtkx          1/1     Running       0          32m
foo-website-54fb9c98b4-g95wl          0/1     Terminating   0          3m18s
foo-website-canary-6bd675c4f8-69cpr   1/1     Running       0          26m
foo-website-canary-6bd675c4f8-jpgsn   1/1     Running       0          6s
foo-website-canary-6bd675c4f8-ngcnc   1/1     Running       0          26m
```

A partir de este momento tendremos una probabilidad del 50% de ver la versión 2.0 de la página web.

Si miramos los objetos `Deployment`:

```shell
$ kubectl get deployments -n demo-nodeport
NAME                 READY   UP-TO-DATE   AVAILABLE   AGE
foo-website          3/3     3            3           35m
foo-website-canary   3/3     3            3           29m
```

## _Canary deployment_: paso 3

Llevemos a cabo un tercer paso antes de desplegar definitivamente la versión 2.0 en el `Deployment` `foo-website`.

En este tercer paso, reduciremos el número de replicas del `Deployment` `foo-website` a 1 y aumentaremos 
las del `Deployment` `foo-website-canary` a 6. Para hacerlo, creamos el fichero [`deployment-v2.0-step3.yml`](./deployment-v2.0-step3.yml)
y lo aplicaremos:

```shell
kubectl apply -f .\deployment-v2.0-step3.yml
deployment.apps/foo-website configured
deployment.apps/foo-website-canary configured
```

Si miramos los `Pods`:

```shell
$ kubectl get pods -n demo-nodeport       
NAME                                  READY   STATUS    RESTARTS   AGE
foo-website-54fb9c98b4-4qw2t          1/1     Running   0          39m
foo-website-canary-6bd675c4f8-69cpr   1/1     Running   0          33m
foo-website-canary-6bd675c4f8-92rzb   1/1     Running   0          56s
foo-website-canary-6bd675c4f8-f868j   1/1     Running   0          56s
foo-website-canary-6bd675c4f8-jpgsn   1/1     Running   0          7m50s
foo-website-canary-6bd675c4f8-ngcnc   1/1     Running   0          33m
foo-website-canary-6bd675c4f8-p8x29   1/1     Running   0          56s
```

A partir de este momento tendremos una probabilidad del 6/7 de ver la versión 2.0 de la página web.

Si miramos los objetos `Deployment`:

```shell
$ kubectl get deployments -n demo-nodeport    
NAME                 READY   UP-TO-DATE   AVAILABLE   AGE
foo-website          1/1     1            1           39m
foo-website-canary   6/6     6            6           33m
```

## _Canary deployment_: último paso

Llegados a este punto hemos comprobado que la versión 2.0 de la página web está funcionando bien y podemos actualizar
todos nuestros `Pods` a esta versión.

En este último paso, haremos dos cosas:
* Actualizaremos nuestro `Deployment` `foo-website` a la versión 2.0, de la misma forma en la que lo hicimos en el taller
  [Actualización de un `Deployment`](../../0070-deployment/update/README_es.md). Para ello, utilizaremos el fichero 
  [`deployment-v2.0.yml`](./deployment-v2.0.yml)
* Eliminaremos el `Deployment` `foo-website-canary`

```shell
$ kubectl apply -f deployment-v2.0.yml

$ kubectl delete -f deployment-v2.0-step1.yml
```

Podemos ver cómo los `Pods` se van creando y eliminando:

```shell
$ kubectl get pods -n demo-nodeport          
NAME                                  READY   STATUS        RESTARTS   AGE
foo-website-54fb9c98b4-4qw2t          0/1     Terminating   0          47m
foo-website-54fb9c98b4-9l8v5          1/1     Terminating   0          13s
foo-website-54fb9c98b4-gw476          0/1     Terminating   0          13s
foo-website-54fb9c98b4-kk9wz          1/1     Terminating   0          13s
foo-website-57c666fb49-mm4t2          1/1     Running       0          13s
foo-website-57c666fb49-pbnkn          1/1     Running       0          13s
foo-website-57c666fb49-sgcx7          1/1     Running       0          7s
foo-website-57c666fb49-w2qbj          1/1     Running       0          13s
foo-website-57c666fb49-wkmxj          1/1     Running       0          8s
foo-website-canary-6bd675c4f8-69cpr   0/1     Terminating   0          41m
foo-website-canary-6bd675c4f8-92rzb   0/1     Terminating   0          8m26s
foo-website-canary-6bd675c4f8-f868j   0/1     Terminating   0          8m26s
foo-website-canary-6bd675c4f8-jpgsn   0/1     Terminating   0          15m
foo-website-canary-6bd675c4f8-ngcnc   0/1     Terminating   0          41m
foo-website-canary-6bd675c4f8-p8x29   0/1     Terminating   0          8m26s
```

A continuación, vamos a ver en qué estado ha quedado nuestro `Deployment`:

```shell
$ kubectl describe deployment foo-website -n demo-nodeport
Name:                   foo-website
Namespace:              demo-nodeport
CreationTimestamp:      Sun, 13 Feb 2022 18:44:21 +0100
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 2
                        kubernetes.io/change-cause: Deploy version 2.0
Selector:               app=foo-website-pod,env=production
Replicas:               5 desired | 5 updated | 5 total | 5 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=foo-website-pod
           env=production
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
NewReplicaSet:   foo-website-57c666fb49 (5/5 replicas created)
Events:
  Type    Reason             Age                 From                   Message
  ----    ------             ----                ----                   -------
  Normal  ScalingReplicaSet  113s (x3 over 49m)  deployment-controller  Scaled up replica set foo-website-54fb9c98b4 to 5
  Normal  ScalingReplicaSet  113s                deployment-controller  Scaled up replica set foo-website-57c666fb49 to 2
  Normal  ScalingReplicaSet  113s                deployment-controller  Scaled down replica set foo-website-54fb9c98b4 to 4
  Normal  ScalingReplicaSet  113s                deployment-controller  Scaled up replica set foo-website-57c666fb49 to 3
  Normal  ScalingReplicaSet  109s (x3 over 20m)  deployment-controller  Scaled down replica set foo-website-54fb9c98b4 to 3
  Normal  ScalingReplicaSet  108s                deployment-controller  Scaled up replica set foo-website-57c666fb49 to 4
  Normal  ScalingReplicaSet  107s (x2 over 10m)  deployment-controller  Scaled down replica set foo-website-54fb9c98b4 to 1
  Normal  ScalingReplicaSet  107s                deployment-controller  Scaled down replica set foo-website-54fb9c98b4 to 2
  Normal  ScalingReplicaSet  107s                deployment-controller  Scaled up replica set foo-website-57c666fb49 to 5
  Normal  ScalingReplicaSet  104s                deployment-controller  (combined from similar events): Scaled down replica set foo-website-54fb9c98b4 to 0
```

Vemos que alcanza el estado deseado: 5 réplicas de la versión 2.0 de nuestra página web.

Si miramos la historia del `Deployment`, y gracias a que hemos usado las anotaciones, veremos los dos despliegues:

```shell
$ kubectl rollout history deployment/foo-website -n demo-nodeport
deployment.apps/foo-website 
REVISION  CHANGE-CAUSE
1         Deploy version 1.0
2         Deploy version 2.0
```

## Automatización

Kubernetes no facilita ninguna forma de automatizar este proceso de despliegue basado en patrón _canary deployment_. Normalmente, nos apoyamos en sistemas de integración contínua o despliegue
continuo para automatizar total o parcialmente estos procesos.

Si tu cluster está gestionado, ten en cuenta que cada proveedor de servicios gestionados facilita 
sus propias herramientas y documentación para automatizar
total o parcialmente este proceso. A continuación tenéis algunos enlaces con información
para Azure, GKE y EKS:
* [Azure: Canary deployment strategy for Kubernetes deployments](https://docs.microsoft.com/en-us/azure/devops/pipelines/ecosystems/kubernetes/canary-demo?view=azure-devops&tabs=yaml)
* [Google Cloud: feedbackAutomating Canary Analysis on Google Kubernetes Engine with Spinnaker](https://cloud.google.com/architecture/automated-canary-analysis-kubernetes-engine-spinnaker)
* [AWS: Create a pipeline with canary deployments for Amazon EKS with AWS App Mesh](https://aws.amazon.com/blogs/containers/create-a-pipeline-with-canary-deployments-for-amazon-eks-with-aws-app-mesh/)

## Limpieza


Volvemos a poner `default` como espacio de nombres por defecto:

```shell
$ kubectl config set-context --current --namespace default
Context "managed" modified.
```

Para borrar todos los objetos, basta con borrar el espacio de nombres:

```shell
$ kubectl delete -f namespace.yml
namespace "demo-nodeport" deleted
```