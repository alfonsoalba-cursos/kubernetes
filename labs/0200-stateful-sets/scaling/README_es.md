# Escalar un `StatefulSet`

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `managed`

## Requisitos previos

Para poder seguir los pasos de este taller, es necesario tener los recursos creados en el taller
anterior: [Crear un StatefulSet](../create). Si estos recursos ya existe en el cluster, puedes
omitir los siguientes comandos y pasar a la siguiente sección:

```shell
$ kubectl create -f ../create/namespace.yml
$ kubectl apply -f ../create/headless-service.yml
$ kubectl apply -f ../create/statefulset.yml
```

## Aumentar el número de réplicas

Al igual que hicimos en el taller anterior, utilizaremos dos consolas para ver cómo
evoluciona el proceso. En una consola ejecutamos el siguiente comando:

```shell
$ kubectl get pods -w -l app=nginx -n demo-statefulsets
NAME    READY   STATUS    RESTARTS   AGE
web-0   1/1     Running   0          43m
web-1   1/1     Running   0          43m
web-2   1/1     Running   0          42m
```

En otra consola ampliamos el número de réplicas de nuestro `StatefulSet`:

```shell
$ kubectl apply -f statefulset-scale-up.yml
statefulset.apps/web configured
```

También podíamos haber realizado la operación utilizando el comando:

```shell
$ kubectl scale statefulset web --replicas=5 -n demo-statefulsets       
statefulset.apps/web scaled
```
En la primera consola, veremos cómo aparecerá una cuarta réplica `web-3`. Una vez la réplica
esté en ejecución y `Ready`, aparecerá la quinta y última, `web-4`:

```shell
$ kubectl get pods -w -l app=nginx -n demo-statefulsets
NAME    READY   STATUS    RESTARTS   AGE
web-0   1/1     Running   0          43m
web-1   1/1     Running   0          43m
web-2   1/1     Running   0          42m
web-3   0/1     Pending   0          0s
web-3   0/1     Pending   0          8s
web-3   0/1     ContainerCreating   0          8s
web-3   0/1     ContainerCreating   0          26s
web-3   1/1     Running             0          26s
web-4   0/1     Pending             0          0s
web-4   0/1     Pending             0          7s
web-4   0/1     ContainerCreating   0          7s
web-4   0/1     ContainerCreating   0          41s
web-4   1/1     Running             0          41s
```

Si miramos los `PersistenceVolumes` y `PersistenceVolumeClaims`, veremos que se han creado
dos nuevos, uno para cada nueva réplica:

```shell
$ kubectl get pv -n demo-statefulsets                       
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                         STORAGECLASS           REASON   AGE
pvc-49164358-c172-46d7-b72a-f82e14e77d85   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-2   ionos-enterprise-hdd            131m
pvc-9049b7cc-2985-4824-a61e-7eaa054b98ac   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-4   ionos-enterprise-hdd            12m
pvc-b0468b2d-90f5-44e3-8f60-c2d25a9c0dc4   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-3   ionos-enterprise-hdd            12m
pvc-e901cf64-484a-42c4-bdd6-5852dc35a7ce   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-0   ionos-enterprise-hdd            132m
pvc-ea0779a6-583a-4624-844b-146d1964db02   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-1   ionos-enterprise-hdd            131m

kubectl get pvc -n demo-statefulsets
NAME        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS           AGE
www-web-0   Bound    pvc-e901cf64-484a-42c4-bdd6-5852dc35a7ce   1Gi        RWO            ionos-enterprise-hdd   132m
www-web-1   Bound    pvc-ea0779a6-583a-4624-844b-146d1964db02   1Gi        RWO            ionos-enterprise-hdd   132m
www-web-2   Bound    pvc-49164358-c172-46d7-b72a-f82e14e77d85   1Gi        RWO            ionos-enterprise-hdd   131m
www-web-3   Bound    pvc-b0468b2d-90f5-44e3-8f60-c2d25a9c0dc4   1Gi        RWO            ionos-enterprise-hdd   12m
www-web-4   Bound    pvc-9049b7cc-2985-4824-a61e-7eaa054b98ac   1Gi        RWO            ionos-enterprise-hdd   12m
```

## Reduciendo el número de réplicas

Vamos reducir el número de réplicas de 5 a 2. Mantenemos en ejecución la primera consola
en la que estamos observando el listado de `Pods` del espacio de nombres `demo-statefulsets`.

En una segunda consola, reducimos el número de réplicas. Podemos hacerlo ejecutando el fichero
`statefulset-scale-down.yml`:

```shell
$ kubectl get pods -w -l app=nginx -n demo-statefulsets
NAME    READY   STATUS    RESTARTS   AGE
...
web-4   1/1     Running             0          41s
web-4   1/1     Terminating         0          18m
web-4   1/1     Terminating         0          18m
web-4   0/1     Terminating         0          18m
web-4   0/1     Terminating         0          18m
web-4   0/1     Terminating         0          18m
web-3   1/1     Terminating         0          19m
web-3   1/1     Terminating         0          19m
web-3   0/1     Terminating         0          19m
web-3   0/1     Terminating         0          19m
web-3   0/1     Terminating         0          19m
web-2   1/1     Terminating         0          63m
web-2   1/1     Terminating         0          63m
web-2   0/1     Terminating         0          63m
web-2   0/1     Terminating         0          63m
web-2   0/1     Terminating         0          63m
```

Vemos cómo las réplicas se van eliminando en el orden inverso al que se crearon. Primero se termina 
el `Pod` `web-4` (la última réplica que se creó), cuando esta réplica se ha borrado, se borra `web-3`
y una vez esta réplica se ha borrado, se borra `web-2`.

Como alternativa, podemos utilizar el comando `kubectl patch`:

```shell
$ kubectl patch statefulset web -n demo-statefulsets -p '{"spec":{"replicas":2}}'
statefulset.apps/web patched
```

o 

```shell
$ kubectl scale statefulset web --replicas=2 -n demo-statefulsets       
statefulset.apps/web scaled
```

Una vez las tres réplicas se han eliminado, miremos los `PersistentVolumes` y los
`PersistentVolumeClaims`:


```shell
$ kubectl get pv -n demo-statefulsets                       
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                         STORAGECLASS           REASON   AGE
pvc-49164358-c172-46d7-b72a-f82e14e77d85   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-2   ionos-enterprise-hdd            131m
pvc-9049b7cc-2985-4824-a61e-7eaa054b98ac   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-4   ionos-enterprise-hdd            12m
pvc-b0468b2d-90f5-44e3-8f60-c2d25a9c0dc4   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-3   ionos-enterprise-hdd            12m
pvc-e901cf64-484a-42c4-bdd6-5852dc35a7ce   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-0   ionos-enterprise-hdd            132m
pvc-ea0779a6-583a-4624-844b-146d1964db02   1Gi        RWO            Delete           Bound    demo-statefulsets/www-web-1   ionos-enterprise-hdd            131m

kubectl get pvc -n demo-statefulsets
NAME        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS           AGE
www-web-0   Bound    pvc-e901cf64-484a-42c4-bdd6-5852dc35a7ce   1Gi        RWO            ionos-enterprise-hdd   132m
www-web-1   Bound    pvc-ea0779a6-583a-4624-844b-146d1964db02   1Gi        RWO            ionos-enterprise-hdd   132m
www-web-2   Bound    pvc-49164358-c172-46d7-b72a-f82e14e77d85   1Gi        RWO            ionos-enterprise-hdd   131m
www-web-3   Bound    pvc-b0468b2d-90f5-44e3-8f60-c2d25a9c0dc4   1Gi        RWO            ionos-enterprise-hdd   12m
www-web-4   Bound    pvc-9049b7cc-2985-4824-a61e-7eaa054b98ac   1Gi        RWO            ionos-enterprise-hdd   12m
```

Es decir, los recursos siguen ahí. En el laboratorio anterior vimos como al borrar un `Pod`
del `StatefulSet`, no se borraban los volúmenes. Aquí hemos comprobado cómo tampoco
se borran cuando el motivo por el que los `Pods` se borran es una reducción 
en el número de réplicas. Los volúmenes deben borrarse manualmente.

