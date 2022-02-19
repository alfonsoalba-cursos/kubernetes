# _Service Discovery_

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `minikube`

## Preparación

Vamos a desplegar dos páginas web sobre el mismo espacio de nombres: `foo-website` y `bar-website`

## Despliegue de la página web de Foo Corporation

En el fichero [foo-website.yml](foo-website.yml) está la definición del despliegue de la página web de nuestro cliente.
Esta consiste en:
* Un `Deployment` con tres réplicas
* Un `Service` de tipo `NodePort` para poder acceder a él desde el exterior

Aplicamos la configuración a nuestro cluster:

```shell
$ kubectl create -f foo-website.yml
deployment.apps/foo-website created
service/foo-website created
```

Veamos los objetos que se han creado:

```shell
$ > kubectl get pods
NAME                           READY   STATUS    RESTARTS   AGE
foo-website-689949cc58-8cfdh   1/1     Running   0          32s
foo-website-689949cc58-dmr86   1/1     Running   0          32s
foo-website-689949cc58-qph5p   1/1     Running   0          32s
```

```shell
$ kubectl get deployments
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
foo-website   3/3     3            3           97s
```

```shell
 kubectl get services   
NAME          TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
foo-website   NodePort    10.108.1.147   <none>        80:30290/TCP   119s
kubernetes    ClusterIP   10.96.0.1      <none>        443/TCP        38m
```

Podemos comprobar que la página se ve correctamente obteniendo la página del servicio ejecutando

```shell
$ minikube service foo-website --url
http://192.168.1.155:30290
```

y abriendo un navegador con en esta URL.

## Despliegue de la página web de Bar Corporation

En el fichero [bar-website.yml](bar-website.yml) está la definición del despliegue de la página web de nuestro cliente.
Esta consiste en:
* Un `Deployment` con dos réplicas
* Un `Service` de tipo `NodePort` para poder acceder a él desde el exterior

Aplicamos la configuración a nuestro cluster:

```shell
$ kubectl create -f bar-website.yml
deployment.apps/bar-website created
service/bar-website created
```

Veamos los objetos que se han creado:

```shell
$ > kubectl get pods
NAME                           READY   STATUS    RESTARTS   AGE
bar-website-689949cc58-8cfdh   1/1     Running   0          32s
bar-website-689949cc58-dmr86   1/1     Running   0          32s
bar-website-689949cc58-qph5p   1/1     Running   0          32s
```

```shell
$ kubectl get deployments
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
bar-website   3/3     3            3           97s
```

```shell
 kubectl get services   
NAME          TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
bar-website   NodePort    10.108.1.147   <none>        80:30290/TCP   119s
kubernetes    ClusterIP   10.96.0.1      <none>        443/TCP        38m
```

Podemos comprobar que la página se ve correctamente obteniendo la página del servicio ejecutando

```shell
$ minikube service bar-website --url
http://192.168.1.155:30290
```

y abriendo un navegador con en esta URL.

## _Service discovery_

### Usando curl para ver la web de un `Pod` desde el otro

Vamos a acceder a la página web de _Bar Corporation_ desde uno de los contenedores de _Foo Corporation_.

Seleccionamos uno de los `Pods` de _Foo Corporation_, en este caso usaremos `foo-website-689949cc58-8cfdh`. 
Abrimos una consola dentro del contenedor de este `Pod`:

```shell
$ kubectl exec -ti foo-website-689949cc58-8cfdh -- bash
root@foo-website-689949cc58-8cfdh:/$
```

Utilizando el nombre del contenedor, podemos acceder al servicio. Por ejemplo:

```shell
root@foo-website-689949cc58-8cfdh:/$ curl -s bar-website | grep \<title\>
    <title>BarPhone XM-900 - Bar Corporation</title>
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" class="d-block mx-auto" role="img" viewBox="0 0 24 24"><title>Product</title><circle cx="12" cy="12" r="10"/><path d="M14.31 8l5.74 9.94M9.69 8h11.48M7.38 12l5.74-9.94M9.69 16L3.95 6.06M14.31 16H2.83m13.79-4l-5.74 9.94"/></svg>
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" class="d-block mb-2" role="img" viewBox="0 0 24 24"><title>Product</title><circle cx="12" cy="12" r="10"/><path d="M14.31 8l5.74 9.94M9.69 8h11.48M7.38 12l5.74-9.94M9.69 16L3.95 6.06M14.31 16H2.83m13.79-4l-5.74 9.94"/></svg>
```

### Usando wget para consumir la api de Bar desde dentro del cluster

La página _Bar Corporation_ tiene una API que podemos consumir. Vamos a consultar la API desde 
un nuevo `Pod`.

Crear un nuevo `Pod` :

```shell
$ kubectl run busybox -it --image=docker.io/busybox --restart=Never
If you don't see a command prompt, try pressing enter.
/ #
```

Vamos a acceder al fichero `.json` con los productos que vende _Bar Corporation_:

```shell
/ $ wget -q -O - http://bar-website/products.json
[
    {
        "name": "BarPhone XM-900",
        "SKU": "XM-900",
        "description": "...",
        "price": "199.99",
        "currency": "€"
    },
    {
        "name": "BarPhone XMH-950-4K",
        "SKU": "XMH-950-4K",
        "description": "...",
        "price": "199.99",
        "currency": "€"
    }
]
```

### Configuración DNS de los pods

Vamos a ver cuál es el contenido del fichero `/etc/resolv.conf` dentro de cualquiera de los contenedores:

```shell
$ kubectl run busybox -it --image=docker.io/busybox --restart=Never -- cat /etc/resolv.conf
nameserver 10.96.0.10
search default.svc.cluster.local svc.cluster.local cluster.local 
options ndots:5
```

```shell
$ kubectl exec foo-website-689949cc58-8cfdh -- cat /etc/resolv.conf 
nameserver 10.96.0.10
search default.svc.cluster.local svc.cluster.local cluster.local
options ndots:5
```

La dirección IP del servidor DNS se corresponde con la IP del servicio `kube-dns`:

```shell
$ kubectl get services -n kube-system
NAMESPACE     NAME          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
kube-system   kube-dns      ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP   12h
```

Mirando la definición del fichero `resolv.conf`, podemos utilizar diferentes urls para acceder al servicio:

```shell
$ kubectl run busybox -it --image=docker.io/busybox --restart=Never -- wget -O . -q http://bar-website.default
kubectl run busybox -it --image=docker.io/busybox --restart=Never -- wget -O - -q http://bar-website.default/products.json
[
    { 
        "name": "BarPhone XM-900",
        "SKU": "XM-900",
        "description": "...",
        "price": "199.99",
        "currency": "€"
    },
    {
        "name": "BarPhone XMH-950-4K",
        "SKU": "XMH-950-4K",
        "description": "...",
        "price": "199.99",
        "currency": "€"
    }
]
```

También poodíamos haber utilizado cualquiera de estas direcciones:
* bar-website.default.svc
* bar-website.default.svc.cluster.local

