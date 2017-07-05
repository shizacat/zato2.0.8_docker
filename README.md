# Docker

## Build

```bash
cd docker_base
docker build -t shizacat/zato_base_2.0.8:<tag> .
docker push shizacat/zato_base_2.0.8:<tag>
```

## Volume

- /opt/zato/code/conf - Configuration zato
- /opt/zato/code/cert - Folder with certificates

## Naming certificate files

The names will match what will generate the gencert script.
Excluded only for server certificates. For them, each will need to remove the index in the name of the certificate when it is transferred to the container, for example:

```
 zato.server1.cert.pem -> zato.server.cert.pem
```

## CMD Balancer

### Ports

- 11223
- 20151

## CMD Server

### Environmets

- CLUSTER_NAME
- SERVER_NAME

- KVDB_HOST
- KVDB_PORT
- KVDB_PASSWORD

- ODB_DB_NAME
- ODB_PASSWORD
- ODB_HOST
- ODB_PORT
- ODB_TYPE
- ODB_USER
- POSTGRESQL_SCHEMA

### Ports
- 17010

## CMD Web

### Environmets

- ODB_DB_NAME
- ODB_PASSWORD
- ODB_HOST
- ODB_PORT
- ODB_TYPE
- ODB_USER
- POSTGRESQL_SCHEMA

- TECH_ACCOUNT_NAME
- TECH_ACCOUNT_PASSWORD
- ADMIN_PASSWORD

### Ports

- 8183

# Разворачивание

## Create Zato ODB

```
docker run --rm zato_base_2.0.8 \
    create odb postgresql \
    --odb_host localhost \
    --odb_port 5432 \
    --odb_user zato1 \
    --odb_password password \
    --odb_db_name zatodb1
```

## Create cluster

Creates a cluster’s configuration in the ODB.
- https://zato.io/docs/admin/cli/create-cluster.html

Смотрите хелп, они немного меняют аргументы

Указываем технический аккаунт, он должен быть такой же и для веба!!! (tech_account_name, --tech_account_password)

```bash
# Example
docker run --rm zato_base_2.0.8 \
    create cluster postgresql \
    --odb_host localhost \
    --odb_port 5432 \
    --odb_user zato1 \
    --odb_db_name zatodb1 \
    --tech_account_password tech_password \
    <lb_host> 11223 20151 \
    <redis_host> 6379 \
    <cluster_name> \
    <tech_account_name>
```

## Create certificates

Взят скрипт из quick_setup:

```bash
scripts/gencert.sh
```

## Create and start Zato components

Создается при передаче команд в докер контейнер

Команды:
- cmd balancer
- cmd server
- cmd web

### Load Balancer

```bash
docker run \
    -v /test/conf-bl:/opt/zato/code/conf \
    -v /test/cert:/opt/zato/code/cert \
    -p 11223:11223 \
    -p 20151:20151 \
    --name zt28_bl \
    -d \
    zato_base_2.0.8 \
    cmd balancer
```

### Server

```bash
docker run \
    -v /test/conf-srv1:/opt/zato/code/conf \
    -v /test/cert:/opt/zato/code/cert \
    -p 17010:17010 \
    -e ODB_TYPE="postgresql" \
    -e ODB_HOST="10.211.55.90" \
    -e ODB_PORT="5432" \
    -e ODB_USER="postgres" \
    -e ODB_DB_NAME="zato" \
    -e ODB_PASSWORD="123456" \
    -e KVDB_HOST="10.211.55.90" \
    -e KVDB_PASSWORD="test" \
    -e CLUSTER_NAME="cluster-test2" \
    -e SERVER_NAME="srv1" \
    --name zt28_srv1 \
    -d \
    zato_base_2.0.8 \
    cmd server
```

### Web Admin

```bash
docker run \
    -v /test/conf-web:/opt/zato/code/conf \
    -v /test/cert:/opt/zato/code/cert \
    -p 8183:8183 \
    -e ODB_TYPE="postgresql" \
    -e ODB_HOST="10.211.55.90" \
    -e ODB_PORT="5432" \
    -e ODB_USER="postgres" \
    -e ODB_DB_NAME="zato" \
    -e ODB_PASSWORD="123456" \
    -e TECH_ACCOUNT_NAME="tech" \
	-e TECH_ACCOUNT_PASSWORD="12345" \
	-e ADMIN_PASSWORD="admin" \
    --name zt28_web \
    -d \
    zato_base_2.0.8 \
    cmd web
```
