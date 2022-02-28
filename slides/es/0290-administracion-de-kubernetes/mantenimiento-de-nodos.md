### Mantenimiento de nodos

La componente que se encarga de gestionar los nodos es _Node Controller_

* Asigna una dirección IP cuando un nuevo nodo se añade al cluster
* Mantiene actualizada la lista de nodos y su estado
* Monitoriza la salud / estado de los nodos
  * Borra el nodo si está dañado
  * Marca los nodos como no disponibles para que `kube-scheduler` pueda reprogramar sus nodos

^^^^^^

### Mantenimiento de nodos: _self-registration_

Permite que cuando se añade un nuevo nodo, `kubelet` del nodo se registre en el cluster

También es posible hacer el registro de manera manual, haciendo las correspondientes llamadas a la API

Cuando se crea el objeto `Node` en la API, este recibe:
* `metadata` (por ejemplo, el nombre, roles, etc)
* `labels`: que incluyen la zona, región, etc

```shell
$ kubectl describe node standardnodes-47omh62yrr 
Name:               standardnodes-47omh62yrr
Roles:              node
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/os=linux
                    enterprise.cloud.ionos.com/datacenter-id=3914a457-f19b-4bba-8742-b21fa61d4521
                    enterprise.cloud.ionos.com/node-id=7d8e6973-92c9-41b3-96c8-97a28e0cc736
                    failure-domain.beta.kubernetes.io/region=es-vit
                    failure-domain.beta.kubernetes.io/zone=AUTO
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=standardnodes-47omh62yrr
                    kubernetes.io/os=linux
                    kubernetes.io/role=node
                    node-role.kubernetes.io/node=
                    topology.kubernetes.io/region=es-vit
                    topology.kubernetes.io/zone=AUTO
...
```

^^^^^^

### _Decommission_

Antes de sacar un nodo del cluster o apagarlo, debemos drenarlo

```shell
kubectl drain [NOMBRE]
```

Si el nodo ejecuta `Pods` sueltos 
(que no estén vinculados a un controlador, como por ejemplo un `ReplicaSet`)
debemos usar `--force`

```shell
kubectl drain [NOMBRE] --force
```
