# Multicontainer `Pod`: nginx container

This container is used in the lab that shows how multicontainer `Pods` work.

## Build

```shell
$ docker-compose build
```

After building, you can push the image using:

```shell
$ docker push kubernetescourse/multicontainer-pod-nginx
```

## Usage

This image is meant to be used inside a `Pod`. It configures nginx as a reverse proxy
and will redirect all traffic to http://hello-app:8080. If the upstream `hello-app`
cannot be resolved, the container running this image will fail.

However, you can still run the image locally to access the static assets by running

```shell
$ docker compose up nginx
[+] Running 2/2
 - Network multicontainer-pod-nginx_default    Crea...                                            0.0s 
 - Container multicontainer-pod-nginx-nginx-1  Cr...                                              0.2s 
Attaching to multicontainer-pod-nginx-nginx-1
multicontainer-pod-nginx-nginx-1  | /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
multicontainer-pod-nginx-nginx-1  | /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
multicontainer-pod-nginx-nginx-1  | /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
multicontainer-pod-nginx-nginx-1  | 10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
multicontainer-pod-nginx-nginx-1  | 10-listen-on-ipv6-by-default.sh: info: /etc/nginx/conf.d/default.conf differs from the packaged version
multicontainer-pod-nginx-nginx-1  | /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
multicontainer-pod-nginx-nginx-1  | /docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
multicontainer-pod-nginx-nginx-1  | /docker-entrypoint.sh: Configuration complete; ready for start up
multicontainer-pod-nginx-nginx-1  | 2021/12/26 17:51:02 [notice] 1#1: using the "epoll" event method   
multicontainer-pod-nginx-nginx-1  | 2021/12/26 17:51:02 [notice] 1#1: nginx/1.21.4
multicontainer-pod-nginx-nginx-1  | 2021/12/26 17:51:02 [notice] 1#1: built by gcc 10.2.1 20210110 (Debian 10.2.1-6)
multicontainer-pod-nginx-nginx-1  | 2021/12/26 17:51:02 [notice] 1#1: OS: Linux 5.10.60.1-microsoft-standard-WSL2
multicontainer-pod-nginx-nginx-1  | 2021/12/26 17:51:02 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
multicontainer-pod-nginx-nginx-1  | 2021/12/26 17:51:02 [notice] 1#1: start worker processes
multicontainer-pod-nginx-nginx-1  | 2021/12/26 17:51:02 [notice] 1#1: start worker process 31
multicontainer-pod-nginx-nginx-1  | 2021/12/26 17:51:02 [notice] 1#1: start worker process 32
multicontainer-pod-nginx-nginx-1  | 2021/12/26 17:51:02 [notice] 1#1: start worker process 33
multicontainer-pod-nginx-nginx-1  | 2021/12/26 17:51:02 [notice] 1#1: start worker process 34
multicontainer-pod-nginx-nginx-1  | 2021/12/26 17:51:02 [notice] 1#1: start worker process 35
multicontainer-pod-nginx-nginx-1  | 2021/12/26 17:51:02 [notice] 1#1: start worker process 36
multicontainer-pod-nginx-nginx-1  | 2021/12/26 17:51:02 [notice] 1#1: start worker process 37
multicontainer-pod-nginx-nginx-1  | 2021/12/26 17:51:02 [notice] 1#1: start worker process 38
```

Once the container is up and running, you can access the static assets using this 
URL: http://localhost:9090/hello.html

## Upstream configuration

Containers inside one `Pod` can communicate with each other using the port number.
That's the reason why we use `proxy-pass http://localhost:8080`.

When we configure the `Pod` later that uses this image, we should remember that we'll
need to run the upstream container in this port.
