# Nuestra primera aplicación en `minikube`

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `minikube`

## La aplicación: `Foo Corporation Website`

Nuestro objetivo es desplegar un `Pod` en minikube con la página web de nuestro
cliente `Foo Corporation Website`.

Ya existe un contenedor con la página web de la aplicación, 
[disponible en Docker Hub](https://hub.docker.com/repository/docker/kubernetescourse/foo-website).

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

En este momento, nuestro `Pod` `foo-website` sólo es accesible desde dentro de minikube.
Podemos crear un nuevo `Pod` y desde este, acceder a la página web.

Antes de continuar, necesitaremos saber cuál es la IP del `Pod`. Para ello podemos utilizar
el siguiente comando:

```shell
$ kubectl get pods -o wide
NAME          READY   STATUS    RESTARTS      AGE     IP           NODE       NOMINATED NODE   READINESS GATES
foo-website   1/1     Running   0             17m     172.17.0.3   minikube   <none>           <none>
```
Tomamos nota de la dirección IP: 172.17.0.3.

Creamos un nuevo `Pod` que contendrá una imagen de `busybox`:

```text
$ kubectl run busybox -t -i --image=busybox
If you don't see a command prompt, try pressing enter.
/ # _
```

Dentro de este `Pod` utilizamos el comando `wget` para acceder a la página web:

```text
(busybox)/ # wget -q -O - 172.17.0.3
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

La consola se quedará en bloqueada y no nos dejará ejecutar más comandos.

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
NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
foo-website   NodePort    10.97.167.118   <none>        80:31487/TCP   10s
kubernetes    ClusterIP   10.96.0.1       <none>        443/TCP        35h
```

Para acceder a la web utilizamos el comando `service` de minikube, que nos da una URL
para poder acceder al puerto `31487` del nodo:

```shell
C:\WINDOWS\system32> minikube service foo-website --url
http://192.168.1.165:31487
```

Si apuntamos nuestro navegador a esta URL, veremos la página web.

## Limpieza

Para terminar el taller, borraremos el `Pod` y el `Service` que hemos creado:

```shell
$ kubectl delete -f foo-website-pod.yml
pod "foo-website" deleted

$ kubectl delete service foo-website
service "foo-website" deleted
```

Acuerdate de ejecutar `minikube stop` para detener minikube.

## Siguiente paso

[Nuestra primera aplicación en `minikube` usando `kubectl run`](../minikube_and_kubectl_run/README_es.md)