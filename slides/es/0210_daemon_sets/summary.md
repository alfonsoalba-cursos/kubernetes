### Resumen

* Un `DaemonSet` es un objeto que nos garantiza que un `Pod` se ejecute en los
  nodos seleccionados
* Si se crean / destruyen nodos, el `DaemonSet` se encarga de añadir o quitar 
  `Pods` según la especificación
* Aunque existen alternativas, los `DaemonSet` garantizan un `Pod` por nodo, cosa
  que ninguna de las alternativas puede garantizar

^^^^^^

### Más información

* [DaemonSets](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/#taints-and-tolerations)
* [API Reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/daemon-set-v1/)
