### `NodeAffinity`

Al igual que `NodeSelector`, nos permiten indicarle a `kube-scheduler` en qué nodo
queremos (o preferimos) que los `Pods` se ejecuten

`NodeSelector` sólo permite seleccionar nodos en base a si tiene etiquetas definidas

`NodeAffinity` permite el uso de _set-based_ selectors y definir condiciones obligatorias
o nuestras preferencias a la hora de distribuir los `Pods` en los nodos

^^^^^^

### `NodeAffinity`

Se define en la sección `spec.affinity.nodeAffinity` del `Pod`:

* `preferredDuringSchedulingIgnoredDuringExecution`: indica nuestra preferencia. `kube-scheduler`
  puede no cumplir esta regla si lo necesita
* `requiredDuringSchedulingIgnoredDuringExecution `: indica condiciones que se tienen que cumplir.
  Si no se puede cumplir esta condición, el `Pod` no se programará

notes:

[NodeAffinity API reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#NodeAffinity)

^^^^^^

### `NodeAffinity`

```yaml [6-23]
apiVersion: v1
kind: Pod
metadata:
  name: with-node-affinity
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/e2e-az-name
            operator: In
            values:
            - e2e-az1
            - e2e-az2
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: another-node-label-key
            operator: In
            values:
            - another-node-label-value
  containers:
  - name: with-node-affinity
    image: k8s.gcr.io/pause:2.0
```

notes:

Ejemplo en el que se muestra el uso de las dos opciones para la seleccionar los nodos:
`preferred` y `required`

Podemos asignar un peso (`weight` en el ejemplo) con valores entre 0 y 100. `kube-scheduler` 
suma los diferentes pesos a medida que va aplicando las reglas y dará prioridad a los nodos
con más peso.

^^^^^^

### `NodeAffinity`

`requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms`: Si definimos varios elementos 
en este array, basta con que **uno de ellos** coincida para que el `Pod` se pueda crear en el nodo

Si dentro de `NodeSelectorTerm` o dentro de `preferredDuringSchedulingIgnoredDuringExecution.preference` definimos un `matchExpressions` con varias entradas **todas ellas se deben satisfacer**

[Más información](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity)

