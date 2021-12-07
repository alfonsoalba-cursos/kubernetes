### Estados (_conditions_)

Nos indican el estado en el que está un `Pod`

Un `Pod` tiene varios estados a la vez

Note:

En la definición de [`PodState`](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#PodStatus)
vemos que `conditions` es un array de objetos `PodCondition`.

^^^^^^

### Tipos de estados

| `condition.type` | `condition.status` |
| ---- | ----------- |
| `PodScheduled`| `True` cuando el `Pod`ha quedado programado para ser asignado a un nodo |
| `Initialized` | `True` cuando los contenedores de incialización han completado su ejecución correctamente |

^^^^^^

| `condition.type` | `condition.status` |
| ---- | ----------- |
| `ContainersReady` | `True` cuando todos los contendores del `Pod` se han inicializado correctamente y están listos (_ready_) |
| `Ready`| El `Pod` está listo para recibir peticiones |   

Note:

Que el estado `ContainersReady` está a `True` es condición necesaria pero no suficiente
para que el estado del `Pod` sea `Ready`. Necesitamos que, además, las `readinessGates`
también esté listas. 

Las `readinessGates` son condiciones personalizadas que podemos añadir a nuestro `Pod`.
Una vez definidas, algún agente externo a nuestro `Pod` (por ejemplo un controlador
de Kubernetes) puede cambiar el estado de esta condición de `False` a `True` o viceversa,
haciendo así que cambie el estado del contenedor (y con él, el estado del `Pod`).


Vídeo acerca de las `readinessGates`: https://www.youtube.com/watch?v=Vw9GmSeomFg

#### Ejemplo de uso
_Suppose you have a GraphQL application running on two pods, and you want to restart the deployment. Load balancers expose these pods to the outside world, so they need to be registered in the load balancer target group. When you execute #kubectl rollout restart deploy/graphql to restart, the new pods will start the cycle until they are in a running state. When this happens, Kubernetes will start terminating old pods, irrespective of whether the new pods are registered in the load balancers and are ready to send and receive the traffic._

Utilizando una condición adicional en nuestros `Pods` que tenga el valor `False` por defecto 
cuando se crea un `Pod`, podemos hacer que nuestros `Pods` no aparezcan como listos
hasta que un controlador externo verifique en el balanceador de carga que los nuevos
`Pods` están ya correctamente enrutados. Una vez lo detecta, cambia el estado de esta
condición personalizada a `True`, los nuevos `Pods` pasan, ahora sí, a estar listos,
y se pueden elminar ya los viejos.

Fuentes: 
* [Achieving High Availability Through Health Probes and Readiness Gates](https://www.contentstack.com/blog/tech-talk/kubernetes-availability-through-health-probes-and-readiness-gates/)
* [Using pod conditions / pod readiness gates](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v1.1/guide/ingress/pod-conditions/)

^^^^^^

### Tipos de estados

`PodScheduled` y `Initialized` comienzan con siendo `False`

Una vez pasan a `True`, permanecen en ese estado durante la vida del `Pod`

^^^^^^

### Tipos de estados

Por el contrario, `Ready` y `ContainersReady` pueden cambiar durante la vida del 
`Pod`

Note:

Si una de las comprobaciones de estado indica que uno de los contenedores 
del `Pod` no responde y `kubelet` decide reiniciarlo, `ContainerReady` y `Ready`
pasarán a valer `False`