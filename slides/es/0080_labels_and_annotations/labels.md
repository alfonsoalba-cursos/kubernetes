### Etiqueta (`Label`)

Parejas de valores clave/valor que se pueden _pegar_ a objetos de Kubernetes.

^^^^^^

Añadir a los objetos propiedades 

**que permitan identificarlos**.

Note:

Las etiquetas están pensadas para añadir atributos a los objetos de Kubernetes
que sean relevantes para los usuarios.

Las etiquetas nos permiten plasmar dentro de la estructura de objetos de Kubernetes
las peculiaridades de nuestra organización o nuestros proyectos. Podemos tener
una única empresa con una aplicación o tener estructuras más complicadas con
multiples organizaciones y departamentos cada uno con sus entornos y aplicaciones.

Las etiquetas, junto con los espacios de nombres, son los elementos que nos permitirán 
discriminar qué objetos pertenecen a qué unidad organizativa o flujo de trabajo.

Las etiquetas están pensadas para identificar objetos, para lo que usaremos selectores.
Si queremos añadir información genérica, por ejemplo, versión que estamos usando
de nginx en un Pod, usaríamos una anotación.

^^^^^^

### Ejemplos

* `release: stable`
* `environment: dev`, `environment: cicd`
* `tier: customerX`

^^^^^^

### 🕐

Las etiquetas se pueden añadir y modificar en cualquier momento, no solo 
cuando se crea el objeto.

^^^^^^

### Formato de la clave

`<prefix>/<name>`

* `prefix`: 
  * Opcional
  * Tiene que ser un subdominio DNS seguido del caracter `/`
  * 253 caracteres máximo
  * Si se omite, kubernetes considerará la pareja clave/valor es privada para
    el usuario
  * Los prefijos `kubernetes.io/` y `k8s.io/` están reservadas para componentes
    de Kubernetes

Note:

Los componentes del sistema como `kube-apiserver`, `kube-scheduler` o `kube-controller-manager`
entre otros, así como herramientas de terceros, sólo pueden crear claves on un prefijo
para evitar colisiones con las claves privadas que puedan definir los usuarios.

^^^^^^

### Formato de la clave

`<prefix>/<name>`

* `name`: 
  * **Obligatorio**
  * Empezar y acabar por `[a-zA-Z0-9]`
  * Puede contener además guiones `-`,  guiones bajos `_` y puntos `.`
  * Máximo 63 caracteres

^^^^^^

### Formato del valor

* Puede estar vacío
* Empezar y acabar por `[a-zA-Z0-9]`
* Puede contener además guiones `-`,  guiones bajos `_` y puntos `.`
* Máximo 63 caracteres

^^^^^^

```yaml [5-8]
apiVersion: v1
kind: Pod
metadata:
  name: label-demo
  labels:
    environment: production
    app: nginx
    uses-lets-encrypt:
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    ports:
    - containerPort: 80
```

Note:

Aquí tenemos un ejemplo de como añadir etiquetas a un pod.

^^^^^^

### Etiquetas recomendadas

* Conjunto de etiquetas estandarizadas
* Permiten describir los objetos de Kubernetes de una forma común que 
  cualquier herramienta puede entender y utilizar.
  <!-- .element: class="fragment" data-fragment-index="2" -->
* Pensadas para mejorar la interoperabilidad. <!-- .element: class="fragment" data-fragment-index="3" -->
* Están organizadas en torno al concepto de aplicación. <!-- .element: class="fragment" data-fragment-index="4" -->
* Utilizan el prefijo app.kubernetes.io <!-- .element: class="fragment" data-fragment-index="5" -->

^^^^^^

#### Etiquetas recomendadas

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    app.kubernetes.io/name: mysql
    app.kubernetes.io/instance: mysql-master
    app.kubernetes.io/version: "5.7.21"
    app.kubernetes.io/managed-by: helm
    app.kubernetes.io/component: server
    app.kubernetes.io/part-of: wordpress
```

Note:

En este ejemplo podemos ver cómo etiquetaríamos un pod que contuviese
la base de datos de un wordpress.

| Nombre | Descripción | Ejemplo | Tipo |
| ------ | ----------- | ------- | ---- |
| app.kubernetes.io/name | Nombre de la aplicación | mysql | string |
| app.kubernetes.io/instance | Nombré único que identifica la instancia de la aplicación | 	mysql-master | string |
| app.kubernetes.io/version | Versión de la aplicación (e.g., semantic version, hash del commit, etc.) | 5.7.21 | string |
| app.kubernetes.io/component | The component within the architecture | database | string |
| app.kubernetes.io/part-of | El nombre de la aplicación de más alto nivel del que forma parte | wordpress | string |
| app.kubernetes.io/managed-by | La herramienta utilizada para gestionar la aplicación | helm | string |
| app.kubernetes.io/created-by | El controlador o usuario que crearon la aplicación | controller-manager | string |