### Uso

Una vez tenemos la aplicación `external-dns` ejecutándose en nuestro cluster

¿Cómo podemos interactuar con ella?

* Campo `host` del objeto `Ingress` 👈
* Anotaciones 👈
* _Compatibility mode_
* Opción `--fqdn-template`

notes:

La forma más habitual de uso, al menos en los proyectos en los que he trabajado hasta ahora
ha sido mediante el objeto `Ingress` y/o el uso de anotaciones.

El modo compatible (_compatibility mode_) permite parsear anotaciones de los proyectos
`mate` o `route53-kubernetes`, que están ya en desuso.

La tercera opción permite generar los registros DNS a partir de una plantilla 
pasada como argumento a la aplicación `external-dns`. Útil cuando necesitamos 
gestionar cientos de servicios.

^^^^^^

### Uso: `Ingress`

`external-dns` busca los _hosts_ definidos en los objetos `Ingress` y crea los registros
DNS correspondientes

```yaml [6,7,10]
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo-ingress
  #annotations:
  #  external-dns.alpha.kubernetes.io/ingress-hostname-source: defined-hosts-only  
spec:
  ingressClassName: nginx
  rules:
  - host: foo-website.alfonsoalba.com
    http:
      paths:
      - path: /*
        pathType: Prefix
        backend:
          service:
            name: foo-website-service
            port:
              number: 80
```

^^^^^^

### Uso: `Ingress`

```yaml [5-7]
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo-ingress
  annotations:
    external-dns.alpha.kubernetes.io/ingress-hostname-source: annotation-only
    external-dns.alpha.kubernetes.io/hostname: foo-website.alfonsoalba.com
spec:
  ingressClassName: nginx
  rules:
  - host: foo-website.alfonsoalba.com
    http:
      paths:
      - path: /*
        pathType: Prefix
        backend:
          service:
            name: foo-website-service
            port:
              number: 80
```

notes:

La segunda manera en la que podemos utilizar `external-dns` es mediante el uso
de anotaciones:

* `external-dns.alpha.kubernetes.io/hostname`: listado, separado por comas, de los
  nombres de _host_ que se crearán
* `external-dns.alpha.kubernetes.io/ingress-hostname-source`: de dónde se leen los
  nombres de _host_:
  * `annotations-only`
  * `defined-hosts-only`

^^^^^^

### Uso: `Service`

⚠️ Sólo servicios de tipo `LoadBalancer` ⚠️

```yaml [5-7]
apiVersion: v1
kind: Service
metadata:
  name: nginx
  annotations:
    external-dns.alpha.kubernetes.io/hostname: example.com
    external-dns.alpha.kubernetes.io/ttl: "120" #optional
spec:
  selector:
    app: nginx
  type: LoadBalancer
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

^^^^^^

### Uso: `--fqdn-template`

```yaml [26]
# external-dns-deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: external-dns
spec:
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: external-dns
  template:
    metadata:
      labels:
        app: external-dns
    spec:
      containers:
      - name: external-dns
        image: k8s.gcr.io/external-dns/external-dns:v0.7.6
        args:
        - --source=service # ingress is also possible
        - --domain-filter=example.com # (optional) limit to only example.com domains; change to match the zone created above.
        - --zone-id-filter=023e105f4ecef8ad9ca31a8372d0c353 # (optional) limit to a specific zone.
        - --provider=cloudflare
        - --cloudflare-proxied # (optional) enable the proxy feature of Cloudflare (DDOS protection, CDN...)
        - --fqdn-template={{.Name}}-{{.Namespace}}.alfonsoalba.com
        env:
        - name: CF_API_KEY
          value: "YOUR_CLOUDFLARE_API_KEY"
        - name: CF_API_EMAIL
          value: "YOUR_CLOUDFLARE_EMAIL"
```

notes:

Podemos pasarle esta opción al servicio desde el fichero de definición de `external-dns`.

El valor que se pase a esta opción, se parseará como un _template_ de `Go`.

Para generar el nombre, se utilizarán los campos definidos en la especificación
del recurso `Service` o `Ingress`.