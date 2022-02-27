# Borrar un `StatefulSet`

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `managed`

## Requisitos previos

Para poder seguir los pasos de este taller, es necesario tener los recursos creados en el taller
anterior: [Crear un StatefulSet](../create). Si estos recursos ya existen en el cluster, puedes
omitir los siguientes comandos y pasar a la siguiente sección:

```shell
$ kubectl create -f ../create/namespace.yml
$ kubectl apply -f ../create/headless-service.yml
$ kubectl apply -f ../create/statefulset.yml
```

## Borrado sin cascada

En este modo, cuando borramos el `StatefulSet`, los `Pods` no se borran. Seremos nosotros
los responsable de borrarlos de manera manual.

Utilizamos la primera terminal para observar la salida del siguiente comando:

```shell
$ kubectl get pods -w -n demo-statefulsets
NAME    READY   STATUS    RESTARTS   AGE
web-0   1/1     Running   0          10m
web-1   1/1     Running   0          10m
web-2   1/1     Running   0          11m
```

En una segunda terminal, borramos el `StatefulSet` usando el comando `kubectl delete`:

```shell
$ kubectl delete statefulset web --cascade=orphan -n demo-statefulsets 
statefulset.apps "web" deleted
```

Aunque el `StatefulSet` se ha borrado, los `Pods` siguen arriba:

```shell
kubectl get pods -w -n demo-statefulsetsNAME    READY   STATUS    RESTARTS   AGE
web-0   1/1     Running   0          8m22s
web-1   1/1     Running   0          8m35s
web-2   1/1     Running   0          9m19s
```

Borremos el `Pod` `web-2`:

```shell
$ kubectl delete pod web-2 -n demo-statefulsets
pod "web-2" deleted
```

Si miramos el listado de `Pods`, veremos que a diferencia de antes, el `Pod` se elimina
y no se vuelve a crear:

```shell
$ kubectl get pods -w -n demo-statefulsets
NAME    READY   STATUS    RESTARTS   AGE
web-0   1/1     Running   0          10m
web-1   1/1     Running   0          10m
```

Borrar el resto de `Pods`:

```shell
$ kubectl delete pod web-1 -n demo-statefulsets
pod "web-1" deleted

$ kubectl delete pod web-0 -n demo-statefulsets
pod "web-0" deleted
```

Recuerda que aunque los `Pods` se hayan borrado, los volúmenes no:

```shell
$ kubectl get pvc -n demo-statefulsets 
NAME        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS           AGE
www-web-0   Bound    pvc-e901cf64-484a-42c4-bdd6-5852dc35a7ce   1Gi        RWO            ionos-enterprise-hdd   23h
www-web-1   Bound    pvc-ea0779a6-583a-4624-844b-146d1964db02   1Gi        RWO            ionos-enterprise-hdd   23h
www-web-2   Bound    pvc-49164358-c172-46d7-b72a-f82e14e77d85   1Gi        RWO            ionos-enterprise-hdd   23h
www-web-3   Bound    pvc-b0468b2d-90f5-44e3-8f60-c2d25a9c0dc4   1Gi        RWO            ionos-enterprise-hdd   21h
www-web-4   Bound    pvc-9049b7cc-2985-4824-a61e-7eaa054b98ac   1Gi        RWO            ionos-enterprise-hdd   21h

$ kubectl get pv -n demo-statefulsets  
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                         STORAGECLASS           REASON   AGE
pvc-49164358-c172-46d7-b72a-f82e14e77d85   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-2   ionos-enterprise-hdd            23h
pvc-9049b7cc-2985-4824-a61e-7eaa054b98ac   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-4   ionos-enterprise-hdd            21h
pvc-b0468b2d-90f5-44e3-8f60-c2d25a9c0dc4   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-3   ionos-enterprise-hdd            21h
pvc-e901cf64-484a-42c4-bdd6-5852dc35a7ce   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-0   ionos-enterprise-hdd            23h
pvc-ea0779a6-583a-4624-844b-146d1964db02   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-1   ionos-enterprise-hdd            23h
```

No los vamos a borrar todavía, los borraremos más adelante cuando hayamos terminado con los siguientes pasos
de este laboratorio.

## Borrado en cascada

Antes de ilustrar como funciona el borrado en cascada, volvamos a crear el `StatefulSet`

```shell
$ kubectl apply -f ../create/statefulset.yml
statefulset.apps/web created
```

Una vez los tres `Pods` están en ejecución, vamos a borrar el `StatefulSet` usando la opción para
hacerlo en cascada.

Utilizamos la primera terminal para observar la salida del siguiente comando:

```shell
$ kubectl get pods -w -n demo-statefulsets
NAME    READY   STATUS    RESTARTS   AGE
web-0   1/1     Running   0          10m
web-1   1/1     Running   0          10m
web-2   1/1     Running   0          11m
```

En una segunda terminal, ejecutamos el comando:

```shell
$ kubectl delete statefulset web -n demo-statefulsets
statefulset.apps "web" deleted
```

Si miramos la primera terminal, veremos cómo los `Pods` se van eliminando uno a uno en orden
decreciente del valor de su ordinal:

```shell
kubectl get pods -w -n demo-statefulsets
NAME    READY   STATUS              RESTARTS   AGE
web-0   1/1     Running             0          16m
web-1   1/1     Running             0          16m
web-2   0/1     ContainerCreating   0          7s
web-2   0/1     ContainerCreating   0          18s
web-2   1/1     Running             0          19s
web-0   1/1     Terminating         0          19m
web-2   1/1     Terminating         0          3m13s
web-1   1/1     Terminating         0          19m
web-1   1/1     Terminating         0          19m
web-2   1/1     Terminating         0          3m14s
web-0   1/1     Terminating         0          19m
web-1   0/1     Terminating         0          19m
web-0   0/1     Terminating         0          19m
web-2   0/1     Terminating         0          3m15s
web-0   0/1     Terminating         0          19m
web-0   0/1     Terminating         0          19m
web-2   0/1     Terminating         0          3m22s
web-2   0/1     Terminating         0          3m22s
web-1   0/1     Terminating         0          19m
web-1   0/1     Terminating         0          19m
```

## _Cosas_ que no se borran

Una vez borrado el `StatefulSet`, es necesario borrar los siguientes recursos manualmente:

* El `HeadlessService`:

```shell
$ kubectl delete -f ../create/headless-service.yml
service "nginx" deleted
```

* Los `PersistentVolumeClaims` y los `PersistenVolumes`

```shell
$ kubectl delete pvc --all -n demo-statefulsets        
persistentvolumeclaim "www-web-0" deleted
persistentvolumeclaim "www-web-1" deleted
persistentvolumeclaim "www-web-2" deleted
persistentvolumeclaim "www-web-3" deleted
persistentvolumeclaim "www-web-4" deleted
```

