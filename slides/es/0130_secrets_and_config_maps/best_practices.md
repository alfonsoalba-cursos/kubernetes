### Buenas prácticas

* Utiliza la última versión estable de la API
* Prefiere el formato YAML frente a JSON (más legible)
* Versiona la configuración
* Agrupa objetos relacionados en un mismo fichero
* Recuerda que `kubectl` puede leer todos los ficheros de un directorio
* Mantén la configuración lo más sencilla posible: no redefinas valores por defecto
* No utilices `Pods` si lo puedes evitar. Recuerda que un `Pod` _pelao_
  no se regenerará en caso de que el nodo muera

[Fuente: documentación de Kubernetes](https://kubernetes.io/docs/concepts/configuration/overview/)