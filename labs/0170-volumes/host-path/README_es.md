# Uso de `HostPath` (cluster gestionado)

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `managed`


## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-hostpath`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-hostpath created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                STATUS   AGE
default             Active   34d
demo-hostpath       Active   16s
kube-node-lease     Active   34d
kube-public         Active   34d
kube-system         Active   34d
```

Puedes seleccionar este espacio de nombres por defecto ejecutando:

```shell
$ kubectl config set-context --current --namespace demo-hostpath
Context "minikube" modified.
```
## Obtener el listado de dispositivos del nodo

Creamos un contenedor de depuración en uno de los nodos:

```shell
$ kubectl get nodes

$ kubectl debug node/standardnodes-tsl5rq2g7y  -ti --image busybox
Creating debugging pod node-debugger-standardnodes-tsl5rq2g7y-j5d56 with container debugger on node standardnodes-tsl5rq2g7y.
If you don't see a command prompt, try pressing enter.
/ #
```

```shell
$ / # ls -l /host/dev/disk/by-label/
total 0
lrwxrwxrwx    1 root     root            10 Feb 17 16:32 cloudimg-rootfs -> ../../vda1
```

Con este comando, ya sabemos el dispositivo de bloques del disco duro del nodo: `/dev/vda`.


## El `Pod`

Usaremos el fichero [`pod.yml`](./pod.yml) para crear el `Pod`. Este accederá a tres ficheros / directorios del nodo. 
**Antes de ejecutar el comando, editar el fichero y cambiar el dispositivo en caso de que
no sea `/dev/vda1`.**

```shell
$ kubectl apply -f pod.yml
```

Veamos que el `Pod` se ha creado correctamente:

```shell
$  kubectl get pods -n demo-hostpath
NAME           READY   STATUS    RESTARTS   AGE
hostpath-pod   1/1     Running   0          40s
```

Si miramos la información del `Pod`:

```shell
$ kubectl describe pod hostpath-pod -n demo-hostpath
Name:         hostpath-pod
Namespace:    demo-hostpath
Containers:
Volumes:
  test-directory:
    Type:          HostPath (bare host directory volume)
    Path:          /demo-hostpath/data
    HostPathType:  DirectoryOrCreate
  test-file:
    Type:          HostPath (bare host directory volume)
    Path:          /demo-hostpath/hello.txt
    HostPathType:  FileOrCreate
  test-device:
    Type:          HostPath (bare host directory volume)
    Path:          /dev/vda
    HostPathType:  BlockDevice
  kube-api-access-fdbb5:
    Type:                    Projected (a volume that contains injected data from multiple sources) 
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
```

## Accediendo a los volúmenes desde el `Pod`

Accedamos al `Pod`:

```shell
$ kubectl exec hostpath-pod -ti -n demo-hostpath -- bash 
root@hostpath-pod:/#
```

Una vez dentro del `Pod`, vamos a ver cómo podemos acceder al dispositivo `/dev/host-block-device`. Para ello, dentro del contenedor, instalamos `fdisk`:

```shell
$ apt update && apt install -y fdisk
```

Una vez tenemos `fdisk` instalado, podemos listar la tabla de particiones del
disco duro del host:

```shell
$ fdisk -l /dev/host-block-device 
Disk /dev/host-block-device: 50 GiB, 53687091200 bytes, 104857600 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: F939C69C-B7F6-4E7D-90FC-BD42C215FA09

Device                   Start       End   Sectors Size Type
/dev/host-block-device1  10240 104857566 104847327  50G Linux filesystem
/dev/host-block-device14  2048     10239      8192   4M BIOS boot

Partition table entries are not in disk order.
```

Vamos a modificar el fichero `/hello.txt`. Añadimos una línea al final del fichero:

```shell
root@hostpath-pod:/# echo "Hola desde el pod: $(date)." >> /hello.txt
```

En la carpeta `/test-directory` crearemos un fichero:

```shell
root@hostpath-pod:/# touch /tmp/$(date +%Y%m%d-%H%M%S)-$(hostname).txt
```

Cerramos la consola con `exit` y abrimos un contenedor de depuración en el nodo
en el que está el `Pod`:

```shell
$ kubectl get pods -o wide -n demo-hostpath
NAME           READY   STATUS    RESTARTS   AGE     IP              NODE                       NOMINATED NODE   READINESS GATES
hostpath-pod   1/1     Running   0          8m40s   10.221.166.18   standardnodes-tsl5rq2g7y   <none>           <none>

$ kubectl debug node/standardnodes-tsl5rq2g7y  -ti --image busybox
Creating debugging pod node-debugger-standardnodes-tsl5rq2g7y-xn8q5 with container debugger on node standardnodes-tsl5rq2g7y.
If you don't see a command prompt, try pressing enter.
/ #
```

Dentro de este contenedor, veremos el fichero que creamos antes, así como las 
modificaciones que hicimos el fichero del host. Estos ficheros estarán 
en la carpeta `/host` del contenedor de depuración:

```shell
/ # ls /host/demo-hostpath/data/
20220219-113001-hostpath-pod.txt

/ # cat /host/demo-hostpath/hello.txt
Hola desde el pod: Sat Feb 19 11:29:03 UTC 2022.
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
namespace "demo-hostpath" deleted
```