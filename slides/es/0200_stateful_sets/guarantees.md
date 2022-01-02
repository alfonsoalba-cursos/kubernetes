### ¿Qué nos garantiza un `StatefulSet`?

* Cuando se despliegan los `Pods`, estos se despliegan de forma ordenada, empezando
  por de índice 0 y acabando por el de índice `N-1`
* Cuando se borran los `Pods`, estos se borran en orden inverso. Se empieza por
  el `Pod` con índice `N-1` y se acaba por 0 
* Antes de añadir un `Pod` durante una operación de escalado, todos los `Pods`
  con índice inferior deben estar en estado `Ready`
* Antes de que se borre un `Pod`durante una operación de escalado, todos los `Pods`
  con índice superior deben haber terminado 

note:

Supongamos que estamos creando un `StatefulSet` con tres réplicas con el que crearemos 
en los laboratorios.

Se crea correctamente `web-0` y se se crea correctamente `web-1`. Antes de que se cree
`web-2`, por razones inesperadas. `web-0` falla. En ese caso, `web-2` no se creará hasta
que `web-0` se haya vuelto a crear y esté de nuevo en estado `Ready`.

^^^^^^

### ¿Qué nos garantiza un `StatefulSet`?

⚠️ No utilizar el parámetro `pod.Spec.TerminationGracePeriodSeconds=0`

[Más información aquí](https://kubernetes.io/docs/tasks/run-application/force-delete-stateful-set-pod/)

note:

Se pueden dar ciertas condiciones en las que un `Pod` entre en un estado
`Terminating` o `Unknown`, por ejemplo si un nodo del cluster pasa a no estar 
disponible.

En esta situación, para poder borrar un `Pod` del `api-server` tenemos tres opciones:
* borrar el nodo
* tener pacieciencia o resolver los problemas de conectivicad, que el nodo vuelva 
  a responder y mata el `Pod`
* forzamos el borrado del `Pod`

El comportamiento recomendado es usar una de las dos primeras opciones. Si se fuerza el borrado
del `Pod`, el nombre del `Pod` se borra inmediatamente del `apis-server`, independientemente
de que el `Pod` se haya borrado o no. Si hacemos esto, el controlador del `StatefulSet` puede 
crear un `Pod` de reemplazo con el mismo nombre y acabaríamos con un `Pod` duplicado.

Para forzar el borrado de un `Pod` usar el siguiente comando:

```shell
$ kubectl delete pods <pod> --grace-period=0 --force
```

Dado lo delicado de esta operación, es importante que leas detenidamente la
[documentación oficial respecto a este tema](https://kubernetes.io/docs/tasks/run-application/force-delete-stateful-set-pod/)
para que entiendas los riesgos antes de proceder a forzar el borrado de un `Pod`.