### `ReplicaSet`

El objeto de kubernetes responsable de este escalado horizontal es
<a href="https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/" target="_blank" rel="noopener noreferrer"><code>ReplicaSet</code></a>

notes:

Hace unas versiones de Kubernetes que este objeto es el recomendado, usado junto con
el `Deployment`, para gestionar la replicación dentro de un cluster de Kubernetes. 
El anterior objeto, [`ReplicationController`](https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/)
ya no se recomienda y se espera que en futuras versiones acabe siendo abandonado.

^^^^^^
### ¿Cuándo usarlo?

* Se trata de un objeto de bajo nivel
* La manera en la que trabajaremos durante el curso será mediante el objeto `Deployment`
* Se utiliza cuando tu sistema require una lógica de orquestación personalizada o no se necesita actualizar los `Pods` nunca

notes:

El objeto `ReplicaSet` no suele usarse directamente, sino que son los objetos `Deploy` los que se encargan
de abstraer este objeto y gestionar también las actualizaciones que podamos necesitar de los Pods.

Lo vemos aquí para que veamos qué está pasando por debajo cuando despleguemos más adelante nuestros 
Pods en el Kubernetes.

^^^^^^

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: frontend
  labels:
    app: guestbook
    tier: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
    spec:
      containers:
      - name: php-redis
        image: gcr.io/google_samples/gb-frontend:v3
```

notes:

La especificación de un `ReplicaSet` consta de dos partes:
* La plantilla de los `Pods`: especifica cómo serán los `Pods` que se crearán cuando
  sea necesario aumentar las réplicas
* Un selector: indica qué `Pods` estarán gestionados por el `ReplicaSet`

^^^^^^

```yaml [5]
apiVersion: apps/v1
kind: ReplicaSet
metadata: ...
spec:
  replicas: 3
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
    spec:
      containers:
      - name: php-redis
        image: gcr.io/google_samples/gb-frontend:v3
```

notes:

Seleccionamos el número de réplicas que queremos mantener activas en
el cluster

^^^^^^

```yaml [9-16]
apiVersion: apps/v1
kind: ReplicaSet
metadata: ...
spec:
  replicas: 3
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
    spec:
      containers:
      - name: php-redis
        image: gcr.io/google_samples/gb-frontend:v3
```
notes:
En estas líneas especificamos la plantilla para los Pods que va a levantar el 
objeto ReplicaSet. En este caso, va a levantar pods con un solo contenedor
con la imagen `gcr.io/google_samples/gb-frontend:v3`

En el taller que haremos a continuación, usaremos este manifiesto para levantar tres réplicas 
de esta aplicación.
