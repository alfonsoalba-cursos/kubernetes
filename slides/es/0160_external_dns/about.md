### ExternalDNS<!-- .element: style="text-transform: none" -->

Sincroniza `Services` y `Ingresses` con proveedores de servicios DNS

Note:

Este proyecto nace con el objetivo de 
[unificar otros proyectos](https://github.com/kubernetes-sigs/external-dns#heritage) 
que implementaban funcionalidades parecidas: 

* Zalando `mate`
* Molecule `route53-kubernetes`
* kops `DNS controller`

En los repositorios fe GitHub de los dos primeros, se puede ver una nota indicando que ambos
proyectos han sido abandonados en favor de `external-dns`.

^^^^^^

### ¿Cómo funciona?

1. Consulta la API de Kubernetes para obtener los recursos (`Service`, `Ingress`, etc)
1. Extrae de esos recursos los nombres y direcciones IP de los registros DNS
1. Configura los registros en el proveedor

^^^^^^

### ¿Qué recursos de kubernetes soporta?

* `Service`: sólo de tipo `LoadBalancer`
* `Ingress`

notes:

En el momento en el que se redactaron esas diapositivas, y según se indica en la propia
[página de preguntas frecuentes del cluster](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/faq.md#which-kubernetes-objects-are-supported),
en mayo de 2018 se empezó a trabajar en añadir soporte para recursos `NodePort`,  pero a día 
de hoy es un trabajo que todavía está en desarrollo.

