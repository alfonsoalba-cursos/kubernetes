# `LoadBalancer` en ARSYS

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `managed`

Este taller se ejecutará en el entorno de clusters gestionados de ARSYS.

## La aplicación

Levantaremos una aplicación sin estado utilizando la imagen `kubernetescourse/bar-website`.

## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-loadbalancer`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-loadbalancer created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                STATUS   AGE
default             Active   34d
demo-loadbalancer   Active   25s
kube-node-lease     Active   34d
kube-public         Active   34d
kube-system         Active   34d
```

Puedes seleccionar este espacio de nombres por defecto ejecutando:

```shell
$ kubectl config set-context --current --namespace demo-loadbalancer
Context "managed" modified.
```

## `Deployment`

Utilizaremos [este `Deployment`](./deployment.yml), que levantará 5 réplicas de la aplicación
`kubernetescourse/bar-website`


```shell
$ kubectl apply -f deployment.yml
```

Podemos ver los `Pods` creaándose usando el comando `kubectl get pods`:

```shell
$ kubectl get pods -n demo-loadbalancer
NAME                                 READY   STATUS        RESTARTS   AGE
bar-website-6f956fb4f5-b7nzw         1/1     Running       0          67s
bar-website-6f956fb4f5-gzgls         1/1     Running       0          67s
bar-website-6f956fb4f5-m9gwl         1/1     Running       0          67s
bar-website-6f956fb4f5-mxrcl         1/1     Running       0          67s
bar-website-6f956fb4f5-qdsgc         1/1     Running       0          67s
```

## `Service`

Creamos un [servicio de tipo `LoadBalancer`](./service.yml):

```shell
$ kubectl apply -f service.yml
```

Vemos los servicios que tenemos disponibles utlizando `kubectl get services`:

```shell
$ kubectl get services -n demo-loadbalancer
NAME                TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
demo-loadbalancer   LoadBalancer   10.233.11.32   <pending>     80:32159/TCP   5s
```

Si esperamos unos segundos, el proveedor de servicios creará el balanceador de carga y
nos facilitará una dirección IP:

```shell
$ kubectl get services -n demo-loadbalancer
NAME          TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)        AGE
bar-website   LoadBalancer   10.233.59.215   93.93.114.54   80:32366/TCP   15s
```

Si miramos el detalle del balanceador de carga:

```shell
$ kubectl describe service bar-website  -n demo-loadbalancer
Name:                     bar-website
Namespace:                demo-loadbalancer
Labels:                   <none>
Annotations:              <none>
Selector:                 app=bar-website-pod
Type:                     LoadBalancer
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.233.14.160
IPs:                      10.233.14.160
LoadBalancer Ingress:     93.93.114.54
Port:                     http  80/TCP
TargetPort:               80/TCP
NodePort:                 http  32727/TCP
Endpoints:                10.214.40.83:80,10.214.40.84:80,10.221.166.28:80 + 2 more...
Session Affinity:         None
External Traffic Policy:  Cluster
Events:
  Type    Reason                Age   From                Message
  ----    ------                ----  ----                -------
  Normal  EnsuringLoadBalancer  10s   service-controller  Ensuring load balancer
  Normal  EnsuredLoadBalancer   3s    service-controller  Ensured load balancer
```

## Accediendo al servicio

Si apuntamos nuestro navegador a la direccin `http://93.93.114.54` veremos la página web.

## `DataCenter`

En el panel de gestión de nuestro _Data Center_, no veremos el balanceador de carga
que se ha creado. 

## Limpieza

Volvemos a poner `default` como espacio de nombres por defecto:

```shell
$ kubectl config set-context --current --namespace default
Context "managed" modified.
```


Para borrar todos los objetos, basta con borrar el espacio de nombres:

```shell
$ kubectl delete -f namespace.yml
namespace "demo-loadbalancer" deleted
```