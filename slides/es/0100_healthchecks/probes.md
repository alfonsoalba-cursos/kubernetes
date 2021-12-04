### `Probe`

La definición del tipo 
[`Probe`](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#Probe)<!-- .element: target="_blank "-->
puede encontrarse dentro de la API del objeto
[Pod](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#lifecycle-1)<!-- .element: target="_blank "-->

Note:

Dentro de la definición del objeto `Pod`, existen dos comprobacionoes de estado
que podemos hacer:

* `spec.livenessProbe`
* `spec.readinessProbe`

Si abrimos el enlace a la definición de estas dos palabras clave, veremos que
el tipo de ambas de `Probe`.

Veremos en primer lugar como definir las sondas y luego cómo podemos utilizarlas.
Las sondas son un ejemplo más de abstracción en Kubernetes, en el que
separamos la definición de los objetos de su utilización.

^^^^^^

### `Probe`

Una sonda describe una **comprobación de estado** que se realiza contra un contenedor
para determinar si está **disponible para recibir tráfico**.

^^^^^^

### `Probe`: tipos

* Comando
* Petición HTTP
* Comprobación de socket TCP


Note:

Estos son los tres tipos de sondas que nos permite definir Kubernetes a día de hoy.

^^^^^^

### `Probe`: ejecución de un comando

```yaml [16-20]
kind: Deployment
apiVersion: apps/v1
metadata:
  name: lifecycle
spec:
  replicas: 1
  selector:
    matchLabels:
      app: lifecycle
  template:
    ...
    spec:
      containers:
      - name: app-container
        image: app-image
        readinessProbe:
          exec:
            command: ['mysql', '-u', 'healhcheck', '<<', 'SELECT count(*) FROM table', ...]
          initialDelaySeconds: 35
          timeoutSeconds: 30
```

^^^^^^

### `Probe`: ejecución de un comando

```yaml [16-20]
kind: Deployment
apiVersion: apps/v1
metadata:
  name: lifecycle
spec:
  replicas: 1
  selector:
    matchLabels:
      app: lifecycle
  template:
    ...
    spec:
      containers:
      - name: app-container
        image: app-image
        readinessProbe:
          exec:
            command: ['./probe.sh']
          initialDelaySeconds: 35
          timeoutSeconds: 30
```


Note:

Si el comando que queremos ejecutar tiene cierta complejidad, podemos escribir un
script que ejecutaremos como sonda.


^^^^^^

### `Probe`: ejecución de un comando

* El comando se ejecutará en la raiz del sistema de ficheros del contenedor
* **NO se ejecuta dentro una shell**
* Si devuelve `0` el contenedor estará listo para recibir tráfico

Note:

Si queremos ejecutar nuestros comandos dentro de una shell, deberemos hacer la llamada
nosotros de forma explícita en el comando.

Cualquier cosa distinta de cero que devuelva el comando hará que Kubernetes 
considere que el contenedor no está _sano_ y no recibirá peticiones.

^^^^^^

### `Probe`: petición HTTP

Realizan una petición http GET a la URL y puerto especificados

```yaml [16-23]
kind: Deployment
apiVersion: apps/v1
metadata:
  name: lifecycle
spec:
  replicas: 1
  selector:
  ...
  template:
    ...
    spec:
      containers:
      - name: app-container
        image: app-image
        readinessProbe:
        httpGet:
            host:
            scheme: HTTP
            path: /
            httpHeaders:
            - name: Host
              value: myapplication.com
            port: 80
        initialDelaySeconds: 35
        timeoutSeconds: 30
```

^^^^^^

### `Probe`: petición HTTP

* `httpGet.host`: por defecto la IP del contenedor. 
* `httpGet.port`: obligatioro especificarlo
* `httpGet.path`: la ruta completa de la petición, incluyendo los parámetros que
  necesitemos parsar
* `httpGet.scheme`: por defecto es HTTP

Note:


`httpGet.host`: Normalmente este campo se deja en blanco y se utiliza la 
cabecera `Host` de la petición HTTP para pasar el dominio adecuado cuando lo necesitamos.
Podéis ver un ejemplo en la diapositiva anterior, en el ejemplo de definición del `Deployment`.

^^^^^^

### `Probe`: socket TCP

Comprueban que un socket está abierto y escuchando en el puerto indicado

```yaml [16-23]
kind: Deployment
apiVersion: apps/v1
metadata:
  name: lifecycle
spec:
  replicas: 1
  selector:
  ...
  template:
    ...
    spec:
      containers:
      - name: app-container
        image: app-image
        readinessProbe:
          tcpSocket:
            host:
            port: 80
        initialDelaySeconds: 35
        timeoutSeconds: 30
```

^^^^^^

### `Probe`: socket TCP

* `tcpDocket.host`: por defecto la IP del contenedor
* `tcpDocket.port`: Número de puerto o nombre (IANA_SVC_NAME)
