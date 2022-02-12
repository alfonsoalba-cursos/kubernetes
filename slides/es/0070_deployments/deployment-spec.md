### Especificación de `Deployment`

notes:

En esta sección veremos algunos parámetros de configuración de un objeto `Deployment` que no están
disponibles para un `ReplicaSet`.

Más información en 
[Writing a Deployment Spec](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#writing-a-deployment-spec)

^^^^^^

#### `spec.replicas`

Número de réplicas que queremos que tenga nuestro `Deployment`

^^^^^^

#### `spec.selector`

Campo Obligatorio

`Pods` que gestionará este `Deployment`

notes:

Si creas un `Pod` que coincida el selector por cualquier otro procedimienta (crear un `Pod`, otro `ReplicaSet` o `Deployment`, 
un `StatefulSet`) el primer `Deployment` se _quedará_ con los `Pods`.

Kubernetes no facilita una manera de evitar esto; es responsabilidad del usuario evitar que esto ocurra.

^^^^^^

#### `spec.strategy`

* `RollOut`: las réplicas se van reemplazando progresivamente
* `Recreate`: se eliminan los `Pods` existentes antes de crear los nuevos

^^^^^^

#### `spec.strategy`

Disponemos de dos opciones para controlar el `RollOut`

* `.spec.strategy.rollingUpdate.maxUnavailable`: número o procentage de `Pods` que se empezarán eliminando
* `.spec.strategy.rollingUpdate.maxSurge`:  número o porcentaje de `Pods` en que se puede superar el número máximos de réplicas

**No se puede poner ambos valores a cero**

notes:

Si `.spec.strategy.rollingUpdate.maxUnavailable` le asignamos un valor de 30%, cuando la actualización empiece, el `ReplicaSet`
original puede escalarse hasta un 70%, eliminando un 30% de los `Pods`.

Si `.spec.strategy.rollingUpdate.maxSurge` le asignamos un valor de un 30%, El nuevo objeto `ReplicaSet` se puede escalar
inmediatamente un 30%$ por encima del número de réplicas.

Estos valores permiten que se pueda empezar a crear `Pods` en el nuevo `ReplicaSet` sin necesidad de esperar a que los
`Pods` del antiguo `ReplicaSet` se eliminen.

^^^^^^

#### `.spec.progressDeadlineSeconds`

Número de segundos que se tiene que esperar antes de que el `Deployment` reporte un estado _failed progress_

notes:

Hablaremos sobre los estados de los `Pods` en uno de los talleres

^^^^^^

#### `.spec.minReadySeconds`

Cuando se crea un `Pod`, tendremos que esperar este tiempo con el `Pod` _ready_ (sin que fallen sus contenedores) antes de
considerar que el `Pod` está de verdad _ready_

^^^^^^

#### `.spec.revisionHistoryLimit`

Número máximo de `ReplicaSets` que se almacenarán

notes:

Como veremos en los talleres, algunas operaciones de actualización de un `Deployment` crear nuevos objetos `ReplicaSet`,
por ejemplo, cuando cambiamos la imagen de los contenedores.

Este parámetro controla cuántos `ReplicaSet` se guardarán.

^^^^^^

#### `.spec.paused`

Si `Deploymnent` que está pausado, los cambios que se hagan en la especificación de los `Pods` (_Template Pod Spec_)
no activarán una actualización.
