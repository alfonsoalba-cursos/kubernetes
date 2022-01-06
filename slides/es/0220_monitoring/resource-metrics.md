### _Resource metrics_

Exponen en una API específica (`metrics.k8s.io`) un subconjunto de las métricas 
con valores agregados.

Es una componente del _core_ de kubernetes dentro de la arquitectura de monitorización
de Kubernetes 

notes:

[_Resource metrics pipeline](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/#resource-metrics-pipeline)



^^^^^^

### _Resource metrics_: `metrics-server`

Aplicación que consulta la API expuesta por `kubelet` en los diferentes nodos del
cluster

Obtiene valores de uso de CPU y memoria y los agrega de forma conveniente

`HorizontalPodAutoscaler` y `VerticalPodAutoscaler` usan esta API para escalar 
el número de réplicas en función del uso de CPU y memoria de nuestros `Pods`

notes:

Como se indica en la propia documentación de `metrics-server`, esta aplicación está
pensada para ser utilizada por `HorizontalPodAutoscaler` y `VerticalPodAutoscaler`.

Si lo que necesitamos es una métrica detallada del uso de los recursos, debemos
utilizar `/metrics/resource`, que lo sirve directamente `kubelet`

^^^^^^

### _Resource metrics_: `metrics-server`

Depende de la instalación del cluster o del proveedor del servicio gestionado,
esta aplicación puede o no estar instalada

En caso de que no lo esté, podemos instalarla nosotros a través de un `Deployment`

notes:

[Repositorio de la aplicación `metrics-server`](https://github.com/kubernetes-sigs/metrics-server).
En este repositorio se indica cómo hacer la instalación en caso de que no dispongamos
de `metrics-server` en nuestro cluster.

En el caso de minikube, como veremos en el taller, se puede instalar a través de un
_Addon_.

^^^^^^

### _Resource metrics_: `kube-state-metrics`

Facilita información sobre diferentes recursos de kubernetes, como por ejemplo
`Pods`, `Deployments`, nodos

Utiliza también `metrics.k8s.io`

^^^^^^

### _Resource metrics_: `kube-state-metrics`


[Repositorio de la aplicación `kube-state-metrics`](https://github.com/kubernetes/kube-state-metrics)


`metrics-server` ofrece métricas agregadas (que lee a de kubelet través del _Summary API_)
para que sean utilizadas por `HorizontalPodAutoscaler`. `kube-state-metrics` ofrece
un conjunto diferente de métricas que reflejan el estado de los recursos de Kubernetes
en ese momento.
