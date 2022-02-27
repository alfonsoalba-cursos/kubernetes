# `PodAntiAffinity`: levantar un sitio web con Wordpress

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `managed`

## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-podaffinity-wordpress`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-podaffinity-wordpress created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                        STATUS   AGE
default                     Active   34d
demo-podaffinity-wordpress  Active   10s
kube-node-lease             Active   34d
kube-public                 Active   34d
kube-system                 Active   34d
```

Puedes seleccionar este espacio de nombres por defecto ejecutando:

```shell
$ kubectl config set-context --current --namespace demo-podaffinity-wordpress
Context "managed" modified.
```

## La aplicación

Vamos a levantar un wordpress con su base de datos. Para levantar la base de datos,
usaremos un `StatefulSet`. Estos son los objetos que utilizaremos:
* `Secret` para almacenar las contraseñas de MySQL
* `ConfigMap` para almacenar la configuración de la base de datos
* `StatefulSet` + `HeadlessService` con la base de datos
* `Deployment` para desplegar wordpress

## Creamos los ficheros de configuración

En los ficheros [`secret.yml`](secret.yml) y [`config-map.yml`](./config-map.yml) incluimos
la información que necesitamos para configurar la base de datos. Cargamos ambos ficheros usando
`kubectl apply`:

```shell
$ kubectl apply -f secret.yml -f config-map.yml
secret/mysql-secret created
configmap/mysql-config-map created
```

Podemos ver los objetos que acabamos de crear:

```shell
$ kubectl get secret,cm -n demo-podaffinity-wordpress  
NAME                         TYPE                                  DATA   AGE
secret/default-token-knsbj   kubernetes.io/service-account-token   3      10m
secret/mysql-secret          Opaque                                2      40s

NAME                         DATA   AGE
configmap/kube-root-ca.crt   1      10m
configmap/mysql-config-map   2      40s
```

## La base de datos

Utilizaremos el fichero [`statefulset.yml`](./statefulset.yml) para crear el `Pod` con la base de datos.

Este `StatefulSet` incluye:
* El _Headless Service_ necesario para acceder al `StatefulSet`
* Lee la configuración de la base de datos de los objetos `Secret` y `ConfigMap` que creamos en la 
  sección anterior
* Utiliza los `Secrets` a través de ficheros, en lugar de usar variables de entorno
* Utiliza un `PersistentVolumeClaim` para persistir el estado.

Creamos la base de datos usando `kubectl`:

```shell
$ kubectl apply -f statefulset.yml 
service/mysql created
statefulset.apps/web created
```

Al cabo de unos segundos / minutos, nuestra base de datos estará levantada y funcionando:

```shell
$ kubectl get all -n demo-podaffinity-wordpress  
NAME          READY   STATUS    RESTARTS   AGE
pod/mysql-0   1/1     Running   0          28s

NAME            TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
service/mysql   ClusterIP   None         <none>        3306/TCP   28s

NAME                     READY   AGE
statefulset.apps/mysql   1/1     28s
```

Podemos probar que se ha levantado correctamente ejecutando el siguiente comando (la contraseña es `password`):

```shell
$ kubectl exec mysql-0 -ti -n demo-podaffinity-wordpress -- mysql -u wordpress -p

Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 10
Server version: 8.0.28 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
```

Una vez tenemos la base de datos lista, vamos a desplegar Wordpress.

## Wordpress

Creamos un `Deployment` para nuestro wordpress:
* Lee la configuración de la base de datos del `Secret` y el `ConfigMap` que creamos en las secciones anteriores
* Se configura para que no se cree ningún  `Pod` en el mismo nodo en el que está nuestro servidor de base de datos MySQL

Aplicamos el fichero [`deployment.yml`](./deployment.yml):

```shell
$ kubectl apply -f deployment.yml
```

Veamos en qué nodos se han creado los `Pods`:

```shell
$ kubectl get pods -o wide -n demo-podaffinity-wordpress  
NAME                         READY   STATUS    RESTARTS   AGE   IP              NODE                       NOMINATED NODE   READINESS GATES
mysql-0                      1/1     Running   0          24m   10.216.183.61   standardnodes-zuf5eywgar   <none>           <none>
wordpress-5b669d6bcc-ggmxm   1/1     Running   0          58s   10.212.142.10   standardnodes-wypldyeewy   <none>           <none>
wordpress-5b669d6bcc-rhwlf   1/1     Running   0          58s   10.223.58.108   standardnodes-paka7v2imr   <none>           <none>
wordpress-5b669d6bcc-xqtnb   1/1     Running   0          58s   10.212.142.17   standardnodes-wypldyeewy   <none>           <none>
```

Ninguno de ellos se ha programado en el mismo nodo que el `Pod` `mysql-0`. 

Si aumentamos el número de réplicas, veremos que ninguna de ellas se programan en ese nodo:

```shell
$ kubectl scale deployment wordpress --replicas=10 -n demo-podaffinity-wordpress  

$ kubectl get pods -o wide -n demo-podaffinity-wordpress  
NAME                         READY   STATUS    RESTARTS   AGE     IP              NODE                       NOMINATED NODE   READINESS GATES
mysql-0                      1/1     Running   0          31m     10.216.183.61   standardnodes-zuf5eywgar   <none>           <none>
wordpress-5b669d6bcc-2nggp   1/1     Running   0          29s     10.212.142.7    standardnodes-wypldyeewy   <none>           <none>
wordpress-5b669d6bcc-5sjjc   1/1     Running   0          29s     10.223.58.110   standardnodes-paka7v2imr   <none>           <none>
wordpress-5b669d6bcc-b82fj   1/1     Running   0          29s     10.223.58.112   standardnodes-paka7v2imr   <none>           <none>
wordpress-5b669d6bcc-ggmxm   1/1     Running   0          8m34s   10.212.142.10   standardnodes-wypldyeewy   <none>           <none>
wordpress-5b669d6bcc-hc6vg   1/1     Running   0          29s     10.223.58.109   standardnodes-paka7v2imr   <none>           <none>
wordpress-5b669d6bcc-lwqgc   1/1     Running   0          29s     10.212.142.28   standardnodes-wypldyeewy   <none>           <none>
wordpress-5b669d6bcc-lx24q   1/1     Running   0          29s     10.223.58.111   standardnodes-paka7v2imr   <none>           <none>
wordpress-5b669d6bcc-q2lzs   1/1     Running   0          29s     10.212.142.4    standardnodes-wypldyeewy   <none>           <none>
wordpress-5b669d6bcc-rhwlf   1/1     Running   0          8m34s   10.223.58.108   standardnodes-paka7v2imr   <none>           <none>
wordpress-5b669d6bcc-xqtnb   1/1     Running   0          8m34s   10.212.142.17   standardnodes-wypldyeewy   <none>           <none>
```

## ¿Qué ocurre si escogemos el `topologyKey` incorrecto?

Vamos a ilustrar cuál es el efecto del campo 
`spec.affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution.topologyKey`.

Para ello, vamos a borrar el `Deployment` que creamos en la sección anterior:

```shell
$ kubectl delete -f deployment.yml
```

Y vamos a crear un deployment nuevo, usando el fichero [`deployment-with-region-topology-key.yml`](./deployment-with-region-topology-key.yml).
La única diferencia entre estos dos `Deployments` es el valor de `topologyKey`:

```shell
$ diff deployment.yml deployment-with-zone-topology-key.yml    
47c47
<           - topologyKey: kubernetes.io/hostname
---
>           - topologyKey: topology.kubernetes.io/region 
```

Es decir, pasamos de utilizar el `hostnmane` del nodo a utilizar la región en la que se encuentra el nodo.

Creemos el nuevo `Deployment`:

```shell
$ kubectl apply -f deployment-with-zone-topology-key.yml
deployment.apps/wordpress configured
```

Si miramos los `Pods` veremos que estos no pasan a la fase `Running`:

```shell
$ kubectl get pods -o wide
NAME                         READY   STATUS    RESTARTS   AGE   IP              NODE                       NOMINATED NODE   READINESS GATES
mysql-0                      1/1     Running   0          40m   10.216.183.61   standardnodes-zuf5eywgar   <none>           <none>
wordpress-7dd4cf797c-4qrf8   0/1     Pending   0          3s    <none>          <none>                     <none>           <none>
wordpress-7dd4cf797c-6k87x   0/1     Pending   0          3s    <none>          <none>                     <none>           <none>
wordpress-7dd4cf797c-f9fd2   0/1     Pending   0          3s    <none>          <none>                     <none>           <none>
```

Si miramos la descripción de uno de los `Pods`:

```shell
$ kubectl describe pod wordpress-7dd4cf797c-4qrf8 -n demo-podaffinity-wordpress

Name:           wordpress-7dd4cf797c-4qrf8
Namespace:      demo-podaffinity-wordpress
...
...
Events:
  Type     Reason            Age                 From               Message
  ----     ------            ----                ----               -------
  Warning  FailedScheduling  103s                default-scheduler  0/3 nodes are available: 3 node(s) didn't match pod anti-affinity rules.
  Warning  FailedScheduling  15s (x1 over 102s)  default-scheduler  0/3 nodes are available: 3 node(s) didn't match pod anti-affinity rules.
```

Los `Pods` no se pueden programar porque no existe un nodo que cumpla los requisitos: un nodo que **no contenga un `Pod` con la 
etiqueta `app: mysql` y que no esté en la misa región que el nodo que cotiene ese `Pod`**. Como todos nuestros nodos están en la misma región,
estas condiciones no se pueden cumplir.

Podemos relajar un poco estas condiciones para que los `Pods` se puedan programar 
([`deployment-with-required-and-preferred-antiaffinity.yml`](./deployment-with-required-and-preferred-antiaffinity.yml)):

* Requerimos que los `Pods` con wordpress no estén en el mismo nodo que la base de datos
* _Preferimos_ que los `Pods` estén en otra región

Borramos el deployment que acabamos crear:

```shell
$ kubectl delete -f deployment-with-region-topology-key.yml
deployment.apps "wordpress" deleted
```

Creamos el nuevo `Deployment` con las dos condiciones 
`requiredDuringSchedulingIgnoredDuringExecution` y `preferredDuringSchedulingIgnoredDuringExecution`:

```shell
kubectl create -f .\deployment-with-required-and-preferred-antiaffinity.yml
deployment.apps/wordpress created
```

Vemos que ahora los `Pods` si que llegan a la fase `Running`:

```shell
$ kubectl get pods -o wide -n demo-podaffinity-wordpress
NAME                         READY   STATUS    RESTARTS   AGE   IP              NODE                       NOMINATED NODE   READINESS GATES
mysql-0                      1/1     Running   0          56m   10.216.183.61   standardnodes-zuf5eywgar   <none>           <none>
wordpress-76c8dff465-gvmnt   1/1     Running   0          62s   10.223.58.114   standardnodes-paka7v2imr   <none>           <none>
wordpress-76c8dff465-ms47c   1/1     Running   0          62s   10.212.142.6    standardnodes-wypldyeewy   <none>           <none>
wordpress-76c8dff465-vkflx   1/1     Running   0          62s   10.212.142.33   standardnodes-wypldyeewy   <none>           <none>
```

Si tuviésemos nodos en otras regiones, los `Pods` se habrían programado en ellos. Al no tenerlos, los programa en los dos nodos
que no contienen el `Pod` `mysql-0`.

## Limpieza

Volvemos a poner `default` como espacio de nombres por defecto:

```shell
$ kubectl config set-context --current --namespace default
Context "managed" modified.
```

Para borrar todos los objetos, basta con borrar el espacio de nombres:

```shell
$ kubectl delete -f namespace.yml
namespace "demo-podaffinity-wordpress" deleted
```
