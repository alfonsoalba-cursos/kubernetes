### Resumen

* `PersistentVolume` y `PersistentVolumeClaim` separan el rol de gestión del espacio de almacenamiento 
  (tarea realizada por administradores) del uso de ese espacio de almacenamiento (tarea realizada por los 
  desarrolladores)
* Los administradores definen las `StorageClasses` y los `PersistentVolumes` disponibles dentro del cluster
* Los desarrolladores utilizan estos volúmenes mediante el uso de `PersistentVolumeClaims`
* Para evitar que los administradores tengan que crear los volúmenes con antelación, el cluster
  se puede configurar para que estos se puedan crear de forma dinámica


^^^^^^

### Más información

* [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
* [Dynamic Volume Provisioning](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/)
* API Reference:
  * [`PersistentVolume`](https://kubernetes.io/docs/reference/kubernetes-api/config-and-storage-resources/persistent-volume-v1/)
  * [`PersistentVolumeClaim`](https://kubernetes.io/docs/reference/kubernetes-api/config-and-storage-resources/persistent-volume-claim-v1/)
  * [`StorageClass`](https://kubernetes.io/docs/reference/kubernetes-api/config-and-storage-resources/storage-class-v1/)