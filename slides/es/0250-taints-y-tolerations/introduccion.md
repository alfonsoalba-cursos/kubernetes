### `Taints` & `Tolerations`

`Affinity` y `AntiAffinity` permite que los nodos _atrigan_ a determinados los `Pods`.

`Taints` consiguen el efecto contrario: _repelen_ los `Pods`

^^^^^^

### `Taints` & `Tolerations`


Con el comando `kubectl taint` _marcamos_ los nodos:

```shell
$ kubectl taint nodes node1 component=database:NoSchedule
```

El nodo `node1` **solo aceptará `Pods` que tengan un `toleration` que concuerde con
este `taint`**

^^^^^^

### Casos de uso

* Nodos dedicados: por ejemplo nodos optimizados para el uso de memoria RAM que solo 
  aceptan bases de datos en memoria (redis, memcached, etc)
* Nodos con hardware especial: nodos que tienen GPUs
