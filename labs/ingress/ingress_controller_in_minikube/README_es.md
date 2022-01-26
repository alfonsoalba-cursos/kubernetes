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
