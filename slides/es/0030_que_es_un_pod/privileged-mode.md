### _Privileged mode_
* Linux: activar la opción `privileged`
* Windows: Se pueden crear pods de tipo `HostProcess`. Se ejecutan directamente sobre el host.

notes:

Si necesitamos ejecutar `Pods`/contenedores que necesitan acceso al systema operativo, por ejemplo
para manipular la red o para acceder a un dispositivo de hardware, deberemos 
crear contenedores en modo `privileged`.

Este tipo de contenedores se pueden usar en Linux y Windows.
