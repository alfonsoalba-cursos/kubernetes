# Usar `ExternalName` para conectarnos a una base de datos fuera del cluster

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `minikube`

## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-externalname`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-externalname created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                STATUS   AGE
default             Active   34d
demo-externalname   Active   10s
kube-node-lease     Active   34d
kube-public         Active   34d
kube-system         Active   34d
```

Puedes seleccionar este espacio de nombres por defecto ejecutando:

```shell
$ kubectl config set-context --current --namespace demo-externalname
Context "minikube" modified.
```
## Antes de empezar

Tendremos que configurar una máquina virtual a la que podamos acceder a través de un
nombre DNS. Dentro de esta máquina virtual:

* Instalaremos MySQL / MariaDB
* Configurarmeos el servidor de base de datos para que podamos acceder a él desde fuera de la máquina:
  * `bind` a la IP `0.0.0.0`
  * Configurar un usuario con acceso desde cualquier IP:
    ```sql
    CREATE user demo@`%` IDENTIFIED by 'demodemo';
    ```
* Configurar un registro DNS que apunte a esa máquina virtual. En mi caso `externalnamedemo.alfonsoalba.com`

## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-externalname`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-externalname created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                STATUS   AGE
default             Active   34d
demo-externalname   Active   11s
kube-node-lease     Active   34d
kube-public         Active   34d
kube-system         Active   34d
```

Puedes seleccionar este espacio de nombres por defecto ejecutando:

```shell
$ kubectl config set-context --current --namespace demo-externalname
Context "minikube" modified.
```


## `Service`

Creamos el `Service` de tipo `ExternalName` utilizando el fichero [`service.yml`](./service.yml):

```shell
$ kubectl apply -f .\service.yml   
service/mariadb created
```

Podemos ver que el servicio se ha creado correctamente ejecutando `kubectl get services`:

```shell
kubectl get services -o wide -n demo-externalname   
NAME      TYPE           CLUSTER-IP   EXTERNAL-IP                        PORT(S)   AGE     SELECTOR
mariadb   ExternalName   <none>       externalnamedemo.alfonsoalba.com   <none>    2m40s   <none>
```

## Accediendo a la base de datos

Levantamos un `Pod` que contenga el cliente de MySQL/Mariadb:

```shell
$ kubectl run mysqlclient -n demo-externalname -ti --image mysql -- bash
If you don't see a command prompt, try pressing enter.
root@mysqlclient:/#
```

Una vez dentro del `Pod` nos conectamos al servicio externo utilizando el nombre del servicio:

```shell
root@mysqlclient:/#  mysql -u demo -h mariadb -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 42
Server version: 5.5.5-10.3.32-MariaDB-0ubuntu0.20.04.1 Ubuntu 20.04

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```

## Limpieza

Volvemos a poner `default` como espacio de nombres por defecto:

```shell
$ kubectl config set-context --current --namespace default
Context "minikube" modified.
```


Para borrar todos los objetos, basta con borrar el espacio de nombres:

```shell
$ kubectl delete -f namespace.yml
namespace "demo-externalname" deleted
```

Borrar el registro DNS `externalnamedemo.alfonsoalba.com`