# apachephpkerberos-server

Apache / PHP 8.2 Server /  OpenJDK 1.8

* Apache + HTTPS
* PHP 8.2 + PHP Zip
* PostgreSQL PDO
* composer
* OpenJDK 1.8
* tools
* Apache Mod Evasive
* Session com Redis or File

# Teste de Compilar Docker

```
## gerando para desenvolvimento
docker build -f ./Dockerfile -t php8.2-apache:v1.0 . --build-arg arg=develop
podman build -f ./Dockerfile -t php8.2-apache:v1.0 . --build-arg arg=develop

## gerando para produção
docker build -f ./Dockerfile -t php8.2-apache:v1.0 . --build-arg arg=production
podman build -f ./Dockerfile -t php8.2-apache:v1.0 . --build-arg arg=production
```
