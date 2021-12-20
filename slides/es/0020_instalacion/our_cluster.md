### Gestionar nuestro cluster
* Instalación de un cluster desde cero (<a href="https://github.com/kelseyhightower/kubernetes-the-hard-way" target="_blank" rel="noopener noreferrer">Kubernetes the hard way</a>)
* Nubes privadas como <a href="https://cloud.redhat.com/learn/topics/kubernetes/" target="_blank" rel="noopener noreferrer">OpenShift</a>
* <a href="https://k3s.io/" target="_blank" rel="noopener noreferrer">k3s</a>

^^^^^^
* 💰 Coste de infraestructura
* 💰 Coste de mantenimiento de infraestructura y mantenimiento de software
  * 🧨 Red
  * 🧨 Sistemas de ficheros
  * 🧨 Incompatibilidades entre componentes, kernels, versiones de kubernetes
  * 🧨 Operators
  * ♻️ Actualizaciones</li>
*🔒 Impacto en la seguridad (aumento de los vectores de ataque)

notes:

Kubernetes no es más que una aplicación que se instala en un cluster ¡Siempre podemos hacerlo nosotros!	

Sin embargo, es necesario tener un buen motivo para hacerlo. Algunos casos de uso:

* Si la entidad ya gestiona clusters de tamaño considerable, será mucho más barato y, además,
    ya se dispondrá de las personas que puedan encargarse de gestionar este tipo de infraestructura.
* Baja latencia: si entre tus requisitos está una baja latencia de comunicación entre nodos, el uso
    de clusters gestionados puede no ser una opción (normalmente utilizan máquinas virtuales con una 
    latencia superior a la de las máquinas físicas)
* Motivos legales: la regulación existente puede impedirte alojar tu cluster en un servicio gestionado
* Necesitas control completo sobre el hardware: los proveedores de servicios gestionados suelen dar bastante
    control sobre el hardware, pero no todo. Si el proyecto require del uso de hardware muy específico o necesitamos
    poder configurarlo de una determinada manera, montar nuestro proppio cluster puede ser una solución.

¿Por qué? Porque la gestión de un cluster de Kubernetes implica todo lo expuesto en esta diapositiva.
No se recomienda gestionar un cluster a no ser que el equipo sea capaz de resolver incidencias a distintos
niveles del stack, desde la gestión del hardware, gestión de redes y administración del sistema operativo 
a bajo nivel hasta la administración del propio Kubernetes.

^^^^^^
### 🛠️ Herramientas

* <a href="https://kubespray.io/#/" target="_blank" rel="noopener noreferrer">kubespray</a>
* <a href="https://rancher.com/docs/rke/latest/en/" target="_blank" rel="noopener noreferrer">rke</a>
* <a href="https://github.com/kinvolk/bootkube" target="_blank" rel="noopener noreferrer"></a>bootkube

notes: 
Algunas herramientas que pueden ayudarnos para instalar nuestro propio cluster.

No usaremos ninguna en el curso. Utilizaremos un servicio gestionado.

* kubespray: basado en Ansible, permite instalar un cluster en máquinas virtuales y físicas
* rke: se ejecuta sobre contenedores de docker
* bootkube: ejecuta el `control-plane` de kubernetes dentro de kubernetes (api-server, 
    controller-manager y scheduler). Ventaja: parte de kubernetes se puede gestionar usando
    el comando `kubectl`, como si fuesen pods

^^^^^^
### k3s
						
* _lightweigth kubernetes_
* Diseñado para iOt y Edge computing
* Un solo ejecutable (&lt;50MB) que contiene la implementación de kubernetes

notes:
Una herramienta muy interesante que me gustaría mencionar es k3s. 

* Distribución certificada
* Listo para producción
* Pensado para máquinas con recursos limitados
* Optimizado para ARM64 y ARMv7
* ¿Cómo consiguen meter kubernetes en 50MB? quitando funcionalidades en deshuso, en beta o en alfa,

¡Es algo que puedes montar en tu casa con tres RaspberryPi!

Ideal para trastear con cómo funciona un cluster de kubernetes, pero ¡cuidad! que mis palabras
no te confundan: es un proyecto pensado para desplegar en producción.
