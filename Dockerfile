FROM alpine:latest
#
WORKDIR /app
COPY config/ ./
#
ARG APK_REPO=/etc/apk/repositories
RUN ls "${APK_REPO}" &> /dev/null && mv "${APK_REPO}" "${APK_REPO}.backup" || \
    touch "${APK_REPO}" && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v$(cat /etc/alpine-release | cut -d'.' -f1,2)/main" > "${APK_REPO}" && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v$(cat /etc/alpine-release | cut -d'.' -f1,2)/community" >> "${APK_REPO}" && \
    apk update && \
    export phpverx=$(alpinever=$(cat /etc/alpine-release|cut -d '.' -f1);[ $alpinever -ge 9 ] && echo  7|| echo 5) && \
    apk add apache2 php8$phpverx-apache2 openssh net-tools iputils-ping ufw iptables busybox-suid
#
ARG VAR_WWW_HTML=/var/www/localhost/htdocs
ARG SERVER_STATIC=static
RUN find /etc -name "php.ini" | while read line; \
    do mv "$line" "$line.backup" && \
    export dir_name=$(dirname "$line") && \
    mv *.ini "$dir_name"; \
    done && \
    ufw allow 80/tcp && \
    mkdir -p /run/apache2 && \
    mkdir -p "${SERVER_STATIC}" && \
    chmod -R a+r "${SERVER_STATIC}" && \
    mv *.html "${SERVER_STATIC}" && \
    rm -rf ${VAR_WWW_HTML}/* && \
    mv *.php ${VAR_WWW_HTML} && \
    mkdir -p "${VAR_WWW_HTML}/files" && \
    chmod -R a+rw "${VAR_WWW_HTML}/files"
#
ARG SSH_USER=root
ARG SSH_PASSWORD=admin
ARG ROOT_PASSWORD=admin
ARG SSH_CONFIG=/etc/ssh/sshd_config
RUN adduser -D -s /bin/sh ${SSH_USER} && \
    echo "${SSH_USER}:${SSH_PASSWORD}" | chpasswd && \
    echo "root:${ROOT_PASSWORD}" | chpasswd && \
    ssh-keygen -A && \
    ufw allow ssh && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' "${SSH_CONFIG}" && \
    sed -i '/PermitRootLogin/s/yes/no/' "${SSH_CONFIG}" && \
    sed -i '/#Port 22/s/#//' "${SSH_CONFIG}"
#
ENTRYPOINT [ "sh", "-c", "httpd -D BACKGROUND && /usr/sbin/sshd && ufw enable && sh" ]
