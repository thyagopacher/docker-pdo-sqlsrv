FROM php:7.4.3-apache
WORKDIR /var/www/html/

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions gd xdebug ssh2

COPY . ./
COPY config/php.ini $PHP_INI_DIR/php.ini
COPY config/xdebug.ini $PHP_INI_DIR/xdebug.ini

#copia de arquivos de configuração de hosts
COPY ./vhost/ /etc/apache2/sites-available/

RUN a2ensite email.local.conf
RUN a2ensite crmmw.local.conf
RUN a2ensite indicadores.local.conf
RUN a2ensite testador.local.conf

# Get repository and install wget and vim
RUN apt-get update \
    && apt-get install -y \
        nano \ 
        wget \
        apt-utils \
        gnupg \
        cron \ 
        libxslt-dev \
        software-properties-common \
        curl \
        apt-transport-https \
        unixodbc \
        unixodbc-dev \
        ca-certificates \
        tdsodbc \
        odbcinst \
        freetds-bin \
        freetds-common \
        && docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr \
        && docker-php-ext-install pdo_odbc

# Install Composer
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

RUN cp /usr/share/tdsodbc/odbcinst.ini /etc/

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -y tzdata \
    && ln -fs /usr/share/zoneinfo/America/Fortaleza /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

# necessário para sqlsrv
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - 
RUN curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update 
RUN ACCEPT_EULA=Y apt-get -y --no-install-recommends install msodbcsql17 unixodbc-dev 

RUN pecl install sqlsrv-5.8.0
RUN pecl install pdo_sqlsrv-5.8.0

RUN apt-get -y update \
&& apt-get install -y libicu-dev \ 
&& docker-php-ext-configure intl \
&& docker-php-ext-install intl

RUN docker-php-ext-install \
iconv \
sockets \
pdo \
mysqli \
pdo_mysql

RUN docker-php-ext-enable \
sqlsrv \
pdo_sqlsrv

RUN docker-php-ext-install calendar && docker-php-ext-configure calendar

# Clean repository
RUN apt-get autoremove -y && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*
#RUN sed -e 's/max_execution_time = 30/max_execution_time = 900/' -i /etc/php/7.3/fpm/php.ini

COPY ./ssl/*.pem /etc/apache2/ssl/

RUN a2enmod rewrite
RUN a2enmod headers
RUN a2enmod ssl

RUN mkdir -p /etc/apache2/ssl
COPY ./ssl/* /etc/apache2/ssl/

RUN service apache2 restart

#coloca um padrão melhor para memory do PHP
RUN cd /usr/local/etc/php/conf.d/ && \
  echo 'memory_limit = 2048M' >> /usr/local/etc/php/conf.d/docker-php-ram-limit.ini


EXPOSE 80 443