### Gestión de usuarios

Tipos de usuarios:

* Usuario regular (usuario)
  * Accede al cluster desde el exterior (usando `kubectl`)
  * **no tiene un objeto en Kubernetes**
* Cuentas de servicio
  * Se utilizan para autenticar **dentro del cluster**
  * Los credenciales se gestionan usando `Secrets`

^^^^^^

### Autenticación de usuarios

* _Client Certificates_
* _Bearer Tokens_
* _Authentication Proxy_
* _OpenID_
* _Webhooks_

[Más información](https://kubernetes.io/docs/reference/access-authn-authz/authentication/)

^^^^^^

### Autenticación de cuentas de servicio

Se utilizan _Service Account Tokens_ que se almacenan en `Secrets`

Están vinculadas a un `Namespace`

Una llamada a la API que no esté autorizada se considera una llamada anónima

