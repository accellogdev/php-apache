# apachephpkerberos-server

Apache / PHP 8.4 Server / OpenJDK 11

* Apache + HTTPS
* PHP 8.4 + PHP Extensions (Zip, GD, Redis, PostgreSQL, MySQL, etc.)
* PostgreSQL PDO
* MySQL PDO
* Composer 2.x
* OpenJDK 8.22
* Git, SVN, Mercurial
* Redis support
* Xdebug (development mode only)
* JIT compilation enabled
* Optimized OPcache settings
* Session com Redis ou File

## Principais melhorias na versão PHP 8.4

- **Property Hooks**: Nova funcionalidade para computed properties
- **Asymmetric Visibility**: Controle de visibilidade assimétrica em propriedades
- **HTML5 Support**: Suporte melhorado para HTML5 no DOM extension
- **JIT Optimizations**: Melhorias na compilação JIT
- **Performance**: Melhorias gerais de performance

## Extensões PHP incluídas

- bcmath
- bz2
- exif
- gd (com suporte a FreeType e JPEG)
- gmp
- iconv
- intl
- mbstring
- mysqli
- opcache (com JIT habilitado)
- pdo
- pdo_mysql
- pdo_pgsql
- pgsql
- redis
- soap
- xml
- zip
- xdebug (apenas em modo desenvolvimento)

### Configurar Session

Utilizar variável de ambiente SESSION_HANDLER e SESSION_PATH.

#### Arquivo:

```bash
SESSION_HANDLER=files
SESSION_PATH="/tmp"
```

#### Redis:

```bash
SESSION_HANDLER=redis
SESSION_PATH="tcp://redis:6379"
```

## Configurações de Build

### Desenvolvimento (com Xdebug)

```bash
# Docker
docker build -f ./Dockerfile -t docker.io/accellogdev/php8.4-apache:v1.0-dev . --build-arg arg=develop

# Podman
podman build -f ./Dockerfile -t docker.io/accellogdev/php8.4-apache:v1.0-dev . --build-arg arg=develop
```

### Produção

```bash
# Docker
docker build -f ./Dockerfile -t docker.io/accellogdev/php8.4-apache:v1.0 . --build-arg arg=production

# Podman
podman build -f ./Dockerfile -t docker.io/accellogdev/php8.4-apache:v1.0 . --build-arg arg=production
```

## Gerenciamento de Tags

```bash
# Docker
docker tag php8.4-apache:v1.0 docker.io/accellogdev/php8.4-apache:latest

# Podman
podman tag php8.4-apache:v1.0 docker.io/accellogdev/php8.4-apache:latest
```

## Push para Registry (necessário login)

```bash
# Docker
docker push docker.io/accellogdev/php8.4-apache:v1.0
docker push docker.io/accellogdev/php8.4-apache:latest

# Podman
podman push docker.io/accellogdev/php8.4-apache:v1.0
podman push docker.io/accellogdev/php8.4-apache:latest
```

## Variáveis de Ambiente Suportadas

- `SESSION_HANDLER`: Tipo de handler de sessão (files|redis)
- `SESSION_PATH`: Caminho ou URL para armazenamento de sessão
- `PHP_MEMORY_LIMIT`: Limite de memória PHP (padrão: 512M)
- `PHP_MAX_EXECUTION_TIME`: Tempo máximo de execução (padrão: 300s)

## Volumes Recomendados

```yaml
volumes:
  - ./app:/var/www/html
  - ./logs:/var/log/apache2
  - ./php-config:/usr/local/etc/php/conf.d
```

## Ports

- **80**: Apache HTTP
- **9003**: Xdebug (apenas modo desenvolvimento)

## Comandos Úteis

### Debug de configuração
```bash
docker run --rm php8.4-apache:v1.0 php -m  # Módulos carregados
docker run --rm php8.4-apache:v1.0 php --ini  # Arquivos de configuração
```
