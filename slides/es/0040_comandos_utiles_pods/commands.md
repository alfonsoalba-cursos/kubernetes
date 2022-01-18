|   |
| - |
| `kubectl get pods` |
| `kubectl describe pod <name>` |
| `kubectl expose pod <name> --port=... --name=...` |
| `kubectl port-forward <name> <localPortNumber>:<podPortNumber>` |
| `kubectl exec <name> --command <command>` |
| `kubectl run ...` |
| `kubectl label pod <name> key=value` |
| `kubectl attach <name> -i` |
| `kubectl debug <name> -it --image=<name>` |


^^^^^^                

```shell
$ kubectl get pods 
```

* `-o wide|json|yaml`
* `-L` Lista separada por comas con los `labels` que queremos mostrar

notes:

Obtiene el listado de `Pods`


[Manual de referencia](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get)

^^^^^^

```shell
$ kubectl describe pod <name>
```

notes:

[Manual de referencia](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#describe)

^^^^^^


```shell
$ kubectl expose pod <name> --port=... --name=...
```

notes:

Crea un servicio para exponer un puerto de un pod.

[Referencia](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#expose)

^^^^^^

```shell										
$ kubectl port-forward <name> <localPortNumber>:<podPortNumber>
```

notes:

Sirve para crear servicios.

Expone el puerto `<podPortNumber>` del `Pod` a través del puerto local `<localPortNumber>`
creando un objeto de tipo `Service`.


[Referencia](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#expose)

^^^^^^

```shell
$ kubectl exec <name> --command <command>
```

* `-c` Selecciona el contenedor en el que queremos ejecutar el `Pod`

notes:

Ejecuta el comando `<command>` en el primer contededor del `Pod` `<name>`.

Si queremos ejecutar el comando en otro contenedor, podemos seleccionarlo con la opción `-c`.

[Referencia](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#exec)

^^^^^^

```shell
$ kubectl run <name> --image=<image>  -- <command> <args> <arg> ...
```

notes:

Comando utilizado para crear `Pods`.

Crea un `Pod` con el nombre `<name>` utilizando la imagen `<image>` y ejecuta el comando indicado dentro de este contenedor.

[Referencia](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#run)


^^^^^^

```shell
$ kubectl label pod <name> key=value
```

notes:

Añade y modifica etiquetas de un `Pod`.

[Referencia](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#label)

^^^^^^

```shell
$ kubectl attach <name> -i
```

* `-c` Selecciona el contenedor dentro del `Pod`

notes:

Se adjunta a un proceso que ya está en ejecución dentro de un contenedor
[Referencia](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#attach)

^^^^^^

```shell
$ kubectl debug <name> -it --image=<image>
```

* `-i` Mantiene la entrada estándar (`stdin`) abierta
* `-t` Crear una termina para el contenedor
* `--image` Imagen a utilizar

notes:

Crea un _ephemeral container_ en el  `Pod` `<name>` usando la imagen `<image>`.

[Referencia](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#debug)