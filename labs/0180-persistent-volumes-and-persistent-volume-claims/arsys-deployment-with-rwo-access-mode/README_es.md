# Arsys: Deployment con PVC en modo de acceso RWO

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `managed`

## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-deployment-rwo`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-deployment-rwo created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                        STATUS   AGE
default                     Active   34d
demo-deployment-rwo         Active   10s
kube-node-lease             Active   34d
kube-public                 Active   34d
kube-system                 Active   34d
```

Puedes seleccionar este espacio de nombres por defecto ejecutando:

```shell
$ kubectl config set-context --current --namespace demo-deployment-rwo
Context "managed" modified.
```


## `PersistentVolumeClaim`

En este taller utilizaremos un `PersistentVolumeClaims` que solicita cada una un disco de 15Gi de espacio de la clase `ionos-enterprise-hdd` ([pvc.yml](./pvc.yml):

```shell
$ kubectl apply -f pvc.yml
```

Veamos el `PersistentVolumeClaim` que acabamos de crear:

```shell
$ kubectl get pvc -n demo-accessmodes
NAME           STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS           AGE
15gi-hdd-rwo   Pending                                      ionos-enterprise-hdd   10m
```

El objetos queda en estado `Pending` hasta que un `Pod` utilice el `PersistentVolumeClaim`.

## `Deployment`

A continuación, creamos un `Deployment` que desplegará tres réplicas de la página web de Foo Corporation ([`deployment.yml`](./deployment.yml)).
Los `Pods` de este `Deployment` montan un volumen utilizando el objeto `PersistentVolumeClaim` que acabamos de crear:

```yaml
...
apiVersion: apps/v1
kind: Deployment
...
spec:

  replicas: 3
  ...
  template:
    spec:
      ...
      containers:
      - name: nginx
        image: kubernetescourse/foo-website
        ports:
        - containerPort: 80
        volumeMounts:
        - name: rwo-volume
          mountPath: /mnt/rwo-volume
      volumes:
      - name: rwo-volume
        persistentVolumeClaim:
          claimName: 15gi-hdd-rwo
```

Tras unos segundos, los `Pods` estarán en esado `Running`:

```shell
$ kubectl get all -n demo-accessmodes
NAME                               READY   STATUS    RESTARTS   AGE
pod/foo-website-6d8c87fd46-2zppm   1/1     Running   0          52s
pod/foo-website-6d8c87fd46-89lpk   1/1     Running   0          52s
pod/foo-website-6d8c87fd46-vjqbr   1/1     Running   0          52s

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/foo-website   3/3     3            3           53s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/foo-website-6d8c87fd46   3         3         3       53s
```

El comando `kubectl get all` no muestra los objetos `PersistentVolumeClaim`. Si los listamos, veremos cómo ha pasado 
de estado `Pending` a `Bound`:

```shell
$ kubectl get pvc -n demo-accessmodes
NAME           STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS           AGE
15gi-hdd-rwx   Bound    pvc-4cd6d094-19b3-4568-91d1-b6c4a4a2128a   15Gi       RWO            ionos-enterprise-hdd   5m29s
```

## Los `Pod`

Como consecuencia de utilizar el modo de acceso `RWO`, **todos los `Pods` se programarán en el mismo nodo del cluster**:

```shell
$ kubectl get pods -n demo-deployment-rwo -o wide
NAME                          READY   STATUS    RESTARTS   AGE   IP              NODE                       NOMINATED NODE   READINESS GATES
foo-website-5c74dd858-7z77v   1/1     Running   0          10m   10.212.142.51   standardnodes-wypldyeewy   <none>           <none>
foo-website-5c74dd858-vmptw   1/1     Running   0          10m   10.212.142.49   standardnodes-wypldyeewy   <none>           <none>
foo-website-5c74dd858-w7v45   1/1     Running   0          10m   10.212.142.50   standardnodes-wypldyeewy   <none>           <none>
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
namespace "demo-deployment-rwo" deleted
```