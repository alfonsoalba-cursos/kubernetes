### ¿Porqué se usan `PersinstentVolumes`?

Los volúmenes **acoplan el `Pod` a la tecnología de almacenamiento subyacente**

notes:

El problema que tienen los volúmenes es:

* acoplan los `Pods` y la tecnología que se utiliza para crear el espacio de almacenamiento de las aplicaciones: 
  obligan al desarrollador de la aplicación a conocer los detalles de acceso al volumen: tipo de disco, IP de 
  red del disco, etc
* el espacio de almacenamiento se tiene que crear con antelación, lo que no permite el autoescalado de 
  aplicaciones que los utlicen
* No permiten cambiar nos de un cluster a otro con facilidad: si en un cluster usamos `iscsi` nos cambiamos a un cluster
  que use `fc` (_fiber channel_) nos veremos obligados a modificar todos nuestros `Pods`

^^^^^^

### ¿Porqué se usan `PersinstentVolumes`?

Esto es contrario a lo que hemos visto ahora: todos los objetos de la API que hemos visto

**abstraen a los desarrolladores de la tecnología que se utiliza para conseguir el estado de la aplicación al que
se quiere llegar**

notes:

* `Deployments`: quiero una aplicación con esta imagen y tres réplicas... y Kubernetes se encarga de hacerlo
* `StateFulSets`: quiero una base de datos replicada con 3 réplicas... y Kubernetes se encarga de hacerlo
* `Ingress` e `ingress-controller`: Quiero acceder a mi servicio usando esta URL... y Kubernetes se encarga de hacerlo

^^^^^^

### ¿Porqué se usan `PersinstentVolumes`?

¿Cómo lo resuelve Kubernetes? Añadiendo nuevas capas de abstracción a la API
