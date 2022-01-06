### Instalación en local
* <a href="https://minikube.sigs.k8s.io/docs/" target="_blank" rel="noopener noreferrer">Minikube</a>
* <a href="https://k3d.io/" target="_blank" rel="noopener noreferrer">k3d</a>
* <a href="https://kind.sigs.k8s.io/" target="_blank" rel="noopener noreferrer">KinD</a>
</ul>

notes:

Dentro de los flujos de trabajo de un equipo de desarrollo, el disponer de un
cluster local de Kubernetes es fundamental para poder hacer pruebas. A no 
ser que el equipo trabaje con herramientas de desarrollo que se alojen únicamente en 
la nube, el uso de un kubernetes en local facilitará a los miembros de nuestro equipo
un mecanismo para realizar tareas como:

* probar la aplicación
* probar nuevas herramientas
* probar procesos de despliegue e intregración contínua
    desde su propia máquina.

^^^^^^

#### Minikube

Es la aplicación _oficial_ a la que da soporte kubernetes.

Es la que utilizaremos durante el curso

Ofrece soporte para Hyper-V, VirtualBox, Hyperkit, VMWare.

Incluye un driver para docker

notes:

El driver para docker utiliza contenedores para levantar todas las piezas
del cluster en lugar de levantar una máquina virtual.

^^^^^^

#### k3d

Envoltorio para ejecutar [k3s](https://github.com/rancher/k3s) usando contenedores de docker.

note:

k3s es una distribución ligera de Kubernetes pensada para poder desplegarse en 
entorno IoT. Luego volveremos a hablar de ella.

^^^^^^

### KinD

Ejecutar nodos de Kubernes dentro de contenedores de docker

Se diseñó para probar Kubernetes, pero se puede utilizar para hacer desarrollo local.

note:

Muchas de las herramientas modernas utilizan ya el enfoque de implementar Kubernetes
a través de contenedores de docker ¡Hasta minikube se ha subido a ese tren!

