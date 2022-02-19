# Configuración de Redis usando `ConfigMap`

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `minikube`


## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-configmaps`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-configmaps created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                STATUS   AGE
default             Active   34d
demo-configmaps     Active   10s
kube-node-lease     Active   34d
kube-public         Active   34d
kube-system         Active   34d
```

Puedes seleccionar este espacio de nombres por defecto ejecutando:

```shell
$ kubectl config set-context --current --namespace demo-configmaps
Context "minikube" modified.
```

## La configuración

Creamos un fichero de configuración [`config-map-yml`](./config-map.yml) que contendrá la configuración de Redis.

Empezamos con una configuración vacía:

```yml
...
data:
  redis-config: ""
```

Aplicamos la configuración:

```shell
$ kubectl apply -f .\config-map.yml
configmap/redis-config created
```

Vemos el `ConfigMap` que acabamos de crear:

```shell
$ kubectl get configmaps -n demo-configmaps
NAME               DATA   AGE
kube-root-ca.crt   1      14m
redis-config-map   1      3m8s
```

También podemos ver el contenido, que en este momento contiene la clave `redis-config` sin ningún valor:


```shell
kubectl describe configmap redis-config-map
Name:         redis-config-map
Namespace:    demo-configmaps
Labels:       <none>
Annotations:  <none>

Data
====
redis-config:
----


BinaryData
====

Events:  <none>
```
## El `Pod` con Redis

Especificamos un `Pod` de Redis con una sola réplica en el fichero [`redis-pod.yml`](./redis-pod.yml).

En este fichero configuramos el `ConfigMap` que creamos en el paso anterior:

```yaml
...
spec:
  containers:
  - name: redis
  ...
  volumeMounts:
    - mountPath: /config
      name: config
  volumes:
    - name: config
      configMap:
        name: redis-config-map
        items:
        - key: redis-config
          path: redis.conf
```
* Se crea un volumen `config`
* Este volumen expone la clave `redis-config` del `ConfigMap` de nombre `redis-config-map`, como el fichero `redis.conf`
  dentro del volumen
* Montamos el volumen en la carpeta `/config` del contenedor

Levantamos el `Pod`:

```shell
$ kubectl apply -f redis-pod.yml
pod/redis
```

Verificamos que el `Pod` se está ejecutando:

```shell
$  kubectl get pods -n demo-configmaps
NAME    READY   STATUS    RESTARTS   AGE
redis   1/1     Running   0          46s
```

En la salida del comando `kubectl describe` veremos la información relativa al `ConfigMap` y
al volumen en el que este se monta:

```shell
$ kubectl describe pod redis -n demo-configmaps
Name:         redis
Namespace:    demo-configmaps
...
Containers:
  redis:
    Container ID:  containerd://e6761cfb56231f10942e83d28d1b3231f091ca00fd75fcc40ab35bde960f411a
    Image:         redis:5.0.4
...
    Mounts:
      /config from config (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-gxtbz (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      redis-config-map
    Optional:  false
...
```

## Configuración actual

Nos conectamos al servicio de redis usando `redis-cli`:

```shell
$ kubectl exec -it redis -- redis-cli -n demo-configmaps
```

Una vez conectamos, veamos cuál es la configuración de memoria que tiene el 
servidor en este momento:

```shell
127.0.0.1:6379> CONFIG GET maxmemory
1) "maxmemory"
2) "0"
127.0.0.1:6379> CONFIG GET maxmemory-policy
1) "maxmemory-policy"
2) "noeviction"```
```

## Cambiar la configuración

Creamos el fichero [`config-map-updated.yml`](./config-map-updated.yml), en el que 
añadimos las siguientes opciones de configuración de redis:

```yml
...
data:
  redis-config: |
    maxmemory 2mb
    maxmemory-policy allkeys-lru    
```

Aplicamos la configuración:

```shell
$ kubectl apply -f config-map-updated.yml
```

Utilizando el comando `kubectl describe` podemos ver el nuevo valor de la configuración:

```shell
$ kubectl describe configmap redis-config-map
Name:         redis-config-map
Namespace:    demo-configmaps
Labels:       <none>
Annotations:  <none>

Data
====
redis-config:
----
maxmemory 2mb
maxmemory-policy allkeys-lru


BinaryData
====

Events:  <none>
```

Si nos conectamos de nuevo a redis, veremos que la nueva configuración no se ha aplicado:

```shell
$ kubectl exec -ti redis -n demo-configmaps -- redis-cli CONFIG GET maxmemory
1) "maxmemory"
2) "0"
```

Sin embargo, la configuración **si se ha propagado al `Pod`**:

```shell
$ kubectl exec -ti redis -n demo-configmaps -- cat /config/redis.conf        
maxmemory 2mb
maxmemory-policy allkeys-lru
```

Para aplicarla, en este caso, necesitamos reiniciar el `Pod`

```shell
$ kubectl delete -f redis-pod.yml
$ kubectl apply -f redis-pod.yml
```

Cuando el `Pod` se vuelva a levantar, podemos comprobar que la nueva configuración
se ha aplicado con éxito:

```shell
$ kubectl exec -ti redis -n demo-configmaps -- redis-cli CONFIG GET maxmemory
1) "maxmemory"
2) "2097152"
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
namespace "demo-configmaps" deleted
```