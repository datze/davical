#Version 0.4
#Davical + apache
#---------------------------------------------------------------------
#Default configuration: hostname: davical.example
#			user: admin			
#			pass: 12345
#---------------------------------------------------------------------

FROM 	alpine
MAINTAINER https://github.com/datze 

ARG     TIME_ZONE "Europe/Rome"
ENV	TIME_ZONE=$TIME_ZONE

ARG     HOST_NAME "davical.example"
ENV	HOST_NAME=$HOST_NAME


RUN addgroup -S apache && adduser -S apache -G apache

# apk
RUN	apk --update add \
	sudo \
	bash \
	less \
	sed \
	apache2 \
	apache2-utils \
	apache2-ssl \
	php7 \
	php7-apache2 \
	php7-pgsql \
	php7-imap \
	php7-curl \
	php7-cgi \
	php7-xml \
	php7-gettext \ 
	php7-iconv \ 
	php7-ldap \
	php7-pdo \
	php7-pdo_pgsql \
	php7-calendar \
	php7-session \
	git \
        libcap \
# git
	&& git clone https://gitlab.com/davical-project/awl.git /usr/share/awl/ \
	&& git clone https://gitlab.com/davical-project/davical.git /usr/share/davical/ \
	&& rm -rf /usr/share/davical/.git /usr/share/awl/.git/ \
	&& apk del git


# config files, shell scripts
COPY	apache2_start.sh /sbin/apache2_start.sh
COPY	apache.conf /config/apache.conf
COPY	davical.php /config/davical.php

# Apache
RUN chown -R root:apache /usr/share/davical \
	&& cd /usr/share/davical/ \
	&& find ./ -type d -exec chmod u=rwx,g=rx,o=rx '{}' \; \
	&& find ./ -type f -exec chmod u=rw,g=r,o=r '{}' \; \
	&& find ./ -type f -name *.sh -exec chmod u=rwx,g=r,o=rx '{}' \; \
	&& find ./ -type f -name *.php -exec chmod u=rwx,g=rx,o=r '{}' \; \
	&& chmod o=rx /usr/share/davical \
	&& chown -R root:apache /usr/share/awl \
	&& cd /usr/share/awl/ \
	&& find ./ -type d -exec chmod u=rwx,g=rx,o=rx '{}' \; \
	&& find ./ -type f -exec chmod u=rw,g=r,o=r '{}' \; \
	&& find ./ -type f -name *.sh -exec chmod u=rwx,g=rx,o=r '{}' \; \
	&& find ./ -type f -name *.sh -exec chmod u=rwx,g=r,o=rx '{}' \; \
	&& chmod o=rx /usr/share/awl \
        && mkdir /etc/davical \
	&& sed -i /CustomLog/s/^/#/ /etc/apache2/httpd.conf \
	&& sed -i /ErrorLog/s/^/#/ /etc/apache2/httpd.conf \
	&& sed -i /TransferLog/s/^/#/ /etc/apache2/httpd.conf \
	&& sed -i /CustomLog/s/^/#/ /etc/apache2/conf.d/ssl.conf \
	&& sed -i /ErrorLog/s/^/#/ /etc/apache2/conf.d/ssl.conf \
	&& sed -i /TransferLog/s/^/#/ /etc/apache2/conf.d/ssl.conf \
# permissions for shell scripts and config files
	&& chmod 0755 /sbin/apache2_start.sh \
	&& chown -R root:apache /etc/davical \
	&& chmod -R u=rwx,g=rx,o= /etc/davical \
	&& chown root:apache /config/davical.php \
	&& chmod u+rwx,g+rx /config/davical.php \
	&& ln -s /config/apache.conf /etc/apache2/conf.d/davical.conf \	
	&& ln -s /config/davical.php /etc/davical/config.php \
# clean-up etc
	&& rm -rf /var/cache/apk/* \
 	&& mkdir -p /run/apache2 \
        && chown -R apache:apache /var/www /run/apache2 /var/log/apache2 /etc/ssl/apache2 \
        && rm /etc/apache2/conf.d/ssl.conf

#SET THE TIMEZONE
RUN apk add --update tzdata
RUN cp /usr/share/zoneinfo/$TIME_ZONE /etc/localtime
RUN echo $TIME_ZONE > /etc/timezone
RUN apk del tzdata

RUN setcap cap_net_bind_service=+epi /usr/sbin/httpd

USER apache
