### Kubernetes y sistemas sin estado

Pueden escalar horizontalmente

<img src="../../images/stateles_cluster_low_traffic.png" alt="Stateless Cluster Low Traffic" class="r-stretch">

notes:

Imaginemos que tenemos una aplicación web con un frontal sin estado que está
desplegado en nuestro cluster en un `Pod`.

Al tratarse de un sistema sin estado, todos los pods responderán a la aplicación de la misma 
manera, ya tengamos uno, cien o mil.

En esta imagen, supongamos que con un único `Pod` somos capaces de absorver el tráfico
que recibe la aplicación.

^^^^^^

<img src="../../images/stateles_cluster_high_traffic.png" alt="">

notes:

¿Qué ocurre si ese tráfico aumenta? Pues que al tratarse de un `Pod` sin estado,
podemos escalarlo fácilmente. Cualquier `Pod` que añadamos al sistema y reciba
peticiones, las procesaré de la misma manera.
