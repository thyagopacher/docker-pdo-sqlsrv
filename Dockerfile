FROM php:7.3.28-apache

MAINTAINER Thyago Henrique Pacher <thyago.pacher@gmail.com>

WORKDIR /var/www/html/

COPY . ./

RUN echo " == Criando pasta integrador-dev == "
RUN mkdir -p /var/www/html/integrador-dev/
COPY php.ini $PHP_INI_DIR/php.ini

COPY vhost.conf /etc/apache2/sites-available/sites.local.conf

RUN a2ensite sites.local.conf

# Get repository and install wget and vim
RUN apt-get update && apt-get install -y \
    wget \
    apt-utils \
    gnupg \
    cron \ 
    libxslt-dev \
    software-properties-common \
    apt-transport-https \
    libxml2-dev \
    unixodbc-dev \
    git \
    openssh-server \    
    libzip-dev

# Install Composer
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

# Authorize SSH Host
RUN mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh && \
    ssh-keyscan github.com > /root/.ssh/known_hosts

# Add the keys and set permissions
RUN echo "$ssh_prv_key" > /root/.ssh/id_rsa && \
    echo "$ssh_pub_key" > /root/.ssh/id_rsa.pub && \
    chmod 600 /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa.pub

# necessário para sqlsrv
RUN wget -qO - https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && wget -qO - https://packages.microsoft.com/config/debian/10/prod.list \
        > /etc/apt/sources.list.d/mssql-release.list

# Install PHP extensions deps
RUN apt-get update \
&& apt-get install --no-install-recommends -y \
libfreetype6-dev \
libjpeg62-turbo-dev \
libmcrypt-dev \
libpng-dev \
libjpeg-dev \
libmagickwand-dev \
zlib1g-dev \
libicu-dev \
g++ \
unixodbc-dev \ 
&& ACCEPT_EULA=Y apt-get install --no-install-recommends -y msodbcsql17 mssql-tools \
&& apt-get install --no-install-recommends -y libxml2-dev \
libaio-dev \
libmemcached-dev \
freetds-dev \
libssl-dev \
openssl \
supervisor

RUN docker-php-ext-configure calendar && docker-php-ext-install calendar

# Install PHP extensions
RUN pecl install sqlsrv-5.6.0 pdo_sqlsrv-5.6.0


RUN apt-get -y update \ 
&& apt-get install -y libicu-dev \ 
&& docker-php-ext-configure intl \ 
&& docker-php-ext-install intl

RUN echo " == Instalando CURL == "
RUN apt-get install curl

RUN echo " == Baixando setup NodeJS == "
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install --yes nodejs
RUN node -v
RUN npm -v
RUN npm i -g nodemon
RUN npm i -g forever
RUN nodemon -v

# PRA VER SE TEM ALGUM BUG NO PHP
# RUN php -i | grep "Configure Command"

RUN docker-php-ext-install \
iconv \
sockets \
pdo \
pdo_mysql \
xsl \
exif \
xml \
zip \
bcmath \
xmlrpc \
zip \
gd \
&& docker-php-ext-enable \
sqlsrv \
pdo_sqlsrv \
gd

# Clean repository
RUN apt-get autoremove -y && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*
#RUN sed -e 's/max_execution_time = 30/max_execution_time = 900/' -i /etc/php/7.3/fpm/php.ini

RUN a2enmod rewrite


RUN a2enmod headers

#coloca um padrão melhor para memory do PHP
RUN cd /usr/local/etc/php/conf.d/ && \
  echo 'memory_limit = 2048M' >> /usr/local/etc/php/conf.d/docker-php-ram-limit.ini

EXPOSE 80
