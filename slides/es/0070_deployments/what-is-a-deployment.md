* Objeto que proporciona actualizaciones declarativas para nuestros Pods y `ReplicaSets`
* Describimos en un manifiesto (fichero YAML) cuál es el estado que queremos alcanzar en nuestro  
  sistema y el `Deployment Controller` se encarga de llevar el sistema hasta ese estado


^^^^^^

### `Deployment`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: demo-deployment
  name: foo-website
  labels:
    app: foo-website
spec:
  replicas: 3
  selector:
    matchLabels:
      app: foo-website-pod
  template:
    metadata:
      labels:
        app: foo-website-pod
    spec:
      containers:
      - name: foo-website
        image: kubernetescourse/foo-website:1.0
        imagePullPolicy: Always # Let's use this policy se we have some time to run kubectl commands
        ports:
        - containerPort: 80
```

notes:

Esta es la definición de un `Deployment`. Como podemos ver, se parece mucho a la definición
del objeto `ReplicaSet`.

^^^^^^
### ¿Para qué se usa?

* Desplegar nuestros pods 
  [🔗](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#creating-a-deployment)
* Hacer Rollouts 
* Cambiar el estado de nuestros pods (actualizar a una nueva versión) 
  [🔗](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#updating-a-deployment)
* Rollback 
  [🔗](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-back-a-deployment)
* Escalar el sistema ante un aumento de la carga
  [🔗](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#scaling-a-deployment)
* Pausar un despliegue
  [🔗](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pausing-and-resuming-a-deployment)

^^^^^^

### Sobre múltiples actualizaciones simultáneas

* Iniciamos una actualización (por ejemplo de la versión 1.0 a la versión 2.0)
* Cuando la actualización lleva atualizadas 6 de 10 réplicas, actualizamos a la versión 3.0
* Se crea un nuevo `ReplicaSet` 
* En este caso, tendríamos tres `ReplicaSets`
* Los dos viejos se esacalan hasta cero mientras que el nuevo se va eslacando hasta que llega a las 10 réplicas

^^^^^^

### Cambiar el `labelSelector`

No se recomienda hacerlo

**No se puede hacer desde la versión 1 de la API**

notes:

Como se indica en la [documentación de Kubernetes](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#label-selector-updates)
esta práctica está desaconsejada. Intenta planificar bien los nombres de los selectores cuando crees el 
`Deployment`. Si aún así tienes que hacerlo, entiende bien las consecuencias que esto tiene, especialmente
si añades etiquetas a un selector.

^^^^^^

### Cambiar el `labelSelector`

Si añadimos o modificamos un selector:
* Añadir la etiqueta tanto al `labelSelector` como a la plantilla del `Pod`
* Al hacer el cambio se creará un nuevo `ReplicaSet`
* Los `Pods` y `ReplicaSets` ya existentes quedarán huerfanos

^^^^^^

### Cambiar el `labelSelector`

Si se elimina un selector:
* No hace falta cambiar la plantilla
* Los `Pods` y el `ReplicaSet` no quedan huérfanos
* No se elimina la antigua etiqueta de los `Pods`
