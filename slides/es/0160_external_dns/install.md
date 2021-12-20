### Instalación

```yaml [19-27]
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
        env:
        - name: CF_API_KEY
          value: "YOUR_CLOUDFLARE_API_KEY"
        - name: CF_API_EMAIL
          value: "YOUR_CLOUDFLARE_EMAIL"
```

notes:

La instalación se realiza a través de un `Deployment` que instala la aplicación
en nuestro cluster.

^^^^^^

### Instalación

```shell
$ kubectl create -f external-dns-deployment.yml
```

Note:

Este comando creará un `Deployment` con su correspondiente `Pod`. Dentro de este
se ejecutará la aplicación que consulta la API de Kubernetes y actualiza la información
en nuestro proveedor DNS.
