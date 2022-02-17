# Comprobaciones de estado: _Liveness and readiness probes_

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `minikube`


## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-healthchecks`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-healthchecks created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                STATUS   AGE
default             Active   34d
demo-healthchecks   Active   10s
kube-node-lease     Active   34d
kube-public         Active   34d
kube-system         Active   34d
```

Puedes seleccionar este espacio de nombres por defecto ejecutando:

```shell
$ kubectl config set-context --current --namespace demo-healthchecks
Context "minikube" modified.
```

## El `Pod`

Utilizaremos el `Pod` [`pod.yml`](./pod.yml) para mostrar cómo funcionan las
comprobaciones de estado. Levantamos la aplicación:


```shell
$ kubectl apply -f pod.yml
```

Desde que el `Pod` se crea hasta que el estado pasa a _ready_, van a pasar 30 segundos. Durante este tiempo, este
es el estado en el que se encuentra el `Pod`

* `kubectl get pods` muestra el pod en la fase `Running` pero todavía no está _ready_ 
  ```shell
  $ kubectl get pods -n demo-healthchecks
  NAME          READY   STATUS    RESTARTS   AGE
  bar-website   0/1     Running   0          6s
  ```
* El estado del contenedor, que podemos ver con `kubectl get pod bar-website -n demo-healthchecks  -o yaml`, nos
  muestra que no está listo:
  ```yaml
  statue:
    condition: ...
      containerStatuses:
      - containerID: containerd://6ea8fc3d3c12aa40e498dfbe7d4845767a14bb588945dbb0b9344ba3e19c7a6d
        image: docker.io/kubernetescourse/bar-website-for-healthchecks:latest
        imageID: docker.io/kubernetescourse/bar-website-for-healthchecks@sha256:8fbb0bbbc7e30535f632c1913649510727f39b34e5951fd67c2b6c862de6bfe9
        lastState: {}
        name: nginx
        ready: false
        restartCount: 0
        started: true
        state:
          running:
            startedAt: "2022-02-17T05:56:14Z"
  ```
* Usando el comando `kubectl describe pod bar-website -n demo-healthchecks` también podemos ver el estado del 
  contenedor y los estados (_conditions_) del `Pod`

  ```shell
  kubectl describe pod bar-website -n demo-healthchecks         
  Name:         bar-website
  Namespace:    demo-healthchecks
  Priority:     0
  Node:         standardnodes-caadtmk6sp/93.93.115.93
  Start Time:   Thu, 17 Feb 2022 06:56:10 +0100
  Labels:       <none>
  Annotations:  cni.projectcalico.org/containerID: 7585014c1e63a50fbb365d8b04e4b0f6e9497fa303f2daf1fd8c0245d38a282d
                cni.projectcalico.org/podIP: 10.222.77.91/32
                cni.projectcalico.org/podIPs: 10.222.77.91/32
  Status:       Running
  IP:           10.222.77.91
  IPs:
    IP:  10.222.77.91
  Containers:
    nginx:
      Container ID:   containerd://6ea8fc3d3c12aa40e498dfbe7d4845767a14bb588945dbb0b9344ba3e19c7a6d
      Image:          kubernetescourse/bar-website-for-healthchecks
      Image ID:       docker.io/kubernetescourse/bar-website-for-healthchecks@sha256:8fbb0bbbc7e30535f632c1913649510727f39b34e5951fd67c2b6c862de6bfe9
      Port:           80/TCP
      Host Port:      0/TCP
      State:          Running
        Started:      Thu, 17 Feb 2022 06:56:14 +0100
      Ready:          False
      Restart Count:  0
      Liveness:       exec [/live.sh] delay=30s timeout=1s period=15s #success=1 #failure=3
      Readiness:      exec [/ready.sh] delay=30s timeout=1s period=15s #success=1 #failure=3
      Environment:    <none>
      Mounts:
        /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-k827n (ro)
  Conditions:
    Type              Status
    Initialized       True
    Ready             False
    ContainersReady   False
    PodScheduled      True
  Volumes:
    kube-api-access-k827n:
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
    Type    Reason     Age   From               Message
    ----    ------     ----  ----               -------
    Normal  Scheduled  24s   default-scheduler  Successfully assigned demo-healthchecks/bar-website to standardnodes-caadtmk6sp
    Normal  Pulling    21s   kubelet            Pulling image "kubernetescourse/bar-website-for-healthchecks"
    Normal  Pulled     20s   kubelet            Successfully pulled image "kubernetescourse/bar-website-for-healthchecks" in 1.193145098s
    Normal  Created    20s   kubelet            Created container nginx
    Normal  Started    20s   kubelet            Started container nginx
  ```
  
En la especificación del `Pod` hemos utilizado `intialDelaySeconds`, lo que 
significa tendremos que esperar 30 segundos para que las comprobaciones de estado
se ejecuten y el estado del `Pod` cambie.

Pasado este tiempo, podemos ver que el `Pod` está en _ready_:

```shell
$ kubectl get pods -n demo-healthchecks        
NAME          READY   STATUS    RESTARTS   AGE
bar-website   1/1     Running   0          7m37s

$ kubectl describe pod bar-website -n demo-healthchecks
...
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
...
```


## Fallo en el _liveness probe_

Vamos a forzar un fallo en el contenedor. Para ello, borraremos el fichero `/usr/share/nginx/html/live`:

```shell
$ kubectl exec bar-website -n demo-healthchecks -- rm /usr/share/nginx/html/live
```

Tras 15 segundos, veremos que el contenedor se reinicia:

```shell
$ kubectl describe pod bar-website -n demo-healthchecks 
....
Containers:
  nginx:
    Container ID:   containerd://d321a7297c5af01aee99b66e7f6b60da55ac0a5c9f64e4dbb4c88554a541b29a
    Image:          kubernetescourse/bar-website-for-healthchecks
    Image ID:       docker.io/kubernetescourse/bar-website-for-healthchecks@sha256:8fbb0bbbc7e30535f632c1913649510727f39b34e5951fd67c2b6c862de6bfe9
    ....
    Ready:          False
    Restart Count:  1
    ....
Conditions:
  Type              Status
  Initialized       True
  Ready             False
  ContainersReady   False
  PodScheduled      True
....
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  11m                default-scheduler  Successfully assigned demo-healthchecks/bar-website to standardnodes-caadtmk6sp
  Normal   Pulled     11m                kubelet            Successfully pulled image "kubernetescourse/bar-website-for-healthchecks" in 1.193145098s
  Normal   Pulling    23s (x2 over 11m)  kubelet            Pulling image "kubernetescourse/bar-website-for-healthchecks"
  Warning  Unhealthy  23s (x3 over 53s)  kubelet            Liveness probe failed:
  Normal   Killing    23s                kubelet            Container nginx failed liveness probe, will be restarted
  Normal   Created    22s (x2 over 11m)  kubelet            Created container nginx
  Normal   Started    22s (x2 over 11m)  kubelet            Started container nginx
  Normal   Pulled     22s                kubelet            Successfully pulled image "kubernetescourse/bar-website-for-healthchecks" in 1.199177621s
```

Vemos que el contenedor ha tenido un reinicio. También podemos verlo con `kubectl get pods`:

```shell
$  kubectl get pods -n demo-healthchecks         
NAME          READY   STATUS    RESTARTS     AGE
bar-website   1/1     Running   1 (3m ago)   14m
```

Podemos borrar el fichero `/usr/share/nginx/html/live` más de una vez para forzar 
el reinicio del contenedor las veces que queramos.

## Fallo en el _readiness probe_

Vamos a crear el fichero `/usr/share/nginx/html/maintenance` dentro del contenedor:

```shell
$ kubectl exec bar-website -n demo-healthchecks -- touch /usr/share/nginx/html/maintenance
```

Si esperamos unos 15 segundos, veremos que el _readiness probe_ falla y el contenedor para a
no estar _ready_:

```shell
$ kubectl describe pod bar-website -n demo-healthchecks 
....
Containers:
  ....
  nginx:
    Ready:          False
    Restart Count:  1
  ....
Conditions:
  Type              Status
  Initialized       True
  Ready             False
  ContainersReady   False
  PodScheduled      True
....
Events:
  Type     Reason     Age                    From               Message
  ----     ------     ----                   ----               -------
  Normal   Scheduled  19m                    default-scheduler  Successfully assigned demo-healthchecks/bar-website to standardnodes-caadtmk6sp
  Normal   Pulled     19m                    kubelet            Successfully pulled image "kubernetescourse/bar-website-for-healthchecks" in 1.193145098s
  Normal   Pulling    8m14s (x2 over 19m)    kubelet            Pulling image "kubernetescourse/bar-website-for-healthchecks"
  Warning  Unhealthy  8m14s (x3 over 8m44s)  kubelet            Liveness probe failed:
  Normal   Killing    8m14s                  kubelet            Container nginx failed liveness probe, will be restarted
  Normal   Created    8m13s (x2 over 19m)    kubelet            Created container nginx
  Normal   Started    8m13s (x2 over 19m)    kubelet            Started container nginx
  Normal   Pulled     8m13s                  kubelet            Successfully pulled image "kubernetescourse/bar-website-for-healthchecks" in 1.199177621s
  Warning  Unhealthy  14s (x4 over 59s)      kubelet            Readiness probe failed:
```

Vemos que el contenedor no se reinicia, a diferencia de lo que ocurrió cuando falló el _liveness probe_:

```shell 
$ kubectl get pods -n demo-healthchecks
NAME          READY   STATUS    RESTARTS      AGE
bar-website   0/1     Running   1 (11m ago)   22m
```

Para recuperar el servicio, basta con borrar el fichero que hemos creado:

```shell
$ kubectl exec bar-website -n demo-healthchecks -- rm /usr/share/nginx/html/maintenance
```

...y esperar ~15 segundos:

```shell
$ kubectl get pods -n demo-healthchecks
NAME          READY   STATUS    RESTARTS      AGE
bar-website   1/1     Running   1 (13m ago)   24m
```

## Limpieza

Volvemos a poner `default` como espacio de nombres por defecto:

```shell
$ kubectl config set-context --current --namespace default
Context "minikube" modified.
```


Para borrar todos los objetos, basta con borrar el espacio de nombres:

```shell
$ kubectl delete -f namespace.yml
namespace "demo-healthchecks" deleted
```