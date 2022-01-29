### Tipos de volúmenes
* `EmptyDir`
* `nfs`
* _Network Storage_
* `csi`
* `configMap`, `Secret`, `downwardAPI`, `projected`
* `persistentVolume`, `persistentVolumeClaim`
* `hostPath`

^^^^^^


### Tipos de volúmenes: `EmptyDir`

Almacena información durante el tiempo de vida del `Pod`

**El contenido se pierde cuando el `Pod` se mueve a otro nodo**

Si se reinician los contenedores, el volumen no se vuelve a crear

Se puede usar la opción `emptyDir.medium: "Memory"` para usar memoria en lugar de disco

notes:

Por defecto, el `EmptyDir` utiliza el espacio de almacenamiendo del nodo (SSH, HDD, almacenamiento de red... lo
que sea que el nodo tenga configurado).

Recuerda que si el nodo se reinicia y has utilizado la opción `emptyDir.medium: "Memory"`, la información se borrará
(!porque está en memoria¡)

[Más información sobre `EmptyDir`](https://kubernetes.io/docs/concepts/storage/volumes/#emptydir)

^^^^^^

### Tipos de volúmenes: `nfs`

Permite acceder a volúmenes NFS desde nuestros contenedores

notes:

* [Más información sobre `nfs`](https://kubernetes.io/docs/concepts/storage/volumes/#nfs)
* [Ejemplo de uso](https://github.com/kubernetes/examples/tree/master/staging/volumes/nfs)

^^^^^^

### Tipos de volúmenes: facilitados por proveedores cloud

* [awsElasticBlockStore ](https://kubernetes.io/docs/concepts/storage/volumes/#awselasticblockstore)
* [gcePersistentDisk](https://kubernetes.io/docs/concepts/storage/volumes/#gcepersistentdisk)
* [azureDisk](https://kubernetes.io/docs/concepts/storage/volumes/#azuredisk) / 
  [azureFile](https://kubernetes.io/docs/concepts/storage/volumes/#azurefile)

**Estos volúmenes están en el código fuente de Kubernetes**

notes:

Son volúmenes facilitados por los proveedores cloud. De momento, sólo los tres con más cuota de mercado 
han incluido su propio tipo de volúmen. 



^^^^^^

### Tipos de volúmenes: `csi`

Permite a los fabricantes crear drivers para sus sitemas de almacenamiento

* [Más información sobre `csi`](https://kubernetes.io/docs/concepts/storage/volumes/#out-of-tree-volume-plugins)
* [Driver disponibles](https://kubernetes-csi.github.io/docs/drivers.html)

notes: 

Para evitar que cada proveedor tenga que subir el código de sus drivers a Kubernetes, se ha creado una
interfaz llamada [Container Storage Interface (`csi`)](https://github.com/container-storage-interface/spec/blob/master/spec.md)
que permite a cada fabricante integrar sus sitemas
de almacenamiento de forma independiente.

Otros proveedores utilizan `csi`. Actualmente, existen rutas de migración para en lugar de utilizar estos volúmenes,
se utilice `csi`. Por ejemplo:
* https://kubernetes.io/docs/concepts/storage/volumes/#gce-csi-migration
* https://kubernetes.io/docs/concepts/storage/volumes/#azuredisk-csi-migration

^^^^^^

### Tipos de volúmenes: `csi`

Los volúmenes `csi` de pueden utilizar

* A través de un `PersistentVolumeClaim`
* A través de un volúmenes efímeros

^^^^^^

### Tipos de volúmenes: _Network Storage_

cephfs, cinder, fc, flexVolume, flocker, glusterfs, iscsi, portworxVolume, quobyte, rbd, scaleIO, storageos, photonPersistentDisk, vsphereVolume

notes:

Si nuestra infraestructura dispone de este tipo de almacenamiento de red, podemos acceder a él desde Kubernetes

^^^^^^

### Tipos de volúmenes: `configMap`, `Secret`, `downwardAPI`, `projected`

Inyectar configuración a los contenedores

notes:

* `Downward API`: permite exponer configuración de los `Pods`a los contenedores para que puedan leerla
* [`projected`](https://kubernetes.io/docs/concepts/storage/projected-volumes/): 
  permite mapear varios volúmes del tipo mencionado en esta diapositiva, y que se monten
  dentro de un mismo volumen

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-test
spec:
  containers:
  - name: container-test
    image: busybox
    volumeMounts:
    - name: all-in-one
      mountPath: "/projected-volume"
      readOnly: true
  volumes:
  - name: all-in-one
    projected:
      sources:
      - secret:
          name: mysecret
          items:
            - key: username
              path: my-group/my-username
      - downwardAPI:
          items:
            - path: "labels"
              fieldRef:
                fieldPath: metadata.labels
            - path: "cpu_limit"
              resourceFieldRef:
                containerName: container-test
                resource: limits.cpu
      - configMap:
          name: myconfigmap
          items:
            - key: config
              path: my-group/my-config
```

^^^^^^

### Tipos de volúmenes: `persistentVolume`, `persistentVolumeClaim`

Capa de abstracción para separar la tecnología en la que se implementa un volumen de cómo
este se utiliza

Lo veremos en el siguiente módulo

^^^^^^

### Tipos de volúmenes: `hostPath`

Permite acceder a carpetas y ficheros del nodo desde los contenedores de un `Pod`

⚠️ Cuidado con lo que expones al `Pod`. Puedes abrir brechas de seguridad significativas

notes:

Por ejemplo, si expones el sistema de ficheros raiz completo,
o si expones un socket de Kubelet o cualquier otra API privada, un atacante puede
escapar del contenedor y acceder a otras partes del systema.

[Más información: `HostPath`](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath)