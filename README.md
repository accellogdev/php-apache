# apachephpkerberos-server

Apache / PHP 8.5 Server /  OpenJDK 1.8

* Apache + HTTPS
* PHP 8.5 + PHP Zip
* PostgreSQL PDO
* composer
* OpenJDK 1.8
* tools
* Apache Mod Evasive
* Session com Redis or File

### Configurar Session

Utilizar variável de ambiente SESSION_HANDLER e SESSION_PATH.

### Configurar Arquivo

Utilizar variável de ambiente

#### Arquivo:

```
SESSION_HANDLER: files
SESSION_PATH: "/tmp"
```

#### Redis:

```
SESSION_HANDLER: redis
SESSION_PATH: "tpc://redis:6379"
```

# Teste de Compilar Docker

```
## gerando para desenvolvimento
docker build -f ./Dockerfile -t docker.io/accellogdev/php8.5-apache:v2.0 . --build-arg arg=develop
podman build -f ./Dockerfile -t docker.io/accellogdev/php8.5-apache:v2.0 . --build-arg arg=develop

## gerando para produção
docker build -f ./Dockerfile -t docker.io/accellogdev/php8.5-apache:v1.0 . --build-arg arg=production
podman build -f ./Dockerfile -t docker.io/accellogdev/php8.5-apache:v1.0 . --build-arg arg=production
```

## Renomear tag

```
docker tag php8.5-apache:v1.0 docker.io/accellogdev/php8.5-apache:v2.1-dev

podman tag php8.5-apache:v1.0 docker.io/accellogdev/php8.5-apache:v2.1-dev
```

## Push docker.io (precisa fazer login)

```
docker push docker.io/accellogdev/php8.5-apache:2.1-dev
podman push docker.io/accellogdev/php8.5-apache:2.1-dev
```