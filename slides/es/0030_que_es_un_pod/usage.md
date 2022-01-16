### ¿Cómo se usan los `Pods`?

En términos de docker, un `Pod` es similar a un conjunto de contenedores que
comparten un espacio de nombres y uno o varios volúmenes.

^^^^^^

### ¿Cómo se usan los `Pods`?

A nivel de diseño y arquitectura de nuestra aplicación, un pod modela un host
lógico:

**encapsula partes de la aplicación que están fuertemente acopladas**

notes: 

Un ejemplo de este pod puede ser un servicio que contiene dos contenedores:
* Un contenedor que sirve ficheros almacenados en un volumen
* Un contenedor asociado que actualiza los ficheros que se están sirviendo

^^^^^^

### ¿Cómo se usan los `Pods`?

Dos modelos de uso

* Un contenedor por pod
* Varios contenedores por pod

^^^^^^

### ¿Cómo se usan los `Pods`?

⚠️

Agrupar múltiples contenedores en un mismo pod es un caso de uso avanzado

Usarlo sólo cuando los contenedores están fuertemente acoplados

notes:
Los pods están pensados para que ejecuten instancias únicas de una aplicación. Por ejemplo:
* Si estamos trabajando con un monolito: cada pod contendrá una instancia del monolito,
que normalmente contendrá un solo contenedor.
* Si estamos trabajando en una aplicación con microservicios, cada pod contendrá un
microservicio y, normalmente, un microservicio se ejecuta dentro de un contenedor.

No confundir microservicios dependientes entre sí con microservicios fuertemente acoplados.
En una arquitectura de microservicios, se busca el máximo desacoplamiento, lo que se consigue con
una adecuada gestión de dependencias y arquitecturas basadas en eventos / colas de mensajes.

Cada microservicio se ejectuará en su propio pod y, quizás alguno de esos pods necesite varios
contenedores para poder ejecutarse.

Lo que no se debe hacer es poner dentro de un mismo pod varios microservicios por que 
resulta que unos dependen de otros.

En el taller sobre `Pods` multicontenedor, veremos un ejemplo de contenedor de este tipo.

^^^^^^

### ¿Cómo se usan los `Pods`?

Habitualmente no se trabaja con `Pods`

Normalmente, trabajamos con otros recursos de kubernetes como `Deployments`, `Jobs` o `StatefulSets`

Estos recursos son los que se encargan de crear los pods por nosotros


^^^^^^

### ¿Cómo se usan los `Pods`?
 
1. Especificamos el  `Pod`    
   ```yaml
   # Fichero pod-definition.yml
   apiVersion: v1
   kind: Pod
   metadata:
     name: nginx
   spec:
     containers:
     - name: nginx
       image: nginx:1.14.2
       ports:
       - containerPort: 80
   ```
1. Creamos el `Pod`
   ```shell
   $ kubectl create -f pod-definition.yml
   ```