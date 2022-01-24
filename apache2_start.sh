#!/bin/bash

getcap /usr/sbin/httpd && /usr/sbin/httpd -e error -E /var/log/apache2/apache-start.log -DFOREGROUND && tail -f /var/log/apache2/*
