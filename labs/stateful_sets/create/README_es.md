# Crear un `StatefulSet`

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `managed`

## La aplicación

Con el objetivo de ilustrar los diferentes conceptos relacionados con los `StatefulSets`,
levantaremos una aplicación con estado que consistirá en tres réplicas de un
servidor web nginx.

A diferencia de lo que ocurre con un `Deployment`, cada una de las réplicas mantendrá 
su identidad en caso de que el `Pod` necesite ser reprogramado.

## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-statefulsets`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-statefulsets created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                STATUS   AGE
default             Active   34d
demo-statefulsets   Active   29s
kube-node-lease     Active   34d
kube-public         Active   34d
kube-system         Active   34d
```

## `HeadlessService`

Lo primero que necesitamos es crear el `HeadlessService` que se encargará de exponer
los `Pods` del `StatefulSet`:

```shell
$ kubectl apply -f headless-service.yml
service/nginx created
```

Verificamos que el servicio se ha creado correctamente:

```shell
$ kubectl get services -n demo-statefulsets
NAME    TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
nginx   ClusterIP   None         <none>        80/TCP    22s
```

Al tratarse de un servicio _headless_, no se asigna una dirección IP a la propiedad
CLUSTER-IP. En su lugar, el servicio asignará direcciones IP a los `Pods` individuales
que coincidan con el selector del servicio.


## Creación del `StatefulSet`

En este taller utilizaremos dos terminales. En la primera, ejecutaremos el siguiente
comando:

```shell
kubectl get pods -w -l app=nginx -n demo-statefulsets
```

La opción `-w` (`--watch`) nos evitará tener que ejecutar el comando multiples veces.
Una vez nos muestre el primer listado de pods, se quedará esperando a que haya algún cambio
y nos lo mostrará por la consola. 

En la segunda terminal, creamos el `StatefulSet`:

```shell
$ kubectl apply -f statefulset.yml
statefulset.apps/web created
```

Una vez ejecutado este comando en la segunda terminal, podemos ver en la primera terminal 
cómo se crean los `Pods` en orden:

```shell
kubectl get pods -w -l app=nginx -n demo-statefulsets
NAME    READY   STATUS    RESTARTS   AGE
web-0   0/1     Pending   0          0s
web-0   0/1     Pending   0          7s
web-0   0/1     ContainerCreating   0          7s
web-0   0/1     ContainerCreating   0          24s
web-0   1/1     Running             0          24s
web-1   0/1     Pending             0          1s
web-1   0/1     Pending             0          8s
web-1   0/1     ContainerCreating   0          8s
web-1   0/1     ContainerCreating   0          25s
web-1   1/1     Running             0          26s
web-2   0/1     Pending             0          0s
web-2   0/1     Pending             0          7s
web-2   0/1     ContainerCreating   0          7s
web-2   0/1     ContainerCreating   0          25s
web-2   1/1     Running             0          26s
```

## El nombre de los `Pods`

Los `Pods` dentro del `StatefulSet` tienen una identidad que permanece en el tiempo:

```shell
$ kubectl get pods -n demo-statefulsets -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP              NODE                       NOMINATED NODE   READINESS GATES
web-0   1/1     Running   0          16m   10.211.11.201   standardnodes-ilnvolhssf   <none>           <none>
web-1   1/1     Running   0          15m   10.221.239.70   standardnodes-3woa3k35du   <none>           <none>
web-2   1/1     Running   0          15m   10.217.50.197   standardnodes-jiik2wmh3t   <none>           <none>
```

Los nombres `web-0`, `web-1`, `web-2` persisten en el tiempo, como veremos un poco más adelante
en este mismo laboratorio. 

El `HeadlessService` que hemos creado, se ha encargado de crear los
registros DNS dentro de `kube-dns`. Creemos un `Pod` desde el que podamos ejecutar el comando
`nslookup` ([ver aquí](https://github.com/docker-library/busybox/issues/48) porqué usamos la 
versión 1.28 de busybox en este caso):

```shell
$ kubectl run -i --tty -n demo-statefulsets --image busybox:1.28 dns-test --restart=Never --rm
/ #
``` 

Desde este contenedor, podemos resolver los nombres de cualquiera de los tres `Pods`
del `StatefulSet`:

```shell
/ # nslookup web-0.nginx
Server:    10.233.18.128
Address 1: 10.233.18.128 coredns.kube-system.svc.cluster.local
Name:      web-0.nginx
Address 1: 10.211.11.201 web-0.nginx.demo-statefulsets.svc.cluster.local


/ # nslookup web-1.nginx
Server:    10.233.18.128
Address 1: 10.233.18.128 coredns.kube-system.svc.cluster.local
Name:      web-1.nginx
Address 1: 10.221.239.70 web-1.nginx.demo-statefulsets.svc.cluster.local


/ # nslookup web-2.nginx
Server:    10.233.18.128
Address 1: 10.233.18.128 coredns.kube-system.svc.cluster.local
Name:      web-2.nginx
Address 1: 10.217.50.197 web-2.nginx.demo-statefulsets.svc.cluster.local
```

Los nombres de los `Pods` no cambiarán. Sí pueden cambiar las direcciones IP asociadas
a ellos. Por ello es necesario que nuestras aplicaciones accedan a los `Pods`
usando el nombre DNS y nunca la dirección IP.

Vamos a reprogramar el `Pod` `web-1`. De nuevo, utilizamos dos consolas para ver cómo evoluciona
el proceso. Por un lado ejecutamos:

```shell
$ kubectl get pods -w -l app=nginx -n demo-statefulsets
NAME    READY   STATUS    RESTARTS   AGE
web-0   1/1     Running   0          37m
web-1   1/1     Running   0          37m
web-2   1/1     Running   0          37m
```

Y en otra consola borramos el `Pod`:

```shell
$ kubectl delete pod web-1 
pod "web-1" deleted
```

Si volvemos a la primera consola, veremos una salida similar a la siguiente:

```shell
$ kubectl get pods -w -l app=nginx -n demo-statefulsets
NAME    READY   STATUS    RESTARTS   AGE
web-0   1/1     Running   0          37m
web-1   1/1     Running   0          37m
web-2   1/1     Running   0          37m
web-1   1/1     Terminating   0          38m
web-1   1/1     Terminating   0          38m
web-1   0/1     Terminating   0          38m
web-1   0/1     Terminating   0          39m
web-1   0/1     Terminating   0          39m
web-1   0/1     Pending       0          0s
web-1   0/1     Pending       0          0s
web-1   0/1     ContainerCreating   0          0s
web-1   0/1     ContainerCreating   0          9s
web-1   1/1     Running             0          10s
```

Se miramos cuál es la dirección IP del nuevo `Pod`:

```shell
$ kubectl run -i --tty -n demo-statefulsets --image busybox:1.28 dns-test --restart=Never --rm nslookup web-1.nginx
Server:    10.233.18.128
Address 1: 10.233.18.128 coredns.kube-system.svc.cluster.local
Name:      web-1.nginx
Address 1: 10.221.239.71 web-1.nginx.demo-statefulsets.svc.cluster.local
pod "dns-test" deleted
```

comprobamos que la dirección IP del `Pod` `web-1` ha cambiado (antes era `10.221.239.70`)

## Accediendo al almacenamiento persistente

Cada uno de los `Pods` de nuestro `StatefulSet` monta su propio volumen. Podemos ver los
recursos `PersistentVolume` y los correspondientes `PersistentVolumeClaims` creados
usando kubectl:

```shell
$ kubectl get pvc -n demo-statefulsets -o wide
NAME        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS           AGE   VOLUMEMODE
www-web-0   Bound    pvc-e901cf64-484a-42c4-bdd6-5852dc35a7ce   1Gi        RWO            ionos-enterprise-hdd   56m   Filesystem
www-web-1   Bound    pvc-ea0779a6-583a-4624-844b-146d1964db02   1Gi        RWO            ionos-enterprise-hdd   55m   Filesystem
www-web-2   Bound    pvc-49164358-c172-46d7-b72a-f82e14e77d85   1Gi        RWO            ionos-enterprise-hdd   55m   Filesystem


$ kubectl get pv -n demo-statefulsets -o wide
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                         STORAGECLASS           REASON   AGE   VOLUMEMODE
pvc-49164358-c172-46d7-b72a-f82e14e77d85   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-2   ionos-enterprise-hdd            54m   Filesystem
pvc-e901cf64-484a-42c4-bdd6-5852dc35a7ce   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-0   ionos-enterprise-hdd            55m   Filesystem
pvc-ea0779a6-583a-4624-844b-146d1964db02   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-1   ionos-enterprise-hdd            55m   Filesystem
```


Usando de nuevos dos consolas, podemos verificar que al reprogramar un `Pod`, no se crea un nuevo volumen.
En una consola ejecutamos:

```shell
kubectl get pv -w  -n demo-statefulsets            
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                         STORAGECLASS           REASON   AGE
pvc-49164358-c172-46d7-b72a-f82e14e77d85   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-2   ionos-enterprise-hdd            59m
pvc-e901cf64-484a-42c4-bdd6-5852dc35a7ce   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-0   ionos-enterprise-hdd            60m
pvc-ea0779a6-583a-4624-844b-146d1964db02   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-1   ionos-enterprise-hdd            60m
```

mientras que en una segunda consola borramos el `Pod` `web-2`:

```shell
$ kubectl delete pod web-2 -n demo-statefulsets
pod "web-2" deleted
```

Vemos que durante todo el proceso de borrado y creación del `Pod` `web-2` no se crea un nuevo volumen
para el nuevo `Pod`, sino que se reutilizará el que ya existe.

Para verificar cómo se reutilizan los volúmenes, vamos a escribir un fichero diferente para cada uno de los `Pods`:

```shell
$ for I in $(seq 0 2); do kubectl exec -n demo-statefulsets web-$I -- bash -c "echo 'Fichero de web-$I' > /usr/share/nginx/html/web-$I.txt"; done
```

podemos verificar que los ficheros se han creado usando:

```shell
$ for I in $(seq 0 2); do kubectl exec -n demo-statefulsets web-$I -- bash -c "cat /usr/share/nginx/html/web-$I.txt"; done
Fichero de web-0
Fichero de web-1
Fichero de web-2
```

Usaremos de nuevo dos consolas. Por un lado, listamos los `Pods`:

```shell
$ kubectl delete pod -n demo-statefulset -l app=nginx
NAME    READY   STATUS    RESTARTS   AGE
web-0   1/1     Running   0          72m
web-1   1/1     Running   0          33m
web-2   1/1     Running   0          9m49s
```

En una segunda consola, borramos todos los `Pods`:

```shell
 kubectl delete pod -n demo-statefulsets -l app=nginx
pod "web-0" deleted
pod "web-1" deleted
pod "web-2" deleted
```

Mirando la primera consola, esperamos a que los `Pods` se hayan creado de nuevo:

```shell
$ kubectl get pods -w -l app=nginx -n demo-statefulsets
NAME    READY   STATUS    RESTARTS   AGE
web-0   1/1     Running   0          72m
web-1   1/1     Running   0          33m
web-2   1/1     Running   0          9m49s
web-0   1/1     Terminating   0          74m
web-1   1/1     Terminating   0          34m
web-2   1/1     Terminating   0          11m
web-0   1/1     Terminating   0          74m
web-1   1/1     Terminating   0          34m
web-2   1/1     Terminating   0          11m
web-2   0/1     Terminating   0          11m
web-1   0/1     Terminating   0          34m
web-0   0/1     Terminating   0          74m
web-0   0/1     Terminating   0          74m
web-0   0/1     Terminating   0          74m
web-0   0/1     Pending       0          0s
web-0   0/1     Pending       0          0s
web-0   0/1     ContainerCreating   0          0s
web-2   0/1     Terminating         0          11m
web-2   0/1     Terminating         0          11m
web-1   0/1     Terminating         0          35m
web-1   0/1     Terminating         0          35m
web-0   0/1     ContainerCreating   0          17s
web-0   1/1     Running             0          18s
web-1   0/1     Pending             0          0s
web-1   0/1     Pending             0          0s
web-1   0/1     ContainerCreating   0          0s
web-1   0/1     ContainerCreating   0          6s
web-1   0/1     ContainerCreating   0          34s
web-1   1/1     Running             0          35s
web-2   0/1     Pending             0          0s
web-2   0/1     Pending             0          0s
web-2   0/1     ContainerCreating   0          0s
web-2   0/1     ContainerCreating   0          18s
web-2   1/1     Running             0          19s
```

Ejecutamos el siguiente script, con el que podemos verificar que el fichero 
creado en volumen de cada `Pod` sigue en el mismo punto de montaje después de que 
el `Pod` se volviese a crear:

```shell
$ for I in $(seq 0 2); do kubectl exec -n demo-statefulsets web-$I -- bash -c "echo \$(hostname): \$(cat /usr/share/nginx/html/web-$I.txt)"; done
web-0: Fichero de web-0
web-1: Fichero de web-1
web-2: Fichero de web-2
```

## Siguiente paso

En el [siguiente taller](../scaling/README_es.md), aumentaremos (y reduciremoes) el número de réplicas 
de nuestro `StatefulSet`.

