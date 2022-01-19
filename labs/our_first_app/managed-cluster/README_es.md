# Nuestra primera aplicación en un cluster gestionado

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `minikube`

## La aplicación: `Foo Corporation Website`

Nuestro objetivo es desplegar un `Pod` en minikube con la página web de nuestro
cliente `Foo Corporation Website`.

Ya existe un contenedor con la página web de la aplicación, 
[disponible en Docker Hub](https://hub.docker.com/repository/docker/kubernetescourse/foo-website).

## Selección del contexto

Utilizando el comando `kubectl config get-contexts` listaremos los contextos que tenemos disponibles:

```shell
$ CURRENT   NAME       CLUSTER                  AUTHINFO        NAMESPACE
            managed    TestClusterForTraining   cluster-admin   
*           minikube   minikube                 minikube        default
```

Cambiamos el contexto:

```shell
$ kubectl config use-context managed
Switched to context "managed".
```


## Desplegando el `Pod`

Para desplegar el `Pod`, ejecutamos el comando:

```shell
$ kubectl create -f foo-website-pod.yml
pod/foo-website created
```

Podemos confirmar que el `Pod` se ha desplegado correctamente utilizando:

```shell
$ kubectl get pods
NAME          READY   STATUS    RESTARTS   AGE
foo-website   1/1     Running   0          54s
```

## Viendo el contenido del `Pod`: usando otro `Pod`

En este momento, nuestro `Pod` `foo-website` sólo es accesible desde dentro de cluster gestionado.
Podemos crear un nuevo `Pod` y desde este, acceder a la página web.

Antes de continuar, necesitaremos saber cuál es la IP del `Pod`. Para ello podemos utilizar
el siguiente comando:

```shell
$ kubectl get pods -o wide
NAME          READY   STATUS    RESTARTS   AGE   IP              NODE                       NOMINATED NODE   READINESS GATES
foo-website   1/1     Running   0          38s   10.212.64.201   standardnodes-a7v4hgqn4z   <none>           <none>
```

Tomamos nota de la dirección IP: 10.212.64.201.

Creamos un nuevo `Pod` que contendrá una imagen de `busybox`:

```text
$ kubectl run busybox -t -i --image=busybox
If you don't see a command prompt, try pressing enter.
/ # _
```

Dentro de este `Pod` utilizamos el comando `wget` para acceder a la página web:

```text
(busybox)/ # wget -q -O - 10.212.64.201
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="Alfonso Alba García">
    <meta name="generator" content="Hugo 0.84.0">
    <title>Pricing - Foo Corporation</title>
    ...
    ...
    ...
  </body>
</html> 
```

Muy interesante pero muy poco práctico. Veremos en talleres posteriores cómo
exponer el `Pod` para que sea accesible desde el exterior.

Antes de pasar a la siguiente sección, podemos borrar el `Pod` que hemos llamado
`busybox` ejecutando:

```shell
$ kubectl pod delete busybox
pod "busybox" deleted
```


## Viendo el contenido del `Pod`: usando `kubectl port-forward`

`kubectl` nos da la opción de redireccionar un puerto de nuestra máquina local
a un puerto de un `Pod`. Para ver la página web, redireccionaremos el puerto local
8080 al puerto 80 del `Pod`:

```shell
$ kubectl port-forward pod/foo-website 8080:80
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
```

La consola se quedará bloqueada y no nos dejará ejecutar más comandos.

Si abrimos un navegador, y abrimos la página `localhost:8080` veremos la página
web de Foo Corporation.

Para detener el reenvío de puertos, presinamos `CTRL+C` en la consola.

👉 El `port-forward` es extremadamente útil a la hora de depurar.

## Viendo el contenido del `Pod`: usando un `Service`

Adelantándonos a lo que veremos en laboratorios y secciones posteriores del curso, vamos 
a terminar este laboratorio creando un `Service` para acceder al `Pod`.

_Exponemos_ el puerto del `Pod` ejecutando el siguiente comando:

```shell
$ kubectl expose pod foo-website --type=NodePort
service/foo-website exposed
```

¿Qué es lo que ha pasado en realidad? Que se ha creado un `Service` de tipo `NodePort`:

```shell
$ kubectl get services
NAME          TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
foo-website   NodePort    10.233.20.99   <none>        80:32345/TCP   12s
kubernetes    ClusterIP   10.233.0.1     <none>        443/TCP        52d
```

Para acceder a la web, podemos conectarnos al puerto `32345` de cualquier nodo del cluster.

Podemos obtener las direcciones IP usando el siguiente comando:

```shell
$ kubectl get nodes -o wide
NAME                       STATUS   ROLES   AGE    VERSION   INTERNAL-IP   EXTERNAL-IP     OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
standardnodes-a7v4hgqn4z   Ready    node    2d6h   v1.21.4   <none>        93.93.114.199   Ubuntu 20.04.3 LTS   5.4.0-88-generic   containerd://1.4.11
standardnodes-bbhnkr67cs   Ready    node    2d6h   v1.21.4   <none>        93.93.114.133   Ubuntu 20.04.3 LTS   5.4.0-88-generic   containerd://1.4.11
standardnodes-jiz65zo7mj   Ready    node    2d6h   v1.21.4   <none>        93.93.114.191   Ubuntu 20.04.3 LTS   5.4.0-88-generic   containerd://1.4.11
```

Para ver la web, podemos apuntar nuestro navegador, por ejemplo, a `http://93.93.114.133:32345`. Podemos sustituir esta
dirección IP por la de cualquier otro nodo.

## Limpieza

Para terminar el taller, borraremos el `Pod` y el `Service` que hemos creado:

```shell
$ kubectl delete -f foo-website-pod.yml
pod "foo-website" deleted

$ kubectl delete service foo-website
service "foo-website" deleted
```

Acuerdate de ejecutar `minikube stop` para detener minikube.