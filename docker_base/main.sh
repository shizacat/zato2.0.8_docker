#!/bin/bash

ZATO_BASE=/opt/zato/code
ZATO_TEMPLATE=${ZATO_BASE}/config_template
ZATO_CONF=${ZATO_BASE}/conf

CMD=""

# ==========================================

function web_update_password_web {
	echo "command=update_password" > /tmp/up.config
	echo "path=/opt/zato/code/conf" >> /tmp/up.config
	echo "store_config=False" >> /tmp/up.config
	echo "username=admin" >> /tmp/up.config
	echo "password=${ADMIN_PASSWORD}" >> /tmp/up.config

	${ZATO_BASE}/bin/zato from-config /tmp/up.config

	rm /tmp/up.config
}

function web_create_config_zato {
	echo "odb_type=${ODB_TYPE}" >> ${ZATO_TEMPLATE}/web_template.config
	echo "odb_host=${ODB_HOST}" >> ${ZATO_TEMPLATE}/web_template.config
	echo "odb_port=${ODB_PORT}" >> ${ZATO_TEMPLATE}/web_template.config
	echo "odb_user=${ODB_USER}" >> ${ZATO_TEMPLATE}/web_template.config
	echo "odb_db_name=${ODB_DB_NAME}" >> ${ZATO_TEMPLATE}/web_template.config
	echo "odb_password=${ODB_PASSWORD}" >> ${ZATO_TEMPLATE}/web_template.config
	echo "postgresql_schema=${POSTGRESQL_SCHEMA}" >> ${ZATO_TEMPLATE}/web_template.config
	echo "tech_account_name=${TECH_ACCOUNT_NAME}" >> ${ZATO_TEMPLATE}/web_template.config
	echo "tech_account_password=${TECH_ACCOUNT_PASSWORD}" >> ${ZATO_TEMPLATE}/web_template.config

	echo "store_config=False" >> ${ZATO_TEMPLATE}/web_template.config
}

function web_setup {
	web_create_config_zato

	mkdir -p ${ZATO_CONF}
	${ZATO_BASE}/bin/zato from-config ${ZATO_TEMPLATE}/web_template.config

	web_update_password_web
	# sed -i 's/127.0.0.1/0.0.0.0/g' /opt/zato/env/web-admin/config/repo/web-admin.conf
}

function web_start {
	trap "${ZATO_BASE}/bin/zato stop ${ZATO_CONF}; exit" SIGINT SIGTERM

	rm -f ${ZATO_CONF}/pidfile

	${ZATO_BASE}/bin/zato start $ZATO_CONF --fg
}

function fn_web {
	if [ ! -d "${ZATO_CONF}" ]; then
		web_setup
	fi

	if [ ! "$(ls -A ${ZATO_CONF})" ]; then
		web_setup
	fi

	web_start
}

# -------

function server_create_config {
	echo "odb_type=${ODB_TYPE}" >> ${ZATO_TEMPLATE}/server_template.config
	echo "odb_host=${ODB_HOST}" >> ${ZATO_TEMPLATE}/server_template.config
	echo "odb_port=${ODB_PORT}" >> ${ZATO_TEMPLATE}/server_template.config
	echo "odb_user=${ODB_USER}" >> ${ZATO_TEMPLATE}/server_template.config
	echo "odb_db_name=${ODB_DB_NAME}" >> ${ZATO_TEMPLATE}/server_template.config
	echo "odb_password=${ODB_PASSWORD}" >> ${ZATO_TEMPLATE}/server_template.config
	echo "postgresql_schema=${POSTGRESQL_SCHEMA}" >> ${ZATO_TEMPLATE}/server_template.config

	echo "kvdb_host=${KVDB_HOST}" >> ${ZATO_TEMPLATE}/server_template.config
	echo "kvdb_port=${KVDB_PORT}" >> ${ZATO_TEMPLATE}/server_template.config
	echo "kvdb_password=${KVDB_PASSWORD}" >> ${ZATO_TEMPLATE}/server_template.config

	echo "cluster_name=${CLUSTER_NAME}" >> ${ZATO_TEMPLATE}/server_template.config
	echo "server_name=${SERVER_NAME}" >> ${ZATO_TEMPLATE}/server_template.config

	echo "store_config=False" >> ${ZATO_TEMPLATE}/server_template.config
}

function server_setup {
	server_create_config

	mkdir -p ${ZATO_CONF}
	${ZATO_BASE}/bin/zato from-config ${ZATO_TEMPLATE}/server_template.config

	sed -i 's/gunicorn_workers=2/gunicorn_workers=1/g' ${ZATO_CONF}/config/repo/server.conf
	sed -i 's/localhost:17010/0.0.0.0:17010/g' ${ZATO_CONF}/config/repo/server.conf
}

function server_start {
	trap "${ZATO_BASE}/bin/zato stop ${ZATO_CONF}; exit" SIGINT SIGTERM

	rm -f ${ZATO_CONF}/pidfile

	${ZATO_BASE}/bin/zato start $ZATO_CONF --fg
}

function fn_server {
	if [ ! -d "${ZATO_CONF}" ]; then
		server_setup
	fi

	if [ ! "$(ls -A ${ZATO_CONF})" ]; then
		server_setup
	fi

	server_start
}

# -------

function balancer_setup {
	mkdir -p ${ZATO_CONF}
	${ZATO_BASE}/bin/zato from-config ${ZATO_BASE}/config_template/loadbalancer_template.config

	sed -i 's/127.0.0.1:11223/0.0.0.0:11223/g' ${ZATO_CONF}/config/repo/zato.config
	sed -i 's/localhost/0.0.0.0/g' ${ZATO_CONF}/config/repo/lb-agent.conf
}

function balancer_start {
	trap "${ZATO_BASE}/bin/zato stop ${ZATO_CONF}; exit" SIGINT SIGTERM

	rm -f ${ZATO_CONF}/zato-lb-agent.pid
	rm -f ${ZATO_CONF}/pidfile

	${ZATO_BASE}/bin/zato start ${ZATO_CONF} --fg
}

function fn_balancer {
	if [ ! -d "${ZATO_CONF}" ]; then
		balancer_setup
	fi

	if [ ! "$(ls -A ${ZATO_CONF})" ]; then
		balancer_setup
	fi

	balancer_start
}

# ==========================================

if  [ $# -ge 1 ] && [ "$1" == "cmd" ]; then
	shift
	if [ $# -ge 1 ]; then
		CMD=$1
		shift
	fi
fi

if [ "$CMD" == "help" ]; then
	fn_help
	exit 0
fi

if [ "$CMD" == "server" ]; then
	fn_server
	exit 0
fi

if [ "$CMD" == "web" ]; then
	fn_web
	exit 0
fi

if [ "$CMD" == "balancer" ]; then
	fn_balancer
	exit 0
fi

${ZATO_BASE}/bin/zato $@