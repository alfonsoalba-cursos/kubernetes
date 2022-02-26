### `Taints`

Para añadir un `taint` a un nodo utilizamos el comando `kubectl taint`

```shell
$ kubectl taint [NODE] [KEY]=[VALUE]:[EFFECT]
```

^^^^^^

### `Taints`

* [KEY]
  * Caracteres permitidos: [\w\d-._]
  * Debe empezar con letra o número
  * Máximo: 253 characters
  * Puede contener un prefijo (nobre DNS) por ejemplo `example.com/my-app`
* [VALUE]
  * Opcional
  * Caracteres permitidos: [\w\d-._]
  * Debe empezar con letra o número
  * Máximo: 63 characters
* [EFFECT]: `NoSchedule`, `PreferNoSchedule` o `NoExecute`

^^^^^^

### `Taints`: [EFFECT]

* `NoSchedule`: `kube-scheduler` no programará nuevos `Pods` en el nodo si el `Pod` no
  tolera este `taint`. Los `Pods` que ya estén en ese nodo no se desahucian
* `PreferNoSchedule`: `kube-scheduler` intentará no programar nuevos `Pods` en 
  el nodo si el `Pod` no tolera este `taint`. Los `Pods` que ya estén en ese nodo no se desahucian
* `NoExecute`: desahucia todos los `Pods` que están en el nodo y que no toleran este `taint`


^^^^^^

### `Taints`

Para quitar un `taint` de un nodo utilizamos el comando `kubectl taint`

```shell
$ kubectl taint [NODE] [KEY]:-
$ kubectl taint [NODE] [KEY]:[EFFECT]-
```

(notar el caracter ` - ` después de [KEY])
