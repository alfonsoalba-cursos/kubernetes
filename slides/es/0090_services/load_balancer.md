### `LoadBalancer`

Este servicio es una extensión del servicio `NodePort`

Se integra con el proveedor del cluster y levanta un balanceador de carga
de ese proveedor

El balanceador se configura automáticamente para balancear el tráfico a los Pods
del cluster

^^^^^^

### `LoadBalancer`

Depende de cada proveedor

Es el proveedor el que decide qué balanceador de carga utiliza y su configuración

Note:

Los proveedores de servicios en la nube suelen facturar el coste del balanceador
como un servicio a parte del cluster de Kubernetes.

^^^^^^

### `LoadBalancer`

```yaml [6]
apiVersion: v1
kind: Service
metadata:
  name: LB-service
spec:
  type: LoadBalancer
  selector:
    app: LB
  ports:
    - port: 8700
      targetPort: 8080
```