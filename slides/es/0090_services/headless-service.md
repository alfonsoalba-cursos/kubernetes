### _Headless Service_

Servicio que no necesita balanceo ni una dirección IP dedicada

notes:

A veces podemos necesitar servicios que no necesitan una dirección IP ni hacer balanceo entre
diferentes `Pods`. Sin embargo, sí queremos _beneficiarnos_ de la parte de 
_service discovery_ que veremos más adelante. En este caso utlizamos este tipo de servicios
para seguir encontrando nuestros `Pods` por su nombre.

Veremos un ejemplo de utilización en los talleres del módulo dedicado a los `StatefulSets`

^^^^^^

### _Headless Service_

Creación: `spec.clusterIP: None`

* No se crea un dirección IP 
* `kube-proxy` no gestiona el servicio
* No hay balanceo de carga
* Si se utilizan selectores: se crean registros en el DNS de kubernetes que apuntan a los `Pods`
* Si no se utilizan selectores, se crean:
  * Registros CNAME si el servicio es de tipo `ExternalName`
  * Registroa A para los para los `Endpoints` con comparten el nombre del `Service`, para los demás tipos de serivios


