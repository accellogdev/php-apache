# apachephpkerberos-server
Apache / PHP 7.2 Server / kerberos / OpenJDK 1.8

* Apache + HTTPS + Let's Encrypt Certbot
* PHP 7.2 + PHP Zip
* PostgreSQL PDO
* composer
* sendmail
* kerberos
* OpenJDK 1.8
* tools
* Apache Mod Evasive

### Teste de Compilar Container

```
docker build -f ./Dockerfile -t php-apache:7.2-redis .
podman build -f ./Dockerfile -t php-apache:7.2-redis .
```

## Configuração Session

```
session.save_handler = ${SESSION_HANDLER}
session.save_path = ${SESSION_PATH}
```

### Configurar REDIS

Utilizar variável de ambiente

```
SESSION_HANDLER: redis
SESSION_PATH: "tpc://redis:6379"
```

### Configurar Arquivo

Utilizar variável de ambiente

```
SESSION_HANDLER: files
SESSION_PATH: "/tmp"
```