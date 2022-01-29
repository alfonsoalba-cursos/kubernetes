### Resumen

* Los volúmenes permiten compartir información entre contenedores de un `Pod` y entre diferentes `Pods`
* Existen diferentes tipos de volúmenes
* El tipo de volumen `csi` facilita a los fabricants una interfaz para que puedan desarrollar sus
  propios drivers de almacenamiento
* Para usar volúmenes, los desarrolladores deben saber sobre qué tecnología se crea el volumen para poder
  usarlo
* Para abstraer la tecnología sobre la que se crea el volumen, se utilizan `PersistenVolumes` y
  `PersistentVolumeClaims`

^^^^^^

### Más información

* [Kubernetes Storage](https://kubernetes.io/docs/concepts/storage/)
* [Kubernetes Storage: Types of volumes](https://kubernetes.io/docs/concepts/storage/volumes/#volume-types)