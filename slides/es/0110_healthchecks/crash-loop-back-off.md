### `CrashLoopBackOff`


Si un `Pod` tiene un `restartPolicy` igual a `Always`,  **siempre que un contenedor
se pare, este se intentará volver a levantar**.

Esto hace que entremos en un bucle infinito

^^^^^^

### `CrashLoopBackOff`

Para gestionar estas situaciones, los contenedores se reinician con un retraso
exponencial (_exponencial back-off delay_): 10s, 20s, 40s, 80s...

El tiempo máximo es de 5 minutos

^^^^^^

### `CrashLoopBackOff`

Este tiempo se resetea de nuevo a 10s cuando un contenedor está en estado
_ready_ durante 10 minutos.


^^^^^^

### `CrashLoopBackOff`

Ejemplos de cuándo se puede dar esta situación:

* Error en la aplicación
* Error en la configuración que impide que esta se ejecute correctamente
* Error en el despliegue / configuración de kubernetes (un manifiesto mal configurado)

