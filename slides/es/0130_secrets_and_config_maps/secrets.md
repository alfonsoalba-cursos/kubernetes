### `Secrets`

Objetos que almacenan información sensible: contraseñas, tokens, claves privadas...

**Por defecto, se almacenan sin encriptar**

Son como `ConfigMaps` pero pensados para guardar información confidencial

Note:

Por defecto los `Secrets` se almacenan sin encriptar. Cualquiera con acceso a la 
API podrá leerlos. Soluciones:
* [Activar la encriptación](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/)
  Esto es algo que se hace a nivel de configuración del cluster. Es una opción que se 
  aplica al servicio `kupe-apiserver`. Requiere kubernetes v1.13 y etcd v3.0
* Usar [RBACL](https://kubernetes.io/docs/reference/access-authn-authz/authorization/) para
  decidir quién tiene acceso a esos objetos

^^^^^^

### ¿Porqué?

* Desacoplar configuración de código
* Reducir el riesgo de que la información confidencial quede expuesta

Note:

Uno de los errores más comunes en la creación de imágenes es el de 
gestionar incorrectamente este tipo de información. Estos objetos nos
ayudan a gestionar mejor esta información y mantener su confidencialidad.

^^^^^^ 

### Tipos predefinidos

| Tipo |  Descripción |
| ---- | ------------ |
| `Opaque` | [Información arbitraria](https://kubernetes.io/docs/concepts/configuration/secret/#opaque-secrets) |
| `kubernetes.io/tls` | [Certificados](https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets) |
| `.../service-account-token` | [Tokens de cuentas de servicio](https://kubernetes.io/docs/concepts/configuration/secret/#service-account-token-secrets) |
| `.../dockercfg` | [Fichero `.dockercfg` serializado](https://kubernetes.io/docs/concepts/configuration/secret/#docker-config-secrets) |
| `.../dockerconfigjson` | [Fichero `~/.docker/config.json` serializado](https://kubernetes.io/docs/concepts/configuration/secret/#docker-config-secrets) |

Note:

El fichero `.dockercfg` es el formato _legacy_ de configuración de docker. 
`~/.docker/config.json` es le nuevo formato que los sustituye.

^^^^^^ 

### Tipos predefinidos

| Tipo |  Descripción |
| ---- | ------------ |
| `.../basic-auth	` | [Credenciales HTTP-Basic](https://kubernetes.io/docs/concepts/configuration/secret/#basic-authentication-secret) |
| `.../ssh-auth` | [Credenciales SSH](https://kubernetes.io/docs/concepts/configuration/secret/#ssh-authentication-secrets) |
| `.../token` | [_Bootstrap token_](https://kubernetes.io/docs/concepts/configuration/secret/#bootstrap-token-secrets) |

Note:

`bootstrap.kubernetes.io/token` es un token especial utilizado durante el arranque
de los nodos del cluster para facilitar las tareas de automatización, como 
por ejemplo añadir nuevos nodos al cluster.

^^^^^^

### Tipos

Podemos usar cualquier nombre para el tipo de un credencial

**Si utilizamos uno de los tipos predefinidos estamos obligados a cumplir
con las condiciones para ese tipo**

^^^^^^

### El objeto `Secret`

* `name`: nombre de subdominio DNS válido
* `data`: parejas clave/valor con el valor codificado en _base64_
* `stringData`: parejas clave/valor siendo el valor una cadena arbitraria
* Las claves solo pueden contener carateres alfanuméricos, `-`, `_` y `.`
* Si una clave aparece en `data` y en `stringData`, el valor de `stringData` 
  tendrá preferencia

^^^^^^

### El objeto `Secret`

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  username: YWRtaW4=
  password: MWYyZDFlMmU2N2Rm
```

Note:

Ejemplo de uso con las claves codificadas usando _base64_

^^^^^^

### El objeto `Secret`

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
stringData:
  config.yaml: |
    apiUrl: "https://my.api.com/api/v1"
    username: <user>
    password: <password>    
```

Note:

Ejemplo de uso de una cadena arbitraria. Cuando el objeto se cree o se actualice,
Kubernetes se encargará de serializarlo.

^^^^^^

### El objeto `Secret`

Deben crearse antes de los `Pods` que los usan

Solo pueden _verlos_ los `Pods`que estén en el mismo espacio de nombres

Tamaño límite 1MB

Note:

Los volúmenes de tipo `secret` se validan para cerciorarse de que efectivamente
hacer referencia a un objeto de tipo `Secret` antes de montarlos. Por este motivo,
el objeto `Secret` debe existir en el _API Server_ antes de que se puedan 
montar los volúmenes del `Pod`

El límite de 1MB está creado a propósito para evitar que se creen objetos muy grandes.
Esto afectaría al rendimiento tanto del API Server (que es el que los tiene que servir)
como de `kubelet`, que es el que los consume. ¿Os imagináis tener que servir ficheros de 
secrets de varias centenas de MB o incluso Gigas?

[_Fuente: Documentación de kubernetes_](https://kubernetes.io/docs/concepts/configuration/secret/#restrictions)



^^^^^^

### Uso

* Como variables de entorno para nuestro contenedor
* Como un fichero que nuestro contenedor puede leer para obtener la configuración
* `kubelet` para descargarse imágenes de _registries_ privados

^^^^^^

### Uso: como variables de entorno

```yaml [9-19]
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-pod
spec:
  containers:
  - name: mycontainer
    image: redis
    env:
      - name: SECRET_USERNAME
        valueFrom:
          secretKeyRef:
            name: mysecret # El nombre del objeto Secret
            key: username  # La clave que contiene el valor que necesitamos
      - name: SECRET_PASSWORD
        valueFrom:
          secretKeyRef:
            name: mysecret
            key: password
```

Note:

La forma de uso es muy similar a como vimos en los `ConfigMaps`

^^^^^^

### Uso: volúmenes

```yaml [9-19]
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: redis
    volumeMounts:
    - name: secretVolume # Nombre del volume definido abado
      mountPath: "/etc/secrets"
      readOnly: true
  volumes:
  - name: secretVolume # Nombre del volume
    secret:
      secretName: mysecret # Nombre del objeto Secret que queremos utilizar
      items:
      - key: username
        path: my-group/my-username
```

Note:

El secreto `username` estará disponible en el fichero `/etc/secrets/my-group/my-username`.

El secreto `password` no estará disponible ya que no se ha declarado expresamente 
dentro de `.spec.volumes[].secret.items[]`.

^^^^^^

### Uso: volúmenes

```yaml [9-16]
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: redis
    volumeMounts:
    - name: secretVolume # Nombre del volume definido abado
      mountPath: "/etc/secrets"
      readOnly: true
  volumes:
  - name: secretVolume # Nombre del volumen
    secret:
      secretName: mysecret # Nombre del objeto Secret que queremos utilizar
```

Note:

Si no se especifican `.spec.volumes[].scret.items[]`, todas las claves del
objeto secret (definidas en `data` y `dataString`) aparecerán como ficheros
en `/etc/secrets`. En nuestro ejemplo tendríamos:

* `/etc/secrets/username`
* `/etc/secrets/password`

^^^^^^

### Uso: volúmenes

```yaml [17]
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: redis
    volumeMounts:
    - name: secretVolume # Nombre del volume definido abado
      mountPath: "/etc/secrets"
      readOnly: true
  volumes:
  - name: secretVolume # Nombre del volumen
    secret:
      secretName: mysecret # Nombre del objeto Secret que queremos utilizar
      defaultMode: 0400
```

Note:

Podemos definir los permisos por defecto para los ficheros que se crean.

* [Referencia de `.spec.volumes[].secret`](https://kubernetes.io/docs/reference/kubernetes-api/config-and-storage-resources/volume/#projections)
* [Referencia de `.spec.volumes[].secret`](https://kubernetes.io/docs/reference/kubernetes-api/config-and-storage-resources/volume/#KeyToPath)
^^^^^^

### Uso: volúmenes

```yaml [17,21]
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: redis
    volumeMounts:
    - name: secretVolume # Nombre del volume definido abado
      mountPath: "/etc/secrets"
      readOnly: true
  volumes:
  - name: secretVolume # Nombre del volumen
    secret:
      secretName: mysecret # Nombre del objeto Secret que queremos utilizar
      defaultMode: 0400
      items:
      - key: username
        path: my-group/my-username
        mode: 0777
      - key:
        ...  
```

Note:

Si no se especifica la propiedad `mode`, se utilizará `defaultMode`

* [Referencia de `.spec.volumes[].secret`](https://kubernetes.io/docs/reference/kubernetes-api/config-and-storage-resources/volume/#projections)
* [Referencia de `.spec.volumes[].secret`](https://kubernetes.io/docs/reference/kubernetes-api/config-and-storage-resources/volume/#KeyToPath)

^^^^^^

### Uso: `kubelet`

La propiedad `imagePullSecrets` del `Pod` especifica una lista de objetos `Secret` que se
pueden utilizar para autenticarse en el repositorio de imágenes

**Forma recomendada de acceder a repositorios privados**

```yaml [10,11]
apiVersion: v1
kind: Pod
metadata:
  name: foo
  namespace: awesomeapps
spec:
  containers:
    - name: awesomecontainer
      image: aalbagarcia/awesomeapp:v1
  imagePullSecrets:
    - name: alfonsoRegistryKey
```

Note:

* [Referencia del objeto `PodSped`](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#PodSpec)
* [Specifying imagePullSecrets on a Pod](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod)

^^^^^^


### Propagación de cambios

Si usamos el `Secret` dentro del `Pod` como variable de entorno:

Reiniciar el `Pod`

Note:

En este caso, los cambios no se progagan. Es necesario reiniciar el `Pod`

^^^^^^

### Propagación de cambios

Si usamos el `Secret` dentro del `Pod` como un volumen:

Los cambios se propagan

Note:

Eventualmente, los cambios aparecerán en nuestros volúmenes. ¿Cuánto tardan en propagarse?
Depende de cómo esté configurado nuestro cluster

> When a secret currently consumed in a volume is updated, projected keys are eventually updated
  as well. The kubelet checks whether the mounted secret is fresh on every periodic sync. 
  However, the kubelet uses its local cache for getting the current value of the Secret. The type 
  of the cache is configurable using the ConfigMapAndSecretChangeDetectionStrategy field in the 
  KubeletConfiguration struct. A Secret can be either propagated by watch (default), ttl-based, 
  or by redirecting all requests directly to the API server. As a result, the total delay from 
  the moment when the Secret is updated to the moment when new keys are projected to the Pod can 
  be as long as the kubelet sync period + cache propagation delay, where the cache propagation 
  delay depends on the chosen cache type (it equals to watch propagation delay, ttl of cache, or 
  zero correspondingly).


_Fuente: [documentación Kubernetes](https://kubernetes.io/docs/concepts/configuration/secret/#mounted-secrets-are-updated-automatically)_

Una última nota: si el secreto se monta en un volumen 
[`SubPath`](https://kubernetes.io/docs/concepts/storage/volumes#using-subpath)
el volumen no recibirá las actualizaciones del objeto `Secret` montado en ese
volumen.

^^^^^^

### Propagación de cambios

Al igual que con los `ConfigMaps`, la gestión de la actualización de un cambio
dependerá de nuestra aplicación.


^^^^^^

### _Immutable `Secrets`_

Introducidos en la versión 1.21

```yaml
apiVersion: v1
kind: Secret
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