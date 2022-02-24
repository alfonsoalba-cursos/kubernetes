### _Topology constraints_

Nos permite controlar cómo queremos distribuir nuestros `Pods` en base a regiones, zonas de disponiblidad o nodos.

Podemos definir nuestras propias topologías y aplicar los criterios que necesitemos

Ayudan a la hora de configurar la alta disponibilidad de nuestras aplicaciones

[Más información](https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/)


^^^^^^

### _Topology constraints_

Esta característica se basa en el uso de etiquetas en los nodos

Etiquetamos los nodos adecuadamente y luego definimos las reglas en la definición de los `Pods`

```yaml
kind: Pod
apiVersion: v1
metadata:
  name: mypod
  labels:
    foo: bar
spec:
  topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: zone
    whenUnsatisfiable: DoNotSchedule
    labelSelector:
      matchLabels:
        foo: bar
  containers:
  - name: pause
    image: k8s.gcr.io/pause:3.1
```

^^^^^^

## _Topology constraints_

* `spec.maxSkew`: controla cómo de irregular es la distribución de los `Pods`
* `spec.topologyKey`: seleccionar todos los nodos que tengan la etiqueta `zone` definida (independientemente del valor)
* `spec.whenUnsatisfiable`: decide qué hacer con el `Pod` si no se pueden satisfacer los requisitos
* `spec.labelSelector`: `Pods` a los que aplicar estar reglas

notes:

* `spec.maxSkew`: cuanto más bajo sea este parámetro, menos diferencia en el número de nodos
  habrá entre las zonas
* `spec.whenUnsatisfiable`: admite los valores:
  * `DoNotSchedule`: no programa el `Pod` 
  * `ScheduleAnyway`: programa el `Pod` de todas formas buscando la manera de minimizar el _skew_
