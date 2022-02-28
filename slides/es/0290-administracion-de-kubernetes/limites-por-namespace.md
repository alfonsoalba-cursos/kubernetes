### `ResourceQuota`

Objeto que permite definir los recursos de un `Namespace`

```yaml
# compute-resources.yaml 
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-resources
spec:
  hard:
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
    requests.nvidia.com/gpu: 4
```

[Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/)

notes:

[`ResourceQuota` API Reference](https://kubernetes.io/docs/reference/kubernetes-api/policy-resources/resource-quota-v1/)

^^^^^^

### `ResourceQuota`

Límites de objetos

```yaml
# object-counts.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: object-counts
spec:
  hard:
    configmaps: "10"
    persistentvolumeclaims: "4"
    pods: "4"
    replicationcontrollers: "20"
    secrets: "10"
    services: "10"
    services.loadbalancers: "2"
```

^^^^^^

### `ResourceQuota`

Si creamos los dos ficheros mencionados en las diapostivas anteriores:

```shell
$ kubectl create -f object-counts.yaml -f compute-resources.yaml --namespace=myspace
```

^^^^^^

### `ResourceQuota`

Podemos ver estos objetos utilizando el comando `kubectl quota`:

```shell
$ kubectl get quota --namespace=myspace
NAME                    AGE
compute-resources       30s
object-counts           32s
```

^^^^^^

### `LimitRange`

Objeto definido a nivel del `Namespace` que permite definir valores por defecto
y límites de recursos utilizados por distintos tipos de objetos

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: cpu-limit-range
spec:
  limits:
  - default:
      cpu: 1
    defaultRequest:
      cpu: 0.5
    type: Container
```

[Limit Ranges](https://kubernetes.io/docs/concepts/policy/limit-range/)

