FROM debian:buster


ARG DEBIAN_FRONTEND=noninteractive

# https://linuxize.com/post/how-to-install-apache-on-debian-10/
# https://www.linode.com/docs/security/ssl/ssl-apache2-debian-ubuntu/
# https://www.linode.com/docs/security/ssl/create-a-self-signed-tls-certificate/
# https://www.linode.com/docs/websites/hosting-a-website-ubuntu-18-04/

# RUN \
#     sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
#     sed -i 's|security.debian.org/debian-security|mirrors.ustc.edu.cn/debian-security|g' /etc/apt/sources.list

RUN \
    apt-get -q -y update && \
    apt-get install -q -y procps vim-tiny curl && \
    apt-get install -q -y apache2 libapache2-mod-php php-mbstring php-curl php-ldap

COPY ssp-site.conf /etc/apache2/sites-available/

RUN \
    chown root:root /etc/apache2/sites-available/ssp-site.conf && \
    chmod 644 /etc/apache2/sites-available/ssp-site.conf && \
    a2enmod ssl && \
    a2dissite *default && \
    a2ensite ssp-site.conf && \
    curl -L https://ltb-project.org/archives/ltb-project-self-service-password-1.3.tar.gz -o ssp.tar.gz  && \
    tar xf ssp.tar.gz -C /var/www/html && rm -f ssp.tar.gz && \
    mv /var/www/html/ltb-project-self-service-password-1.3 /var/www/html/ssp && \
    chown -R www-data:www-data /var/www/html/ssp && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


EXPOSE 443
WORKDIR /var/www/html/

CMD ["apache2ctl","-D","FOREGROUND"]