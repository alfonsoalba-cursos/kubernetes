* Objeto que proporciona actualizaciones declarativas para nuestros Pods y `ReplicaSets`
* Describimos en un manifiesto (fichero YAML) cuál es el estado que queremos alcanzar en nuestro  
  sistema y el `Deployment Controller` se encarga de llevar el sistema hasta ese estado
------

### ¿Para qué se usa?

* Desplegar nuestros pods 
  [🔗](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#creating-a-deployment)
* Hacer Rollouts 
* Cambiar el estado de nuestros pods (actualizar a una nueva versión) 
  [🔗](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#updating-a-deployment)
* Rollback 
  [🔗](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-back-a-deployment)
* Escalar el sistema ante un aumento de la carga
  [🔗](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#scaling-a-deployment)
* Pausar un despliegue
  [🔗](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pausing-and-resuming-a-deployment)


------

Hay poco más que decir 🤷

Lo mejor es verlo en acción con ejemplos.