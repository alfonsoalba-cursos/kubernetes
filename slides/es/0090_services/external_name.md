### `ExternalName`

Mapean un servicio a un nombre DNS

Funciona a nivel de DNS

```yaml
apiVersion: v1
kind: Service
metadata:
  name: database
spec:
  type: ExternalName
  externalName: my.database.example.com
```

notes:

Que funciona a nivel de DNS significa que cuando desde dentro de Kubernetes
se hace una petición para resolver el nombre del servicio, el servicio
DNS de Kubernetes devuelve un registro indicado como un CNAME.

Por ejemplo, si tuviesemos un servicio como el descrito en este ficher `yaml`,
y dentro de un Pod ejecutamos:

 ```
> mysql -u production -h database
 ```

 Cuando se resuelve el nombre del servicio `database`, se devuelve my.database.example.com como
 un CNAME, por lo que se debe hacer una segunda resolución de nombres para convertir
my.database.example.com en una IP.

^^^^^^

### `ExternalName`

Casos de uso:

* Acceder a servicios externos
* Acceder a servicios que están en otro espacio de nombres

notes:

Si nuestras bases de datos no se encuentran dentro del cluster de Kubernetes,
esta es una forma de configurar el acceso a ellas desde dentro de nuestros Pods. 

También se puede utilizar para acceder a servicios que están en otros espacios de nombres.
Por ejemplo, si tienes un espacio de nombres dedicado a alojar servicios compartidos
por otros espacios de nombres, el uso de `ExternalNames` nos permite 
no tener que escribir en nuestro código las URLs de acceso a esos servicios compartidos.

Ante un cambio en la URL del servicio (por ejemplo, porque se mueve a otro espacio de nombres)
bastaría con reconfigurar el `ExternalName`. No tendríamos que reconfigurar ni modificar 
nuestra aplicación.
