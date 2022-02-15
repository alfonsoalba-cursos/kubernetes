# Ciclo de vida del `Pod`: fase y estados (_conditions_)

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `minikube`


## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-podphase`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-podphase created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                STATUS   AGE
default             Active   34d
demo-podphase       Active   10s
kube-node-lease     Active   34d
kube-public         Active   34d
kube-system         Active   34d
```

Puedes seleccionar este espacio de nombres por defecto ejecutando:

```shell
$ kubectl config set-context --current --namespace demo-podphase
Context "minikube" modified.
```


## Fases y estados de un `Pod` que finaliza sin errores

Utilizaremos el `Pod` [`pod.yml`](./pod.yml) para mostrar las fases y estados de un `Pod`
que contiene una aplicación que termina correctamente (devuelve 0).


```shell
$ kubectl apply -f pod.yml
```

Una vez creado el `Pod` ejecutaremos varias veces los siguientes comando para ver 
la fase y los estados:

```shell
$ kubectl get pod myapp -n demo-podphase  -o yaml
$ kubectl describe pod myapp -n demo-podphase
$ kubectl get pods -n demo-podphase
```


### `Pending`


Unos segundos después de ejecutar el comando, podemos ver que el `Pod` está en la fase `Pending`
y que el contenedor de inicialización se está ejecutando:

```yaml
status:
  conditions:
  - lastProbeTime: null
    lastTransitionTime: "2022-02-15T05:39:20Z"
    message: 'containers with incomplete status: [init-myservice]'
    reason: ContainersNotInitialized
    status: "False"
    type: Initialized
  - lastProbeTime: null
    lastTransitionTime: "2022-02-15T05:39:20Z"
    message: 'containers with unready status: [the-application]'
    reason: ContainersNotReady
    status: "False"
    type: Ready
  - lastProbeTime: null
    lastTransitionTime: "2022-02-15T05:39:20Z"
    message: 'containers with unready status: [the-application]'
    reason: ContainersNotReady
    status: "False"
    type: ContainersReady
  - lastProbeTime: null
    lastTransitionTime: "2022-02-15T05:39:20Z"
    status: "True"
    type: PodScheduled
  containerStatuses:
  - image: busybox:1.28
    imageID: ""
    lastState: {}
    name: the-application
    ready: false
    restartCount: 0
    started: false
    state:
      waiting:
        reason: PodInitializing
  hostIP: 192.168.1.160
  initContainerStatuses:
  - containerID: docker://c728264e7279094eb4d816e49e409f5f6ab13ba200e58323bccb295e40a1de04
    image: busybox:1.28
    imageID: docker-pullable://busybox@sha256:141c253bc4c3fd0a201d32dc1f493bcf3fff003b6df416dea4f41046e0f37d47 
    lastState: {}
    name: init-myservice
    ready: false
    restartCount: 0
    state:
      running:
        startedAt: "2022-02-15T05:39:20Z"
  phase: Pending
```

Podemos ver esta información también con el comando `kubectl describe`:

```shell
$ kubectl describe pod myapp  -n demo-podphase
...
Status:       Pending
...
Conditions:
  Type              Status
  Initialized       False
  Ready             False
  ContainersReady   False
  PodScheduled      True
```

El comando `kubectl get pods` muestra lo siguiente:

```shell
$  kubectl get pods -n demo-podphase
NAME    READY   STATUS     RESTARTS   AGE
myapp   0/1     Init:0/1   0          16s
```

### `Running`

Si esperamos un poco más de 20 segundos (que es el tiempo que tarda en ejecutarse el contenedor
de inicialización) y volvemos a ejecutar los comandos, veremos el contenedor con la aplicación
empieza a ejecutarse y el `Pod` pasa a la fase `Running`:

```yaml
status:
  conditions:
  - lastProbeTime: null
    lastTransitionTime: "2022-02-15T05:39:41Z"
    status: "True"
    type: Initialized
  - lastProbeTime: null
    lastTransitionTime: "2022-02-15T05:39:42Z"
    status: "True"
    type: Ready
  - lastProbeTime: null
    lastTransitionTime: "2022-02-15T05:39:42Z"
    status: "True"
    type: ContainersReady
  - lastProbeTime: null
    lastTransitionTime: "2022-02-15T05:39:20Z"
    status: "True"
    type: PodScheduled
  containerStatuses:
  - containerID: docker://e212e0406e70d70470d22150a4e43fe6389181b5bb34ddbe6f41c7e98e6a484d
    image: busybox:1.28
    imageID: docker-pullable://busybox@sha256:141c253bc4c3fd0a201d32dc1f493bcf3fff003b6df416dea4f41046e0f37d47 
    lastState: {}
    name: the-application
    ready: true
    restartCount: 0
    started: true
    state:
      running:
        startedAt: "2022-02-15T05:39:41Z"
  hostIP: 192.168.1.160
  initContainerStatuses:
  - containerID: docker://c728264e7279094eb4d816e49e409f5f6ab13ba200e58323bccb295e40a1de04
    image: busybox:1.28
    imageID: docker-pullable://busybox@sha256:141c253bc4c3fd0a201d32dc1f493bcf3fff003b6df416dea4f41046e0f37d47 
    lastState: {}
    name: init-myservice
    ready: true
    restartCount: 0
    state:
      terminated:
        containerID: docker://c728264e7279094eb4d816e49e409f5f6ab13ba200e58323bccb295e40a1de04
        exitCode: 0
        finishedAt: "2022-02-15T05:39:40Z"
        reason: Completed
        startedAt: "2022-02-15T05:39:20Z"
  phase: Running
```

Podemos ver esta información también con el comando `kubectl describe`:

```shell
$ kubectl describe pod myapp  -n demo-podphase
...
Status:       Running
...
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
```

El comando `kubectl get pods` muestra lo siguiente:

```shell
$ kubectl get pods -n demo-podphase
NAME    READY   STATUS    RESTARTS   AGE
myapp   1/1     Running   0          34s
```

### `Succeeded`

Por último, si esperamos a que pasen 20 segundos más (tiempo que tarda la aplicación en ejecutarse),
llegaremos a la fase final, que es este caso es `Succeeded` ya que la aplicación termina correctamente:

```yaml
status:
  conditions:
  - lastProbeTime: null
    lastTransitionTime: "2022-02-15T05:39:41Z"
    reason: PodCompleted
    status: "True"
    type: Initialized
  - lastProbeTime: null
    lastTransitionTime: "2022-02-15T05:40:11Z"
    reason: PodCompleted
    status: "False"
    type: Ready
  - lastProbeTime: null
    lastTransitionTime: "2022-02-15T05:40:11Z"
    reason: PodCompleted
    status: "False"
    type: ContainersReady
  - lastProbeTime: null
    lastTransitionTime: "2022-02-15T05:39:20Z"
    status: "True"
    type: PodScheduled
  containerStatuses:
  - containerID: docker://e212e0406e70d70470d22150a4e43fe6389181b5bb34ddbe6f41c7e98e6a484d
    image: busybox:1.28
    imageID: docker-pullable://busybox@sha256:141c253bc4c3fd0a201d32dc1f493bcf3fff003b6df416dea4f41046e0f37d47 
    lastState: {}
    name: the-application
    ready: false
    restartCount: 0
    started: false
    state:
      terminated:
        containerID: docker://e212e0406e70d70470d22150a4e43fe6389181b5bb34ddbe6f41c7e98e6a484d
        exitCode: 0
        finishedAt: "2022-02-15T05:40:11Z"
        reason: Completed
        startedAt: "2022-02-15T05:39:41Z"
  hostIP: 192.168.1.160
  initContainerStatuses:
  - containerID: docker://c728264e7279094eb4d816e49e409f5f6ab13ba200e58323bccb295e40a1de04
    image: busybox:1.28
    imageID: docker-pullable://busybox@sha256:141c253bc4c3fd0a201d32dc1f493bcf3fff003b6df416dea4f41046e0f37d47 
    lastState: {}
    name: init-myservice
    ready: true
    restartCount: 0
    state:
      terminated:
        containerID: docker://c728264e7279094eb4d816e49e409f5f6ab13ba200e58323bccb295e40a1de04
        exitCode: 0
        finishedAt: "2022-02-15T05:39:40Z"
        reason: Completed
        startedAt: "2022-02-15T05:39:20Z"
  phase: Succeeded
```

Podemos ver esta información también con el comando `kubectl describe`:

```shell
$ kubectl describe pod myapp  -n demo-podphase
...
Status:       Succeeded
...
Conditions:
  Type              Status
  Initialized       True
  Ready             False
  ContainersReady   False
  PodScheduled      True
```

El comando `kubectl get pods` muestra lo siguiente:

```shell
$ kubectl get pods -n demo-podphase
NAME    READY   STATUS      RESTARTS   AGE
myapp   0/1     Completed   0          68s
```

## Fases y estados de un `Pod` que finaliza con errores

Utilizaremos el `Pod` [`pod-with-error.yml`](./pod-with-error.yml) para mostrar las fases y 
estados de un `Pod` que contiene una aplicación que termina con un error (devuelve
un entero distinto de cero). Este `Pod` tiene la política `spec.restartPolicy: Never`.


```shell
$ kubectl apply -f pod-with-error.yml
```

Una vez creado el `Pod` ejecutaremos varias veces los siguientes comando para ver 
la fase y los estados:

```shell
$ kubectl get pod mybadapp -n demo-podphase  -o yaml
$ kubectl describe pod mybadapp -n demo-podphase
$ kubectl get pods -n demo-podphase
```
### `Pending` y `Running`

Esta aplicación pasa por estos dos estados de la misma forma que la aplicación `myapp`.

### `Failed`

Si esperamos a que la aplicación termine de ejecutarse llegaremos a la fase final, que en 
este caso es `Failed`, ya que la aplicación termina con un error:

```yaml
status:
  conditions:
  - lastProbeTime: null
    lastTransitionTime: "2022-02-15T06:01:38Z"
    status: "True"
    type: Initialized
  - lastProbeTime: null
    lastTransitionTime: "2022-02-15T06:02:09Z"
    message: 'containers with unready status: [the-application]'
    reason: ContainersNotReady
    status: "False"
    type: Ready
  - lastProbeTime: null
    lastTransitionTime: "2022-02-15T06:02:09Z"
    message: 'containers with unready status: [the-application]'
    reason: ContainersNotReady
    status: "False"
    type: ContainersReady
  - lastProbeTime: null
    lastTransitionTime: "2022-02-15T06:01:17Z"
    status: "True"
    type: PodScheduled
  containerStatuses:
  - containerID: docker://e91894dcb0e108c1dfe14e1d5cb4f7cfca651b75bf016a020bdd6484c12ffa31
    image: busybox:1.28
    imageID: docker-pullable://busybox@sha256:141c253bc4c3fd0a201d32dc1f493bcf3fff003b6df416dea4f41046e0f37d47 
    lastState: {}
    name: the-application
    ready: false
    restartCount: 0
    started: false
    state:
      terminated:
        containerID: docker://e91894dcb0e108c1dfe14e1d5cb4f7cfca651b75bf016a020bdd6484c12ffa31
        exitCode: 20
        finishedAt: "2022-02-15T06:02:09Z"
        reason: Error
        startedAt: "2022-02-15T06:01:39Z"
  initContainerStatuses:
  - containerID: docker://63baa22d1d8a79821f9e78267a36be78dc7a60774b0bbb634e22be4433057f86
    image: busybox:1.28
    imageID: docker-pullable://busybox@sha256:141c253bc4c3fd0a201d32dc1f493bcf3fff003b6df416dea4f41046e0f37d47 
    lastState: {}
    name: init-myservice
    ready: true
    restartCount: 0
    state:
      terminated:
        containerID: docker://63baa22d1d8a79821f9e78267a36be78dc7a60774b0bbb634e22be4433057f86
        exitCode: 0
        finishedAt: "2022-02-15T06:01:38Z"
        reason: Completed
        startedAt: "2022-02-15T06:01:18Z"
  phase: Failed
```

Podemos ver esta información también con el comando `kubectl describe`:

```shell
$ kubectl describe pod mybadapp  -n demo-podphase
...
Status:       Failed
...
Conditions:
  Type              Status
  Initialized       True
  Ready             False
  ContainersReady   False
  PodScheduled      True
```

El comando `kubectl get pods` muestra lo siguiente:

```shell
$ kubectl get pods -n demo-podphase
NAME    READY   STATUS      RESTARTS   AGE
NAME       READY   STATUS      RESTARTS   AGE
myapp      0/1     Completed   0          15m57s
mybadapp   0/1     Error       0          4m16s
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
namespace "demo-podphase" deleted
```