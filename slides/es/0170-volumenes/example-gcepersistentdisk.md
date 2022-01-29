### Ejemplo: `gcePersistentDisk`

Paso 1: Creamos el volumen en Google Cloud

```shell
$ gcloud compute disks create --size=500GB --zone=us-central1-a my-data-disk
```

^^^^^^

### Ejemplo: `gcePersistentDisk`

Paso 2: Montamos el volume en un contenedor

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
  - image: k8s.gcr.io/test-webserver
    name: test-container
    volumeMounts:
    - mountPath: /test-pd
      name: test-volume
  volumes:
  - name: test-volume
    # This GCE PD must already exist.
    gcePersistentDisk:
      pdName: my-data-disk
      fsType: ext4
```