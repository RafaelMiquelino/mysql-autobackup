FROM debian:10.9-slim
ARG FREQ_FULL_BACKUP=weekly
ARG FREQ_BINLOG_BACKUP=daily
ARG SCRIPTS_LOCATION=/opt/mysql/scripts
ARG RCLONE_CONFIG_LOCATION=/root/.config/rclone
ARG MYSQLSH_PKG_URL=https://dev.mysql.com/get/Downloads/MySQL-Shell/mysql-shell_8.0.23-1debian10_amd64.deb
ARG RCLONE_PKG_URL=https://downloads.rclone.org/v1.55.0/rclone-v1.55.0-linux-amd64.deb

RUN set -ex && \
    apt-get update && \
    apt-get install -y \
        wget \
        cron \
        jq

RUN wget -qO /tmp/mysql-shell.deb ${MYSQLSH_PKG_URL} && \
    dpkg -i /tmp/mysql-shell.deb || true && \
    apt-get -f -y install && \
    rm -rf /tmp/mysql-shell.deb

RUN wget -qO /tmp/rclone.deb ${RCLONE_PKG_URL} && \
    dpkg -i /tmp/rclone.deb

RUN mkdir -p ${SCRIPTS_LOCATION}
COPY ./scripts/* ${SCRIPTS_LOCATION}/
RUN chmod a+x ${SCRIPTS_LOCATION}/* && \
    ln -s ${SCRIPTS_LOCATION}/backup-db /bin/backup-db && \
    ln ${SCRIPTS_LOCATION}/backup-db /etc/cron.${FREQ_FULL_BACKUP}/backup-db && \
    ln -s ${SCRIPTS_LOCATION}/backup-binlog /bin/backup-binlog && \
    ln ${SCRIPTS_LOCATION}/backup-binlog /etc/cron.${FREQ_BINLOG_BACKUP}/backup-binlog

RUN mkdir -p ${RCLONE_CONFIG_LOCATION}
COPY ./rclone_config/* ${RCLONE_CONFIG_LOCATION}/

COPY ./entrypoint.sh /
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
