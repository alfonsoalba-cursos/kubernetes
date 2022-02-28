### Autorización de usuarios

Cuando creamos un nuevo usuario, este tendrá por defecto acceso a todo

Debemos configurar autorizaciones para limitar el acceso

* AlwaysAllow / AlwaysDeny
* ABAC (Attribute-Based Access Control)
* RBAC (Role Based Access Control)
* Webhook (autorización a través de servicios externos)

[Más información](https://kubernetes.io/docs/reference/access-authn-authz/authorization/)

^^^^^^

### Autorización de usuarios

Se realiza a nivel de API

Cuando se recibe una petición (por ejemplo `kubectl get nodes`) se verifica si el usuario
tiene permiso para ejecutar ese comando

^^^^^^

### RBAC

Se utilizan varios tipos de objetos para implementar RBAC en un cluster de Kubernetes

Los roles pueden aplicarse a
* Un `Namespace`: se utiliza `Role` y `RoleBinding`
* Todo el cluster: se utiliza `ClusterRole` y `ClusterRoleBinding`

[Más información](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

^^^^^^

### RBAC: crear un rol

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default # Namespace al que se aplica este rol
  name: pod-reader
rules:
- apiGroups: [""] # "" Significa Core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

notes:

Este es un rol definido para el espacio de nombres por defecto que se puede usar
para dar permisos de lectura a los `Pods`

^^^^^^

#### RBAC: Asignar un rol

Asignamos el rol `pod-reader` a un usuario

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: User
  name: menganito
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader # Rol definido en la diapositiva anterior
  apiGroup: rbac.authorization.k8s.io
```

^^^^^^

### RBAC: crear un `ClusterRole`

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  # "namespace" omitted since ClusterRoles are not namespaced
  name: secret-reader
rules:
- apiGroups: [""]
  #
  # at the HTTP level, the name of the resource for accessing Secret
  # objects is "secrets"
  resources: ["secrets"]
  verbs: ["get", "watch", "list"]
```

Un `ClusterRole` se puede utilizar desde un `RoleBinding` o desde un `ClusterRoleBinding`

notes:

Este rol puede utilizarse dentro de un `RoleBinding`, en cuyo caso servirá para dar permisos
dentro de un espacio de nombres, o dentro de un `ClusterRoleBinding`, en cuyo caso servirá 
para dar permisos a nivel de cluster

^^^^^^

### RBAC: crear un `ClusterRoleBinding`

Uso a nivel de cluster:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
# Permitimos a los usuarios del grupo manager que puedan ver secrets en todos los Namespaces
kind: ClusterRoleBinding
metadata:
  name: read-secrets-global
subjects:
- kind: Group
  name: manager
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

^^^^^^

### RBAC: crear un `ClusterRoleBinding`

Uso a nivel de `Namespace`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-secrets
  namespace: development
subjects:
- kind: User
  name: gutierrezqueleveo
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

notes:

En este ejemplo utilizamod un `ClusterRole` desde un `RoleBinding` para asignar
permiso de lectura a los `Secrets` dentro del `Namespace` development.
