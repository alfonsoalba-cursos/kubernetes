### Identidad de los `Pods`

Dentro de un `StatefulSet` cada `Pod` tiene una identidad con consta de

* índice: número entero consecutivo (empezando por el cero)
* ID de red
* epacio de almacenamiento

^^^^^^

### Identidad de los `Pods`

**Índice**

Para un `StatefulSet` con N réplicas, cada `Pod` tendrá un índice que empezará en
0 y llegará hasta `N-1`

^^^^^^

### Identidad de los `Pods`

**ID de red**

El `hostname` de cada `Pod` será siempre el mismo seguirá el patrón:

`$(nombre statefulset)-$(indice)

En el caso anterior, los `Pods` se llamarán: `web-0`, `web-1` y `web-2`

^^^^^^

### Identidad de los `Pods`

**ID de red**

Al utilizar un `Headless Service` para gestionar los `Pods`, estos serán encontrables
a través del nombre de dominio:

`<hostname>.<nombre headless service>.<namespace>.svc.<cluster name>`

Por ejemplo:

`web-0.nginx.default.svc.cluster.local`

note:

Depende de cómo esté configurado el servicio DNS en el cluster, puede existir un 
retraso entre el momento en el que el `Pod` se crea y el momento en el que este queda
accesible a través de su nombre DNS. Este comportamiento ocurre cuando otros clientes
dentro del cluster preguntan al DNS por el hostname de un `Pod` antes de que este se cree.
En esos casos, el servicio DNS cacheará la respuesta fallida durante (típicamente) 30 segundos
antes de dar la respuesta correcta.

Si necesitamos acceder a los `Pods` muy rápido después de su creación tendríamos dos opciones:
* Usar la API de kubernetes (por ejemplo, el comando `kubectl`) en lugar de realizar
  búsquedas DNS
* Reconfigurar `CoreDNS` para que el tiempo de cache sea inferior a 30 segundos

^^^^^^

### Identidad de los `Pods`

**Almacenamiento persistente estable**

Los volúmenes montados en un `Pod` de un `StatefulSet` serán siempre los mismos.

Se garantiza que el espacio de almacenamiento será el mismo después de que un `Pod`
haya sido reprogramado.

note:

Esto lo veremos en los laboratorios, donde se entenderá muy facilmente.

Recuerda que el espacio de almacenamiento deberá borrarse manualmente después
de borrar el `StatefulSet`

^^^^^^

### Identidad de los `Pods`

**Etiqueta `pod-name`**

Cuando se crea un `Pod` de un `StetefulSet`, el controlador le añade una etiqueta

`statefulset.kubernetes.io/pod-name`

cuyo valor es el nombre del `Pod`

Útil para configurar un `Service` vinculado a un `Pod` específico dentro del
`StatefulSet`

