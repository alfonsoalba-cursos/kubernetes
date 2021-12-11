# Instalación de minikube en una máquina virtual con Linux

En este taller prepararemos una máquina virtual con Linux que podremos utilizar para correr minikube.

Utilizaremos Ubuntu 21.10 como distribución de Linux dentro de la máquina virtual. Si ya dispones de una 
máquina virtual con Ubuntu, puedes ir directamente a la sección [Instalación de docker](/#instalación-de-docker).

## Creación de la máquina virtual

El procedimiento de instalación es muy parecido para Linux, Windows o MacOS.
### Requisitos previos
#### Virtual Box

Descarga e instala Virtual Box desde [este enlace](https://www.virtualbox.org/wiki/Downloads)

Nota: en MacOS es posible instalar VirtualBox usando `brew`: `brew install virtualbox`
#### Vagrant
Descarga e instala `Vagrant` (puedes descargarlo de [este enlace](https://www.vagrantup.com/downloads)).

Nota: en MacOS es posible instalar Vagrant usando `brew`: `brew install vagrant`

### Crear la máquina virtual

Clona este repositorio:

```
> git clone https://github.com/alfonsoalba-cursos/kubernetes.git
```

Accede a la carpeta labs/es/instalacion-minikube-en-maquina-virtual-linux:

```
> cd labs/es/instalacion-minikube-en-maquina-virtual-linux
```

Crea la máquina virtual:

```shell
> VAGRANT_EXPERIMENTAL="disks" vagrant up
```

O, si estás utilizando Powershell en Windows:

```Powershell
> $env:VAGRANT_EXPERIMENTAL="disks"
> vagrant up
```

<details>
    <summary>Aquí puedes ver la salida de una ejecución típica del comando vagrant up</summary>
    <pre>
> vagrant up    
==> vagrant: You have requested to enabled the experimental flag with the following features:
==> vagrant:
==> vagrant: Features:  disks
==> vagrant:
==> vagrant: Please use with caution, as some of the features may not be fully
==> vagrant: functional yet.
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'ubuntu/hirsute64'...
==> default: Matching MAC address for NAT networking...
==> default: Checking if box 'ubuntu/hirsute64' version '20211210.0.0' is up to date...
==> default: Setting the name of the VM: instalacion-minikube-en-linux_default_1639164821139_32646
Vagrant is currently configured to create VirtualBox synced folders with
the `SharedFoldersEnableSymlinksCreate` option enabled. If the Vagrant
guest is not trusted, you may want to disable this option. For more
information on this option, please refer to the VirtualBox manual:

  https://www.virtualbox.org/manual/ch04.html#sharedfolders

This option can be disabled globally with an environment variable:

  VAGRANT_DISABLE_VBOXSYMLINKCREATE=1

or on a per folder basis within the Vagrantfile:

  config.vm.synced_folder '/host/path', '/guest/path', SharedFoldersEnableSymlinksCreate: false
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
==> default: Forwarding ports...
    default: 22 (guest) => 2222 (host) (adapter 1)
==> default: Configuring storage mediums...
    default: Disk 'vagrant_primary' needs to be resized. Resizing disk...
==> default: Running 'pre-boot' VM customizations...
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 127.0.0.1:2222
    default: SSH username: vagrant
    default: SSH auth method: private key
    default: Warning: Connection aborted. Retrying...
    default: Warning: Connection reset. Retrying...
    default: 
    default: Vagrant insecure key detected. Vagrant will automatically replace
    default: this with a newly generated keypair for better security.
    default: 
    default: Inserting generated public key within guest...
    default: Removing insecure key from the guest if it's present...
    default: Key inserted! Disconnecting and reconnecting using new SSH key...
==> default: Machine booted and ready!
==> default: Checking for guest additions in VM...
    default: The guest additions on this VM do not match the installed version of
    default: VirtualBox! In most cases this is fine, but in rare cases it can
    default: prevent things such as shared folders from working properly. If you see
    default: shared folder errors, please make sure the guest additions within the
    default: virtual machine match the version of VirtualBox you have installed on
    default: your host and reload your VM.
    default:
    default: Guest Additions Version: 6.0.0 r127566
    default: VirtualBox Version: 6.1
==> default: Mounting shared folders...
    default: /vagrant => C:/Users/aalba/MyStuff/online-training/kubernetes/labs/es/instalacion-minikube-en-linux
==> default: Running provisioner: shell...
    default: Running: inline script
    default: 
    default: WARNING: apt does not have a stable CLI interface. Use with caution in scripts.
    default:
    default: Get:1 http://security.ubuntu.com/ubuntu hirsute-security InRelease [110 kB]
    default: Hit:2 http://archive.ubuntu.com/ubuntu hirsute InRelease
    default: Get:3 http://archive.ubuntu.com/ubuntu hirsute-updates InRelease [115 kB]
    default: Get:4 http://archive.ubuntu.com/ubuntu hirsute-backports InRelease [101 kB]
    default: Get:5 http://archive.ubuntu.com/ubuntu hirsute/universe amd64 Packages [13.2 MB]
    default: Get:6 http://security.ubuntu.com/ubuntu hirsute-security/universe amd64 Packages [229 kB]
    default: Get:7 http://security.ubuntu.com/ubuntu hirsute-security/universe Translation-en [49.7 kB]
    default: Get:8 http://security.ubuntu.com/ubuntu hirsute-security/universe amd64 c-n-f Metadata [5792 B]
    default: Get:9 http://security.ubuntu.com/ubuntu hirsute-security/multiverse amd64 Packages [3372 B]
    default: Get:10 http://security.ubuntu.com/ubuntu hirsute-security/multiverse Translation-en [828 B]
    default: Get:11 http://security.ubuntu.com/ubuntu hirsute-security/multiverse amd64 c-n-f Metadata [220 B]
    default: Get:12 http://archive.ubuntu.com/ubuntu hirsute/universe Translation-en [5441 kB]
    default: Get:13 http://archive.ubuntu.com/ubuntu hirsute/universe amd64 c-n-f Metadata [279 kB]
    default: Get:14 http://archive.ubuntu.com/ubuntu hirsute/multiverse amd64 Packages [206 kB]
    default: Get:15 http://archive.ubuntu.com/ubuntu hirsute/multiverse Translation-en [108 kB]
    default: Get:16 http://archive.ubuntu.com/ubuntu hirsute/multiverse amd64 c-n-f Metadata [8124 B]
    default: Get:17 http://archive.ubuntu.com/ubuntu hirsute-updates/main amd64 Packages [445 kB]
    default: Get:18 http://archive.ubuntu.com/ubuntu hirsute-updates/universe amd64 Packages [346 kB]
    default: Get:19 http://archive.ubuntu.com/ubuntu hirsute-updates/universe Translation-en [86.4 kB]
    default: Get:20 http://archive.ubuntu.com/ubuntu hirsute-updates/universe amd64 c-n-f Metadata [8068 B]
    default: Get:21 http://archive.ubuntu.com/ubuntu hirsute-updates/multiverse amd64 Packages [7356 B]
    default: Get:22 http://archive.ubuntu.com/ubuntu hirsute-updates/multiverse Translation-en [2196 B]
    default: Get:23 http://archive.ubuntu.com/ubuntu hirsute-updates/multiverse amd64 c-n-f Metadata [440 B]
    default: Get:24 http://archive.ubuntu.com/ubuntu hirsute-backports/main amd64 c-n-f Metadata [112 B]
    default: Get:25 http://archive.ubuntu.com/ubuntu hirsute-backports/restricted amd64 c-n-f Metadata [120 B]
    default: Get:26 http://archive.ubuntu.com/ubuntu hirsute-backports/universe amd64 Packages [3708 B]
    default: Get:27 http://archive.ubuntu.com/ubuntu hirsute-backports/universe Translation-en [1252 B]
    default: Get:28 http://archive.ubuntu.com/ubuntu hirsute-backports/universe amd64 c-n-f Metadata [176 B]
    default: Get:29 http://archive.ubuntu.com/ubuntu hirsute-backports/multiverse amd64 c-n-f Metadata [120 B]
    default: Fetched 20.7 MB in 4s (4810 kB/s)
    default: Reading package lists...
    default: Building dependency tree...
    default: Reading state information...
    default: All packages are up to date.
    default: 
    default: WARNING: apt does not have a stable CLI interface. Use with caution in scripts.
    default:
    default: Reading package lists...
    default: Building dependency tree...
    default: Reading state information...
    default: Calculating upgrade...
    default: 0 upexgraded, 0 newly installed, 0 to remove and 0 not upgraded.
    </pre>
</details>

Podemos verificar que la máquina se ha levando ejecutando el siguiente comando:

```text
> vagrant ssh -- uname -a
Linux ubuntu-hirsute 5.11.0-41-generic #45-Ubuntu SMP Fri Nov 5 11:37:01 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux
```

## Instalación de docker

Para poder utilizar minikube en una máquina virtual, nos veremos obligados a utilizar el driver `none`, que 
utiliza docker. Ese es el motivo por el que necesitamos instalarlo.

Seguiremos las [instrucciones de instalación de docker para Ubuntu.](https://docs.docker.com/engine/install/ubuntu/).

Después de la instalación, añadiremos el usuario `vagrant` al grupo `docker` para poder ejecutar
comandos con ese usuario:

```shell
vagrant@ubuntu-hirsute:~$>sudo adduser vagrant docker
```
## Instalación de Minikube

Una vez tenemos la máquina virtual instalada y lista para operar con ella, instalaremos Minikube.

Accedemos a la máquina virtual:

```sh
> vagrant ssh
vagrant@ubuntu-hirsute:~$
```

Para poder instalar Minikube en Linux necesitaremos el paquete `conntrack`:

```shell
vagrant@ubuntu-hirsute:~$ apt-install conntrack
```

Instalamos minikube:

```shell
vagrant@ubuntu-hirsute:~$ curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube
vagrant@ubuntu-hirsute:~$ sudo mkdir -p /usr/local/bin/
vagrant@ubuntu-hirsute:~$ sudo install minikube /usr/local/bin/
```

Una vez instalado, lo levantamos:

```shell
vagrant@ubuntu-hirsute:~$ minikube start --driver=docker
😄  minikube v1.24.0 on Ubuntu 21.04 (vbox/amd64)
✨  Using the none driver based on user configuration
👍  Starting control plane node minikube in cluster minikube
🤹  Running on localhost (CPUs=2, Memory=3926MB, Disk=49568MB) ...
ℹ️  OS release is Ubuntu 21.04
🐳  Preparing Kubernetes v1.22.3 on Docker 20.10.11 ...
    ▪ kubelet.resolv-conf=/run/systemd/resolve/resolv.conf
    > kubectl.sha256: 64 B / 64 B [--------------------------] 100.00% ? p/s 0s
    > kubelet.sha256: 64 B / 64 B [--------------------------] 100.00% ? p/s 0s
    > kubeadm.sha256: 64 B / 64 B [--------------------------] 100.00% ? p/s 0s
    > kubeadm: 43.71 MiB / 43.71 MiB [---------------] 100.00% 3.24 MiB p/s 14s
    > kubectl: 44.73 MiB / 44.73 MiB [---------------] 100.00% 2.59 MiB p/s 17s
    > kubelet: 115.57 MiB / 115.57 MiB [-------------] 100.00% 4.73 MiB p/s 25s

    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🤹  Configuring local host environment ...

❗  The 'none' driver is designed for experts who need to integrate with an existing VM
💡  Most users should use the newer 'docker' driver instead, which does not require root!
📘  For more information, see: https://minikube.sigs.k8s.io/docs/reference/drivers/none/

❗  kubectl and minikube configuration will be stored in /home/vagrant
❗  To use kubectl or minikube commands as your own user, you may need to relocate them. For example, to overwrite your own settings, run:

    ▪ sudo mv /home/vagrant/.kube /home/vagrant/.minikube $HOME
    ▪ sudo chown -R $USER $HOME/.kube $HOME/.minikube

💡  This can also be done automatically by setting the env var CHANGE_MINIKUBE_NONE_USER=true
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: default-storageclass, storage-provisioner
💡  kubectl not found. If you need it, try: 'minikube kubectl -- get pods -A'
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

Podemos verificar que se ha instalado correctamente ejecutando:

```shell
vagrant@ubuntu-hirsute:~$ minikube status
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

