### `Tolerations`

Los `Tolerations` se definen en la especificación del `Pod`

notes:

[Tolearions API reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#scheduling)

^^^^^^

### `Tolerations`

```yaml [11-14]
apiVersion: v1
kind: Pod
metadata:
  name: foo-website
  labels:
    security: s1
spec:
  containers:
  - name: bear
    image: kubernetescourse/foo-website
tolerations:
- key: "special"
  operator: "Exists"
  effect: "NoSchedule"
```

Este `Pod` sólo podrá ejecutarse en nodos que tengan el `taint` `special:*:NoSchedule`

^^^^^^

### `Tolerations`

Si definimos múltiples `tolerations`:

* ignora aquellos `taints` para los que existe un `toleration`
* a los `taints` restantes les aplica el efecto que esté definido

notes:

Veamos un ejemplo en la siguiente diapositiva

^^^^^^

### `Tolerations`

```shell
kubectl taint nodes host1 key1=value1:NoSchedule
kubectl taint nodes host1 key1=value1:NoExecute
kubectl taint nodes host1 key2=value2:NoSchedule
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: foo-website
  labels:
    security: s1
spec:
  containers:
  - name: bear
    image: kubernetescourse/foo-website
  tolerations:
  - key: "key1"
    operator: "Equal"
    value: "value1"
    effect: "NoSchedule"
  - key: "key1"
    operator: "Equal"
    value: "value1"
    effect: "NoExecute"
```

notes:

Definimos un nodo que tiene estos tres taints:

* key1=value1:NoSchedule
* key1=value1:NoExecute
* key2=value2:NoSchedule

El `Pod` del ejemplo tiene dos `tolerations` que concuerdan con los dos primeros `taints`.
Quitando estos estos dos `taints`, nos queda:

* key2=value2:NoSchedule

Esto significa que este `Pod` no se podrá programar en el nodo `host1`. Si ya existe algún
`Pod` en `host1` que se estuvise ejecutando antes de que se añadiese el `taint`
`key2=value2:NoSchedule`, este se seguirá ejecutando.

^^^^^^

### `Tolerations`: `NoExecute`

Si se aplica un `taint` con este efecto:

* Los `Pods` que no tengan un `toleration` se desahucian inmediatamente
* Los `Pods` que tengan un `toleration` y no especifiquen el parámetro `tolerationSeconds`
  continúan ejecutándose en el nodo
* Los `Pods` que tengan un `toleration` y especifiquen el parámetro `tolerationSeconds`
  continúan ejecutándose en el nodo durante ese tiempo antes de ser desahuciados

^^^^^^

### `Tolerations`: casos especiales

`Toleration` que tolera cualquier nodo

```yaml [11,12]
apiVersion: v1
kind: Pod
metadata:
  name: foo-website
  labels:
    security: s1
spec:
  containers:
  - name: bear
    image: kubernetescourse/foo-website
  tolerations:
  - operator: "Exists"
```

^^^^^^

### `Tolerations`: casos especiales

`Toleration` que tolera cualquier [EFFECT] para la clave `special`

```yaml [11-13]
apiVersion: v1
kind: Pod
metadata:
  name: foo-website
  labels:
    security: s1
spec:
  containers:
  - name: bear
    image: kubernetescourse/foo-website
  tolerations:
  - operator: Exists
    key: special
```
