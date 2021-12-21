### ¿Qué es Kubernetes?

Es un orquestador de contenedores

🤔

^^^^^^

Tenemos la siguiente aplicación

* Monolito que muestra la interfaz gráfica y procesa las peticiones del usuario
* API
* Base de datos relacionar para almecenar la información
* Cache 

^^^^^^

Después de haber hecho el [curso de Docker](https://docker-course.alfonsoalba.com)
¿Qué contenedores tendríamos?

* Frontend
* API
* nginx como _reverse proxy_
* Redis
* MySQL

^^^^^^

Queremos poner todos estos contenedores a trabajar juntos ¿a qué retos nos enfrentamos?

^^^^^^

#### Inteacción entre contenedores

¿Qué dirección IP les asignamos?

¿Cómo pueden _verse_ entre ellos de forma automática?

`docker compose`<!-- .element: class="fragment" data-fragment-index="1" -->

notes:

Este problema lo resolvimos en su momento con `docker compose`


^^^^^^

#### Escalabilidad

¿Cómo conseguimos que a medida que aumente la demanda nuestra aplicación
tenga los recursos necesarios para absorverla?

¿Cómo balanceamos la carga entre los contenedores?

¿Cómo hacemos que esto ocurra de forma automática?

^^^^^^

#### Gestión de recursos y contenedores

¿Cómo podemos gestionar cientos o miles de contenedores sin volvernos locos?

¿Cómo podemos asignar los contenedores a los nodos adecuados? Por ejemplo: una parte
de la API utiliza GPUs ¿Cómo conseguimos que esos contenedores acaben en el nodo adecuado?

¿Cómo limitamos CPU, GPU, emoria o disco?

^^^^^^

#### Almacenamiento y red

¿Cómo gestionamos una red con cientos o miles de interfaces de red virtuales que estarán
en máquinas diferentes?

¿Cómo podemos dar a estos contenedores espacio de disco persistente para poder
almacenar el estado de nuestra aplicación?

^^^^^^

#### Alta disponibilidad

¿Qué ocurre si un contenedor deja de responder?

¿Qué ocurre si un nodo entero se pierde?

^^^^^^

#### Monitorización

¿Cómo podemos saber qué está pasando en un sistema tan complejo como este?

¿Cuántos contenedores tenemos y en qué estado están?


^^^^^^

🦹‍♀️

Kubernetes nos da las herramientas para responder a todas estas preguntas.

A todas estas preguntas daremos respuesta durante el curso.

------

### Límites

En la versión 1.23, kubernetes soporta hasta 5.000 nodos

* < 110 `Pods` por nodo
* < 5000 nodos
* < 150.000 `Pods`
* < 300.000 contenedores

------

### Separación de roles

Tenemos dos roles muy bien diferenciados:

* Administrador de toda esta infraestructura
* Usuario de esta infraestructura

notes:

En este curso nos centraremos en el segundo rol.

Para los usuarios, la gestión de la infraestructura es transparente. **No hace falta
saber cómo administrar un cluster para poder usarlo.**

Aún así, entender cómo funciona un cluster por debajo, nos ayudará usarlo de forma más 
efectiva y entender mejor algunos conceptos y recursos que usaremos más adelante.


------
<!-- .element: id="introduction-other-orchestrators" -->
### Otros orquestadores

* [Docker Swarm](https://docs.docker.com/engine/swarm/)
* [Nomad](https://www.nomadproject.io/) (Hashicorp)
* [Apache Mesos](https://mesos.apache.org/)

notes:

* Mesos es una aplicación para gestionar clusters y distribuir tareas para ejecutarlas
  en los nodos del cluster. Estas tareas pueden ejecutarse o no usando contenedores.
  Mesos dispone de un framework (Marathon) que facilita la tarea de gestionar las tareas
  que se ejecutan en contenedores.

* Nomad busca una arquitectura más sencilla (tanto el cliente como el servidor son un 
  binario ejecutable) y soporta, además de contenedores, maquinas virtuales y máquinas
  físicas. Según su domentación, son capaces de gestionar clusters de más de 
  10.000 nodos y con hasta [dos millones de contenedores](https://www.hashicorp.com/c2m).