# Arsys: _Failed_ `PersistentVolumes`

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `managed`

## Pasos previos

En este taller partimos del `Pod`, `PersistentVolume` y `PersisntentVolumeClaim` que
creamos en el taller [Arsys: Uso de `PersistentVolume` y `PersistentVolumeClaim`
](../arsys-pv-and-pvc/README_es.md).
Si no has completado los pasos de ese taller, completalos antes de continuar.

## Reiniciar el `Pod`

Vamos a borrar el `Pod` y a volverlo a crear:

```shell
$ kubectl delete -f ../arsys-pv-and-pvc/pod.yml
pod "test-pod" deleted
```

Una vez borrado el `Pod`, vemos que el `PersistentVolumeClaim` y el `PersistentVolume` quedan
en estado `Bound`, esperando a que otro `Pod` _reclame_ el espacio. Si volvemos a levantar el `Pod`:

```shell
$ kubectl apply -f ../arsys-pv-and-pvc/pod.yml
pod/test-pod created
```

Al cabo de unos segundos, el `Pod` volverá a ejecutarse y tendremos acceso al volumen. Podemos ver el fichero que creamos en el taller anterior:

```shell
$ kubectl exec test-pod -n demo-pvandpvc -- ls -l /mnt/shared-data/test-file.txt
-rw-r--r-- 1 root root 0 Feb 19 20:11 /mnt/shared-data/test-file.txt
```

## Borrar el `PersistentVolumeClaim`

Borramos de nuevo el `Pod`:

```shell
$ kubectl delete -f ../arsys-pv-and-pvc/pod.yml
pod "test-pod" deleted
```

Una vez borrado, borramos el `PersistentVolumeClaim`:

```shell
$ kubectl delete -f ..\arsys-pv-and-pvc\persistent-volume-claim.yml
persistentvolumeclaim "shared-data-claim" deleted
```

El estado del `PersistentVolume` es `Failed`. El motivo podemos verlo con el comando `kubectl describe`:

```shell
$ kubectl describe pv shared-data-volume
Name:              shared-data-volume
Labels:            <none>
Annotations:       pv.kubernetes.io/bound-by-controller: yes
Finalizers:        [kubernetes.io/pv-protection external-attacher/cloud-ionos-com]
StorageClass:      ionos-enterprise-hdd
Status:            Failed
Claim:             demo-pvandpvc/shared-data-claim
Reclaim Policy:    Delete
Access Modes:      RWO
VolumeMode:        Filesystem
Capacity:          10Gi
Node Affinity:
  Required Terms:
    Term 0:        enterprise.cloud.ionos.com/datacenter-id in [3914a457-f19b-4bba-8742-b21fa61d4521]
Message:           error getting deleter volume plugin for volume "shared-data-volume": no deletable volume plugin matched
Source:
    Type:              CSI (a Container Storage Interface (CSI) volume source)
    Driver:            cloud.ionos.com
    FSType:            ext4
    VolumeHandle:      datacenters/3914a457-f19b-4bba-8742-b21fa61d4521/volumes/e969bca2-f3fd-47b6-8856-cc05e0564417
    ReadOnly:          false
    VolumeAttributes:      datacenterID=3914a457-f19b-4bba-8742-b21fa61d4521
Events:
  Type     Reason              Age   From                         Message
  ----     ------              ----  ----                         -------
  Warning  VolumeFailedDelete  2m3s  persistentvolume-controller  error getting deleter volume plugin for volume "shared-data-volume": no deletable volume plugin matched
```

## Volver a crear el `PersistentVolumeClaim`

Si en este punto intentamos crear el `PersistentVolumeClaim` de nuevo, este no se enlazará al `PersistentVolume` y quedará
en estado `Pending`

```shell
$ kubectl apply -f ../arsys-pv-and-pvc/persistent-volume-claim.yml
persistentvolumeclaim/shared-data-claim created

$ kubectl get pvc -n demo-pvandpvc
NAME                STATUS    VOLUME               CAPACITY   ACCESS MODES   STORAGECLASS           AGE
shared-data-claim   Pending   shared-data-volume   0                         ionos-enterprise-hdd   31s
```

Podemos ver el motivo usando `kubectl describe`:

```shell
kubectl describe pvc shared-data-claim -n demo-pvandpvc  
Name:          shared-data-claim
Namespace:     demo-pvandpvc
StorageClass:  ionos-enterprise-hdd
Status:        Pending
Volume:        shared-data-volume
Labels:        <none>
Annotations:   <none>
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      0
Access Modes:
VolumeMode:    Filesystem
Used By:       <none>
Events:
  Type     Reason         Age               From                         Message
  ----     ------         ----              ----                         -------
  Warning  FailedBinding  9s (x7 over 91s)  persistentvolume-controller  volume "shared-data-volume" already bound to a different claim.
```

**Para poder volver a usar el volumen, deberemos borrar el `PersistentVolume` y volver a crearlo.**

## Limpieza

Volvemos a poner `default` como espacio de nombres por defecto:

```shell
$ kubectl config set-context --current --namespace default
Context "managed" modified.
```


Para borrar todos los objetos, basta con borrar el espacio de nombres:

```shell
$ kubectl delete -f ../arsys-pv-and-pvc/namespace.yml
namespace "demo-pvandpvc" deleted

$ kubectl delete -f ../arsys-pv-and-pvc/persistent-volume.yml
```

Una vez borrados los objetos de Kubernetes, debemos borrar el volumen en el DCD.