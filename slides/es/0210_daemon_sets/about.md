### `DaemonSets`

Un DaemonSet garantiza que todos (o algunos) de los nodos de un cluster ejecuten 
**una copia de un Pod**

Si se añade un nodo al clúster, Se añade un `Pod` a ese nodo

Si se elimina un nodo del clúster, el `Pod` que estaba en ese nodo se elimina

**No se reprograma en un nodo diferente**

^^^^^^

### Casos de uso

* Ejecutar un proceso de almacenamiento en el clúster.
* Ejecutar un proceso de recolección de logs en cada nodo.
* Ejecutar un proceso de monitorización de nodos en cada nodo.

notes:

De forma básica, se debería usar un DaemonSet, cubriendo todos los nodos, por cada tipo de proceso. En configuraciones más complejas se podría usar múltiples DaemonSets para un único tipo de proceso, pero con diferentes parámetros y/o diferentes peticiones de CPU y memoria según el tipo de hardware.

^^^^^^

### `DaemonSet` 

```yaml [2]
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd-elasticsearch
  namespace: kube-system
  labels:
    k8s-app: fluentd-logging
spec:
  selector:
    matchLabels:
      name: fluentd-elasticsearch
  template:
    metadata:
      labels:
        name: fluentd-elasticsearch
    spec:
      containers:
      - name: fluentd-elasticsearch
        image: gcr.io/fluentd-elasticsearch/fluentd:v2.5.1
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
      terminationGracePeriodSeconds: 30
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
```

notes:

En [este enlace](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/daemon-set-v1/) se puede ver la especificación de la API de los objetos 
`DaemonSet`

Es muy parecida a los `Deployments` o los `StatefulSet`.

Algunas particularidades de la definición:
* `spec.template.RestartPolicy`: debe tener el valor `Always` o no estar especificado,
  en cuyo caso será `Always`


### `DaemonSet`

¿Cómo seleccionar en qué nodos se ejecuta?

Si no se especifica `.spec.template.spec.nodeSelector` ni `.spec.template.spec.affinity`

Se ejecutará un `Pod` en cada nodo

^^^^^^

### `DaemonSet`

¿Cómo seleccionar en qué nodos se ejecuta?

* Definiendo `.spec.template.spec.nodeSelector`, a través del uso de `labels` 
  ([más información](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/))
* Usando `Affinity` / `AntiAffinity` en la difinición ([más información](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity))


^^^^^^

### Cambios en k8s 1.23

Antes de esta versión, los `DaemonSets` los programaba el `DaemonSet Controller`

En k8s 1.23 se pueden programar usando el _default scheduler_ del cluster.

Para ello, es necesario definir `spec.template.spec.affinity.nodeAffinity` en lugar
de `spec.template.spec.nodeName`.

notes:

Puedes encontrar más información sobre esta funcionalidad en [este enlace](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/#scheduled-by-default-scheduler)

Otros enlaces de interés:
* [Referencia de `spec.template.spec.nodeName` y `spec.template.spec.affinity`](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#scheduling)


¿Porqué se ha introducido este cambio?

Un DaemonSet garantiza que todos los nodos elegibles ejecuten una copia de un Pod. Normalmente, es el planificador de Kubernetes quien determina el nodo donde se ejecuta un Pod. Sin embargo, los pods del DaemonSet son creados y planificados por el mismo controlador del DaemonSet. Esto introduce los siguientes inconvenientes:

* Comportamiento inconsistente de los Pods: Los Pods normales que están esperando 
  a ser creados, se encuentran en estado Pending, pero los pods del DaemonSet no 
pasan por el estado Pending. Esto es confuso.

* Cuando es necesario sacar `Pods` de un nodo y entra en juego 
  el [_Pod priority and pre-emption_](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/), 
  el controlador del DaemonSet tomará la decisiones de planificación sin considerar 
  ni la prioridad ni el _pre-empttion_ de loss `Pods`.

Al utilizar el planificador estándar, estos problemas desaparecen.

^^^^^^

### _`Taints` and `Tolerations`_

| key | effect | version |
| --- | ------ | ------- |
| node.kubernetes.io/not-ready | NoExecute | 1.13+ | 
| .../unreachable | NoExecute | 1.13+ |
| .../disk-pressure | NoSchedule | 1.8+ |
| .../memory-pressure | NoSchedule | 1.8+ |
| .../unschedulable | NoSchedule | 1.12+ |
| .../network-unavailable | NoSchedule | 1.12+ |

notes:

Estos `tolerations` garantizan que los `Pods` que de un `DaemonSet` no se
quitan de un nodo si:
* Se produce una partición de red en un nodo
* Un nodo se empieza a quedar sin espacio en disco
* Un nodo se empieza a quedar sin memoria
* Fallos de red cuando el `DaemonSet` utiliza `HostNetwork`


A los `Pods` gestionados por un `DaemonSet` se les añade automáticamente estos
`tolerations`.

Fuente: [DaemonSets taints and tolerations](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/#taints-and-tolerations)