# Zato base image

FROM ubuntu:16.04
MAINTAINER ShizaCat <...@zato.io>

# Install helper programs used during Zato installation
RUN apt-get update && \
	apt-get install -y \
		apt-transport-https \
		python-software-properties \
		software-properties-common \
		telnet \
	&& apt-get -y autoremove && \
	rm -rf /var/lib/apt/lists/*

# Build Zato
RUN apt-get update && \
	apt-get install -y \
		sudo \
		git \
		curl \
		wget \
	&& \
	git clone https://github.com/zatosource/zato.git /opt/zato && \
	cd /opt/zato && \
	git checkout support/2.0 && \
	cd /opt/zato/code && \
	/opt/zato/code/install.sh && \
	/opt/zato/code/bin/python bootstrap.py && \
	/opt/zato/code/bin/buildout && \
	apt-get remove -y \
		git \
		curl \
		wget \
	&& \
	apt-get -y autoremove && \
	rm -rf /var/lib/apt/lists/*

RUN set -a

# db
ENV ODB_TYPE=postgresql
ENV ODB_HOST=
ENV ODB_PORT=5432 
ENV ODB_USER=
ENV ODB_DB_NAME=
ENV ODB_PASSWORD=

ENV POSTGRESQL_SCHEMA=

# Redis
ENV KVDB_HOST=127.0.0.1
ENV KVDB_PORT=6379
ENV KVDB_PASSWORD=

# server
ENV CLUSTER_NAME=
ENV SERVER_NAME=

# web
ENV TECH_ACCOUNT_NAME=
ENV TECH_ACCOUNT_PASSWORD=
ENV ADMIN_PASSWORD=

RUN mkdir /opt/zato/code/config_template && \
	mkdir /opt/zato/code/conf && \
	mkdir /opt/zato/code/cert

COPY ./config_template/ /opt/zato/code/config_template/
COPY ./main.sh /bin/main.sh

RUN ln -s /opt/zato/code/bin/zato /bin/zato && \
	chmod +x /bin/main.sh


WORKDIR	/opt/zato/code/

# ENTRYPOINT ["/opt/zato/code/bin/zato"]
ENTRYPOINT ["/bin/main.sh"]
# CMD ["/opt/zato/code/bin/zato"]
