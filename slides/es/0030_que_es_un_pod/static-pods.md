### `Pods` estáticos

Son `Pods` gestionados directamente por `kubelet` en un nodo del cluster

Si el `Pod` estático falla, el `kubelet` directamente el encargado de restaurarlo

No pueden ser controlados desde la API de kubernetes

notes:

Si creamos los `Pods` a través de un `Deployment` por ejemplo, estos `Pods`
son controlados po `kube-scheduler`, `kube-apiserver`, los controladores de `kube-controller-manager` 
y el resto de componentes del 
[`control plane` del cluster](https://kubernetes.io/docs/concepts/overview/components/#control-plane-components)

`kubelet` crea un `Pod` espejo en el `api-server`. Con esto se consigue ver los 
`Pods` estáticos desde desde la API de kubernetes, pero no se pueden controlar desde
ella.

^^^^^^

### `Pods` estáticos

El fichero de definición de un `Pod` está en la carpeta `/etc/kubelet.d` del
nodo en el que se van ejecutar.

notes:

Aparte de añadiendo el fichero a la carpeta `/etct/kubelet.d` (ver información 
[aquí](https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/#configuration-files)),
es posible alojar el fichero de definición en un servidor web y configurar `kubelet` para
que se lo descargue cuando se levante (más información [aquí](https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/#pods-created-via-http))

^^^^^^

### `Pods` estáticos

`kubelet` escanea periódicamente los cambios de la carpeta `/etc/kubelet.d` y añade / borra los `Pods` estáticos

^^^^^^

### `Pods` estáticos

Caso de uso principal: ejecutar componentes del `control plane` del cluster.

^^^^^^

### `Pods` estáticos

Más información: [Create static Pods](https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/)