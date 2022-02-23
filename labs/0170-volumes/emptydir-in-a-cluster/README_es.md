# Uso de `Emptydir` (cluster gestionado)

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `managed`


## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-emptydir`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-emptydir created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                STATUS   AGE
default             Active   34d
demo-emptydir       Active   16s
kube-node-lease     Active   34d
kube-public         Active   34d
kube-system         Active   34d
```

Puedes seleccionar este espacio de nombres por defecto ejecutando:

```shell
$ kubectl config set-context --current --namespace demo-emptydir
Context "managed" modified.
```

## El `Deployment`

Creamos un fichero [`deployment.yml`](./deployment.yml) con las siguientes caraterísticas
* Tendremos tres réplicas de un `Pod`
* Este `Pod` montará un volumen de tipo `EmptyDir`
* El `Pod` tiene un contenedor de inicialización que añade un fichero al volumen
  con el `hostname` y la fecha

Creamos el `Deployment`:

```shell
$ kubectl apply -f deployment.yml
```

Una vez creado el `Deployment` vemos que los `Pods` se han inicializado correctamente:

```shell
$ kubectl get pods -n demo-emptydir
NAME                        READY   STATUS    RESTARTS   AGE
emptydir-54855db856-kf9rn   1/1     Running   0          86s
emptydir-54855db856-kt8df   1/1     Running   0          71s
emptydir-54855db856-wns6w   1/1     Running   0          78s
```

Si miramos los `Pods` y los ficheros que se han creado en la carpeta `/cache`:

```shell
for pod in $(kubectl get pods -n demo-emptydir | awk '{ print $1 }' | grep -v NAME)
do 
  kubectl exec $pod --container nginx -n demo-emptydir -- ls /cache/
done

20220219-09:15:17-emptydir-7dcfc6cf7b-b7qh4-init.txt
20220219-09:15:04-emptydir-7dcfc6cf7b-f4qpq-init.txt
20220219-09:15:11-emptydir-7dcfc6cf7b-g2ssl-init.txt
```

## Drenando un nodo

Veamos en qué nodos se están ejecutando los `Pods`:

```shell
$ kubectl get pods -o wide -n demo-emptydir
NAME                        READY   STATUS    RESTARTS        AGE     IP              NODE                       NOMINATED NODE   READINESS GATES
emptydir-7dcfc6cf7b-b7qh4   1/1     Running   0               3m23s   10.221.166.16   standardnodes-tsl5rq2g7y   <none>           <none>
emptydir-7dcfc6cf7b-f4qpq   1/1     Running   0               3m36s   10.214.40.109   standardnodes-eovwand2pa   <none>           <none>
emptydir-7dcfc6cf7b-g2ssl   1/1     Running   0               3m30s   10.222.77.74    standardnodes-caadtmk6sp   <none>           <none>
```

Vamos a trabajar con el primer `Pod`: `emptydir-7dcfc6cf7b-b7qh4`. Creemos un fichero en la carpeta `/cache`:

```shell
$ kubectl exec emptydir-7dcfc6cf7b-b7qh4 -n demo-emptydir --container nginx -- touch /cache/alfonso.txt
```

Este `Pod` es está ejecuntado en el nodo `standardnodes-tsl5rq2g7y`. Vamos a vaciarlo:

```shell
$ kubectl drain standardnodes-tsl5rq2g7y

node/standardnodes-tsl5rq2g7y cordoned
error: unable to drain node "standardnodes-tsl5rq2g7y" due to error:[cannot delete Pods with local storage (use --delete-emptydir-data to override): demo-emptydir/emptydir-7dcfc6cf7b-b7qh4, kube-system/metrics-server-5b6dd75459-6kxkl, kubernetes-dashboard/dashboard-metrics-scraper-c45b7869d-2lkhc, kubernetes-dashboard/kubernetes-dashboard-764b4dd7-hm6c6, cannot delete Pods not managed by ReplicationController, ReplicaSet, Job, DaemonSet or StatefulSet (use --force to override): demo-externalname/mysqlclient, cannot delete DaemonSet-managed Pods (use --ignore-daemonsets to ignore): kube-system/calico-node-825rw, kube-system/csi-ionoscloud-bf585, kube-system/konnectivity-agent-lsxlw, kube-system/kube-proxy-bz8w8], continuing command...
There are pending nodes to be drained:
 standardnodes-tsl5rq2g7y
cannot delete Pods with local storage (use --delete-emptydir-data to override): demo-emptydir/emptydir-7dcfc6cf7b-b7qh4, kube-system/metrics-server-5b6dd75459-6kxkl, kubernetes-dashboard/dashboard-metrics-scraper-c45b7869d-2lkhc, kubernetes-dashboard/kubernetes-dashboard-764b4dd7-hm6c6
cannot delete DaemonSet-managed Pods (use --ignore-daemonsets to ignore): kube-system/calico-node-825rw, kube-system/csi-ionoscloud-bf585, kube-system/konnectivity-agent-lsxlw, kube-system/kube-proxy-bz8w8
```

Debido a que el `Pod` está utilizano almacenamiento local con el volumen te tipo `EmptyDir`, kubernetes
no puede sacar el `Pod` del nodo. Para forzarlo, debemos utilizar la opción `--delete-emptydir-data`. Pero antes,
debermos devolver el nodo al estado previo a solicitar su vaciado:

```shell
$ kubectl uncordon standardnodes-tsl5rq2g7y  
node/standardnodes-tsl5rq2g7y uncordoned
```

Una vez ejecutado el `uncordon`, volvamos a vaciar el nodo:

```shell
$  kubectl drain standardnodes-tsl5rq2g7y --delete-emptydir-data --ignore-daemonsets
node/standardnodes-tsl5rq2g7y already cordoned
WARNING: ignoring DaemonSet-managed Pods: kube-system/calico-node-825rw, kube-system/csi-ionoscloud-bf585, kube-system/konnectivity-agent-lsxlw, kube-system/kube-proxy-bz8w8
evicting pod kubernetes-dashboard/kubernetes-dashboard-764b4dd7-hm6c6
evicting pod demo-emptydir/emptydir-7dcfc6cf7b-b7qh4
evicting pod kube-system/metrics-server-5b6dd75459-6kxkl
evicting pod kube-system/ionos-policy-validator-8f85745f-zcl7m
evicting pod kube-system/calico-kube-controllers-5bf6854bb9-8s62v
evicting pod kube-system/coredns-dd9ff6c54-ndcdp
evicting pod kube-system/calico-typha-7b766bdfcb-x2grx
evicting pod kube-system/snapshot-validation-webhook-9dc8d4dd-4ss9k
evicting pod kubernetes-dashboard/dashboard-metrics-scraper-c45b7869d-2lkhc
I0219 10:32:49.181161   10440 request.go:665] Waited for 1.0081156s due to client-side throttling, not priority and fairness, request: POST:https://cp-23321.cluster.ionos.com:11013/api/v1/namespaces/demo-statefulsets/pods/web-0/eviction
pod/calico-typha-7b766bdfcb-x2grx evicted
I0219 10:32:59.338566   10440 request.go:665] Waited for 1.8476568s due to client-side throttling, not priority and fairness, request: GET:https://cp-23321.cluster.ionos.com:11013/api/v1/namespaces/kubernetes-dashboard/pods/kubernetes-dashboard-764b4dd7-hm6c6
pod/emptydir-7dcfc6cf7b-b7qh4 evicted
pod/kubernetes-dashboard-764b4dd7-hm6c6 evicted
I0219 10:33:09.342264   10440 request.go:665] Waited for 1.896172s due to client-side throttling, not priority and fairness, request: GET:https://cp-23321.cluster.ionos.com:11013/api/v1/namespaces/demo-nodeport/pods/foo-website-57c666fb49-4p4f7
pod/ionos-policy-validator-8f85745f-zcl7m evicted
pod/calico-kube-controllers-5bf6854bb9-8s62v evicted
pod/snapshot-validation-webhook-9dc8d4dd-4ss9k evicted
pod/coredns-dd9ff6c54-ndcdp evicted
pod/dashboard-metrics-scraper-c45b7869d-2lkhc evicted
pod/metrics-server-5b6dd75459-6kxkl evicted
node/standardnodes-tsl5rq2g7y drained
```

Vemos que durante el proceso de vaciado del nodo, hay diversos `Pods` relacionados con Kubernetes 
que se sacan del nodo, como por ejemplo `pod/coredns-dd9ff6c54-ndcdp` o `pod/calico-typha-7b766bdfcb-x2grx`.

Tras el vaciado del nodo, nuestro `Pod` habrá sido reprogramado en otro nodo:

```shell
 kubectl get pods -o wide                  
NAME                        READY   STATUS    RESTARTS      AGE     IP              NODE                       NOMINATED NODE   READINESS GATES
busybox                     1/1     Running   3 (21m ago)   26m     10.222.77.72    standardnodes-caadtmk6sp   <none>           <none>
emptydir-7dcfc6cf7b-f4qpq   1/1     Running   0             20m     10.214.40.109   standardnodes-eovwand2pa   <none>           <none>
emptydir-7dcfc6cf7b-g2ssl   1/1     Running   0             20m     10.222.77.74    standardnodes-caadtmk6sp   <none>           <none>
emptydir-7dcfc6cf7b-ht5hz   1/1     Running   0             2m48s   10.214.40.113   standardnodes-eovwand2pa   <none>           <none>
```

Si volvemos a mirar en la carpeta `/cache` de los `Pods`, veremos que el fichero `alfonso.txt` así como el fichero
de inicialización que estaban en el `Pod` del nodo `standardnodes-tsl5rq2g7yp` se han perdido:

```shell
for pod in $(kubectl.exe get pods -n demo-emptydir | awk '{ print $1 }' | grep -v NAME)
do 
  kubectl.exe exec $pod --container nginx -n demo-emptydir -- ls /cache/
done

20220219-09:15:04-emptydir-7dcfc6cf7b-f4qpq-init.txt
20220219-09:15:11-emptydir-7dcfc6cf7b-g2ssl-init.txt
20220219-09:33:01-emptydir-7dcfc6cf7b-ht5hz-init.txt <<<---- Este fichero se ha creado de nuevo y tiene diferente momento de creación
```

Para finalizar, le decimos a kubernetes que ya puede volver reprogramar `Pods` en el nodo `standardnodes-tsl5rq2g7y `:

```shell
$ kubectl uncordon standardnodes-tsl5rq2g7y 
node/standardnodes-tsl5rq2g7y uncordoned
```

## Limpieza

Volvemos a poner `default` como espacio de nombres por defecto:

```shell
$ kubectl config set-context --current --namespace default
Context "managed" modified.
```


Para borrar todos los objetos, basta con borrar el espacio de nombres:

```shell
$ kubectl delete -f namespace.yml
namespace "demo-emptydir" deleted
```
