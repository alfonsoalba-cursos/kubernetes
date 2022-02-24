### `PodAffinity` y `PodAntiAffinity`

Permiten restringir en qué nodos se puede ejecutar un `Pod` en base a las 
etiquetas (_labels_) de los `Pods` que ya se están ejecutando en un nodo.


^^^^^^

### `PodAffinity`

Se define en la sección `spec.affinity.podAffinity` del `Pod`:

* `preferredDuringSchedulingIgnoredDuringExecution`: indica nuestra preferencia. `kube-scheduler`
  puede no cumplir esta regla si lo necesita
* `requiredDuringSchedulingIgnoredDuringExecution `: indica condiciones que se tienen que cumplir.
  Si no se puede cumplir esta condición, el `Pod` no se programará

notes:

[podAffinity API reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#PodAffinity)

^^^^^^

### `PodAntiAffinity`

Se define en la sección `spec.affinity.podAntiAffinity` del `Pod`:

* `preferredDuringSchedulingIgnoredDuringExecution`: indica nuestra preferencia sobre
  donde NO queremos que el `Pod` se programe. `kube-scheduler`
  puede no cumplir esta regla si lo necesita
* `requiredDuringSchedulingIgnoredDuringExecution `: indica dónde NO queremos que se programe.
  Si no se puede cumplir esta condición, el `Pod` no se programará

notes:

[podAntiAffinity API reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#PodAntiAffinity)

^^^^^^

```yaml [6-260]
apiVersion: v1
kind: Pod
metadata:
  name: with-pod-affinity
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: security
            operator: In
            values:
            - S1
        topologyKey: topology.kubernetes.io/zone
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: security
              operator: In
              values:
              - S2
          topologyKey: topology.kubernetes.io/zone
  containers:
  - name: with-pod-affinity
    image: k8s.gcr.io/pause:2.0
```

^^^^^^

#### `PodAffinity` y `PodAntiAffinity`

A tener en cuenta:

⚠️ El uso de estas propiedades **require una cantidad importante de recursos**. En clusters
grandes (varios centenares de nodos) no se recomienda su uso ya que puede puede afectar
al tiempo que tardan los `Pods` en programarse

⚠️ Los nodos deben estar consistentemente etiquetados usando el `topologyKey`. Si algún
nodo no lo tiene, se puede dar lugar a resultados inesperados
