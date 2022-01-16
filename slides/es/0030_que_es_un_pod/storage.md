### Almacenamiento

Cuando especificamos un `Pod`, podemos declara volúmenes a los que el `Pod` tendrá acceso

Todos los contenedores en un pod pueden acceder a los volúmenes montados

notes:

Una forma de permitir que múltiples contenedores dentro de un pod
compartan información es utilizar un volumen.

Cuando veamos los `secrets` y los `ConfigMaps` dentro de kubernetes, veremos
otro ejemplo de cómo utilizar volúmenes para compartir información entre varios pods
y, dentro de ellos, entre los contenedores que conformen cada pod.
