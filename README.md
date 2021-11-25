# Material curso de Kubernetes

Este repositorio contiene el material para el curso de Kubernetes.

## Diapositivas

Puedes ver las diapositivas de las siguientes maneras:

### Descargando los PDFs

### Viendo la versión online

### Abriendo los ficheros html

Clona el repositorio en tu máquina, utiliza el navegador de archivos de tu sistema operativo
para llegar a los ficheros html que están en la carpeta `slides`. Abrelos con tu navegador favorito.

Este método, aunque sencillo, no te permitirá ver las notas del ponente.

### Servidor web local

Para poder levantar un servidor web necesitarás tener instalado docker en tu máquina.

Clona el repositorio:

```bash
> git clone git@github.com:alfonsoalba-cursos/kubernetes.git
> cd kubernetes
```

Levanta el servidor web:

```bash
kubernetes> docker compose up -d slides
```

Apunta tu navegador a `http://localhost:8080`. Deberías tener acceso ya a las diapositivas.

Cuando acabes, detén el servidor web y borra el contenedor ejecutando el comando:

```bash
kubernetes> docker compose down slides
```


## Laboratorios

Puedes acceder al índice de laboratorios en este enlace. La documentación para cada uno de ellos
la encontarás en la carpeta correspondiente.