### Kubernetes y sistemas con estado

¿Qué hacemos si necesitamos desplegar una aplicación con estado?

notes:
Si queremos desplegar una aplicación con estado dentro del cluster, necesitaremos
ser capaces de guardar el estado para que las peticiones puedan acceder a este
estado y actuar en consencia.

Imaginemos un wordpress en el que subimos una imagen y luego queremos mostrarla
en la página ¿cómo persistimos los cambios?

^^^^^^


### ¿Cómo podemos persistir el estado?

`Volumes`

Las aplicaciones que utilizan volúmenes se escalan verticalmente y no de forma horizontal

notes:
La herramienta que nos permitirá persistir el estado son los volúmenes, a los que dedicaremos dos secciones
más adelante dentro del curso.

El hecho de usar volúmenes y tener que almacenar el estado en ellos dificulta e imposibilita
en muchos casos el poder utilizar réplicas para escalar la base de datos.

Imagina que queremos escalar MySQL dentro de kubernetes. No podemos tener múltiples instancias
accediendo a los ficheros en el volumen. Si quisiesemos escalar tendríamos más opciones:
* Ampliar los recursos del nodo en el que se ejecuta MySQL (más procesador, memoria, etc)
* Montar un cluster de MySQL dentro del cluster de Kubernetes

Es decir, para poder escalar aplicaciones con estado dentro de Kubernetes, tendríamos que implementar
arquitecturas y sistemas muy parecidos a los que implemetaríamos sin usar Kubernetes. De este
tema volveremos a hablar cuando hablemos de objeto `Operator`.

