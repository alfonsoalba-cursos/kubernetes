# Instalar `kube-state-metrics` en un cluster gestionado

Todos los comandos están ejecutados utilizando esta carpeta como ruta de trabajo.

Entorno de ejecución del taller: `managed`

## Instalación

Clonamos el repositorio de `kube-state-metrics`:

```shell
git clone https://github.com/kubernetes/kube-state-metrics.git
```

Aplicamos los manifiestos que están en la carpeta `kube-state-metrics/examples/standard`:

```shell
$ kubectl apply -f kube-state-metrics/examples/standard 
clusterrolebinding.rbac.authorization.k8s.io/kube-state-metrics created
clusterrole.rbac.authorization.k8s.io/kube-state-metrics created
deployment.apps/kube-state-metrics created
serviceaccount/kube-state-metrics created
service/kube-state-metrics created
```

Este comando crea un `Deployment` y un `Service` en el espacio de nombres `kube-system`:

```shell
$ kubectl get deployment,service -n kube-system | grep state
deployment.apps/kube-state-metrics            1/1     1            1           10m
service/kube-state-metrics            ClusterIP   None            <none>        8080/TCP,8081/TCP   10m
```

## Acceso a la API

Debemos acceder al puerto 8080 del servicio `kube-state-metrics`, que es de tipo 
`ClusterIP`. Esto significa que sólo podemos acceder a él desde dentro del cluster.

Podemos utilizar `kubeclt port-forward` para acceder desde nuestra máquina:

```shell
$ kubectl port-forward service/kube-state-metrics 3000:8080 -n kube-system
Forwarding from 127.0.0.1:3000 -> 8080
Forwarding from [::1]:3000 -> 8080
```

Una vez creado el reenvío de puertos, podemos apuntar nuestro navegador a 
[http://localhost:3000](http://localhost:3000) para ver las métricas.

También podemos acceder a las métricas usando un `Pod`

```shell
$ kubectl run --image busybox busybox -ti
/ # wget -q -O - kube-state-metrics.kube-system:8080/healthz
OK
/ # wget -q -O - kube-state-metrics.kube-system:8080/metrics

# HELP kube_certificatesigningrequest_annotations Kubernetes annotations converted to Prometheus labels.
# TYPE kube_certificatesigningrequest_annotations gauge
# HELP kube_certificatesigningrequest_labels Kubernetes labels converted to Prometheus labels.
# TYPE kube_certificatesigningrequest_labels gauge
# HELP kube_certificatesigningrequest_created Unix creation timestamp
# TYPE kube_certificatesigningrequest_created gauge
# HELP kube_certificatesigningrequest_condition The number of each certificatesigningrequest condition
# TYPE kube_certificatesigningrequest_condition gauge
# HELP kube_certificatesigningrequest_cert_length Length of the issued cert
# TYPE kube_certificatesigningrequest_cert_length gauge
# HELP kube_configmap_annotations Kubernetes annotations converted to Prometheus labels.
# TYPE kube_configmap_annotations gauge
kube_configmap_annotations{namespace="ingress-nginx",configmap="ingress-nginx-controller"} 1
kube_configmap_annotations{namespace="default",configmap="kube-root-ca.crt"} 1
kube_configmap_annotations{namespace="demo-hostpath",configmap="kube-root-ca.crt"} 1
...
...
...
```

Una vez tenemos `kube-state-metrics` instalado, podemos utilizar Prometheus y Grafana 
para monitorizar y ver estas métricas.

