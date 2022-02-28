### ¿Cómo podemos comunicarnos con los `Pods` de un `DaemonSet`

_*Push*_

En lugar de comunicarnos con el `Pod` para extraer la información, este 
envía la información a otro servicio, como por ejemplo una base de datos.

notes:

Ejemplo: Filebeat de Elasticsearch

En este caso, no hace falta facilitar medios para comunicarnos con el `Pod`

^^^^^^

`NodeIP` y uso de un puerto conocido ('HostPort')

notes:

Los `Pods` pueden utilizar un `HostPort` accesible a través de la IP del nodo 
para que podamos conectarnos a ellos.

^^^^^^

DNS + `Headless Service`

notes:

Al crear un `Headless Service` se creará una serie de `endpoints` (uno por cada `Pod` deplegado
en un nodo). Podemos obtener estos `endpoints` consultando la API para conectarnos a los `Pods`.

También podemos obtener múltiples registros A haciendo la consulta a través del DNS del cluster.

^^^^^^

`Service`

notes:

Si definimos un servicio y lo utilizamos para acceder a un `DaemonSet`, podemos conectarnos
a un nodo aleatrio (como ocurre con cualquier otro servicio)