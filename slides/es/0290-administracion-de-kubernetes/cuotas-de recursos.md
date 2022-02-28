## Cuotas de recursos

Permiten gestionar los recursos del cluster y distribuirlos entre diferentes
unidades organizativas.

**⚠️ Es importante definirlos para evitar que, por error, una persona consuma todos los
recursos del cluster**

El cluster se puede compartimentar usando `Namespaces` que tendrán limitados los recursos

^^^^^^

## Cuotas de recursos

En la sección sobre [Monitorización](../0220_monitoring/index.html) vimos cómo podemos 
especificar recursos mínimos y máximos de CPU y memoria.

**Si el administrador define límites para los recursos, todos los `Pods` deberán
especificar límites cuando se crean**

El administrador puede definir valores por defecto.

notes:

Si se definen cuotas de recursos a nivel del cluster, el muy recomendable que definamos
valores por defecto. En caso contrario, nuestros usuarios recibirán erroress cuando intenten
crear los `Pods`

^^^^^^

#### Recursos que se pueden limitar por `Namespace`

| Recurso | Descripción |
| ------- | ----------- |
| `requests.cpu` | Máximo valor de la suma de _CPU requests_ de todos los `Pods` |
| `requests.mem` | Máximo valor de la suma de _Memory requests_ de todos los `Pods` |
| `requests.storage` | Máximo valor de la suma de los `PersistentVolumeClaims` de todos los `Pods` |
| `limits.cpu` | Máximo valor de la suma de _CPU limits_ de todos los `Pods` |
| `limits.memory` | Máximo valor de la suma de _Memory limits_ de todos los `Pods` |


^^^^^^

### _Object count quota_

<div class="two-column-container">
    <div class="col">
    <ul>
        <li><code>ConfigMaps<code></li>
        <li><code>PersistentVolumeClaims<code></li>
        <li><code>Pods<code></li>
        <li><code>ReplicaSets<code></li>
        <li><code>ResourceQuotas<code></li>
    </ul>
    </div>
    <div class="col">
    <ul>
        <li><code>Services<code></li>
        <li><code>Services.LoadBalancers<code></li>
        <li><code>Services.NodePorts<code></li>
        <li><code>Secrets<code></li>
    </ul>
    </div>
</div>

notes:

El administrador del cluster también puede limitar el número de objetos que se crean
por `Namespace`. Aquí os facilito una lista de algunos de los recursos que
el administrador puede limitar.

[Más información sobre _Object Count Quota_](https://kubernetes.io/docs/concepts/policy/resource-quotas/#object-count-quota)