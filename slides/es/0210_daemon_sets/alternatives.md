### Alternativas

Scripts de inicialización en los nodos

notes:

Aunque es perfectamente posible ejecutar procesos arrancándolos directamente en un nodo (ej. usando init, upstartd, o systemd), existen numerosas ventajas si se realiza via un DaemonSet:

* Capacidad de monitorizar y gestionar los logs de los procesos del mismo modo que para 
  las aplicaciones.
* Mismo lenguaje y herramientas de configuración (ej. plantillas de Pod, kubectl) 
  tanto para los procesos como para las aplicaciones.
* Los procesos que se ejecutan en contenedores con límitaciones de recursos 
  aumentan el aislamiento entre dichos procesos y el resto de contenedores de aplicaciones. 
  Sin embargo, esto también se podría conseguir ejecutando los procesos en un contenedor en vez de un Pod (ej. arrancarlos directamente via Docker).

^^^^^^

### Alternativas

Pods individuales

notes:

Es posible crear Pods directamente indicando el nodo donde ejecutarse. Sin embargo, 
la ventaja del DaemonSet es que sustituye los Pods que se eliminan o terminan por 
cualquier razón, como en el caso de un fallo del nodo o una intervención que requiera reiniciarlo (por ejemplo, la actualización del kernel). 

Si utilizas `Pods`, tendrás que acordarte de que estos se ejecutan una vez recuperes el nodo.

^^^^^^

### Alternativas


Pods estáticos

notes:

Un [`Pod` estático](https://kubernetes.io/docs/concepts/cluster-administration/static-pod/) 
es un `Pod` que se define dentro de una carpeta determinada en la que
está escuchando el proceso `kubelet`. A diferencia del DaemonSet, los Pods estáticos 
no se pueden gestionar con kubectl o cualquier otro cliente de la API de Kubernetes. 
Los Pods estáticos no dependen del apiserver, lo cual los hace convenientes para 
el arranque inicial del clúster cuando no existe todavía un planificador. Desafortunadamente,
tienen sus limitaciones a la hora de tratarlos como alternativa a un `DaemonSet`.

^^^^^^

### Alternativas

`Deployment` o `StatefulSet` con configuración de Affinity adecuada

notes:

Jugando con la afinidad, `taints` y `tolerations` se puede _implementar_ una funcionalida
similar a un `DaemonSet`. Este enfoque tiene sus limitaciones ya que no se obtienen las 
mismas garantías de un `DaemonSet` de manera automática. Por ejemplo, ni
un `Deployment` ni un `StatefulSet` garantizan que se creen nuevos `Pods` 
si añadimos nodos a un cluster, requieren algún tipo de intervención o automatización
que un `DaemonSet` nos facilita de serie.
