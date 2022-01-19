# `Pod` con múltiples contenedores

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `minikube`

## La aplicación: `hello-app` + proxy inverso

Como ejemplo de aplicación multicontenedor, crearemos un `Pod` que contiene una
aplicación de ejemplo y un proxy inverso que redireccionará el tráfico al `Pod`
y servirá contenido estátido.

Usaremos 
[`hello-app`](https://github.com/GoogleCloudPlatform/kubernetes-engine-samples/tree/main/hello-app) 
como aplicación de ejemplo. Se trara de una sencilla aplicación escrita en el lenguaje
`Go` que forma parte del 
[conjunto de ejemplos de Kubernetes que Google ha publicado](https://github.com/GoogleCloudPlatform/kubernetes-engine-samples).

Por otro lado, tendremos un contenedor con una instancia de `nginx` actuando 
como proxy inverso con la siguiente configuración:

```nginx
...
    location /static {
        root   /usr/share/nginx/html;
    }

    location ~ \.html {
        root   /usr/share/nginx/html;
    }

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffering off;
        proxy_request_buffering off;
        proxy_intercept_errors on;
        proxy_pass http://hello-app:8080;
    }
...
```

La configuración completa de este contenedor está en la carpeta 
[/labs/docker/multicontainer-pod-nginx](../../docker/multicontainer-pod-nginx)

## Levantando el `Pod`

El fichero de definición del `Pod` es [multicontainer-pod.yml](multicontainer-pod.yml).
Creamos el `Pod` ejecutando:

```shell
$ kubectl create -f multicontainer-pod.yml
pod/multicontainer-pod created
```

En unos segundos (lo que tarde Minikube en descargar las imágenes) tendremos el
`Pod` ejecutándose:

```shell
$ kubectl get pods

NAME                 READY   STATUS    RESTARTS   AGE
multicontainer-pod   2/2     Running   0          2m57s
```

## `port-forward`

Como ya hemos hecho en talleres anteriores, accederemos directamente al `Pod` a través
de un reenvío de puertos (si tienes el puerto 8080 de tu máquina local en uso, utiliza
otro):

```shell
$ kubectl port-forward pod/multicontainer-pod 8080:80
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
```

Una vez activado el reenvío de puertos:
* Accedemos a la aplicación `hello-app` 
  utilizando la URL [http://localhost:8080](http://localhost:8080). 
* Si queremose ver el contenido estático servido directamente a través de nginx
  utilizando al URL [http://localhost:8080/hello.html]

## Accediendo a los contenedores

Usando el comando `kubectl exec` accederemos a los contenedores dentro del `Pod`
y ejecutaremos una _shell_ dentro de ellos.

Si no especificamos el contenedor, nos conectaremos al primero de los contenedores definidos
dentro del `Pod`, en este caso `hello-app`:

```shell
$ kubectl exec -ti multicontainer-pod -- ash
Defaulted container "hello-app" out of: hello-app, reverse-proxy
/ # ls -l /hello-app
-rwxr-xr-x    1 root     root       5894502 Dec 10 23:01 /hello-app
/ #
```

Si queremos conectarnos al contenedor de `nginx`, debemos utilizar la
opción `-c` y pasar el nombre del contenedor, en nuestro caso `reverse-proxy`:

```shell
$ kubectl exec -ti multicontainer-pod -c=reverse-proxy -- bash
root@multicontainer-pod:/# ls /usr/share/nginx/html/
50x.html  hello.html  index.html  static
root@multicontainer-pod:/#
```

Notar que hemos tenido que utilizar una _shell_ diferente para cada contenedor.

## Seleccionar el contenedor por defecto

En la sección anterior, hemos comentado que el contenedor por defecto de un `Pod` 
es el primero que se define.

Desde la versión 1.21 de kubernetes podemos hacer esta selección utilizando una 
anotación (más información en 
[la solicitud de mejora que está en GitHub](https://github.com/kubernetes/kubernetes/pull/97099)).
Se espera que esta funcionalidad sea estable en kubernetes 1.23.

Creamos un nuevo `Pod` en el que usamos esta funcionalidad, seleccionando el contenedor
`reverse-proxy` del `Pod` como contenedor por defecto.
El fichero de definición de este `Pod` es 
[multicontainer-pod-with-default-container.yml](./multicontainer-pod-with-default-container.yml).

```shell
% kubectl create -f multicontainer-pod-with-default-container.yml
pod/multicontainer-pod-with-default-container created
```

Confirmamos que el `Pod` se está ejecutando:

```shell
 kubectl get pods                      
NAME                                        READY   STATUS    RESTARTS   AGE
multicontainer-pod                          2/2     Running   0          8m
multicontainer-pod-with-default-container   2/2     Running   0          2m54s
```

El siguiente comando fallará porque el contenedor por defecto (`reverse-proxy`)
no tiene el ejecutable `ash` en su imagen:

```shell
$ kubectl exec -ti multicontainer-pod-with-default-container -- ash
OCI runtime exec failed: exec failed: container_linux.go:380: starting container process caused: exec: "ash": executable file not found in $PATH: unknown
command terminated with exit code 126
```

En este caso, debemos cambiar el comando:

```shell
$ kubectl exec -ti multicontainer-pod-with-default-container -- bash
root@multicontainer-pod-with-default-container:/#
```

## Limpieza

Recuerda que para detener el reenvío de puertos (`kubectl port-forward`) debes
presionar `CTRL + C`.

Para terminar el taller, borraremos el `Pod` que hemos creado:

```shell
$ kubectl delete -f .\multicontainer-pod.yml -f .\multicontainer-pod-with-default-container.yml
pod "multicontainer-pod" deleted
pod "multicontainer-pod-with-default-container" deleted
```

Acuerdate de ejecutar `minikube stop` para detener minikube si no lo necesitas.

## Siguiente paso

[Desplegar un `Pod` en un cluster gestionado](../managed-cluster/README_es.md)