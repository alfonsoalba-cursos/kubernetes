### _Networking_

* A cada `Pod` se le asigna una dirección IP única
* Cada `Pod` consta de su propio [_network namespace_](https://www.man7.org/linux/man-pages/man7/network_namespaces.7.html)
* Dentro de un `Pod`, los contenedores comparten el espacio de puertos. Se pueden comunicar entre sí usando:
  * `localhost` y el número de puerto
  * IPC estándar de Unix, semaforos o memoria compartida

notes:

Si necesitamos comunicarnos con un contenedor que está en otro `Pod`, la forma
más sencilla de hacerlo es a través de TCP/IP.

