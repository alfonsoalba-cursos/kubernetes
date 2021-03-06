### `Ingress`

* Da a los `Services` dentro del cluster **rutas HTTP/HTTPS para acceder a ellos**.

<img src="../../images/ingress.png" class="r-stretch" alt="Ingress">

Note:

S贸lo funciona con rutas HTTP/HTTPS.  Si necesitamos hacer lo mismo con otros servicios, 
por ejemplo Redis, tendremos que usar `Services` de tipo `NodePort` o balanceadores 
de carga externos que permitan el balanceo TCP/UDP.

^^^^^^

### Motivaci贸n

`LoadBalancer`: s贸lo uno por servicio 

馃捀馃捀馃捀馃捀馃捀

Note:

Los balanceadores de carga que hemos visto en las secciones anteriores no permiten
el enrutamiento entre varios `Services`.

Es decir: 1 `Service` = 1 `Load Balancer`

El coste medio de un balanceador de carga est谩 en torno a los 15-20$ al mes.
Si tienes una aplicaci贸n con 20 `Services` accesible desde el exterior, estamos hablando de 
400$ al mes (4800$ al a帽o) s贸lo para poder enviar tr谩fico a tu cluster.

^^^^^^

### Casos de uso

* Balanceo de tr谩fico HTTP/HTTPS
* Terminaci贸n SSL/TLS
* _Named-Based virtual hosting_


^^^^^^

### Requisitos

_ingress controller_ + `Ingress`

([Ver controladores disponibles](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/))

Note:

El objeto `Ingress` es el que define las reglas que _reparten_ el tr谩fico. 
El _ingress controller_ es el que recibe el tr谩fico y las ejecuta.

Existen controladores para nginx, haproxy, Envoy, Traekik... En el enlace
de la diapositiva dispones de una lista a todos ellos.

