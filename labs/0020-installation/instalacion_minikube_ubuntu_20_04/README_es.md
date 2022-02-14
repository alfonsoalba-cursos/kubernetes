# Instalación de Minikube en Ubuntu 20.04

Este laboratorio se puede realizar en:
* Máquinas físicas con extensiones de virtualización (cualquier
  equipo de trabajo moderno las tiene)
* Máquinas virtuales que tengan activada la virtualización anidada

El primer paso que daremos será verificar esta condición.
## Requisitos de hardware

Debes tener acceso a una máquina con una instalación de Ubuntu 20.04. En este laboratorio
no realizaremos la instalación del sistema operativo.

Como he comentado antes, comprobamos antes de continuar que tenemos las extensiones de 
virtualización activas en nuestra máquina:

```shell
> egrep -c 'vmx|svm' /proc/cpuinfo
6
```

Si tu máquina soporta virtualización, este comando debería devolver un número
mayor que cero (número de cores con soporte para virtualización).

Si no tienes soporte para virtualización, busca como activarlo en tu máquina. Si
estás utilizando un proveedor de servicios en la nube, busca como activar
la virtualización anidada.

## Instalación de un hipervisor: KVM

Minikube puede funcionar de dos maneras: utilizando un hipervisor o utilizando docker.
En este laboratorio utilizaremos el primer método. Puedes ver el segundo método en el
taller 
[Instalación de minikube en una máquina virtual con Linux](../instalacion-minikube-en-maquina-virtual-linux/README.md), en el que usamos
docker como driver al no disponer de virtualización en las CPU.

Instalar el paquete `cpu-checker`:

```shell
> sudo apt install cpu-checker
```

Verificar que podemos acceder a la aceleración por hardware cuando ejecutemos 
máquinas virtuales:

```shell
user@ubuntu:~$ kvm-ok
INFO: /dev/kvm exists
KVM acceleration can be used
```

Instalamos KVM:

```shell
apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
```

Añadir al usuario a los grupos `libvirt` y `kvm`:

```shell
user@ubuntu:~$ sudo adduser user libvirt
user@ubuntu:~$ sudo adduser user kvm
```

Cierra la sesión y vuelve a acceder para que los cambios tengan efecto (o crea
un _login shell_ desde la sesión que ya tienes abierta).

Verificamos la instalación:

```shell
root@ubuntu:~> virsh list --all
 Id   Name   State
--------------------

```

```text
root@ubuntu:~> sudo systemctl status libvirtd
* libvirtd.service - Virtualization daemon
     Loaded: loaded (/lib/systemd/system/libvirtd.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2021-12-12 08:49:26 UTC; 3min 57s ago
TriggeredBy: * libvirtd.socket
             * libvirtd-ro.socket
             * libvirtd-admin.socket
       Docs: man:libvirtd(8)
             https://libvirt.org
   Main PID: 3358 (libvirtd)
      Tasks: 19 (limit: 32768)
     Memory: 22.0M
     CGroup: /system.slice/libvirtd.service
             |-3358 /usr/sbin/libvirtd
             |-3504 /usr/sbin/dnsmasq --conf-file=/var/lib/libvirt/dnsmasq/default.conf --leasefile-ro --dhcp-script=/usr/lib/libvir>
             `-3506 /usr/sbin/dnsmasq --conf-file=/var/lib/libvirt/dnsmasq/default.conf --leasefile-ro --dhcp-script=/usr/lib/libvir>

Dec 12 08:49:26 ubuntu systemd[1]: Started Virtualization daemon.
Dec 12 08:49:26 ubuntu dnsmasq[3504]: started, version 2.80 cachesize 150
Dec 12 08:49:26 ubuntu dnsmasq[3504]: compile time options: IPv6 GNU-getopt DBus i18n IDN DHCP DHCPv6 no-Lua TFTP conntrack ipset au>
Dec 12 08:49:26 ubuntu dnsmasq-dhcp[3504]: DHCP, IP range 192.168.122.2 -- 192.168.122.254, lease time 1h
Dec 12 08:49:26 ubuntu dnsmasq-dhcp[3504]: DHCP, sockets bound exclusively to interface virbr0
Dec 12 08:49:26 ubuntu dnsmasq[3504]: reading /etc/resolv.conf
Dec 12 08:49:26 ubuntu dnsmasq[3504]: using nameserver 127.0.0.53#53
Dec 12 08:49:26 ubuntu dnsmasq[3504]: read /etc/hosts - 5 addresses
Dec 12 08:49:26 ubuntu dnsmasq[3504]: read /var/lib/libvirt/dnsmasq/default.addnhosts - 0 addresses
Dec 12 08:49:26 ubuntu dnsmasq-dhcp[3504]: read /var/lib/libvirt/dnsmasq/default.hostsfile
```

## Instalación de `kubectl`

Seguiremos las [instrucciones de instalación](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management) para instalar
`kubectl` como paquete `.deb`.

Ejecutar la siguiente secuencia de comandos:

```shell
sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
```

Comprobamos que la instalación ha funcionado:

```shell
root@ubuntu:~> kubectl version --client
Client Version: version.Info{Major:"1", Minor:"23", GitVersion:"v1.23.0", GitCommit:"ab69524f795c42094a6630298ff53f3c3ebab7f4", GitTreeState:"clean", BuildDate:"2021-12-07T18:16:20Z", GoVersion:"go1.17.3", Compiler:"gc", Platform:"linux/amd64"}
```

Recuerda que la versión más actualizada de este procesod e instalación
estará siempre en el enlace anterior a la página oficial de la herramienta.

## Instalación de `minikube`

Se puede instalar de diferentes maneras. Utilizaremos la instalación a partir
de paquete `.deb` aunque según pone en la 
[propia documentación](https://v1-18.docs.kubernetes.io/docs/tasks/tools/install-minikube/#install-minikube-using-a-package)
todavía está en modo experimental.

Ir a la [página en GitHub](https://github.com/kubernetes/minikube/releases) 
con las _releases_ de `minikube`. Buscar la última versión liberada, que en el
en el momento en el que se escribió este documento era la versión 1.24.0. Buscar 
el fichero `minikube_1.24.0-0_amd64.deb`, conseguir la URL utilizando el botón
derecho y descargarlo:

```shell
user@ubuntu:~$ wget https://github.com/kubernetes/minikube/releases/download/v1.24.0/minikube_1.24.0-0_amd64.deb
```

Instalar el paquete:

```shell
user@ubuntu:~$sudo dpkg -i minikube_1.24.0-0_amd64.deb
Selecting previously unselected package minikube.
(Reading database ... 127175 files and directories currently installed.)
Preparing to unpack minikube_1.24.0-0_amd64.deb ...
Unpacking minikube (1.24.0-0) ...
Setting up minikube (1.24.0-0) ...
```

Verificar la instalación:

```shell
user@ubuntu:~$ minikube version
minikube version: v1.24.0
commit: 76b94fb3c4e8ac5062daf70d60cf03ddcc0a741b
```

Levantar minikube:

```shell
user@ubuntu:~$ minikube start --driver=kvm
😄  minikube v1.24.0 on Ubuntu 20.04 (kvm/amd64)
✨  Using the kvm2 driver based on user configuration
💾  Downloading driver docker-machine-driver-kvm2:
    > docker-machine-driver-kvm2....: 65 B / 65 B [----------] 100.00% ? p/s 0s
    > docker-machine-driver-kvm2: 11.40 MiB / 11.40 MiB  100.00% 27.09 MiB p/s
💿  Downloading VM boot image ...
    > minikube-v1.24.0.iso.sha256: 65 B / 65 B [-------------] 100.00% ? p/s 0s
    > minikube-v1.24.0.iso: 225.58 MiB / 225.58 MiB  100.00% 117.66 MiB p/s 2.1
👍  Starting control plane node minikube in cluster minikube
💾  Downloading Kubernetes v1.22.3 preload ...
    > preloaded-images-k8s-v13-v1...: 501.73 MiB / 501.73 MiB  100.00% 151.51 M
🔥  Creating kvm2 VM (CPUs=2, Memory=2200MB, Disk=20000MB) ...
🐳  Preparing Kubernetes v1.22.3 on Docker 20.10.8 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

Verificar el estado del nodo:

```shell
user@ubuntu:~$ minikube status
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

## Detener el nodo

Cuando termines los diferentes talleres y quieras parar el nodo ejecuta el siguiente comando:

```shell
user@ubuntu:~$ minikube stop
✋  Stopping node "minikube"  ...
🛑  1 node stopped.
```
