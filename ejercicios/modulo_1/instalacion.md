Para verificar si docker esta instalado.
```bash
docker --version
```
Para verificar si docker esta corriendo.
```bash
docker ps
```
Para verificar si docker esta corriendo.
```bash
docker ps -a
```
Para descargar la imagen de postgres.
```bash
docker  pull postgres
```
Para Crear un contenedor de postgres.
```bash
docker run --name northwind `
-e POSTGRES_USER=tu_usuario `
-e POSTGRES_PASSWORD=tu_contraseña `
-e POSTGRES_DB=tu_base_de_datos `
-p 5432:5432 `
-d postgres
```
