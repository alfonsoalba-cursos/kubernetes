### Autoescalado horizontal

El objeto responsable del autoescalado horizontal de una aplicación es el
[`HorizontalPodAutoscaler`](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/horizontal-pod-autoscaler-v2/)

^^^^^^

### Autoescalado horizontal

Este objeto observa un determinado `Deployment` y aumenta o disminuye el número de réplicas en función de los 
parámetros que se hayan configurado

```yml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```

^^^^^^

### Autoescalado horizontal

✅ Algunos ejemplos de objetos que pueden ser autoescalados por un el `HorizontalPodAutoscaler`:

* `ReplicaSet`
* `Deployment`
* `StatefulSet`

^^^^^^

### Autoescalado horizontal

⛔ Algunos ejemplos de objetos que no pueden ser autoescalados por un el `HorizontalPodAutoscaler`:

* `DaemonSet`
* `CronJob`

^^^^^^

### Autoescalado horizontal

El objeto `HorizontalPodAutoscaler` tiene dos versiones de su API
* Versión 1: sólo permite escalar en base al uso de CPU y memoria
* Versión 2: permite escalar usando _custom metrics_ y _external metrics_

^^^^^^

### Autoescalado horizontal

* `spec.minReplicas` / `spec.maxReplicas`: número mínimo y máximo de réplicas para escalar
* `spec.scaleTargetRef `: objeto sobre el que vamos a actuar
* `spec.behavior`: configuración de cómo queremos que se escale hacia arriba y hacia abajo
* `spec.metrics`: especificación de qué tipo de métricas usar para escalar (CPU, memoria, etc)

notes:

* `spec.maxReplicas` es obligatorio
* `spec.minReplicas` tiene por defecto el valor 1. Si el cluster lo soporta (feature gate `HPAScaleToZero`)
* `spec.behavior`: permite limitar la velocidad a la que se escala o prevenir que se creen
  en muy poco tiempo muchas réplicas estableciendo una ventana de establización
* `spec.metric`: Este campo es un array que permite definir varias métricas (por ejemplo, 
una `ResourceMetric` y un `ExtenalMetric`). Cada una de estas réplicas genera un número
de réplicas final para nuestro `Deployment`. Si se definen varias métricas, se utilizará 
el valor máximo todas ellas.


^^^^^^

### ¿Cómo funciona?

* Bucle de control (_control loop_) que periódicamente comprueba los recursos utilizados
  por los `Pods`
* Calcula el número deseado de réplicas aplicando una fórmula de este estilo:
  ```text
  desiredReplicas = ceil[currentReplicas * ( currentMetricValue / desiredMetricValue )]
  ```
* Aumenta o disminuye el número de réplicas

Más información: [Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)

notes:

Por ejemplo, supongamos que la métrica de CPU dice que estamos usando 200m, 
y el valor deseado para esa métrica es de 100m. Aplicando la fórmula de la diapositiva:

```text
desiredReplicas = ceil[currentReplicas * ( 200m / 100m )]

desiredReplicas = ceil[currentReplicas * 2]
```

Es decir, duplicaremos el número de réplicas.

