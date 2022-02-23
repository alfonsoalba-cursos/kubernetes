### Escalado vertical

El objeto responsable del autoescalado vertical de los `Pods` es el
[`VerticalPodAutoscaler`](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler)

El escalado vertical permite ajustar los límites de CPU y memoria de los `Pods`
de manera automática

^^^^^^

### Escalado vertical

[Require instalación](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler#installation). Este 
objeto no tiene porqué estar instalado en el cluster por defecto

```yaml
apiVersion: "autoscaling.k8s.io/v1"
kind: VerticalPodAutoscaler
metadata:
  name: mydeployment-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind: Deployment
    name: mydeployment
  resourcePolicy:
    containerPolicies:
      - containerName: '*'
        minAllowed:
          cpu: 100m
          memory: 50Mi
        maxAllowed:
          cpu: 1
          memory: 500Mi
        controlledResources: ["cpu", "memory"]
```

^^^^^^

### Escalado vertical

El objeto `VerticalPodAutoscaler` intenta mantener los límites de memoria y CPU de 
los `Pods` proporcionales al ratio `límite/peticiones` (`limit/requests`)


