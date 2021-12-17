
### `Ingress`

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-example
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /testpath
        pathType: Prefix
        backend:
          service:
            name: foo-website-servive
            port:
              number: 80
```

Note:

Ejemplo de objeto `Ingress` para el controlador `ingress-nginx`.

Ejemplo de cómo se utiliza la anotación `rewrite-target` dentro de `ingress-nginx`:
[https://kubernetes.github.io/ingress-nginx/examples/rewrite/](https://kubernetes.github.io/ingress-nginx/examples/rewrite/)

^^^^^^

### `Ingress`

* `name`: nombre de subdominio válido
* `annotations`: forma de 
  [configurar](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/) 
  el controlador
* `spec`: contiene las reglas

^^^^^^

### Reglas

Un regla consta de:

* `host`: opcional. Si no se especifica, la regla se aplica a todo el tráfico entrante
* `paths[]`: lista de rutas. Cada una se asocia a un `Service` a través de 
  `service.name`, `service.port.name` y `service.port.number`

^^^^^^

### Reglas

* `defaultBackend`: `Service` que procesa las peticiones que no concuerdan con 
  ninguna de las reglas definidas
* [_resource backends_](https://kubernetes.io/docs/concepts/services-networking/ingress/#resource-backend):
  usar otros recusos como destino de las peticiones (por ejemplo un _bucket_)
Note:

Es posible definir un `Ingress` que solo tenga un `defaultBackend` si todo el tráfico
va a ser procesado por el mismo `Service`.

Es habitual que los proveedores de servicios en la nube ofrezcan _buckets_ que
sirven contenido estático a por HTTP/HTTPS. El uso de _resource backends_
nos permite utilizar estos _buckets_ desde nuestro `ingress controller` 
([más información](https://kubernetes.io/docs/concepts/services-networking/ingress/#resource-backend)).

^^^^^^

### Reglas

Tipos de rutas (`pathType`):

* `ImplementationSpecific`: se delega en la clase `IngressClass`
* `Exact`: la URL debe ser igual a la especificada (diferencia mayúsuculas de minúsculas)
* `Prefix`: lista de prefijos a partir del caracter `/` (diferencia mayúsuculas de minúsculas)

Ejemplo:

```
Prefix:	/aaa/bbb -> /aaa/bbbxyz no coincide
Prefix:	/aaa/bbb -> /aaa/bbb/ccc si coincide
```

Note:


Ver [ejemplos de rutas aquí](https://kubernetes.io/docs/concepts/services-networking/ingress/#examples).


^^^^^^

### Reglas

En caso de que más de dos rutas coincidan:
* Tendrá preferencia la más específica (aquella con el `pathType` más largo)
* Si tienen la misma longitud, `Exact` tiene preferencia sobre `Prefix`

^^^^^^

### Reglas

* `host`: soporta el uso de comodines

```yaml [11]
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-example
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - http:
      host: "*.myapp.com"
      paths:
      - path: /testpath
        pathType: Prefix
        backend:
          service:
            name: foo-website-servive
            port:
              number: 80
```

