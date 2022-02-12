# Seleccionando el nodo para desplegar nuestros `Pods` 

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `managed`

## La aplicación

Levantaremos una aplicación sin estado utilizando la imagen `kubernetescourse/foo-website`

## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-nodeselector`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-nodeselector created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                STATUS   AGE
default             Active   34d
demo-nodeselector   Active   14s
kube-node-lease     Active   34d
kube-public         Active   34d
kube-system         Active   34d
```

Puedes seleccionar este espacio de nombres por defecto ejecutando:

```shell
$ kubectl config set-context --current --namespace demo-nodeselector
Context "managed" modified.
```

## `Deployment`

Utilizaremos [este `Deployment`](./deployment.yml). Dentro de la especificación del `Pod` podemos
ver el selector `nodeSelector`

```yaml
spec:
  template:
    spec:
      nodeSelector:
        projectType: legacy
```

Intentemos crear el `Deployment`:

```shell
$ kubectl apply -f deployment.yml
replicaset.apps/frontend created
```

Si miramos el listado de `Pods`, veremos que estos no se han podido asignar a ningún nodo:

```shell
kubectl get pods
NAME                           READY   STATUS    RESTARTS   AGE
foo-website-84895f5df7-m4d45   0/1     Pending   0          4m6s
foo-website-84895f5df7-ttxzt   0/1     Pending   0          4m6s
foo-website-84895f5df7-x665n   0/1     Pending   0          4m6s
```

Si miramos el estado de uno de los `Pods`, veremos cuál es el motivo por el que sigue
en estado `Pending`:

```shell
$ kubectl get pod foo-website-84895f5df7-m4d45 -o json | jq .status

{
  "conditions": [
    {
      "lastProbeTime": null,
      "lastTransitionTime": "2022-02-12T08:17:51Z",
      "message": "0/3 nodes are available: 3 node(s) didn't match Pod's node affinity/selector.",
      "reason": "Unschedulable",
      "status": "False",
      "type": "PodScheduled"
    }
  ],
  "phase": "Pending",
  "qosClass": "BestEffort"
}
```

Como era de esperar, el motivo por el que no se puede programar el `Pod` es porque no tenemos
ningún nodo que cumpla con los requisitos.

Podemos ver cómo se refleja esto en nuestro `Deployment`:

```shell
kubectl describe deployment foo-website -n demo-nodeselector
Name:                   foo-website
Namespace:              demo-nodeselector
CreationTimestamp:      Sat, 12 Feb 2022 09:17:51 +0100
Labels:                 app=foo-website
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=foo-website
Replicas:               3 desired | 3 updated | 3 total | 0 available | 3 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=foo-website
  Containers:
   foo-website:
    Image:        kubernetescourse/foo-website:1.0
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      False   MinimumReplicasUnavailable
  Progressing    False   ProgressDeadlineExceeded
OldReplicaSets:  <none>
NewReplicaSet:   foo-website-84895f5df7 (3/3 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  21m   deployment-controller  Scaled up replica set foo-website-84895f5df7 to 3    
```

En la sección `Conditions` obervamos que no hemos podido alcanzar el minimo número de réplicas
y, después de esperar 10 minutos, vemos como se muestra `ProgressDeadlineExceeded`.

## Asignando una etiqueta a un nodo

Veamos qué nodos tenemos disponibles:

```shell
NAME                       STATUS   ROLES   AGE    VERSION   INTERNAL-IP   EXTERNAL-IP     OS-IMAGE            
 KERNEL-VERSION     CONTAINER-RUNTIME
standardnodes-dujzurkh2h   Ready    node    5d9h   v1.21.4   <none>        93.93.115.60    Ubuntu 20.04.3 LTS   5.4.0-88-generic   containerd://1.4.11
standardnodes-kmcoj6rtxw   Ready    node    5d9h   v1.21.4   <none>        93.93.115.62    Ubuntu 20.04.3 LTS   5.4.0-88-generic   containerd://1.4.11
standardnodes-pne5yslqsg   Ready    node    5d9h   v1.21.4   <none>        93.93.114.119   Ubuntu 20.04.3 LTS   5.4.0-88-generic   containerd://1.4.11
```

Asignemos la etiqueta `projectType: legacy` al nodo `standardnodes-dujzurkh2h`:

```shell
$ kubectl label nodes standardnodes-dujzurkh2h projectType=legacy
node/ labeled
```

Si ejecutamos el comando `kubectl get pods`, veremos que al poco de etiquetar el nodo, los `Pods`
se empezarán a crear:

```shell
$ kubectl get pods -n demo-nodeselector
NAME                           READY   STATUS              RESTARTS   AGE   IP             NODE                       NOMINATED NODE   READINESS GATES
foo-website-84895f5df7-m4d45   0/1     ContainerCreating   0          28m   10.208.202.6   standardnodes-dujzurkh2h   <none>           <none>
foo-website-84895f5df7-ttxzt   1/1     Running             0          28m   10.208.202.8   standardnodes-dujzurkh2h   <none>           <none>
foo-website-84895f5df7-x665n   1/1     Running             0          28m   10.208.202.7   standardnodes-dujzurkh2h   <none>           <none>
```

## Aumento de réplicas

Vamos a etiquetar un segundo nodo:

```shell
$ kubectl label nodes standardnodes-kmcoj6rtxw projectType=legacy      
node/standardnodes-kmcoj6rtxw labeled
```

Si aumentamos el número de réplicas, veremos como parte de los nuevos `Pods` se despliegan en el segundo nodo que hemos etiquetado:

```shell
$  kubectl scale deployment/foo-website --replicas 5 -n demo-nodeselector
deployment.apps/foo-website scaled
```

Si listamos los `Pods`

```shell
NAME                           READY   STATUS              RESTARTS   AGE   IP             NODE                       NOMINATED NODE   READINESS GATES
foo-website-84895f5df7-gqj2w   0/1     ContainerCreating   0          91s   <none>         standardnodes-kmcoj6rtxw   <none>           <none>
foo-website-84895f5df7-m4d45   1/1     Running             0          37m   10.208.202.6   standardnodes-dujzurkh2h   <none>           <none>
foo-website-84895f5df7-ttxzt   1/1     Running             0          37m   10.208.202.8   standardnodes-dujzurkh2h   <none>           <none>
foo-website-84895f5df7-x665n   1/1     Running             0          37m   10.208.202.7   standardnodes-dujzurkh2h   <none>           <none>
foo-website-84895f5df7-zqxph   0/1     ContainerCreating   0          90s   <none>         standardnodes-kmcoj6rtxw   <none>           <none>
```

Vemos como los dos nuevos `Pods` se han creado en el segundo nodo.

## Quitar la etiqueta del segundo nodo

Si ahora quitamos la etiqueta del segundo nodo:

```shell
$ kubectl label nodes standardnodes-kmcoj6rtxw projectType-
```

_(para borrar la etiqueta, ponemos el caracter `-` al final del nombre de la etiqueta)_

Si listamos los `Pods`, veremos que a pesar de que la etiqueta se haya eliminado, estos se siguen 
ejecutando en el nodo:

```shell
$ kubectl get pods -o wide -n demo-nodeselector
NAME                           READY   STATUS    RESTARTS   AGE   IP             NODE                       NOMINATED NODE   READINESS GATES
foo-website-84895f5df7-gqj2w   1/1     Running   0          47m   10.216.50.69   standardnodes-kmcoj6rtxw   <none>           <none>
foo-website-84895f5df7-m4d45   1/1     Running   0          82m   10.208.202.6   standardnodes-dujzurkh2h   <none>           <none>
foo-website-84895f5df7-ttxzt   1/1     Running   0          82m   10.208.202.8   standardnodes-dujzurkh2h   <none>           <none>
foo-website-84895f5df7-x665n   1/1     Running   0          82m   10.208.202.7   standardnodes-dujzurkh2h   <none>           <none>
foo-website-84895f5df7-zqxph   1/1     Running   0          47m   10.216.50.70   standardnodes-kmcoj6rtxw   <none>           <none>
```

En la sección sobre _Affinity_, _taints_ y _tolerations_ veremos cómo hacer que, cuando quitemos
la etiqueta del nodo, los `Pods` se reprogramen en otro nodo.

## Limpieza

Volvemos a poner `default` como espacio de nombres por defecto:

```shell
$ kubectl config set-context --current --namespace default
Context "managed" modified.
```


Para borrar todos los objetos, basta con borrar el espacio de nombres:

```shell
$ kubectl delete -f namespace.yml
namespace "demo-nodeselector" deleted
```

Quitamos la etiqueta de ambos nodos:

