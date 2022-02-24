# Autoescalado horizontal basado en CPU

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `managed`

## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-hpa`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-hpa created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                        STATUS   AGE
default                     Active   34d
demo-hpa                    Active   17s
kube-node-lease             Active   34d
kube-public                 Active   34d
kube-system                 Active   34d
```

Puedes seleccionar este espacio de nombres por defecto ejecutando:

```shell
$ kubectl config set-context --current --namespace demo-hpa
Context "managed" modified.
```

## `Deployment`

A continuación, creamos un `Deployment` que desplegará tres réplicas de una [aplicación
php](../../docker/cpu-intensive-app) 
que utiliza extensivamente el procesador ([`deployment.yml`](./deployment.yml)).

Tras unos segundos, los `Pods` estarán en esado `Running`:

```shell
$ kubectl get all -n demo-hpa
NAME                           READY   STATUS    RESTARTS   AGE
pod/cpu-app-5b964cd88f-kq8zv   1/1     Running   0          112s
pod/cpu-app-5b964cd88f-md4pv   1/1     Running   0          112s
pod/cpu-app-5b964cd88f-wxckx   1/1     Running   0          112s

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/cpu-app   3/3     3            3           114s

NAME                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/cpu-app-5b964cd88f   3         3         3       114s
```

## `Service`

Creamos un `Service` de tipo `NodePort` para poder acceder a la página web y realizar peticiones [`service.yml`](./service.yml)

```shell
$ kubectl apply -f .\service.yml                 
service/cpu-app created
```

Uitlizando el comando `kubectl` verificamos que el servicio se ha creado correctamente:

```shell
$ kubectl get services -n demo-hpa
NAME      TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
cpu-app   NodePort   10.233.39.97   <none>        80:31827/TCP   5s

$ kubectl describe service cpu-app -n demo-hpa
Name:                     cpu-app
Namespace:                demo-hpa
Labels:                   run=php-apache
Annotations:              <none>
Selector:                 app=cpu-app
Type:                     NodePort
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.233.39.97
IPs:                      10.233.39.97
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  31827/TCP
Endpoints:                10.212.142.18:80,10.216.183.42:80,10.223.58.95:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

Utilizando el comando `kubectl get nodes`, averiguamos la dirección IP de uno de los nodos:

```shell
$ kubectl get nodes -o wide
NAME                       STATUS   ROLES   AGE    VERSION   INTERNAL-IP   EXTERNAL-IP     OS-IMAGE             
KERNEL-VERSION     CONTAINER-RUNTIME
standardnodes-paka7v2imr   Ready    node    3d4h   v1.21.4   <none>        93.93.114.143   Ubuntu 20.04.3 LTS   5.4.0-97-generic   containerd://1.5.5
standardnodes-wypldyeewy   Ready    node    3d5h   v1.21.4   <none>        93.93.115.7     Ubuntu 20.04.3 LTS   5.4.0-97-generic   containerd://1.5.5
standardnodes-zuf5eywgar   Ready    node    3d4h   v1.21.4   <none>        93.93.114.154   Ubuntu 20.04.3 LTS   5.4.0-97-generic   containerd://1.5.5
```

Con la dirección IP y el puerto, usamos `curl` para hacer acceder a la página:

```shell
$ time curl 93.93.114.143:31827
$x = 2.4999999950006E+19
OK!
real    2m34.151s
user    0m0.011s
sys     0m0.007s
```

Mientras se realiza la operación, podemos ver el consumo de CPU por parte de los `Pods`
usando el comando `kubectl pod`:

```shell
kubectl.exe top pod  -n demo-hpa
NAME                      CPU(cores)   MEMORY(bytes)   
cpu-app-5c6f689c6-l9fhx   1m           9Mi
cpu-app-5c6f689c6-n8tkc   998m         10Mi
cpu-app-5c6f689c6-p7wzr   1m           10Mi
```

## `HorizontalPodAutoscaler`

Definimos un objeto `HorizontalPodAutoscaler` en el fichero [`horizontal-pod-autoscaler-v2.yml`](./horizontal-pod-autoscaler-v2.yml). Este objeto intentará mantener un número de réplicas tal que el uso promedio de CPU por parte de los `Pods` está como máximo al 25%:

```yaml
...
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 25
```

Creamos el objeto:

```shell
$ kubectl apply -f horizontal-pod-autoscaler-v2.yml
```

Si al crear este objeto obtenemos el siguiente error:

```shell
kubectl apply -f .\horizontal-pod-autoscaler-v2.yml
error: unable to recognize ".\\horizontal-pod-autoscaler-v2.yml": no matches for kind "HorizontalPodAutoscaler" in version "autoscaling/v2"
```

el problema es que nuestro cluster no soporta todavía esta versión del autoscaler. En ese caso,
puedes probar a usar el fichero [`horizontal-pod-autoscaler-v2beta2.yml`](./horizontal-pod-autoscaler-v2beta2.yml)

```shell
$ kubectl apply -f .\horizontal-pod-autoscaler-v2beta2.yml
horizontalpodautoscaler.autoscaling/cpu-app created
```

Si vemos los detalles del `HorizontalPodAutoscaler` veremos como pasados unos segundos queda configurado correctamente:

```shell
 kubectl describe hpa cpu-app -n demo-hpa
Name:                                                  cpu-app
Namespace:                                             demo-hpa
Labels:                                                <none>
Annotations:                                           <none>
CreationTimestamp:                                     Thu, 24 Feb 2022 05:43:25 +0100
Reference:                                             Deployment/cpu-app
Metrics:                                               ( current / target )
  resource cpu on pods  (as a percentage of request):  0% (3m) / 25%
Min replicas:                                          3
Max replicas:                                          10
Deployment pods:                                       3 current / 3 desired
Conditions:
  Type            Status  Reason            Message
  ----            ------  ------            -------
  AbleToScale     True    ReadyForNewScale  recommended size matches current size
  ScalingActive   True    ValidMetricFound  the HPA was able to successfully calculate a replica count from cpu resource utilization (percentage of request)
  ScalingLimited  True    TooFewReplicas    the desired replica count is less than the minimum replica count
Events:
  Type     Reason                        Age                   From                       Message
  ----     ------                        ----                  ----                       -------
```

## Autoescalado en acción

Hacemos una petición al `Service` utilizando `curl`

```shell

```

Si miramos los detalles del objeto `HorizontalPodAutoscaler` veremos, pasados unos segundos, como levanta 2 réplicas más:

```shell
kubectl describe hpa cpu-app -n demo-hpa
Name:                                                  cpu-app
Namespace:                                             demo-hpa
Labels:                                                <none>
Annotations:                                           <none>
CreationTimestamp:                                     Thu, 24 Feb 2022 05:43:25 +0100
Reference:                                             Deployment/cpu-app
Metrics:                                               ( current / target )
  resource cpu on pods  (as a percentage of request):  39% (198m) / 25%
Min replicas:                                          3
Max replicas:                                          10
Deployment pods:                                       3 current / 5 desired
Conditions:
  Type            Status  Reason              Message
  ----            ------  ------              -------
  AbleToScale     True    SucceededRescale    the HPA controller was able to update the target scale to 5
  ScalingActive   True    ValidMetricFound    the HPA was able to successfully calculate a replica count from cpu resource utilization (percentage of request)
  ScalingLimited  False   DesiredWithinRange  the desired count is within the acceptable range
Events:
  Type     Reason                        Age                  From                       Message
  ----     ------                        ----                 ----                       -------
  Warning  FailedComputeMetricsReplicas  12m (x12 over 15m)   horizontal-pod-autoscaler  invalid metrics (1 invalid out of 1), first error is: failed to get cpu utilization: missing request for cpu
  Warning  FailedGetResourceMetric       5m4s (x41 over 15m)  horizontal-pod-autoscaler  failed to get cpu utilization: missing request for cpu
  Normal   SuccessfulRescale             0s                   horizontal-pod-autoscaler  New size: 5; reason: cpu resource utilization (percentage of request) above target
```

Si esperamos unos segundos más, veremos como objeto `HorizontalPodAutoscaler` decide finalmente que el número
de réplicas que necesita para mantener el uso de CPU por debajo del 25% es de 8:

```shell
$ kubectl get hpa cpu-app -n demo-hpa
NAME      REFERENCE            TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
cpu-app   Deployment/cpu-app   0%/25%    3         10        8          22m
```

Si dejamos pasar el tiempo suficiente, el `HorizontalPodAutoscaler` volverá a la configuración inicial de 3 réplicas:

```shell
$ kubectl get hpa cpu-app -n demo-hpa
NAME      REFERENCE            TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
cpu-app   Deployment/cpu-app   0%/25%    3         10        3          23m
```

```shell
$ kubectl describe hpa cpu-app -n demo-hpa
Name:                                                  cpu-app
Namespace:                                             demo-hpa
Labels:                                                <none>
Annotations:                                           <none>
CreationTimestamp:                                     Thu, 24 Feb 2022 05:43:25 +0100
Reference:                                             Deployment/cpu-app
Metrics:                                               ( current / target )
  resource cpu on pods  (as a percentage of request):  0% (1m) / 25%
Min replicas:                                          3
Max replicas:                                          10
Deployment pods:                                       3 current / 3 desired
Conditions:
  Type            Status  Reason            Message
  ----            ------  ------            -------
  AbleToScale     True    ReadyForNewScale  recommended size matches current size
  ScalingActive   True    ValidMetricFound  the HPA was able to successfully calculate a replica count from cpu resource utilization (percentage of request)
  ScalingLimited  True    TooFewReplicas    the desired replica count is less than the minimum replica count
Events:
  Type     Reason                        Age                 From                       Message
  ----     ------                        ----                ----                       -------
  Warning  FailedComputeMetricsReplicas  22m (x12 over 24m)  horizontal-pod-autoscaler  invalid metrics (1 invalid out of 1), first error is: failed to get cpu utilization: missing request for cpu
  Warning  FailedGetResourceMetric       14m (x41 over 24m)  horizontal-pod-autoscaler  failed to get cpu utilization: missing request for cpu
  Normal   SuccessfulRescale             9m35s               horizontal-pod-autoscaler  New size: 5; reason: cpu resource utilization (percentage of request) above target
  Normal   SuccessfulRescale             2m12s               horizontal-pod-autoscaler  New size: 6; reason: All metrics below target
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
namespace "demo-hpa" deleted
```