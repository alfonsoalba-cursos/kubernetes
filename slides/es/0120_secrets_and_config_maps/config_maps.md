### `ConfigMap`

Objeto de la API de kubernetes

Almacena información **no sensible**

Forma de almacenar la información: parejas clave/valor

Los `Pods` pueden acceder a la información almacenada en `ConfigMaps`

**Información no secreta ni encriptada**

Note:

Este objeto no provee ningún tipo de privacidad ni de encriptación para las parejas
clave/valor que almacena.

^^^^^^

### ¿Por qué?

* Desacoplar configuración de código
* Tamaño máximo 1MB

Note:

Los `ConfigMaps` se crearon con objeto de separar el código de la configuración.
Objetivo: que nuestras imágenes con contengan configuración para que sean lo más
portables posible.

Si almacenamos los datos de conexión a la base de datos (nombre del servidor y puerto) 
dentro de nuestra imagen, necesitaríamos crear una imagen diferente para cada 
una de las máquinas en las que esa imagen se fuese a ejecutar. O, incluso peor, 
que todas las máquinas compartiesen la misma configuración. 

Si configuramos nuestra imagen para que lea el servidor y el puerto de conexión
de una variable de entorno o de un fichero, habremos conseguido que una misma
imagen se pueda usar en distintos entornos, utilizando diferentes datos de configuración.

El uso de `ConfigMaps` permite inyectar esta información al `Pod` y que los contenedores
que se ejecutan dentro del `Pod` puedan acceder a ella.

#### Tamaño máximo

1MB. Si necesitamos almacenar configuración que ocupe más espacio, deberemos utilizar
un volumen, una base de datos aparte, un servidor de ficheros o un servidor de configuración.

^^^^^^

### El objeto `ConfigMap`

Puede almacenar dos tipos de información

* `data`: secuencias de caracteres UTF-8
* `binaryData`: cualquier cosa que no sea UTF-8 o ASCII 

El nombre del objeto tiene que se un nombre DNS de subdominio válido

Caracteres permitidos para la clave: alfanuméricos, `-`, `_` y `.`

^^^^^^

### `ConfigMap`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: game-demo

binaryData:
   ini-file: dGhpcyBpcyBhIGJhc2U2NCBlbmNvZGVkIHN0cmluZw==

data:
  player_initial_lives: "3"
  ui_properties_file_name: "user-interface.properties"

  game.properties: |
    enemy.types=aliens,monsters
    player.maximum-lives=5    
  user-interface.properties: |
    color.good=purple
    color.bad=yellow
    allow.textmode=true   
```

Note:

En este ejemplo tenemos varias formas de almacenar información dentro del
`ConfigMap`
* Valores sencillos como cadenas de texto o números
* Valores multilínea que representan un fragmento de una configuración. A estos
  valores podremos acceder como si fuesen un fichero
* Valores binarios codificados usando base64

^^^^^^

### Uso

* Pasarse al contenedor como argumentos del comando de inicialización
* Como variables de entorno para nuestro contenedor
* Escribir código en nuestro `Pod` que se conecta a la API de kubernetes y
  lee el `ConfigMap`

Note:

En los tres primeros métodos, `kubelet` usa el objeto `ConfigMap` durante el proceso
de inicialización y arranque de los contenedores del `Pod`.

El último método es un poco más exótico e implica tener que escribir código nosotros.
Tiene las siguientes ventajas ya que al usar directamente la API de Kubernetes:
* Podemos suscribirnos a los cambios que ocurran en la configuración y reaccionar
  ante ellos
* Podemos acceder a `ConfigMaps` que estén en un espacio de nombres diferente

^^^^^^

### Uso: como variables de entorno

```yaml [10-22]
apiVersion: v1
kind: Pod
metadata:
  name: configmap-demo-pod
spec:
  containers:
    - name: demo
      image: alpine
      command: ["sleep", "3600"]
      env:
        # Nombre de la variable de entorno
        - name: PLAYER_INITIAL_LIVES 
          valueFrom:
            configMapKeyRef:
              name: game-demo           # Nombre del objeto ConfigMap
              key: player_initial_lives # Clave que contiene el valor que se al
                                        # almacenará en la variable de entorno
        - name: UI_PROPERTIES_FILE_NAME
          valueFrom:
            configMapKeyRef:
              name: game-demo
              key: ui_properties_file_name
```

^^^^^^

### Uso: argumento del contenedor

```yaml [9-20]
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: [ "/bin/echo", "$(SPECIAL_LEVEL_KEY) $(SPECIAL_TYPE_KEY)" ]
      env:
        - name: SPECIAL_LEVEL_KEY
          valueFrom:
            configMapKeyRef:
              name: special-config
              key: SPECIAL_LEVEL
        - name: SPECIAL_TYPE_KEY
          valueFrom:
            configMapKeyRef:
              name: special-config
              key: SPECIAL_TYPE
  restartPolicy: Never
```

Note:

Este es, en realidad, un ejemplo de cómo se podrían usar variables de entorno

^^^^^^

### Uso: volúmenes

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-demo-pod
spec:
  containers:
    - name: demo
      image: alpine
      command: ["sleep", "3600"]
      volumeMounts:
      - name: config # Nombre del volumen definido abajo
        mountPath: "/config"
        readOnly: true
  volumes:
    - name: config # Nombre del volumen
      configMap:
        name: game-demo # Nombre del objeto configMap a utilizar
        # Claves del configMap que se montarán como ficheros
        items:
        - key: "game.properties"
          path: "game.properties"
        - key: "user-interface.properties"
          path: "user-interface.properties"
```

Note:

Dentro del contenedor, nuestra aplicación podrá acceder a dos ficheros de configuración:
* `/config/game.properties`
* `/config/user-interface.properties`

Si se omite la definición de `items`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-demo-pod
spec:
  containers:
    - name: demo
      image: alpine
      command: ["sleep", "3600"]
      volumeMounts:
      - name: config # Nombre del volumen definido abajo
        mountPath: "/config"
        readOnly: true
  volumes:
    - name: config # Nombre del volumen
      configMap:
        name: game-demo # Nombre del objeto configMap a utilizar
```

Todas las claves definidas dentro del objeto `configMap` se montarán como un fichero.
En este caso, tendríamos 5 ficheros, uno por cada clave definida en el `configMap`

^^^^^^
### Propagación de cambios

¿Qué pasa si cambia la configuración?

Note:

El objeto `ConfigMap` que tenemos almacenado en la API se puede modificar, como
tantos otros objetos de Kubernetes. Por ejemplo, nuestros `Deployments`.

¿Qué ocurre con nuestra aplicación cuando esto pasa?

^^^^^^

### Propagación de cambios

Si usamos el `ConfigMap` dentro del `Pod` como variable de entorno:

Reiniciar el `Pod`

Note:

En este caso, los cambios no se progagan. Es necesario reiniciar el `Pod`

^^^^^^

### Propagación de cambios

Si usamos el `ConfigMap` dentro del `Pod` como un volumen:

Los cambios se propagan

Note:

Eventualmente, los cambios aparecerán en nuestros volúmenes. ¿Cuánto tardan en propagarse?
Depende de cómo esté configurado nuestro cluster

> When a ConfigMap currently consumed in a volume is updated, projected keys are eventually
  updated as well. The kubelet checks whether the mounted ConfigMap is fresh on every periodic 
  sync. However, the kubelet uses its local cache for getting the current value of the ConfigMap. 
  The type of the cache is configurable using the ConfigMapAndSecretChangeDetectionStrategy field 
  in the KubeletConfiguration struct. A ConfigMap can be either propagated by watch (default), 
  ttl-based, or by redirecting all requests directly to the API server. As a result, the total 
  delay from the moment when the ConfigMap is updated to the moment when new keys are projected 
  to the Pod can be as long as the kubelet sync period + cache propagation delay, where the cache 
  propagation delay depends on the chosen cache type (it equals to watch propagation delay, ttl 
  of cache, or zero correspondingly).

_Fuente: [documentación Kubernetes](https://kubernetes.io/docs/concepts/configuration/configmap/#mounted-configmaps-are-updated-automatically)_

^^^^^^

### Propagación de cambios

¿Qué hacer cuando se propaga la configuración?

Dependerá de nuestra aplicación
* PHP se entera _en el momento_
* Rails: requiere un nuevo despliegue

Note:

La forma en la que reaccionamos a los cambios en la configuración dependerá de
la tecnología que estemos utilizando.

[Aquí](https://dev.to/frosnerd/automatic-configuration-reloading-in-java-applications-on-kubernetes-1li7) 
tenemos un ejemplo de una aplicación en Java que recarga la configuración
de forma periódica. [Aquí](https://medium.com/@fbeltrao/automatically-reload-configuration-changes-based-on-kubernetes-config-maps-in-a-net-d956f8c8399a)
otro ejemplo en `.NET`.

Un artículo don información interesante sobre este tema: 
[Auto-Reload from ConfigMap](https://dev.to/frosnerd/automatic-configuration-reloading-in-java-applications-on-kubernetes-1li7)

Hay aplicaciones que se recargan automáticamente si el fichero de configuración cambia.

^^^^^^

### _Immutable `ConfigMaps`_

Introducidos en la versión 1.21

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  ...
data:
  ...
immutable: true
```

^^^^^^

* No se pueden cambiar: solo se pueden borrar y volver a crear
* Los `Pods` que los usen se deben volver a crear
* Ventajas:
  * Impiden cambios accidentales en la configuración
  * Mejoran el rendimiento del cluster: no hacen falta _watchers_ para propagar
    los cambios