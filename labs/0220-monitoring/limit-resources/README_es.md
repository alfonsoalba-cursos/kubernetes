# Limitación de recursos

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `managed`

## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-limitresources`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-limitresources created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                        STATUS   AGE
default                     Active   34d
demo-limitresources         Active   17s
kube-node-lease             Active   34d
kube-public                 Active   34d
kube-system                 Active   34d
```

Puedes seleccionar este espacio de nombres por defecto ejecutando:

```shell
$ kubectl config set-context --current --namespace demo-limitresources
Context "managed" modified.
```

## `Deployment`

A continuación, creamos un `Deployment` que desplegará tres réplicas de la página web de Foo Corporation ([`deployment.yml`](./deployment.yml)).

Tras unos segundos, los `Pods` estarán en esado `Running`:

```shell
$ kubectl get all -n demo-limitresources
NAME                               READY   STATUS    RESTARTS   AGE
pod/foo-website-6d8c87fd46-2zppm   1/1     Running   0          52s
pod/foo-website-6d8c87fd46-89lpk   1/1     Running   0          52s
pod/foo-website-6d8c87fd46-vjqbr   1/1     Running   0          52s

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/foo-website   3/3     3            3           53s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/foo-website-6d8c87fd46   3         3         3       53s
```

Si miramos la historia del `Deployment` con el comando `kubectl rollout` veremos la primera revisión:

```shell
$ kubectl rollout history deployment/foo-website
deployment.apps/foo-website 
REVISION  CHANGE-CAUSE
1         Initial deployment
```

Usando el comando `kubectl exec` y `curl` en uno de los `Pods` vemos cuánto tiempo tardamos en 
obtener la respuesta:

```shell
time  kubectl.exe exec foo-website-6d8c87fd46-2zppm -- curl -I -s localhost:80
HTTP/1.1 200 OK
Server: nginx/1.21.4
Date: Wed, 23 Feb 2022 04:37:22 GMT
Content-Type: text/html
Content-Length: 10600
Last-Modified: Wed, 09 Feb 2022 04:56:29 GMT
Connection: keep-alive
ETag: "6203497d-2968"
Accept-Ranges: bytes


real    0m1.385s
user    0m0.012s
sys     0m0.000s
```
## Limitación de los recursos

A continuación, actualizamos el `Deployment` limitando la CPU de los contenedores al un valor muy pequeño: `10m`.
Para ello usarmos el siguiente fichero [`deployment-with-limits.yml`](./deployment-with-limits.yml):


Como consecuencia de cambiar los límites de los recursos, se generará una nueva revisión y se llevará
a cabo un _Rollout update_ del `Deployment`:

```shell
kubectl get all -n demo-limitresources
NAME                              READY   STATUS              RESTARTS   AGE
pod/foo-website-85dc889b4-8btt4   1/1     Running             0          10s
pod/foo-website-85dc889b4-9nz6h   0/1     ContainerCreating   0          0s
pod/foo-website-f566c8d57-52rzp   1/1     Running             0          4m25s
pod/foo-website-f566c8d57-6z5w6   1/1     Running             0          4m25s
pod/foo-website-f566c8d57-qzm8z   1/1     Terminating         0          4m25s

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/foo-website   3/3     2            3           4m25s

NAME                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/foo-website-85dc889b4   2         2         1       10s
replicaset.apps/foo-website-f566c8d57   2         2         2       4m25s
```

Si miramos la historia de revisiones, veremos que aparece una nueva revisión:

```shell
kubectl rollout history deployment/foo-website -n demo-limitresources
deployment.apps/foo-website 
REVISION  CHANGE-CAUSE
1         Initial deployment
2         CPU Limit
```

Usando de nuevo el comando `kubectl exec` y `curl`, vemos que la página tarda un poco más de tiempo en responder:

```shell
$ time  kubectl.exe exec foo-website-6d9955dc46-49sdw -- curl -I -s localhost:80
HTTP/1.1 200 OK
Server: nginx/1.21.4
Date: Wed, 23 Feb 2022 04:34:38 GMT
Content-Type: text/html
Content-Length: 10600
Last-Modified: Wed, 09 Feb 2022 04:56:29 GMT
Connection: keep-alive
ETag: "6203497d-2968"
Accept-Ranges: bytes


real    0m2.999s
user    0m0.013s
sys     0m0.000s
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
namespace "demo-limitresources" deleted
```
