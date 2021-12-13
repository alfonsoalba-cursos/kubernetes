<img src="../../images/service_discovery_how_it_works.png" alt="how service discovery works" class="r-stretch"/>

Note:


_add on_ que se instala en el cluster.

Crea un `Pod` y un `Service` con un servidor DNS y configura `kubelet` para que, 
a su vez configure, los contenedores para usar este servidor DNS. Lo hace inyectando
en los contenedores una configuración predeterminada en el fichero 
`/etc/resolv.conf`

Los `Pods` relacionados con el servicio `kube-dns` implentan el DNS utilizando 
[coreDNS](https://coredns.io/) que es una aplicación escrita en el lenguaje de programación Go.

Cuando `kubelet` gestiona los `Pods`, añade y elimina registros de este 
servidor DNS

^^^^^^



