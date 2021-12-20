### `ExternalDNS`<!-- .element: style="text-transform: none;" -->
* [Qué es `external-dns`](#external-dns-about)
* [Instalación](#external-dns-install)
* [Uso](#external-dns-usage)
* [Soporte](#external-dns-support)


notes:

Una vez hemos desplegado nuestros servicios ¿Cómo accedemos a ellos desde fuera? 
Lo habitual es que utilicemos un registro DNS que apunte o bien al `Service` o 
al `Ingress` (o al `NodePort` si los estamos utilizando). ¿Cómo hacemos para que 
estos registros se creen (o se actualicen) directamente desde Kubernetes? Eso es 
lo que veremos en esta sección.