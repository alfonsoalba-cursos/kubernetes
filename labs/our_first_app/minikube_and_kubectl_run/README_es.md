# Nuestra primera aplicación en `minikube` usando `kubectl run`

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `minikube`

En el [taller anterior](../minikube/README_es.md) creamos un `Pod` con la página
web de Foo Corporation. En este taller haremos el mismo ejercicio pero sin usar
un fichero de definición `yaml`.

## La aplicación: `Foo Corporation Website`

Nuestro objetivo es desplegar un `Pod` en minikube con la página web de nuestro
cliente `Foo Corporation Website`.

Ya existe un contenedor con la página web de la aplicación, 
[disponible en Docker Hub](https://hub.docker.com/repository/docker/kubernetescourse/foo-website).

## Desplegando el `Pod`

Para desplegar el `Pod`, usamos el comando [`kubectl run`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#run):

```shell
$ kubectl run foo-website \
  --image=kubernetescourse/foo-website \
  --port=80 --labels="name=foo-website"

pod/foo-website created
```

Podemos confirmar que el `Pod` se ha desplegado correctamente utilizando:

```shell
$ kubectl get pods -o wide --show-labels
NAME          READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES   LABELS
foo-website   1/1     Running   0          87s   172.17.0.3   minikube   <none>           <none>            name=foo-website
```

## Acceder al `Pod`

Podemos ver la página web del `Pod` usando los dos métodos del 
[taller anterior](../minikube/README_es.md):
* `port-forwarding`
* Creando un servicio con `kubectl expose`

## Limpieza

Para terminar el taller, borraremos el `Pod` y el `Service` que hemos creado:

```shell
$ kubectl delete pod foo-website
pod "foo-website" deleted

$ kubectl delete service foo-website
service "foo-website" deleted
```

Acuerdate de ejecutar `minikube stop` para detener minikube.