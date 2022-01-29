### Volúmenes
* [Qué es un volumen](#volumes-whats-a-volume)
* [Tipos](#volumes-types-of-volumes)
* [Ejemplo: `EmptyDir`](#volumes-example-emptydir)
* [Ejemplo: `gcePersistentDisk`](#volumes-example-gcepersistentdisk)

notes:

Hasta ahora hemos trabajado con aplicaciones sin estado. Las aplicaciones con estado necesitan de un mecanismo que les
permita almacenarlo para poder recuperarlo cuando los `Pods` se reinician o reprograman. Los Volúmenes
son la manera de conseguir esta persistencia.