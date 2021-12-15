# _Ingress controller_ en Minikube

Para que los objetos `Ingress` de Kubernetes funcionen, es necesario que el cluster tenga
configurado un _ingress controller_. En este primer taller, configuraremos primero un
controlador de tipo `ingress-nginx` y luego crearemos los objetos `Ingress` en el cluster.

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `minikube`

## Selección del controlador

De la 
[lista de controladores](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
disponibles, en este taller instalaremos el 
[_ingress-nginx Controller_](https://kubernetes.github.io/ingress-nginx/).

## Instalación en Minikube

La instalación en Minikube se realiza a través de un _addon_:

```shell
$ minikube addons enable ingress
```

Este comando realiza varias tareas, entre ellas varios `Pods` dentro del
espacio de nombres `ingress-nginx`. Para ver el estado en el que se encuentran estos
`Pods`, usamos kubectl:

```shell
$ kubectl get pods --namespace=ingress-nginx
NAME                                        READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create--1-k2w7l     0/1     Completed   0          4m33s
ingress-nginx-admission-patch--1-drjqh      0/1     Completed   1          4m33s
ingress-nginx-controller-5f66978484-n7jkt   1/1     Running     0          4m33s
```

Si necesitamos esperar a que el controlador esté funcionando, podemos utilizar
el comando `wait` the `kubectl`:

```shell
$ kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
```

Por último, podemos ver todos los objetos relacionados con controlador `ingress-nginx`
mirando en el espacio de nombres:

```shell
$ kubectl get all -n ingress-nginx

NAME                                            READY   STATUS      RESTARTS   AGE
pod/ingress-nginx-admission-create--1-k2w7l     0/1     Completed   0          11h
pod/ingress-nginx-admission-patch--1-drjqh      0/1     Completed   1          11h
pod/ingress-nginx-controller-5f66978484-n7jkt   1/1     Running     0          11h

NAME                                         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
service/ingress-nginx-controller             NodePort    10.98.129.26    <none>        80:32501/TCP,443:30145/TCP   11h
service/ingress-nginx-controller-admission   ClusterIP   10.109.75.251   <none>        443/TCP                      11h

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ingress-nginx-controller   1/1     1            1           11h

NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/ingress-nginx-controller-5f66978484   1         1         1       11h

NAME                                       COMPLETIONS   DURATION   AGE
job.batch/ingress-nginx-admission-create   1/1           8s         11h
job.batch/ingress-nginx-admission-patch    1/1           9s         11h
```

Este taller es la base del resto de talleres de esta sección.

## Creación del espacio de nombres

Vamos a desplegar en minikube la web de _Foo Corporation_ y vamos acceder a ella
utilizando un objeto `Ingress`.

Lo haremos dentro de un `Namespace`, así que el primer paso será crearlo:

```shell
$ kubectl create -f namespace.yml 
namespace/demo-ingress created
```

Podemos verlo de la siguiente manera:

```shell 
$ kubectl get namespaces -o wide
NAME              STATUS   AGE
default           Active   37h
demo-ingress      Active   82s
ingress-nginx     Active   23m
kube-node-lease   Active   37h
kube-public       Active   37h
kube-system       Active   37h

$ kubectl describe namespace demo-ingress
Name:         demo-ingress
Labels:       kubernetes.io/metadata.name=demo-ingress
Annotations:  <none>
Status:       Active

No resource quota.

No LimitRange resource.
```

## Creación del `Deployment`

Una vez tenemos el espacio de nombres creado, procedemos a crear el `Deployment`:

```shell
$  kubectl create -f deployment.yml
deployment.apps/foo-website-deployment created
```

Podemos verlo ejecutando:

 ```shell
 $ kubectl get deployments -n demo-ingress
 NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
foo-website-deployment   3/3     3            3           62s
```

## Creación del `Service`

Una vez tenemos los `Pods` configurados en el cluster, creamos un `Service` de tipo `ClusterIP`
para poder llegar a ellos. Recuerda que a este tipo `Service` sólo podremos acceder
desde dentro del cluster.

```shell
$ kubectl create -f service.yml
```

<details>
  <summary>ℹ️</summary>
  Otra forma de crear este servicio sería utilizar el comando:

  ```shell
  $ kubectl expose deployment demo
  ```
</details>

Podemos ver el servicio `foo-website-service`:

```shell
$ kubectl get services -n demo-ingress
NAME                  TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
foo-website-service   ClusterIP   10.101.69.73   <none>        80/TCP    8m21s
```

Vamos a verificar que podemos ver la web desde dentro del cluster. Para ello, crearemos un
pod con contenedor _busybox_ y haremos una petición a la IP del `Service` que acabamos
de crear: `foo-website-service`

```shell
$ kubectl run -ti -n demo-ingress --image=busybox -- bash
If you don't see a command prompt, try pressing enter.
/ # wget -q -O - http://10.101.69.73
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="Alfonso Alba García">
    <meta name="generator" content="Hugo 0.84.0">
    <title>Pricing - Foo Corporation</title>

    <link rel="canonical" href="https://getbootstrap.com/docs/5.0/examples/pricing/">
...
...
...
/ # 
 ```

 Una pregunta antes de continuar: ¿Cómo podríamos haber realizado la misma petición sin necesidad
 de conocer la IP del servicio?

 <details>
  <summary>Respuesta...</summary>

  Como vimos en la sección _service discovery_ los servicios que se crean en el
  cluster tienen asociado un registro DNS de tipo A/AAA. 

  En este caso, podemos acceder directamente al servicio utilizando cualquiera de las 
  siguientes URLs en lugar de la IP:

  * `http://foo-website-service.demo-ingress.svc.cluster.local`
  * `http://foo-website-service.demo-ingress.svc`
  * `http://foo-website-service.demo-ingress`
  * `http://foo-website-service`

 </details>

 ## Creación del `Ingress`

El siguiente paso es crear el objeto [`Ingress`](./ingress.yml):

```shell
$ kubectl create -f ingress.yml
ingress.networking.k8s.io/foo-website created
```

Podemos ver el objeto que acabamos de crear:

```shell
$ kubectl get ingresses --all-namespaces
NAMESPACE      NAME           CLASS   HOSTS              ADDRESS     PORTS   AGE
demo-ingress   demo-ingress   nginx   demo.localdev.me               80      64s
```

Averiguamos la IP del controlador:

```shell
$ kubectl get service ingress-nginx-controller -n ingress-nginx
NAME                       TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller   NodePort   10.98.129.26   <none>        80:32501/TCP,443:30145/TCP   11h
```

Al tratarse de un nodo local creado con minikube, no disponemos de IP externa. Por ello,
reenviaremos el puerto 4500 de nuestra máquina local al puerto 80 del cluster:

```shell
$ kubectl port-forward -n=ingress-nginx service/ingress-nginx-controller 4500:80
Forwarding from 127.0.0.1:4500 -> 80
Forwarding from [::1]:4500 -> 80

(consola congelada)
```

Con el reenvío de puertos activo, apuntamos nuestro navegador a 
`http://demo.localdev.me:4500` y veremos la página web de _Foo Corporation_.

Para detener el reenvío de puertos, presionar `CTRL+C`.

## One more thing...

Antes de terminar el ejercicio, vamos a ver todos los objetos que hemos creado
para conseguir nuestro objetivo:

```shell
$ kubectl get all -n demo-ingress
NAME                                          READY   STATUS    RESTARTS   AGE
pod/foo-website-deployment-5bf9fcc485-5tffl   1/1     Running   0          10h
pod/foo-website-deployment-5bf9fcc485-qrwww   1/1     Running   0          10h
pod/foo-website-deployment-5bf9fcc485-zhmrm   1/1     Running   0          10h

NAME                          TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/foo-website-service   ClusterIP   10.101.69.73   <none>        80/TCP    9h

NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/foo-website-deployment   3/3     3            3           10h

NAME                                                DESIRED   CURRENT   READY   AGE
replicaset.apps/foo-website-deployment-5bf9fcc485   3         3         3       10h
```

(Cuidado, que los objetos `Ingress` no aparecen en este listado)

```shell
$ kubectl get ingresses --all-namespaces
NAMESPACE      NAME           CLASS   HOSTS              ADDRESS     PORTS   AGE
demo-ingress   demo-ingress   nginx   demo.localdev.me   localhost   80      64s
```

* Un `Deployment`, que ha generado:
  * Un `ReplicaSet` para gestionar las réplicas
  * Tres `Pods`, los que le hemos pedido
* Un `Service` de tipo `ClusterIP`
* Un `Ingress`

## Limpieza

Para limpiar, borramos el espacio de nombres:

```kubectl
$  kubectl delete namespace demo-ingress
namespace "demo-ingress" deleted
```

(El borrado puede llevar unos segundos.)

⚠️ el controlador `ingress-nginx` no se ha borrado:

```shell
$ kubectl get all -n ingress-nginx
NAME                                            READY   STATUS      RESTARTS   AGE
pod/ingress-nginx-admission-create--1-k2w7l     0/1     Completed   0          10h
pod/ingress-nginx-admission-patch--1-drjqh      0/1     Completed   1          10h
pod/ingress-nginx-controller-5f66978484-n7jkt   1/1     Running     0          10h

NAME                                         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)         
             AGE
service/ingress-nginx-controller             NodePort    10.98.129.26    <none>        80:32501/TCP,443:30145/TCP   10h
service/ingress-nginx-controller-admission   ClusterIP   10.109.75.251   <none>        443/TCP         
             10h

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ingress-nginx-controller   1/1     1            1           10h

NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/ingress-nginx-controller-5f66978484   1         1         1       10h

NAME                                       COMPLETIONS   DURATION   AGE
job.batch/ingress-nginx-admission-create   1/1           8s         10h
job.batch/ingress-nginx-admission-patch    1/1           9s         10h
```