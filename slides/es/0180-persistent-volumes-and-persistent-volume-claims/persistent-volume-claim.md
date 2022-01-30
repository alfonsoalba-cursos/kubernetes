### `PersistentVolumeClaim`

Objeto que permite a los desarrolladores reclamar o solicitar espacio de almacenamiento para su aplicación

Esta solicitud incluye:
* Cuánto espacio necesito
* El tipo de acceso (`ROX`, `RWO`, `RWX`)
* De forma opcional, el tipo de acceso que se desea solicitar

notes: 

Si no se especifica el tipo de acceso a través de la propiedad `spec.storageClassName`, se facilitará el
primer `PersistentVolume` disponible que cumpla con los requisitos de almacenamiento.

^^^^^^

### `PersistentVolumeClaim`

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-data
spec:
  resources:
    requests:
      storage: 10Gi
  accessModes:
  - ReadWriteOnce
  storageClassName: "ionos-enterprise-hdd"
  volumeName: test-pv
```

^^^^^^

### `PersistentVolumeClaim`

Cuando creamos un objeto `PersistentVolumeClaim`, estamos solicitando un `PersistentVolume` que cumpla
con uan serie de características

* `spec.accessModes`: los modos que queremos que tenga
* `spec.volumeMode`: el modo del volumen `Filesystem` o `Block`
* `spec.resources.request.storage`: el espacio que estamos reclamando
* `spec.storageClassName`: la clase
* `spec.selector`: podemos usar etiquetas para filtrar los `PersistentVolumes` que queremos seleccionar
* `spec.volumeName`: si queremos utilizar un volumen en particular

notes:

Más información:
* [Persistent Volumes: PersistentVolumeClaims](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims)
* [Referencia del objeto `PersistentVolumeClaim`](https://kubernetes.io/docs/reference/kubernetes-api/config-and-storage-resources/persistent-volume-claim-v1/)

^^^^^^

### `PersistentVolumeClaim`: uso en un `Pod`

```yaml
apiVersion: v1
kind: Pod
metadata:
  label: test-data-pod
spec:
  volumes:
  - name: test-data
    persistentVolumeClaim:
      claimName: test-data
  containers:
  - name: writer
    image: busybox
    command:
    - sh
    - -c
    - |
      echo "A writer pod wrote this." > /test-data-mountpoint/${HOSTNAME} &&
      echo "I can write to /test-data-mountpoint/${HOSTNAME}." ;
      sleep 9999
    volumeMounts:
    - name: test-data
      mountPath: /test-data-mountpoint
```

notes:

En este ejemplo, montamos el `PersistentVolume` `test-data` en la carpeta `/test-data-mountpoint`
del contenedor principal del `Pod`