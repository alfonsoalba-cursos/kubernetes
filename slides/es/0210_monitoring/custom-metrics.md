### `custom.metrics.k8s.io`

A través de este _endpoint_ podemos definir nuestras propias métricas

[Ejemplo](https://medium.com/swlh/building-your-own-custom-metrics-api-for-kubernetes-horizontal-pod-autoscaler-277473dea2c1)

notes:

En el ejemplo que os facilito, veréis que el proceso para crear métricas personalizadas
no es complicado, aunque si laborioso una vez conoces todos los pequeños sitios en los que
te puedes quedar atascado.

^^^^^^

### `custom.metrics.k8s.io`

Una aplicación que puede resultar útil en estos casos es [KEDA](https://keda.sh/)

> KEDA is a Kubernetes-based Event Driven Autoscaler. 
> With KEDA, you can drive the scaling of any container in Kubernetes based 
> on the number of events needing to be processed.