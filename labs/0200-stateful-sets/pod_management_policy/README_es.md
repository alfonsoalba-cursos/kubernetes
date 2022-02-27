# `podManagementPolicy`

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `managed`

## Requisitos previos

Para poder seguir los pasos de este taller, es necesario tener **solo una parte** de los recursos creados en el taller
anterior: [Crear un StatefulSet](../create). Si estos recursos ya existen en el cluster, puedes
omitir los siguientes comandos y pasar a la siguiente sección:

```shell
$ kubectl create -f ../create/namespace.yml
$ kubectl apply -f ../create/headless-service.yml
```

## Crear el `StatefulSet` con política `Parallel`

En los laboratorio anteriores, hemos utilizado la política por defecto para gestionar los
`Pods` del `StatefulSet`: `.spec.podManagementPolicy=OrderedReady`.

En este laboratorio veremos la política `Parallel`. Existen casos en los que
no necesitamos crear o borrar los `Pods` en orden y las operaciones se pueden realizar en paralelo.
**Esta opción no afecta a las operaciones de actualización, que se seguirán haciendo en orden**.

Usaremos de nuevo dos consolas. Por un lado, listamos los `Pods`:

```shell
$ kubectl get pods -n demo-statefulset -w
NAME    READY   STATUS    RESTARTS   AGE
```

(Todavía no tenemos ninguno ya que los borramos en el [taller anterior](../delete/README_es.md))

En una segunda terminal, aplicamos el manifiesto [`statefulset-parallel.md`](./statefulset-parallel.md):

```shell
kubectl apply -f statefulset-parallel.yml       
statefulset.apps/web created
```

Si miramos la salida de la primera terminal, veremos cómo los `Pods` se levantan en paralelo:

```shell
kubectl get pods -n demo-statefulsets -w
NAME    READY   STATUS    RESTARTS   AGE
web-0   0/1     Pending   0          0s
web-1   0/1     Pending   0          0s
web-0   0/1     Pending   0          0s
web-2   0/1     Pending   0          0s
web-1   0/1     Pending   0          0s
web-2   0/1     Pending   0          0s
web-0   0/1     ContainerCreating   0          0s
web-1   0/1     ContainerCreating   0          0s
web-2   0/1     ContainerCreating   0          0s
web-2   0/1     ContainerCreating   0          13s
web-1   0/1     ContainerCreating   0          14s
web-2   0/1     ContainerCreating   0          18s
web-0   0/1     ContainerCreating   0          18s
web-1   0/1     ContainerCreating   0          18s
web-1   1/1     Running             0          19s
web-2   1/1     Running             0          19s
web-0   1/1     Running             0          19s
```

## Escalado

El escalado de un `StatefulSet` configurado con la opción 
`.spec.podManagementPolicy=Parallel`, también se realizará en paralelo.

Utilizando el comando `kubectl scale` vamos a ampliar el número de réplicas a 5:

```shell
$ kubectl scale statefulset/web --replicas=5 -n demo-statefulsets
statefulset.apps/web scaled
```

Si miramos la salida de la primera terminal, veremos cómo no se espera a que la
primera de las dos nuevas réplicas esté levantada para lanzar la segunda. Se 
levantan las dos a la vez:

```shell
kubectl get pods -n demo-statefulsets -w
NAME    READY   STATUS    RESTARTS   AGE
web-0   1/1     Running   0          77s
web-1   1/1     Running   0          77s
web-2   1/1     Running   0          77s
web-3   0/1     Pending   0          0s
web-4   0/1     Pending   0          0s
web-3   0/1     Pending   0          8s
web-4   0/1     Pending   0          7s
web-3   0/1     ContainerCreating   0          8s
web-4   0/1     ContainerCreating   0          7s
web-3   0/1     ContainerCreating   0          26s
web-4   0/1     ContainerCreating   0          25s
web-4   1/1     Running             0          25s
web-3   1/1     Running             0          27s
```

## Actualización

Por último, vamos a actualizar el `StatefulSet` de la versión 0.7 a la versión 0.8.
Esta operación no se verá afectada por la opción `.spec.podManagementPolicy=Parallel`
y la actualización se realizará uno a uno en orden desdencente del índice del `Pod`.

Veamos qué version estamos ejecutando en los `Pods`:

```shell
for I in $(seq 0 4); do echo web-$I: $(kubectl get pod web-$I -n demo-statefulsets -o jsonpath="{..spec.containers[0].image}"); done
web-0: k8s.gcr.io/nginx-slim:0.7
web-1: k8s.gcr.io/nginx-slim:0.7
web-2: k8s.gcr.io/nginx-slim:0.7
web-3: k8s.gcr.io/nginx-slim:0.7
web-4: k8s.gcr.io/nginx-slim:0.7
```

En una segunda terminal, aplicamos el manifiesto 
[`statefulset-parallel-rollout-version-0-8.yml`](./statefulset-parallel-rollout-version-0-8.yml):

```shell
$ kubectl apply -f statefulset-parallel-rollout-version-0-8.yml
statefulset.apps/web configured
```

Si miramos la primera consola, veremos como la actualización se realiza por orden, empezando por
`web-4` y acabando por `web-0`:

```shell
$ kubectl get pods -n demo-statefulsets -w
NAME    READY   STATUS    RESTARTS   AGE
web-0   1/1     Running   0          77s
web-1   1/1     Running   0          77s
web-2   1/1     Running   0          77s
web-3   0/1     Pending   0          0s
web-4   0/1     Pending   0          0s
web-3   0/1     Pending   0          8s
web-4   0/1     Pending   0          7s
web-3   0/1     ContainerCreating   0          8s
web-4   0/1     ContainerCreating   0          7s
web-3   0/1     ContainerCreating   0          26s
web-4   0/1     ContainerCreating   0          25s
web-4   1/1     Running             0          25s
web-3   1/1     Running             0          27s
PS C:\Users\aalba\MyStuff\online-training\kubernetes> kubectl get pods -n demo-statefulsets -w
NAME    READY   STATUS    RESTARTS   AGE
web-0   1/1     Running   0          12m
web-1   1/1     Running   0          12m
web-2   1/1     Running   0          12m
web-3   1/1     Running   0          8m34s
web-4   1/1     Running   0          8m33s
web-4   1/1     Terminating   0          9m59s
web-4   0/1     Terminating   0          10m
web-4   0/1     Pending       0          0s
web-4   0/1     ContainerCreating   0          0s
web-4   1/1     Running             0          35s
web-3   1/1     Terminating         0          10m
web-3   0/1     Terminating         0          10m
web-3   0/1     Pending             0          0s
web-3   0/1     ContainerCreating   0          18s
web-3   1/1     Running             0          19s
web-2   1/1     Terminating         0          14m
web-2   0/1     Terminating         0          15m
web-2   0/1     Pending             0          0s
web-2   0/1     ContainerCreating   0          7s
web-2   1/1     Running             0          10s
web-1   1/1     Terminating         0          15m
web-1   0/1     Terminating         0          15m
web-1   0/1     Pending             0          0s
web-1   0/1     ContainerCreating   0          34s
web-1   1/1     Running             0          35s
web-0   1/1     Terminating         0          16m
web-0   0/1     Terminating         0          16m
web-0   0/1     Pending             0          0s
web-0   0/1     ContainerCreating   0          18s
web-0   1/1     Running             0          19s
```

Para finalizar, verificamos la versión que están ejecutando nuestros `Pods`:

```shell
$ for I in $(seq 0 4); do echo web-$I: $(kubectl get pod web-$I -n demo-statefulsets -o jsonpath="{..spec.containers[0].image}"); done
web-0: k8s.gcr.io/nginx-slim:0.8
web-1: k8s.gcr.io/nginx-slim:0.8
web-2: k8s.gcr.io/nginx-slim:0.8
web-3: k8s.gcr.io/nginx-slim:0.8
web-4: k8s.gcr.io/nginx-slim:0.8
```

## Limpieza

Para finalizar este taller vamos a borrar todos los recursos que hemos utilizado:

* `Namespace`
* `HeadlessService`
* `Pods`
* `PersistentVolume` y `PersistentVolumeClaim`
* `StatefulSet`

```shell
$ for R in service pod pv pvc sts; do echo "Resource: $R"; kubectl get $R -n demo-statefulsets; done
Resource: service
NAME    TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
nginx   ClusterIP   None         <none>        80/TCP    6s


Resource: pod
NAME    READY   STATUS    RESTARTS   AGE
web-0   1/1     Running   0          11m
web-1   1/1     Running   0          12m
web-2   1/1     Running   0          12m
web-3   1/1     Running   0          13m
web-4   1/1     Running   0          14m


Resource: pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                         STORAGECLASS           REASON   AGE
pvc-6e6ccc1e-1292-4ed4-b085-4d5133c200dc   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-3   ionos-enterprise-hdd            24m
pvc-74a4e048-21d6-46d5-a554-9b1d15afec49   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-1   ionos-enterprise-hdd            29m
pvc-9da9aed4-8656-43ac-af6a-c56d3f22195b   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-2   ionos-enterprise-hdd            29m
pvc-d0746da2-22c2-4774-a78a-72e831629107   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-4   ionos-enterprise-hdd            24m
pvc-e1ba62e6-043c-4e6b-940c-667822c96404   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-0   ionos-enterprise-hdd            29m


Resource: pvc
NAME        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS           AGE
www-web-0   Bound    pvc-e1ba62e6-043c-4e6b-940c-667822c96404   1Gi        RWO            ionos-enterprise-hdd   29m
www-web-1   Bound    pvc-74a4e048-21d6-46d5-a554-9b1d15afec49   1Gi        RWO            ionos-enterprise-hdd   29m
www-web-2   Bound    pvc-9da9aed4-8656-43ac-af6a-c56d3f22195b   1Gi        RWO            ionos-enterprise-hdd   29m
www-web-3   Bound    pvc-6e6ccc1e-1292-4ed4-b085-4d5133c200dc   1Gi        RWO            ionos-enterprise-hdd   24m
www-web-4   Bound    pvc-d0746da2-22c2-4774-a78a-72e831629107   1Gi        RWO            ionos-enterprise-hdd   24m


Resource: sts
NAME   READY   AGE
web    5/5     27m
```

Borraremos en primer el `StatefulSet` y después bastará con borrar el espacio de nombres para que el resto de 
recursos se eliminen de nuestro cluster:

```shell
$ kubectl delete -f statefulset-parallel-rollout-version-0-8.yml
statefulset.apps "web" deleted
```

Una vez borrado el statefulset, podemos eliminar el resto de recursos:

```shell
$ kubectl delete -f ../create/namespace.yml
namespace "demo-statefulsets" deleted
```

Verificamos que se han eliminado todos los recursos:

```shell
$ for R in service pod pv pvc sts; do echo "Resource: $R"; kubectl get $R --all-namespaces; done
Resource: service
NAMESPACE     NAME                          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)         AGE
default       kubernetes                    ClusterIP   10.233.0.1      <none>        443/TCP         35d
kube-system   calico-typha                  ClusterIP   10.233.59.99    <none>        5473/TCP        35d
kube-system   coredns                       ClusterIP   10.233.18.128   <none>        53/UDP,53/TCP   35d
kube-system   pdb-validation-webhook        ClusterIP   10.233.14.241   <none>        443/TCP         35d
kube-system   snapshot-validation-webhook   ClusterIP   10.233.19.102   <none>        443/TCP         35d
Resource: pod
NAMESPACE     NAME                                         READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-5bf6854bb9-z2vlx     1/1     Running   0          6d10h
kube-system   calico-node-5lknj                            1/1     Running   0          6d10h
kube-system   calico-node-brnwt                            1/1     Running   0          6d10h
kube-system   calico-node-x56s4                            1/1     Running   0          6d10h
kube-system   calico-typha-7b766bdfcb-h8dkx                1/1     Running   0          6d10h
kube-system   calico-typha-7b766bdfcb-jfnzw                1/1     Running   0          6d10h
kube-system   coredns-dd9ff6c54-cb4d6                      1/1     Running   0          6d10h
kube-system   coredns-dd9ff6c54-d7cf8                      1/1     Running   0          6d10h
kube-system   csi-ionoscloud-fbs6h                         2/2     Running   0          6d10h
kube-system   csi-ionoscloud-t4c5c                         2/2     Running   0          6d10h
kube-system   csi-ionoscloud-ww4xl                         2/2     Running   0          6d10h
kube-system   konnectivity-agent-jxdhb                     1/1     Running   0          6d10h
kube-system   konnectivity-agent-tr9kq                     1/1     Running   0          6d10h
kube-system   konnectivity-agent-xcqhb                     1/1     Running   0          6d10h
kube-system   kube-proxy-8rrgq                             1/1     Running   0          6d10h
kube-system   kube-proxy-m52b9                             1/1     Running   0          6d10h
kube-system   kube-proxy-s7dzr                             1/1     Running   0          6d10h
kube-system   nginx-proxy-standardnodes-3woa3k35du         1/1     Running   0          6d10h
kube-system   nginx-proxy-standardnodes-ilnvolhssf         1/1     Running   0          6d10h
kube-system   nginx-proxy-standardnodes-jiik2wmh3t         1/1     Running   0          6d10h
kube-system   pdb-validation-webhook-65cd6fd944-5mh4d      1/1     Running   0          6d10h
kube-system   snapshot-validation-webhook-9dc8d4dd-jzgmh   1/1     Running   0          6d10h
Resource: pv
No resources found
Resource: pvc
No resources found
Resource: sts
No resources found
```

Sólo vemos los recursos relacionados con la capa de control y el espacio de nombres por defecto.
