# Usando `taints` para desalojar `Pods` de un nodo.

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `managed`

## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-taints`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-taints created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                        STATUS   AGE
default                     Active   34d
demo-taints                 Active   23s
kube-node-lease             Active   34d
kube-public                 Active   34d
kube-system                 Active   34d
```

Puedes seleccionar este espacio de nombres por defecto ejecutando:

```shell
$ kubectl config set-context --current --namespace demo-taints
Context "managed" modified.
```

## `Deployment`

Creamos un `Deployment` que desplegará 5 réplicas de la página web de Foo Corporation en nuestro cluster.
El `Deployment` está definido en el fichero [`deployment.yml`](./deployment.yml). Este objeto
no define ningún tipo de `Affinity` ni the `tolerations` para los `Pods`:

```shell
$ kubectl apply -f deployment.yml
deployment.apps/foo-website created
```

Tras unos segundos, veremos nuestros `Pods` distribuidos por nustros nodos (en nuestro caso, por los tres que tenemos
disponibles):
```shell
$ kubectl get pods -n demo-taints -o wide
NAME                           READY   STATUS    RESTARTS   AGE   IP              NODE                       NOMINATED NODE   READINESS GATES
foo-website-679fc766c5-2gjfg   1/1     Running   0          28s   10.212.142.32   standardnodes-wypldyeewy   <none>           <none>
foo-website-679fc766c5-8f4th   1/1     Running   0          28s   10.223.58.116   standardnodes-paka7v2imr   <none>           <none>
foo-website-679fc766c5-92jql   1/1     Running   0          28s   10.216.183.63   standardnodes-zuf5eywgar   <none>           <none>
foo-website-679fc766c5-j7czh   1/1     Running   0          28s   10.216.183.11   standardnodes-zuf5eywgar   <none>           <none>
foo-website-679fc766c5-s9cn9   1/1     Running   0          28s   10.223.58.115   standardnodes-paka7v2imr   <none>           <none>
```

## Análisis del nodo `standardnodes-zuf5eywgar`

Del listado anterior, seleccionamos el nodo `standardnodes-zuf5eywgar`, que tiene dos `Pods` en ejecución. A este nodo, le vamos a
añadir el `taint` `memory-optimized=true`. Cuando lo hagamos, los dos `Pods` de nuestro `Deployment` se reprogramarán en los otros dos nodos.

**⚠️ Esto ocurrirá con todos los `Pods` que estén en este momento en este nodo ⚠️**. El siguiente comando afectará a todos los `Pods` 
que no tengan un `toleration` para definido y que sea compatible con el `taint`.

Veamos los `Pods` que se están ejecutando en ese nodo:

```shell
$ kubectl describe node standardnodes-zuf5eywgar

...
...
Non-terminated Pods:          (11 in total)
  Namespace                   Name                                    CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                                    ------------  ----------  ---------------  -------------  ---
  demo-hostpath               hostpath-pod                            0 (0%)        0 (0%)      0 (0%)           0 (0%)         3d19h
  demo-hpa                    cpu-app-868bcd98cf-zhwcp                500m (12%)    0 (0%)      0 (0%)           0 (0%)         3d6h
  demo-ingress                foo-website-7b9d598f67-f7tbw            0 (0%)        0 (0%)      0 (0%)           0 (0%)         3d19h
  demo-taints                 foo-website-679fc766c5-92jql            0 (0%)        0 (0%)      0 (0%)           0 (0%)         15m
  demo-taints                 foo-website-679fc766c5-j7czh            0 (0%)        0 (0%)      0 (0%)           0 (0%)         15m
  kube-system                 calico-node-4w4mv                       250m (6%)     0 (0%)      0 (0%)           0 (0%)         6d12h
  kube-system                 coredns-dd9ff6c54-sgj7k                 100m (2%)     100m (2%)   128Mi (15%)      128Mi (15%)    3d19h
  kube-system                 csi-ionoscloud-zs6j7                    0 (0%)        0 (0%)      0 (0%)           0 (0%)         6d12h
  kube-system                 konnectivity-agent-hrlbh                16m (0%)      0 (0%)      32Mi (3%)        32Mi (3%)      6d12h
  kube-system                 kube-proxy-bhhcx                        0 (0%)        0 (0%)      0 (0%)           0 (0%)         6d12h
  kube-system                 nginx-proxy-standardnodes-zuf5eywgar    25m (0%)      0 (0%)      32M (3%)         0 (0%)         6d12h
```

Aquí podemos ver varios `Pods` que todavía están en ejecución de anteriores talleres que hemos realizado. También vemos
que en este nodo se están ejecutando varios `Pods` del espacio de nombres `kube-system`. ¿Qué ocurrirá con estos `Pods`?

Si miramos los `tolerations` de estos `Pods`, veremos que todos tienen:

```shell
kubectl describe pod coredns-dd9ff6c54-sgj7k -n kube-system
...
...
Tolerations:                 :NoSchedule op=Exists
                             :NoExecute op=Exists
...
```

Es decir, todos ellos tienen un `toleration` al efecto `NoExecute` y `NoSchedule` para cualquier pareja de clave:valor.
Esto significa que estos `Pods` no se moverán cuando apliquemos el `taint` en la siguiente sección.


## Añadir un `taint` a un nodo

Una vez hemos visto lo que se está ejecutando en el nodo `standardnodes-zuf5eywgar`, vamos a añadirle un el `taint`
`memory-optimized=true` usando el comando `kubectl taint`:

```shell
$ kubectl taint node standardnodes-zuf5eywgar memory-optimized=true:NoExecute
node/standardnodes-zuf5eywgar tainted
```

Si listamos todos los `Pods` que tenemos, veremos que sólo los del espacio de nombres `kube-system` se siguen ejecutando 
en ese nodo:

```shell
$ kubectl get pods --all-namespaces -o wide | grep standardnodes-zuf5eywgar
kube-system            calico-node-4w4mv                              1/1     Running     0               6d12h   93.93.114.154   standardnodes-zuf5eywgar   <none>           <none>
kube-system            coredns-dd9ff6c54-sgj7k                        1/1     Running     0               3d19h   10.216.183.39   standardnodes-zuf5eywgar   <none>           <none>
kube-system            csi-ionoscloud-zs6j7                           2/2     Running     0               6d12h   10.216.183.2    standardnodes-zuf5eywgar   <none>           <none>
kube-system            konnectivity-agent-hrlbh                       1/1     Running     0               6d12h   10.216.183.1    standardnodes-zuf5eywgar   <none>           <none>
kube-system            kube-proxy-bhhcx                               1/1     Running     0               6d12h   93.93.114.154   standardnodes-zuf5eywgar   <none>           <none>
kube-system            nginx-proxy-standardnodes-zuf5eywgar           1/1     Running     0               6d12h   93.93.114.154   standardnodes-zuf5eywgar   <none>           <none>
```

También podemos verlo usando el comando `kubectl describe node`:

```shell
$ kubectl describe node standardnodes-zuf5eywgar

Name:               standardnodes-zuf5eywgar
Roles:              node
...
Non-terminated Pods:          (6 in total)
  Namespace                   Name                                    CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                                    ------------  ----------  ---------------  -------------  ---
  kube-system                 calico-node-4w4mv                       250m (6%)     0 (0%)      0 (0%)           0 (0%)         6d12h
  kube-system                 coredns-dd9ff6c54-sgj7k                 100m (2%)     100m (2%)   128Mi (15%)      128Mi (15%)    3d19h
  kube-system                 csi-ionoscloud-zs6j7                    0 (0%)        0 (0%)      0 (0%)           0 (0%)         6d12h
  kube-system                 konnectivity-agent-hrlbh                16m (0%)      0 (0%)      32Mi (3%)        32Mi (3%)      6d12h
  kube-system                 kube-proxy-bhhcx                        0 (0%)        0 (0%)      0 (0%)           0 (0%)         6d12h
  kube-system                 nginx-proxy-standardnodes-zuf5eywgar    25m (0%)      0 (0%)      32M (3%)         0 (0%)         6d12h
```

Esto incluye los `Pods` de nuestro `Deployment`, ninguno de ellos sigue ejecutándose en ese nodo:

```shell
NAME                           READY   STATUS    RESTARTS   AGE     IP              NODE                       NOMINATED NODE   READINESS GATES
foo-website-679fc766c5-2gjfg   1/1     Running   0          23m     10.212.142.32   standardnodes-wypldyeewy   <none>           <none>
foo-website-679fc766c5-4cqr4   1/1     Running   0          5m34s   10.223.58.117   standardnodes-paka7v2imr   <none>           <none>
foo-website-679fc766c5-8f4th   1/1     Running   0          23m     10.223.58.116   standardnodes-paka7v2imr   <none>           <none>
foo-website-679fc766c5-rpgdg   1/1     Running   0          5m34s   10.212.142.35   standardnodes-wypldyeewy   <none>           <none>
foo-website-679fc766c5-s9cn9   1/1     Running   0          23m     10.223.58.115   standardnodes-paka7v2imr   <none>           <none>
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
namespace "demo-taints" deleted
```

Por último, quitamos el taint del nodo:

```shell
$ kubectl taint node standardnodes-zuf5eywgar memory-optimized=true:NoExecute-
node/standardnodes-zuf5eywgar untainted
```