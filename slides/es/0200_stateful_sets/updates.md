### Estrategias de actualización

El campo `.spec.updateStrategy` del `StatefulSet` nos permite configurar la estrategia
de actualización

notes:

Puedes ver la definición de este campo [aquí](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/stateful-set-v1/#StatefulSetSpec).

^^^^^^

### Estrategias de actualización

Posibles valores de `.spec.updateStrategy.type`

* `OnDelete` Para actualizar el `Pod` el usuario deberá borrarlo manualmente
* `RollingUpdate`

notes:

En los laboratorios veremos estas dos políticas de actualización en acción.

^^^^^^

### Estrategias de actualización: `RollingUpdate`

El controlador del `StatefulSet` borrará y recreará cada uno de los `Pods`.

Lo hará empezando por el `Pod` con índice `N-1` y acabará por el de índice 0.

Actualizará un `Pod` cada vez. Esperará a que todos los anteriores estén en estado
`Ready` antes de actualizar el siguiente.

notes:

Si se ha definido el parámetro `minimumReadySeconds`, el controlador esperará esta
cantidad de tiempo antes de marcar los `Pods` como `Ready`.

^^^^^^

### Estrategias de actualización: `RollingUpdate`


Particionado

Si se define el parámetro `.spec.updateStrategy.rollingUpdate.partition`,
todos los `Pods` cuyo índice sea menor que la partición, **no se actualizarán**.

Si el número de replicas es menor o igual que la partición, los cambios que hagamos en 
`spec.template` no se propagarán a los `Pods`

notes:

Este parámetro lo veremos en acción en los laboratorios y nos sirve para
hacer una actualización parcial ydesplegar uno o varios `Pods` con cambios o nuevas versiones
para hacer pruebas.

^^^^^^

### Estrategias de actualización: `RollingUpdate`

Este tipo de actualización puede romperse de forma que requiera una intervención manual.

Si la nueva configuración `.spec.template` crea un `Pod` que nunca llega al estado `Ready`
la actualización quedará en pausa

**No se suficiente con cambiar la configuración a un estado anterior**

Debemos revertir la configuración y **borrar  los `Pods` que se han intentado crear con
la configuración incorrecta**


notes:

Más información sobre esta situación [aquí](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#forced-rollback) y [aquí](https://github.com/kubernetes/kubernetes/issues/67250).