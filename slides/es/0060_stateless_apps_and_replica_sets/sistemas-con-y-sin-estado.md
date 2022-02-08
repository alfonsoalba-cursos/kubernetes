### Sistemas con estado vs sin estado

^^^^^^ 

### Sistemas sin estado


* No guardan información sobre las operaciones anteriores ni se hace referencia a ellas
* Cada operación se lleva a cabo desde cero, como si fuera la primera vez
* Ejemplos: El frontal de una aplicación web, un microservicio que comprime ficheros, 
  un servicio que convierte imágenes de un formato a otro

^^^^^^

### Sistemas con estado
						
* Una operación puede hacer referencia o verse afectada por las operaciones anteriores
* Ejemplos: una base de datos