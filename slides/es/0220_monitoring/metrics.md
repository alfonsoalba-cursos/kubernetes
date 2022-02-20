### Métricas

* Métricas facilitadas por Kubernetes - `/metrics`  
* Métricas de recursos - `metrics.k8s.io`
* Métricas externas - `external.metrics.k8s.io`
* Métricas personalizadas - `custom.metrics.k8s.io`

notes:

Para poder ofrecer un servicio de calidad, es necesario que dispongamos de herramientas
que nos permitan conocer cuál es el estado de nuestro cluster, nuestros `Pods`, servicios,
contenedores, etc. Kubernetes nos facilita [varias APIs](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/) 
para acceder a esta información.

Empezaremos por la primera de ellas.

^^^^^^

### Métricas

Kubernetes facilita, de serie, dos APIs a las que podemos acceder para obtener
métricas sobre el estado de nuestro cluster

* `/metrics`
* El propio proceso `kubelet` que se ejecuta en cada nodo

Estas dos APIs exportan la información en formato compatible con
[Prometheus](https://prometheus.io/).

notes:

En el taller veremos en detalle cómo acceder a estas dos métricas, aunque aquí os adelanto
los comandos. Para acceder a `/metrics`

```shell
$ kubectl get --raw /metrics
```

Para acceder a las métricas de `kubelet`:

```shell
# Dentro de cada nodo
$ curl http://[IP]:10255/metrics
```

Prometheus es un proyecto que forma parte de la Cloud Native Computing Foundation (CNCF),
lo que explica que las métricas sean compatibles con este proyecto.

^^^^^^

### Métricas

Endpoints que expone `kubelet` (a través del puerto 10255)
* /stats/summary (_Summary API_)
* /metrics
* /metrics/resource
* /metrics/cadvisor
* /metrics/probes

^^^^^^

### Métricas

Las métricas, así como qué componentes exponen puntos de acceso a las mismas,
se configuran a nivel del cluster de Kubernetes

Existen varias componentes que pueden exportar métricas:

* kubelet
* kube-controller-manager
* kube-proxy
* kube-apiserver
* kube-scheduler

notes:

En [este enlace](https://kubernetes.io/docs/concepts/cluster-administration/system-metrics/)
tenemos información sobre cómo configurar las métricas del cluster.

En general, a no ser que seamos administradores del cluster, será suficiente con
acceder a las métricas que se muestran en `/metrics`
