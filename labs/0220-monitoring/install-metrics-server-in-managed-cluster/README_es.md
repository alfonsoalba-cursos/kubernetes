# Instalar _Metrics server_ en un cluster gestionado

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `managed`

## Verificación previa

Lo primero que haremos será verificar si el servidor de métricas está ya instalado. En caso
de que ya lo esté, esta veremos el `Deployment` y el `Service` correspondiente:

```shell
kubectl get deploy,svc,pods -n kube-system | grep metrics
deployment.apps/metrics-server                1/1     1            1           46d
service/metrics-server                ClusterIP   10.233.52.120   <none>        443/TCP         46d
pod/metrics-server-5b6dd75459-sxw85              1/1     Running   0          4h30m
```

Si ya está instalado, puedes pasar directamente a [la siguiente sección](#accediento-a-la-informaci%C3%B3n)

## Instalación

Como se indica en el [repositorio de _Metrics Server_](https://github.com/kubernetes-sigs/metrics-server) ,
para poder instalar _Metrics Server_ nuestro cluster debe cumplir ciertos 
[requisitos](https://github.com/kubernetes-sigs/metrics-server#requirements)
que transcribo aquí por conveniencia:

- Metrics Server must be [reachable from kube-apiserver] by container IP address (or node IP if hostNetwork is enabled).
- The kube-apiserver must [enable an aggregation layer].
- Nodes must have Webhook [authentication and authorization] enabled.
- Kubelet certificate needs to be signed by cluster Certificate Authority (or disable certificate validation by passing `--kubelet-insecure-tls` to Metrics Server)
- Container runtime must implement a [container metrics RPCs] (or have [cAdvisor] support)

[reachable from kube-apiserver]: https://kubernetes.io/docs/concepts/architecture/master-node-communication/#master-to-cluster
[enable an aggregation layer]: https://kubernetes.io/docs/tasks/access-kubernetes-api/configure-aggregation-layer/
[authentication and authorization]: https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet-authentication-authorization/
[container metrics RPCs]: https://github.com/kubernetes/community/blob/master/contributors/devel/sig-node/cri-container-stats.md
[cAdvisor]: https://github.com/google/cadvisor

Para instalarlo, utilizaremos el manifiesto que se facilita en el repositorio:

```shell
$ wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

Una vez descargado el fichero, buscaremos la definición del `Deployment` dentro del fichero, y en el comando 
de ejecución del contenedor, añadiremos la opción `--kubelet-insecure-tls`: 

```yaml
...
...
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
  strategy:
    rollingUpdate:
      maxUnavailable: 0
  template:
    metadata:
      labels:
        k8s-app: metrics-server
    spec:
      containers:
      - args:
        - --cert-dir=/tmp
        - --secure-port=4443
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        - --kubelet-insecure-tls                      <<<<<<--------------------- AÑADIR ESTA LÍNEA
        - --metric-resolution=15s
        image: k8s.gcr.io/metrics-server/metrics-server:v0.6.1
        imagePullPolicy: IfNotPresent
```

También es posible instalarlo utilizando [Helm](https://artifacthub.io/packages/helm/metrics-server/metrics-server),
añadiendo la opción `--kubelet-insecure-tls` cuando configueremos el Helml Chart.

## Accediendo a la información

### `kubectl top`

Una vez _Metris Server_ está instalado, podemos utilizar `kubectl top`:

```shell
$ kubectl top node       
NAME                       CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
standardnodes-paka7v2imr   86m          2%     657Mi           79%
standardnodes-wypldyeewy   95m          2%     757Mi           91%
standardnodes-zuf5eywgar   96m          2%     683Mi           82%
```

Si queremos ver la información de un nodo:

```shell
$ kubectl top node standardnodes-paka7v2imr
NAME                       CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
standardnodes-paka7v2imr   82m          2%     657Mi           79%
```

Usando la opción `-l / --selector` podemos filtrar por etiqueta.

### Accediendo a la API

Podemos acceder directamente a la API utilizando las siguientes URLs

* `/apis/metrics.k8s.io/v1beta1/nodes`
* `/apis/metrics.k8s.io/v1beta1/nodes/<NODENAME>`
* `/apis/metrics.k8s.io/v1beta1/namespaces/<NAMESPACENAME>/pods`
* `/apis/metrics.k8s.io/v1beta1/namespaces/<NAMESPACENAME>/pods/<PODNAME>`

Para acceder a estas URLs utilizamos el comando `kubectl get --raw`.

```shell
$ kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes | jq
```

<details>
<summary></summary>

```json
{
  "kind": "NodeMetricsList",
  "apiVersion": "metrics.k8s.io/v1beta1",
  "metadata": {},
  "items": [
    {
      "metadata": {
        "name": "standardnodes-paka7v2imr",
        "creationTimestamp": "2022-02-21T04:15:33Z",
        "labels": {
          "beta.kubernetes.io/arch": "amd64",
          "beta.kubernetes.io/os": "linux",
          "enterprise.cloud.ionos.com/datacenter-id": "3914a457-f19b-4bba-8742-b21fa61d4521",
          "enterprise.cloud.ionos.com/node-id": "706a2c62-c401-4cae-93ed-21b00f6b90a0",
          "failure-domain.beta.kubernetes.io/region": "es-vit",
          "failure-domain.beta.kubernetes.io/zone": "AUTO",
          "kubernetes.io/arch": "amd64",
          "kubernetes.io/hostname": "standardnodes-paka7v2imr",
          "kubernetes.io/os": "linux",
          "kubernetes.io/role": "node",
          "node-role.kubernetes.io/node": "",
          "topology.kubernetes.io/region": "es-vit",
          "topology.kubernetes.io/zone": "AUTO"
        }
      },
      "timestamp": "2022-02-21T04:15:26Z",
      "window": "10s",
      "usage": {
        "cpu": "90789321n",
        "memory": "673180Ki"
      }
    },
    {
      "metadata": {
        "name": "standardnodes-wypldyeewy",
        "creationTimestamp": "2022-02-21T04:15:33Z",
        "labels": {
          "beta.kubernetes.io/arch": "amd64",
          "beta.kubernetes.io/os": "linux",
          "enterprise.cloud.ionos.com/datacenter-id": "3914a457-f19b-4bba-8742-b21fa61d4521",
          "enterprise.cloud.ionos.com/node-id": "e0b9e9c2-3959-478b-a5dd-df7080d82318",
          "failure-domain.beta.kubernetes.io/region": "es-vit",
          "failure-domain.beta.kubernetes.io/zone": "AUTO",
          "kubernetes.io/arch": "amd64",
          "kubernetes.io/hostname": "standardnodes-wypldyeewy",
          "kubernetes.io/os": "linux",
          "kubernetes.io/role": "node",
          "node-role.kubernetes.io/node": "",
          "topology.kubernetes.io/region": "es-vit",
          "topology.kubernetes.io/zone": "AUTO"
        }
      },
      "timestamp": "2022-02-21T04:15:24Z",
      "window": "10s",
      "usage": {
        "cpu": "99599435n",
        "memory": "776328Ki"
      }
    },
    {
      "metadata": {
        "name": "standardnodes-zuf5eywgar",
        "creationTimestamp": "2022-02-21T04:15:33Z",
        "labels": {
          "beta.kubernetes.io/arch": "amd64",
          "beta.kubernetes.io/os": "linux",
          "enterprise.cloud.ionos.com/datacenter-id": "3914a457-f19b-4bba-8742-b21fa61d4521",
          "enterprise.cloud.ionos.com/node-id": "f8848213-bc6b-4145-b5b8-51472677b24c",
          "failure-domain.beta.kubernetes.io/region": "es-vit",
          "failure-domain.beta.kubernetes.io/zone": "AUTO",
          "kubernetes.io/arch": "amd64",
          "kubernetes.io/hostname": "standardnodes-zuf5eywgar",
          "kubernetes.io/os": "linux",
          "kubernetes.io/role": "node",
          "node-role.kubernetes.io/node": "",
          "topology.kubernetes.io/region": "es-vit",
          "topology.kubernetes.io/zone": "AUTO"
        }
      },
      "timestamp": "2022-02-21T04:15:31Z",
      "window": "21s",
      "usage": {
        "cpu": "85109973n",
        "memory": "699848Ki"
      }
    }
  ]
}
```
</details>

Como vimos en las diapositivas, _Metrics Server_ consulta y agrega el _Summary API_ que
expone `kubelet`. Los datos que vemos aquí son los que utiliza el `HorizontalPodAutoscaler`
para escalar nuestros `Deployments` en base a valores de uso de CPU y memoria.
