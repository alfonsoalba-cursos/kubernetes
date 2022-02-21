### Limitación de recursos

Dentro de la [especificación del `Pod`](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#resources)
existe una sección para limitar los recursos

```yaml [10-16,19-25]
---
apiVersion: v1
kind: Pod
metadata:
  name: frontend
spec:
  containers:
  - name: app
    image: images.my-company.example/app:v4
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
  - name: log-aggregator
    image: images.my-company.example/log-aggregator:v6
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

^^^^^^

### ¿Qué recursos se pueden limitar?

* CPU
* Memoria
* _Hugepages_

notes:

[Resource types](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-types)

^^^^^^

### `requests` vs `limits`

* `requests`: tamaño mínimo del recurso necesario para que el  `Pod` se pueda programar
* `limit`: tamaño máximo que el `Pod` puede consumir de ese recurso

notes:

En el ejemplo anterior:

```yaml
...
spec:
  containers:
  - name: app
    image: images.my-company.example/app:v4
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

Este `Pod` sólo se podrá desplegar en un nodo que tenga 64Mi y de memoria 
y 250m de CPU disponibles.

Por otro lado, la máxima cantidad de memoria que el contenedor podrá utilizar
será de 128Mi y no podrá utilizar más de media CPU.

^^^^^^

### Unidades: CPU

* Decimal: 
  * `spec.containers[].resources.requests.cpu: 0.5`
  * `spec.containers[].resources.requests.cpu: 2.7`
* _millicores_ / _millicpu_: 
  * `spec.containers[].resources.requests.cpu: 500m`
  * `spec.containers[].resources.requests.cpu: 2700m`

^^^^^^

### Unidades: Memoria

* E, P, T, G, M, k: múltiplos de 1000
* Ei, Pi, Ti, Gi, Mi, Ki: múltiplos de 1024
* ⚠️ `400m` serían 0.4bytes (400 _millibytes_). 

