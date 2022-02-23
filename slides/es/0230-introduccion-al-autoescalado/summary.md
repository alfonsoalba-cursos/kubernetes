### Resumen

* El autoescalado horizontal se hace a través del objeto `HorizontalPodAutoScaler`
* Este objeto monitoriza un `Deployment` y/o un `ReplicaSet` y aumenta o disminuye el
  número de réplicas
* El escalado vertical permite ampliar los recursos del cluster, bien aumentando los nodos,
  bien aumentando los recursos asignados a estos nodos
* El escalado vertical depende de cada proveedor

^^^^^^

### Más información

* [Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
* [`HorizontalPodAutoscaler` API Reference (Version 2)](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/horizontal-pod-autoscaler-v2/)
* [`HorizontalPodAutoscaler` API Reference (Version 1)](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/horizontal-pod-autoscaler-v1/)
* [`VerticalPodAutoscaler`](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler)
* [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler)