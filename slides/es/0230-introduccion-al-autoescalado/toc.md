* [Autoescalado Horizontal](#autoscaling-intro-hpa)
* [Autoescalado Vertical](#autoscaling-intro-vpa)
* [Escalado del cluster](#autoscaling-intro-cluster-scaling)

notes:
Kubernetes dispone de mecanismos para escalar nuestra aplicación y poder adaptarla al tráfico que está recibiendo
en cada momento. En esta sección veremos los mecanismos para escalar horizontalmente (aumentando el número de réplicas)
y verticalmente (aumentando los límites de memoria y CPU de los `Pods`). También permite
escalar el cluster, aumentado y reduciendo el número de nodos.
