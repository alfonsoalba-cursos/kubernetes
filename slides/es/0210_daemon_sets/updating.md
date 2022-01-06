### Actualización de un `DaemonSet`

Si los `labels` de un nodo cambian, **el planificador puede eliminar / crear
`Pods` de un `DaemonSet`**

notes:

Si se utiliza `NodeSelector` para definir en qué nodos se debe ejecutar un
`DaemonSet`, y se cambian las etiquetas de los nodos, el planificador
revisará la definición del `DaemonSet` y actuará en consecuencia. Eliminará los
`Pods` de los nodos en los que ya no deban estar y los creará en los nodos en los 
que sí.

^^^^^^

### Actualización de un `DaemonSet`

Al igual que con los `StatefulSets`, es posible realizar _rolling updates_ de
un `DaemonSet`

notes:

[Ejemplo de actualización de un `DaemonSet`](https://kubernetes.io/docs/tasks/manage-daemon/update-daemon-set/)

^^^^^^

### Borrado de un `DaemonSet`

Si indicas el parámetro `--cascade=false` al borrarlo, los `Pods` continuarán 
ejecutándose en los nodos. 

notes:

Si depués de borrar el `DaemonSet`, creas otro con un selector que coincide con los
`Pods` que están huerfanos, el nuevo `DaemonSet`, con la plantilla diferente,
reconocerá a todos los `Pods`. Si alguno de los `Pods` necesita ser reemplazado,
el `DaemonSet` lo reemplazará utilizando la estrategia definida en la 
definición del `DaemonSet`