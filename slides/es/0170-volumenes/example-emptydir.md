### Ejemplo: `EmptyDir`

```yaml [9-14]
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
  - image: k8s.gcr.io/test-webserver
    name: test-container
    volumeMounts:
    - mountPath: /cache
      name: cache-volume
  volumes:
  - name: cache-volume
    emptyDir: {}
```

^^^^^^

### Ejemplo: `EmptyDir`

```yaml [14,15]
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
  - image: k8s.gcr.io/test-webserver
    name: test-container
    volumeMounts:
    - mountPath: /in-memory-cache
      name: in-memory-cache
  volumes:
  - name: in-memory-cache
    emptyDir:
        medium: "Memory"
```

