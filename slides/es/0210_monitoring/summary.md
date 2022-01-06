### Resumen

* Tres tipos de métricas: Recursos, externas y personalizadas
* `metrics-server`: ofrece métricas agregadas que utilizaremos más adelante
  pare el autoescalado horizontal de nuestra aplicación
* Métricas externas: permiten leer métricas de terceros y hacerlas disponibles
  en nuestro cluster (Datadog, NewRelic...)
* Métricas personalizadas: nos permiten crear nuestras propias métricas

^^^^^^

### Más información

* [Tools for Monitoring Resources](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/)
* [Resource metrics pipeline](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-metrics-pipeline/#summary-api-source)
* [Metrics For Kubernetes System Components](https://kubernetes.io/docs/concepts/cluster-administration/system-metrics/)
* [New Relic external metrics](https://docs.newrelic.com/docs/kubernetes-pixie/kubernetes-integration/newrelic-hpa-metrics-adapter/newrelic-metrics-adapter/) 
* [DataDog external metrics](https://docs.datadoghq.com/agent/cluster_agent/external_metrics/?tab=helm)
* [Building your own customo metrics api](https://medium.com/swlh/building-your-own-custom-metrics-api-for-kubernetes-horizontal-pod-autoscaler-277473dea2c1)

