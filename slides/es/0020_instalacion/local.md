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
