### Selectores

Los objetos de Kubernetes tienen un 
[nombre y un UUID](https://kubernetes.io/docs/concepts/overview/working-with-objects/names/) 
que los identifica de forma unívoca.

Note:

Hemos visto en los ejercicios que hemos realizado con anterioridad
cómo, por ejemplo cuando hemos desplegado nuestros pods, estos recibían un
nombre. Todos los objetos de Kubernetes tienen nombres únicos que los identifican.

^^^^^^

Usando el nombre, podemos seleccionar un objeto.

Usando etiquetas, podemos seleccionar conjuntos de objetos.<!-- .element:  class="fragment" data-fragment-index="2" -->

^^^^^^

### Tipos de selector

* _equality-based_
* _set-based_

Note:

^^^^^^
### _Requisitos_

Un selector consta de uno o más requisitos separados por coma.

**Todos los requisitos se tienen que cumplir** 

^^^^^^

Las comas de los requisitos se comportan como un operador AND (&&) lógico.

**NO EXISTE UN OPERADOR OR**

^^^^^^
### Operadores

* _equality-based_:  `=`, `==` y `!=`
* _set-based_: `In`, `notIn` y `Exists`


^^^^^^

### Uso: `kubectl`

```text
> kubectl get pods -l environment=production,tier=customerX
```

```text
> kubectl get pods -l 'environment in (production), tier in (frontend)'
```

Note:

Ejemplo de un selector que devuelve los mismos resultados expresado de dos maneras 
diferentes:

Primer ejemplo: tipo _equality-based_ 

Segundo ejemplo: tipo _set-based_.

Ambos comandos mostrarán los pods que tengan ambas etiquetas (operación `AND`).

^^^^^^

### Uso: `kubectl`

```text
> kubectl get pods -l '!environment'
```

```text
> kubectl get pods -l 'environment, tier in (customerX, customerY)'
```

Note:

En el primer ejemplo, se está usando el operador `Exists`. Muestra todos los pods en
los que no existe la etiqueta `environment`

En el segundo ejemplo, mostramos todos los pods en los que existe la etiqueta `environment`
y la etiqueta `tier` tiene alguno de los valores indicados.

^^^^^^

### Uso: API

```text
labelSelector=environment%3Dproduction,tier%3DcustomerX
```

```text
labelSelector=environment+in+%28production%2Cqa%29%2Ctier+in+%28customerX%29
```

Note:

Los selectores pueden utilizarse en diferentes puntos de la API REST de kubernetes.

El primer ejemplo muestra cómo quedaría un _query string_ de una petición GET 
con las condiciones `environment=production,tier=customerX` (_equality-based_)

En el segundo ejemplo se muestra el _query string_ con las condiciones
`environment in (production,qa),tier in (customerX)`
(_set-based_)

^^^^^^
### Uso: `yaml`

Dentro de la especificación de Kubernetes, existen múltiples lugares en los que 
se pueden utlizar selectores.



```yaml [9,10]
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  containers:
    - name: app-container
      image: "eu.gcr.io/production-1234/app:v0.1"
  nodeSelector:
    tier: customerX
    os: linux 
```

Note:

Primer ejemplo del uso de selectores. La especificación del objeto `Pod` 
nos permite seleccionar en qué nodo lo queremos desplegar a través de la clave
`nodeSelector` ([ver la especificación aquí](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#scheduling)).

En este caso, el pod se desplegará en nodos cuya etiqueta cumpla con la condición
`tier=customerX,os: linux` 

^^^^^^

```yaml
apiVersion: v1
kind: Deployment
...
    selector:
      matchLabels:
        component: redis
      matchExpressions:
        - {key: tier, operator: In, values: [cache]}
        - {key: environment, operator: NotIn, values: [dev]}
```

Note:

En este segundo ejemplo, vemos el uso conjunto del selector de tipo _equality-based_ 
a través de la clave `matchLabel` y un selector de tipo _set-based_ con múltiples
requisitos.

Todos ellos se combinan de usando `AND`. **Recuerda que no hay `OR`**

En 
[este enlace](https://kubernetes.io/docs/reference/kubernetes-api/common-definitions/label-selector/#LabelSelector) 
se puede ver la especificación del tipo `LabelSelector` de la API de kubernetes.

En estos enlaces podéis ver varios puntos de la API en los que se utilizan selectores:
* [`Deployment`](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/deployment-v1/#DeploymentSpec)
* [`Job`](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/job-v1/#selector)
* [`ReplicaSet`](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/replica-set-v1/#ReplicaSetSpec)
* [`ReplicationController`](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/replication-controller-v1/#ReplicationControllerSpec) **Si miras bien, verás
  que para este objeto, el valor del selector no es un `LabelSelector` sino un
  `map[string][string]`**. Esta es una de las principales diferencias que hay entre
  el `ReplicationController` y el `ReplicaSet`: el segundo permite ambos tipos de
  selectores mientras que el primero sólo permite selectores de tipo _equality-based_
* [`StatefulSet`](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/stateful-set-v1/#StatefulSetSpec)