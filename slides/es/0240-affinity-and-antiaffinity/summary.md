### Resumen

Tenemos tres formas de influir en `kube-scheduler` a la hora de decidir dónde se programa un `Pod`
* _Topology constraints_: nos permiten organizar los `Pods` en torno a la 
  topología (zonas, regiones, ets) definida en los nodos mediante el uso de tiquetas 
* `NodeAffinity`: En qué nodo queremos (o preferimos que) se ejecuten los `Pods`
* `PodAffinity`: Dónde poner un `Pod` con respecto a en qué nodos están localizados el resto
  de los `Pods`

^^^^^^

### Más información

* [Pod Scheduling reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#scheduling)
* [Assigning Pods to Nodes](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)
* [Pod Topology Spread Constraints](https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/)
* [NodeAffinity API reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#NodeAffinity)
* [PodAffinity API Reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#PodAffinity)
* [PodAntiAffinity API Reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#PodAntiAffinity)