# Arsys: Resolver incidencia con los modos de acceso (ROX, RWO y RWX)

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `managed`

## `Namespace`

Para la realización de este taller utilizaremos el espacio de nombres `demo-ts-accessmodes`:

```shell
$ kubectl create -f namespace.yml
namespace/demo-ts-accessmodes created
```

Verificamos la creación del espacio de nombres:

```shell
$ kubectl get namespaces
NAME                        STATUS   AGE
default                     Active   34d
demo-ts-accessmodes           Active   13s
kube-node-lease             Active   34d
kube-public                 Active   34d
kube-system                 Active   34d
```

Puedes seleccionar este espacio de nombres por defecto ejecutando:

```shell
$ kubectl config set-context --current --namespace demo-ts-accessmodes
Context "managed" modified.
```


## El problema...

Para generar el problema, aplicamos el manifiesto [`manifest.yml`](./manifest.yml)

```shell
$ kubectl apply -f manifest.yml
namespace/demo-ts-accessmodes created
persistentvolumeclaim/15gi-hdd-rox created
persistentvolumeclaim/15gi-hdd-rwo created
persistentvolumeclaim/15gi-hdd-rwx created
deployment.apps/foo-website created
``` 

Desafortunadamente, los `Pods` no llegarán nunca a estar _ready_. ¿Porqué?

## Limpieza

Volvemos a poner `default` como espacio de nombres por defecto:

```shell
$ kubectl config set-context --current --namespace default
Context "managed" modified.
```


Para borrar todos los objetos, basta con borrar el espacio de nombres:

```shell
$ kubectl delete -f namespace.yml
namespace "demo-ts-accessmodes" deleted
```