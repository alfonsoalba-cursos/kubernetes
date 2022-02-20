# Arsys: _Dynamic volume provisioning_

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `managed`

## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-dynamic-provisioning`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-dynamic-provisioning created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                        STATUS   AGE
default                     Active   34d
demo-dynamic-provisioning   Active   16s
kube-node-lease             Active   34d
kube-public                 Active   34d
kube-system                 Active   34d
```

Puedes seleccionar este espacio de nombres por defecto ejecutando:

```shell
$ kubectl config set-context --current --namespace demo-dynamic-provisioning
Context "managed" modified.
```


## `PersistentVolumeClaim`

Creamos un `PersistentVolumeClaim` que solicita un disco de 15Gi de espacio de la clase `ionos-enterprise-hdd` ([persistent-volume-claim.yml](./persistent-volume-claim.yml)):

```shell
$ kubectl apply -f persistent-volume-claim.yml
```

Veamos el `PersistentVolumeClaim` que acabamos de crear:

```shell
$ kubectl get pvc -n demo-dynamic-provisioning
NAME       STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS           AGE
15gi-hdd   Pending                                      ionos-enterprise-hdd   4m46s
```

Este queda en estado `Pending` hasta que un `Pod` utilice este `PersistentVolumeClaim`

## El `Pod`

Creamos a continuación un `Pod`, usando el fichero [`pod.yml`](./pod.yml), que utiliza este `PersistentVolumeClaim`:

```shell
$ kubectl apply -f pod.yml
pod/test-pod created
```

Una vez creamos el `Pod`, el `PersistentVolumeClaim` utiliza la `StorageClass` `ionos-enterprise-hdd` para crear un `PersistentVolume` y enlazarse con él. Tras unos segundos, veremos cómo el `PersistentVolumeClaim` queda en estado `Bound`:

```shell
$ kubectl get pvc -n demo-dynamic-provisioning
NAME       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS           AGE
15gi-hdd   Bound    pvc-57b5198e-15ac-491c-8457-0b879cf1acf4   15Gi       RWO            ionos-enterprise-hdd   8m30s
```

Si miramos la lista de `PersistentVolumes`, veremos aparece uno nuevo:

```shell
$ kubectl get pv 
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                                STORAGECLASS           REASON   AGE
pvc-57b5198e-15ac-491c-8457-0b879cf1acf4   15Gi       RWO            Delete           Bound       demo-dynamic-provisioning/15gi-hdd   ionos-enterprise-hdd            5m42s
...
...
pvc-1f40aad4-db17-4a40-a16e-b222812524c3   1Gi        RWO            Delete           Bound       demo-statefulsets/www-web-1          ionos-enterprise-hdd            27d
pvc-4e9585c5-ce0a-404b-89d9-9f6bb254cb4c   1Gi        RWO            Delete           Bound       demo-statefulsets/www-web-0          ionos-enterprise-hdd            27d
pvc-e2fad6f9-3937-43f8-b351-10ac1f432cef   1Gi        RWO            Delete           Bound       demo-statefulsets/www-web-2          ionos-enterprise-hdd            27d
shared-data-ts-volume                      10Gi       RWO            Delete           Available                                        ionos-enterprise-hdd            41m
shared-data-volume                         10Gi       RWO            Delete           Failed      demo-pvandpvc/shared-data-claim      ionos-enterprise-hdd            17h
test-pv                                    10Gi       RWO            Delete           Bound       default/test-data                    ionos-enterprise-hdd            25d
```

## Borrado

En la columna `RECLAIM POLICY` podemos ver que el `PersistentVolume` que se ha creado tiene el valor `Delete`.
Vamos a borrar el `Pod` y el `PersistentVolumeClaim`:

```shell
$ kubectl delete -f pod.yml -f persistent-volume-claim.yml
pod "test-pod" deleted
persistentvolumeclaim "15gi-hdd" deleted
```

Una vez se borren los objetos, veremos que el `PersistentVolume` `pvc-57b5198e-15ac-491c-8457-0b879cf1acf4` ha sido eliminado:

```shell
$ kubectl get pv | grep pvc-57b5198e-15ac-491c-8457-0b879cf1acf4
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
namespace "demo-dynamic-provisioning" deleted
```