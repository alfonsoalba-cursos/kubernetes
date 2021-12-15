### Resumen

* Kubernetes utiliza un servicio DNS interno para permitir que los `Pods` y `Services`
  se puedan encontrar con facilida
* Se crean registros A/AAAA para `Pods` y `Services`
* Se crean registros SRV para puertos con nombre
* Cómo añadir entradas a `/etc/hosts`

^^^^^^

### Más información

* [DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
* [Página de manual resolv.conf](https://www.man7.org/linux/man-pages/man5/resolv.conf.5.html)
* [Customizing DNS Service](https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/)
* [Repositorio de `kube-dns`](https://github.com/kubernetes/dns)
