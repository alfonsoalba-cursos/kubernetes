# Depuración usando _ephemeral containers_

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `minikube`

Para poder realizar este taller en minikube es necesario levantar minikube activando el _feature gate_
`EphemeralContainers`:

```shell
$ minikube start --feature-gates=EphemeralContainers=true
```

## La aplicación

Levantaremos un `Pod` con la imagen `k8s.gcr.io/pause:3.1` 
([aquí](https://github.com/kubernetes/kubernetes/tree/master/build/pause) podéis ver el repositorio con el 
`Dockerfile` de esta imagen).

```shell
$ kubectl run ephemeral-demo --image=k8s.gcr.io/pause:3.1 --restart=Never
```

Si miramos en detalle [Makefile](https://github.com/kubernetes/kubernetes/blob/master/build/pause/Makefile) 
utilizado para la construcción de la imagen, veremos que para el sistema operativo
Linux, el `Dockerfile` se puede resumir en:

```Dockerfile
FROM scratch
ARG ARCH
ADD bin/pause-linux-${ARCH} /pause
USER 65535:65535
ENTRYPOINT ["/pause"]
```

Es decir, la imagen sólo contiene un ejecutable en el sistema de ficheros, nada más. Así que si 
necesitamos depurar algo usando un intérprete de comandos, no vamos a poder:

```shell
$  kubectl exec -it ephemeral-demo -- sh
OCI runtime exec failed: exec failed: container_linux.go:380: starting container process caused: exec: "sh": executable file not found in $PATH: unknown
command terminated with exit code 126
```

## El contenedor de depuración

Para poder depurar, crearemos un _ephemeral container_ usando `kubectl debug` y le especificaremos
con la opción `--target` a qué `Pod` nos queremos conectar:

```shell
$ kubectl debug -it ephemeral-demo --image=busybox --target=ephemeral-demo
Targeting container "ephemeral-demo". If you don't see processes from this container it may be because the container runtime doesn't support this feature.
Defaulting debug container name to debugger-rj6c6.
If you don't see a command prompt, try pressing enter.
/ #
```

Hemos utilizado las siguientes opciones:
* `-it` para que kubectl se enganche al nuevo contenedor y abra una terminal
* `--target` para enfocarnos en el espacio de nombres del contenedor que ya está en ejecución. 
  Esta opción es necesario porque `kubectl run` no 
  [comparte el espacio de nombres](https://kubernetes.io/docs/tasks/configure-pod-container/share-process-namespace/) 
  de los contenedores de un `Pod`

Podemos ver el nuevo contenedor utilizando, por ejemplo,  `kubectl describe`:

```shell
$ kubectl describe pod ephemeral-demo

Name:         ephemeral-demo
Namespace:    default
Priority:     0
Node:         minikube/192.168.1.155
Start Time:   Sun, 06 Feb 2022 09:22:31 +0100
Labels:       run=ephemeral-demo
Annotations:  <none>
Status:       Running
IP:           172.17.0.3
IPs:
  IP:  172.17.0.3
Containers:
  ephemeral-demo:
    Container ID:   docker://a7ee83de6c2350c7ebefa88b1e7a86afa4a77d077e82d59a0b89b1cff8b77aef
    Image:          k8s.gcr.io/pause:3.1
    Image ID:       docker-pullable://k8s.gcr.io/pause@sha256:f78411e19d84a252e53bff71a4407a5686c46983a2c2eeed83929b888179acea
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Sun, 06 Feb 2022 09:22:32 +0100
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-7ffxh (ro)
Ephemeral Containers:
  debugger-rj6c6:
    Container ID:   docker://8faef2efaa320050430edc2dbccc13ed8764afdd83ca0d5308f0a2b846ad79ab
    Image:          busybox
    Image ID:       docker-pullable://busybox@sha256:afcc7f1ac1b49db317a7196c902e61c6c3c4607d63599ee1a82d702d249a0ccb
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Sun, 06 Feb 2022 09:22:46 +0100
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:         <none>
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-7ffxh:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  7m25s  default-scheduler  Successfully assigned default/ephemeral-demo to minikube
  Normal  Pulled     7m25s  kubelet            Container image "k8s.gcr.io/pause:3.1" already present on machine
  Normal  Created    7m25s  kubelet            Created container ephemeral-demo
  Normal  Started    7m25s  kubelet            Started container ephemeral-demo
  Normal  Pulling    7m14s  kubelet            Pulling image "busybox"
  Normal  Pulled     7m11s  kubelet            Successfully pulled image "busybox" in 2.861229879s
  Normal  Created    7m11s  kubelet            Created container debugger-rj6c6
  Normal  Started    7m11s  kubelet            Started container debugger-rj6c6
```

Dentro del contenedor, podemos ver el proceso:

```shell
/ # ps uxaf
PID   USER     TIME  COMMAND
    1 root      0:00 /pause
    9 root      0:00 sh
   17 root      0:00 ps uxaf
```

## Crear una copia del contenedor

Otra técnica que podemos utilizar es la de crear una copia del `Pod` a la que le añadimos un contenedor
con herramientas de depuración.

```shell
$ kubectl debug ephemeral-demo -it --image=ubuntu --share-processes --copy-to=ephemeral-demo-debug
Defaulting debug container name to debugger-k9k7t.
If you don't see a command prompt, try pressing enter.
root@ephemeral-demo-debug:/#
```

* `--share-process`: permite al contendor de este nuevo `Pod` ver los procesos (contenedores)
  del `Pod` `epehemeral-debug`
* Podemos seleccionar el nombre del contenedor usando la opción `--container`

Dentro de este contenedor, podemos ver dos procesos `/pause`, el del  `Pod` que queremos depurar
y el de la copia:

```shell
root@ephemeral-demo-debug:/# ps uxaf
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root          19  0.0  0.0   4112  3532 pts/0    Ss   04:49   0:00 bash
root          31  0.0  0.0   5900  2976 pts/0    R+   04:49   0:00  \_ ps uxaf
root          10  0.0  0.0   1024     4 ?        Ss   04:49   0:00 /pause
65535          1  1.2  0.0    968     4 ?        Ss   04:49   0:00 /pause
```

Con el comando `kubectl get pods` podemos ver los dos `Pods` que se están ejecutando:

```shell
$ kubectl get pods
NAME                   READY   STATUS     RESTARTS   AGE
ephemeral-demo         1/1     Running    0          20h
ephemeral-demo-debug   1/2     NotReady   0          2m29s
```

En el ejemplo que nos ocupa, el proceso con `PID` 1 es el proceso del `Pod` copia en el que
hemos iniciado sesión. Podmos comprobarlo matando este proceso. Al hacerlo, el contenedor morirá
y la sesión se cerrará:

```shell
root@ephemeral-demo-debug:/$ kill 1
root@ephemeral-demo-debug:/$
/home/myuser $
```

Borramos el `Pod` `ephemeral-demo-debug` y lo volvemos a crear:

```shell
$ kubectl delete pod ephemeral-demo-debug
pod "ephemeral-demo-debug" deleted

$ kubectl debug ephemeral-demo -it --image=ubuntu --share-processes --copy-to=ephemeral-demo-debug
Defaulting debug container name to debugger-nzbfc.
If you don't see a command prompt, try pressing enter.
root@ephemeral-demo-debug:/# ps uxfa
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root          14  0.0  0.0   4112  3404 pts/0    Ss   05:14   0:00 bash
root          24  0.0  0.0   5900  2944 pts/0    R+   05:14   0:00  \_ ps uxfa
root           7  0.0  0.0   1024     4 ?        Ss   05:14   0:00 /pause
65535          1  0.5  0.0    968     4 ?        Ss   05:14   0:00 /pause
```

Podemos acceder al sistema de ficheros del contenedor utilizando el enlace `/proc/<PID>/root`, que
en nuestro caso sería el del proceso `7`:

```shell
root@ephemeral-demo-debug:/$ ls /proc/7/root
dev  etc  pause  proc  sys  var
```

## Copiar el `Pod` cambiando el comando

Vamos a ilustrar otra forma de depurar contenedores que consiste en hacer una copia del `Pod` y cambiar
el comando del contenedor.

Borramos lod `Pods` que ya teenemos en ejecución:

```shell
$ kubectl delete pod ephemeral-demo-debug ephemeral-debug
pod "ephemeral-demo-debug" deleted
pod "ephemeral-demo" deleted
```

Simulamos que tenemos un `Pod` con un fallo de la siguiente manera:

```shell
$ kubectl run --image=busybox ephemeral-demo -- false
pod/ephemeral-demo created
```

Si miramos el estado del `Pod`:

```shell
$ kubectl describe pod ephemeral-demo
Name:         ephemeral-demo
Namespace:    default
Priority:     0
Node:         minikube/192.168.1.155
Start Time:   Mon, 07 Feb 2022 06:28:07 +0100
Labels:       run=ephemeral-demo
Annotations:  <none>
Status:       Running
IP:           172.17.0.3
IPs:
  IP:  172.17.0.3
Containers:
  ephemeral-demo:
    Container ID:  docker://a9ad57202623ecac98b7754ea71cff7d074e45ebb15e5e748189e4aa34246bc7
    Image:         busybox
    Image ID:      docker-pullable://busybox@sha256:afcc7f1ac1b49db317a7196c902e61c6c3c4607d63599ee1a82d702d249a0ccb
    Port:          <none>
    Host Port:     <none>
    Args:
      false
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       Error
      Exit Code:    1
      Started:      Mon, 07 Feb 2022 06:28:51 +0100
      Finished:     Mon, 07 Feb 2022 06:28:51 +0100
    Ready:          False
    Restart Count:  3
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-gfb9n (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             False
  ContainersReady   False
  PodScheduled      True
Volumes:
  kube-api-access-gfb9n:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  93s                default-scheduler  Successfully assigned default/ephemeral-demo to minikube
  Normal   Pulled     91s                kubelet            Successfully pulled image "busybox" in 1.253145553s
  Normal   Pulled     89s                kubelet            Successfully pulled image "busybox" in 1.267099164s
  Normal   Pulled     74s                kubelet            Successfully pulled image "busybox" in 1.2520699s
  Normal   Created    49s (x4 over 91s)  kubelet            Created container ephemeral-demo
  Normal   Started    49s (x4 over 91s)  kubelet            Started container ephemeral-demo
  Normal   Pulled     49s                kubelet            Successfully pulled image "busybox" in 1.25347408s
  Warning  BackOff    10s (x8 over 88s)  kubelet            Back-off restarting failed container
  Normal   Pulling    0s (x5 over 92s)   kubelet            Pulling image "busybox"
```

Si hacemos una copia sin más del `Pod` como hicimos en la sección anterior, la copia dará el mismo error.
Para hacer una copia del `Pod` y cambiar el comando del contenedor utilizamos la opción `--container` y
le pasamos el nuevo comando a `kubectl`:

```shell
$  kubectl debug ephemeral-demo -it --copy-to=ephemeral-demo-debug --container=ephemeral-demo -- sh
If you don't see a command prompt, try pressing enter.
#
```

En el comando anterior debemos especificar la opción `--container` para cambiar el comando de ese contenedor. Si no lo 
hacermos, **se creará un contenedor nuevo**.

Dentro de esta terminal, podemos ver el sistema de ficheros o intentar ejecutar el comando del contenedor
y depurar el error.

## Copiar el `Pod` y cambiar la imagen del contenedor

A veces, podemos necesitar cambiar la imagen del contenedor que está dando problemaspor otra que, por ejemplo,
puede contener herramientas de depuración o utilidades adicionales.

Borramos los `Pods` `ephemeral-demo-debug` y `ephemeral-demo`:

```shell
kubectl delete pod ephemeral-demo-debug ephemeral-demo
pod "ephemeral-demo-debug" deleted
pod "ephemeral-demo" deleted
```

Volvemos a levantar el `Pod` con la imagen `k8s.gcr.io/pause`:

```shell
$ kubectl run ephemeral-demo --image=busybox --restart=Never -- sleep 1d
pod/ephemeral-demo created
```

Creamos una copia del `Pod` cambiando la imagen:

```shell
$ kubectl debug ephemeral-demo --copy-to=ephemeral-demo-debug --set-image=*=ubuntu

$  kubectl get pods
NAME                   READY   STATUS    RESTARTS   AGE
ephemeral-demo         1/1     Running   0          26s
ephemeral-demo-debug   1/1     Running   0          8s
```

Una vez hecho esto, podemos abrir un intérprete de comandos en el nuevo `Pod`:

```shell
$ kubectl exec ephemeral-demo-debug -ti -- bash
```

La sintaxis de la opción `--set-image` es la misma que la del comando `kubectl set image` 
(`[NOMBRE_CONTENEDOR]=[IMAGEN]`). En este caso, `*=ubuntu` quiere decir que todos los contenedores
se sustituirán por la imagen `ubuntu`.

## Abrir un intérprete de comandos en el nodo

`kubectl debug` nos permite acceder al nodo para depurar nuestro problema si lo necesitamos. Para ello,
averiguamos en qué nodo se está ejecutando el `Pod`:

```shell
$ kubectl debug node/minikube -it --image=ubuntu              
Creating debugging pod node-debugger-minikube-vr8s4 with container debugger on node minikube.
If you don't see a command prompt, try pressing enter.

root@minikube:/#
```

* El nombre del `Pod` se genera automáticamente
  ```shell
  kubectl get pods                    
  NAME                           READY   STATUS    RESTARTS   AGE
  ephemeral-demo                 1/1     Running   0          9m34s
  node-debugger-minikube-vr8s4   1/1     Running   0          80s
  ```
* Podemos acceder al sistema de ficheros del nodo a través de la carpeta `/host`
* El contenedor tiene acceso a la red y los procesos del nodo
  ```shell
  USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
  root           2  0.0  0.0      0     0 ?        S    Feb06   0:00 [kthreadd]
  root           3  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [rcu_gp]
  root           4  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [rcu_par_gp]
  root           6  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [kworker/0:0H-kblockd]
  root           8  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [mm_percpu_wq]
  root           9  0.0  0.0      0     0 ?        S    Feb06   0:02  \_ [ksoftirqd/0]
  root          10  0.0  0.0      0     0 ?        I    Feb06   0:49  \_ [rcu_sched]
  root          11  0.0  0.0      0     0 ?        I    Feb06   0:00  \_ [rcu_bh]
  root          12  0.0  0.0      0     0 ?        S    Feb06   0:00  \_ [migration/0]
  root          13  0.0  0.0      0     0 ?        S    Feb06   0:00  \_ [cpuhp/0]
  root          15  0.0  0.0      0     0 ?        S    Feb06   0:00  \_ [cpuhp/1]
  root          16  0.0  0.0      0     0 ?        S    Feb06   0:00  \_ [migration/1]
  root          17  0.0  0.0      0     0 ?        S    Feb06   0:02  \_ [ksoftirqd/1]
  root          19  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [kworker/1:0H-kblockd]
  root          20  0.0  0.0      0     0 ?        S    Feb06   0:00  \_ [kdevtmpfs]
  root          21  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [netns]
  root          25  0.0  0.0      0     0 ?        S    Feb06   0:00  \_ [kauditd]
  root         392  0.0  0.0      0     0 ?        S    Feb06   0:00  \_ [oom_reaper]
  root         468  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [writeback]
  root         470  0.0  0.0      0     0 ?        S    Feb06   0:00  \_ [kcompactd0]
  root         471  0.0  0.0      0     0 ?        SN   Feb06   0:00  \_ [khugepaged]
  root         472  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [crypto]
  root         474  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [kblockd]
  root         654  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [ata_sff]
  root         660  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [md]
  root         679  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [edac-poller]
  root         789  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [rpciod]
  root         790  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [kworker/u5:0-xprtiod]
  root         791  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [xprtiod]
  root         794  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [cfg80211]
  root         806  0.0  0.0      0     0 ?        S    Feb06   0:00  \_ [kswapd0]
  root         932  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [nfsiod]
  root         944  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [cifsiod]
  root         945  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [cifsoplockd]
  root         962  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [xfsalloc]
  root         963  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [xfs_mru_cache]
  root        1014  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [acpi_thermal_pm]
  root        1080  0.0  0.0      0     0 ?        S    Feb06   0:00  \_ [scsi_eh_0]
  root        1081  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [scsi_tmf_0]
  root        1085  0.0  0.0      0     0 ?        S    Feb06   0:00  \_ [scsi_eh_1]
  root        1086  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [scsi_tmf_1]
  root        1139  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [dm_bufio_cache]
  root        1178  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [ipv6_addrconf]
  root        1182  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [ceph-msgr]
  root        1921  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [hv_vmbus_con]
  root        1922  0.0  0.0      0     0 ?        I<   Feb06   0:01  \_ [kworker/1:1H-kblockd]
  root        1923  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [hv_pri_chan]
  root        1925  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [hv_sub_chan]
  root        1968  0.0  0.0      0     0 ?        S    Feb06   0:00  \_ [scsi_eh_2]
  root        1985  0.0  0.0      0     0 ?        S    Feb06   0:01  \_ [hv_balloon]
  root        1993  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [scsi_tmf_2]
  root        2003  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [storvsc_error_w]
  root        2015  0.0  0.0      0     0 ?        S    Feb06   0:00  \_ [scsi_eh_3]
  root        2019  0.0  0.0      0     0 ?        I<   Feb06   0:01  \_ [kworker/0:1H-kblockd]
  root        2020  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [scsi_tmf_3]
  root        2023  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [storvsc_error_w]
  root        2086  0.0  0.0      0     0 ?        S    Feb06   0:02  \_ [jbd2/sda1-8]
  root        2087  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [ext4-rsv-conver]
  root        2203  0.0  0.0      0     0 ?        I<   Feb06   0:00  \_ [kworker/u5:1]
  root        2204  0.0  0.0      0     0 ?        S    Feb06   0:00  \_ [lockd]
  root        2207  0.0  0.0      0     0 ?        S    Feb06   0:00  \_ [nfsd]
  root        2208  0.0  0.0      0     0 ?        S    Feb06   0:00  \_ [nfsd]
  root        2209  0.0  0.0      0     0 ?        S    Feb06   0:00  \_ [nfsd]
  root        2210  0.0  0.0      0     0 ?        S    Feb06   0:00  \_ [nfsd]
  root        2211  0.0  0.0      0     0 ?        S    Feb06   0:00  \_ [nfsd]
  root        2212  0.0  0.0      0     0 ?        S    Feb06   0:00  \_ [nfsd]
  root        2213  0.0  0.0      0     0 ?        S    Feb06   0:00  \_ [nfsd]
  root        2214  0.0  0.0      0     0 ?        S    Feb06   0:00  \_ [nfsd]
  root      269489  0.0  0.0      0     0 ?        I    05:37   0:00  \_ [kworker/0:1-events_power_efficient]
  root      272567  0.0  0.0      0     0 ?        I    05:49   0:00  \_ [kworker/u4:2-events_unbound]
  root      274030  0.0  0.0      0     0 ?        I    05:54   0:00  \_ [kworker/1:3-ata_sff]
  root      274836  0.0  0.0      0     0 ?        I    05:56   0:00  \_ [kworker/0:3-events]
  root      276046  0.0  0.0      0     0 ?        I    06:01   0:00  \_ [kworker/u4:1-events_unbound]
  root      276867  0.0  0.0      0     0 ?        I    06:05   0:00  \_ [kworker/1:0-ata_sff]
  root      278016  0.0  0.0      0     0 ?        I    06:10   0:00  \_ [kworker/1:1-events]
  root           1  0.0  0.1  98128 10280 ?        Ss   Feb06   0:08 /sbin/init noembed norestore
  root        1265  0.0  0.1  22556  9936 ?        Ss   Feb06   0:00 /usr/lib/systemd/systemd-journald
  root        1526  0.0  0.1  11468  6908 ?        Ss   Feb06   0:00 /usr/lib/systemd/systemd-udevd
  1003        1910  0.0  0.1  11272  7048 ?        Ss   Feb06   0:00 /usr/lib/systemd/systemd-networkd
  1004        2051  0.0  0.1  12540  9468 ?        Ss   Feb06   0:00 /usr/lib/systemd/systemd-resolved
  1005        2052  0.0  0.1  85480  6124 ?        Ssl  Feb06   0:00 /usr/lib/systemd/systemd-timesyncd
  1001        2060  0.0  0.0   5880  4200 ?        Ss   Feb06   0:02 /usr/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --sys
  root        2066  0.0  0.0   3728  2480 ?        Ss+  Feb06   0:00 /sbin/agetty -o -p -- \u --noclear tty1 linux
  root        2070  0.0  0.0   3000  1920 ?        Ss   Feb06   0:00 /usr/sbin/hv_kvp_daemon -n
  root        2072  0.0  0.0   2276   216 ?        Ss   Feb06   0:00 /usr/sbin/hv_vss_daemon -n
  root        2082  0.0  0.0   3728  2484 ?        Ss+  Feb06   0:00 /sbin/agetty -o -p -- \u --keep-baud 115200,57600,38400,9600 ttyS0 vt220   
  root        2088  0.0  0.0  10156  5468 ?        Ss   Feb06   0:00 /usr/lib/systemd/systemd-logind
  root        2117  0.0  0.0   7300  5100 ?        Ss   Feb06   0:00 sshd: /usr/sbin/sshd -D -e [listener] 0 of 10-100 startups
  root        2196  0.0  0.0   3904  2164 ?        Ss   Feb06   0:00 /usr/sbin/rpcbind
  root        2197  0.0  0.0   2880  1988 ?        Ss   Feb06   0:00 /usr/sbin/rpc.statd
  root        2198  0.0  0.0   2980   264 ?        Ss   Feb06   0:00 /usr/sbin/rpc.mountd
  root        2463  0.7  1.2 1916700 77348 ?       Ssl  Feb06   9:37 /usr/bin/dockerd -H tcp://0.0.0.0:2376 -H unix:///var/run/docker.sock --def
  root        2470  0.0  0.8 1418560 51196 ?       Ssl  Feb06   0:56  \_ containerd --config /var/run/docker/containerd/containerd.toml --log-le
  root        3682  0.0  0.1 710940  8576 ?        Sl   Feb06   0:06 /usr/bin/containerd-shim-runc-v2 -namespace moby -id a6469a9599817392ed9c7f
  65535       3759  0.0  0.0    968     4 ?        Ss   Feb06   0:00  \_ /pause
  root        3697  0.0  0.1 710940  7976 ?        Sl   Feb06   0:06 /usr/bin/containerd-shim-runc-v2 -namespace moby -id 969f75a1550e093e5bbd12
  65535       3785  0.0  0.0    968     4 ?        Ss   Feb06   0:00  \_ /pause
  root        3725  0.0  0.1 710940  8892 ?        Sl   Feb06   0:05 /usr/bin/containerd-shim-runc-v2 -namespace moby -id d5c0782fae11bd2e9e7bcc
  65535       3810  0.0  0.0    968     4 ?        Ss   Feb06   0:00  \_ /pause
  root        3744  0.0  0.1 710684  8056 ?        Sl   Feb06   0:05 /usr/bin/containerd-shim-runc-v2 -namespace moby -id 65bdb26686d7719e8c7301
  65535       3802  0.0  0.0    968     4 ?        Ss   Feb06   0:00  \_ /pause
  root        3887  0.0  0.1 711196  8560 ?        Sl   Feb06   0:06 /usr/bin/containerd-shim-runc-v2 -namespace moby -id b70f9be639dc1431235171
  root        3935  1.6  1.7 822592 103604 ?       Ssl  Feb06  21:11  \_ kube-controller-manager --allocate-node-cidrs=true --authentication-kub
  root        3908  0.0  0.1 710684  8540 ?        Sl   Feb06   0:06 /usr/bin/containerd-shim-runc-v2 -namespace moby -id c8767bf925e5354b2a1500
  root        3930  5.1  4.8 1106024 287468 ?      Ssl  Feb06  67:38  \_ kube-apiserver --advertise-address=192.168.1.155 --allow-privileged=tru
  root        3952  0.0  0.1 710940  8508 ?        Sl   Feb06   0:06 /usr/bin/containerd-shim-runc-v2 -namespace moby -id caac0e87dcf8445591e10f
  root        3978  0.2  0.8 753768 50500 ?        Ssl  Feb06   3:22  \_ kube-scheduler --authentication-kubeconfig=/etc/kubernetes/scheduler.co
  root        3979  0.0  0.1 711196  8612 ?        Sl   Feb06   0:06 /usr/bin/containerd-shim-runc-v2 -namespace moby -id 9b278fa3c4109cdd4448d1
  root        4003  1.4  1.1 11215288 70244 ?      Ssl  Feb06  19:28  \_ etcd --advertise-client-urls=https://192.168.1.155:2379 --cert-file=/va
  root        4410  0.0  0.1 710940  8632 ?        Sl   Feb06   0:05 /usr/bin/containerd-shim-runc-v2 -namespace moby -id bd5227da5c5b6c02f138ec
  65535       4430  0.0  0.0    968     4 ?        Ss   Feb06   0:00  \_ /pause
  root        4452  0.0  0.1 710940  9052 ?        Sl   Feb06   0:05 /usr/bin/containerd-shim-runc-v2 -namespace moby -id 1062a22a3b1003b125c5bb
  65535       4477  0.0  0.0    968     4 ?        Ss   Feb06   0:00  \_ /pause
  root        4509  0.0  0.1 711196  8108 ?        Sl   Feb06   0:04 /usr/bin/containerd-shim-runc-v2 -namespace moby -id a3796da96f6059d73220ff
  root        4532  0.0  0.6 747708 37988 ?        Ssl  Feb06   0:14  \_ /usr/local/bin/kube-proxy --config=/var/lib/kube-proxy/config.conf --ho
  root        4570  0.0  0.1 710684  8272 ?        Sl   Feb06   0:06 /usr/bin/containerd-shim-runc-v2 -namespace moby -id 8ec1716f6e749906708a02
  65535       4613  0.0  0.0    968     4 ?        Ss   Feb06   0:00  \_ /pause
  root        4597  0.0  0.1 710940  8168 ?        Sl   Feb06   0:06 /usr/bin/containerd-shim-runc-v2 -namespace moby -id 2d1353ccdd41ea29a795ba
  root        4623  0.1  0.7 751500 43748 ?        Ssl  Feb06   2:10  \_ /coredns -conf /etc/coredns/Corefile
  root        4738  0.0  0.1 710940  8852 ?        Sl   Feb06   0:09 /usr/bin/containerd-shim-runc-v2 -namespace moby -id 60801b250c480ee3655fb9
  root        4771  0.1  0.4 735724 29144 ?        Ssl  Feb06   1:44  \_ /storage-provisioner
  root        4807  3.0  1.8 1861556 111500 ?      Ssl  Feb06  40:17 /var/lib/minikube/binaries/v1.22.3/kubelet --bootstrap-kubeconfig=/etc/kube
  root      275895  0.0  0.1 710940  8020 ?        Sl   06:01   0:00 /usr/bin/containerd-shim-runc-v2 -namespace moby -id d2e2a1f4869ad6620107ac
  65535     275920  0.0  0.0    968     4 ?        Ss   06:01   0:00  \_ /pause
  root      275969  0.0  0.1 710940  8796 ?        Sl   06:01   0:00 /usr/bin/containerd-shim-runc-v2 -namespace moby -id 3d8c175f6fab30703975e0
  root      275989  0.0  0.0   1312     4 ?        Ss   06:01   0:00  \_ sleep 1d
  root      276061  0.0  0.1 710940  9056 ?        Sl   06:01   0:00 /usr/bin/containerd-shim-runc-v2 -namespace moby -id 3cfaa8a5bb24385e57fc93
  65535     276084  0.0  0.0    968     4 ?        Ss   06:01   0:00  \_ /pause
  root      276147  0.0  0.1 710940  9380 ?        Sl   06:01   0:00 /usr/bin/containerd-shim-runc-v2 -namespace moby -id e64050e4ec0cd5876c2d6a
  root      276166  0.0  0.0   2512   528 ?        Ss   06:01   0:00  \_ sleep 1d
  root      277832  0.0  0.1 710684  8036 ?        Sl   06:09   0:00 /usr/bin/containerd-shim-runc-v2 -namespace moby -id 45588a117501ecb0311a61
  65535     277853  0.1  0.0    968     4 ?        Ss   06:09   0:00  \_ /pause
  root      277884  0.0  0.1 711004  8376 ?        Sl   06:09   0:00 /usr/bin/containerd-shim-runc-v2 -namespace moby -id f438ff71dba492870de574
  root      277905  0.0  0.0   4112  3512 pts/0    Ss   06:09   0:00  \_ bash
  root      278413  0.0  0.0   6040  2932 pts/0    R+   06:12   0:00      \_ ps uxaf
  ```

## Limpieza

Para terminar el taller, borraremos el `Pod`, las copias y el `Pod` de depuración del host que creamos en la sección anterior:

```shell 
$ kubectl delete pod ephemeral-demo ephemeral-demo-debug node-debugger-minikube-vr8s4
```
Acuerdate de ejecutar `minikube stop` para detener minikube.