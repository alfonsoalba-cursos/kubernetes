### Soporte: controladores

* [Google ingress controller](https://github.com/kubernetes/ingress-gce)
* `ingress-nginx` v0.9.x
* [AWS Ingress Controller de Zalando](https://github.com/zalando-incubator/kube-ingress-aws-controller)
* [Traefik](https://github.com/containous/traefik)

notes:

`ingress-gce` Trabaja con balanceadores de carga de Google.

^^^^^^

### Soporte: controladores

Si se utiliza un controlador no soportado, `external-dns` puede que no encuentre
los `Endpoints` correctamente.

En este caso debemos utilizar la anotación `external-dns.alpha.kubernetes.io/target`
para forzar su creación.

notes:

`external-dns.alpha.kubernetes.io/target` acepta bien una IP o un nobre de _host_. Si se
utiliza un nombre, se creará un registro CNAME. Para que esto funcione, es necesario
que el nombre del _host_ que se pase a esta anotación haya sido definido previamente
en un una anotación `external-dns.alpha.kubernetes.io/hostname` (por ejemplo en un `Service`).

[Más información aquí.](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/faq.md#are-other-ingress-controllers-supported)

^^^^^^

### Soporte: proveedores DNS

* `Stable`: usado para pruebas antes de una nueva versión, usado en producción, 
  mantenimiento activo por equipo de mantenedores
* `Beta`: testado pero los mantenedores no tienen acceso a recursos por parte de los mantenedores para hacer las pruebas
* `Alpha`: Sin soporte por los mantenedores (solo revisión de _Pull Requests_)

[Ver proveedores](https://github.com/kubernetes-sigs/external-dns#status-of-providers)

^^^^^^

### Soporte: versiones

| ExternalDNS | <= 0.9.x | >= 0.10.0 |
| ----------- | -------- | --------- |
| K8s <= 1.18 | ✅ | ❌ |
| K8s >= 1.19 | ❌ | ✅ |