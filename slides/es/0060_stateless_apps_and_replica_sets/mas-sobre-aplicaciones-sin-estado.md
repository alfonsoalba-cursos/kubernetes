### ¿Como implementar aplicaciones sin estado?

notes: 

Vamos a ver algunas sugerencias para diseñar aplicaciones sin estado
que nos permitan escalar horizontalmente.

No vamos a entrar en detalle sobre este asunto, ya que no es el objetivo del curso,
pero sí que veremos algunos conceptos a tener en cuenta cuando diseñemos la 
arquitectura de nuestras aplicaciones.

^^^^^^

### No almacenar nada en los contendores

* ⛔ Sesiones: guardarlas en la base de datos o en volúmenes
* ⛔ Ficheros: nunca dentro de los contenedores
* ⛔ Logs: extraer los logs de los pods
* ⛔ Configuración

Más información: <a href="https://12factor.net/" target="_blank" rel="noopener noreferrer">The 12 factor App</a>

notes:

* **Sesiones**: por defecto, algunos frameworks guardan las sesiones en ficheros de disco
(por ejemplo Ruby On Rails). Cambiar la configuración para que la carpeta en la que se 
almacenan estén en un volumen o, mejor aún, guardarlas en base de datos.

* **Ficheros**: recuerda que los contenedores son efímeros. Si el proceso
`kubelet` de un nodo destruye un pod y lo vuelve a crear, perderás los ficheros. Podemos
utilizar sistemas de ficheros de red o guardarlos en buckets de nuestro proveedor cloud,
pero nunca en el sistema de ficheros del contenedor.

* **Logs**: los logs son muchas veces son ficheros por lo que de nuevo, no debemos
almacenarlos dentro de los contenedores. El mejor enfoque para los logs es tratarlos
como si fuese un _event stream_: sacamos los logs por la salida estándar y los procesamos
por aplicaciones que leen este _stream_ (por ejemplo `logstash`, `fluentd`, etc) y
lo procesan, almacenan o reenvían a otros sistemas como Splunk/Kibana para su indexación y análisis.
Hagas lo que hagas, no los guardes en el pod/contenedor.

* **Configuración**: La configuración debe injectarse en los pods, no almacenarse dentro del código
fuente. Ya sea a través de variables de entorno o volúmenes, la configuración debe almacenarse en el 
entorno de ejecución (_environment_) no dentro del pod. De esta forma, los cambios en la configuración
pueden procesarse de forma diferente a los cambios en el código.

Os facilito un enlace a la página The twelve-factor app, donde podemos encontrar
más información sobre este tema. Además, una búsqueda en google sobre "stateful apps"
os llevará a un sin fin de recursos sobre el tema.
