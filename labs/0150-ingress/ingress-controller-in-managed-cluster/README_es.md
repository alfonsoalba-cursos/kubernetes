# Instalar _Ingress controller_ en un cluster gestionado

Para que los objetos `Ingress` de Kubernetes funcionen, es necesario que el cluster tenga
configurado un _ingress controller_. En este primer taller, configuraremos primero un
controlador de tipo `ingress-nginx` y luego crearemos los objetos `Ingress` en el cluster.

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `managed`

## Selección del controlador

De la 
[lista de controladores](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
disponibles, en este taller instalaremos el 
[_ingress-nginx Controller_](https://kubernetes.github.io/ingress-nginx/).

## Instalación en un cluster gestionado

Según se indica en la propia [página de instalación de `ingress-nginx`](https://kubernetes.github.io/ingress-nginx/deploy/#quick-start), podemos
instalar el controlador bien con Helm o utilizando un manifiesto. En este
taller seguiremos este segundo camino.

La versión disponible en el momento de redactar este taller era la 1.1.1. 
En la documentación del controlador teneís las instrucciones actualizadas para instalar
la última versión.

Ejecutamos el siguiente comando:

```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.1/deploy/static/provider/cloud/deploy.yaml
```

Una vez terminen de crearse todos los recursos, debemos esperar unos minutos hasta que el `Pod` con el controlador
se ejecute:

```shell
$ kubectl get pods --namespace=ingress-nginx
NAME                                        READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create--1-522bq     0/1     Completed   0          55s
ingress-nginx-admission-patch--1-vnf24      0/1     Completed   0          55s
ingress-nginx-controller-54d8b558d4-6wjmv   1/1     Running     0          57s
```

Como parte del manifiesto que hemos instalado, se habrá creado un servicio `ingress-nginx-controler`:

```shell
$ kubectl get service ingress-nginx-controller --namespace=ingress-nginx
NAME                       TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                      AGE
ingress-nginx-controller   LoadBalancer   10.233.55.150   93.93.114.64   80:31648/TCP,443:31104/TCP   9m27s
```

Este servicio tiene asignada una direción IP externa y está escuchando en los puertos 80 y 443.

## Siguiente paso

En el [Siguiente taller](../ingress-in-managed-cluster/README_es.md) accederemos a las páginas web de _Foo Corporation_ y _Web Corporation_ utilizando
dominios DNS a través del controlador `ingress-nginx`.

## Limpieza

---

⚠️ No borres los objetos si vas a realizar el siguiente taller.

---

Para borrar todos los objetos, basta con borrar el espacio de nombres:

```shell
$ kubectl delete namespace ingress-nginx
namespace "ingress-nginx" deleted
```
