FROM php:7.1.33-zts-stretch
# FROM php:7.1.33-fpm-stretch

RUN apt update && apt install -y \
    admesh \
    apt-transport-https \
    git \
    gnupg \
    libzip-dev \
    povray \
    python3-setuptools \
    vim \
    wget \
    && rm -rf /var/lib/apt/lists/*

# RUN COPY docker-php-ext-get /usr/local/bin/

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && sync

RUN install-php-extensions zip pdo_mysql

# install elasticsearch
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list
RUN apt update && apt install elasticsearch

RUN /bin/systemctl enable elasticsearch.service

#install node 8 because newever version go kaboom
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt install -y nodejs

#install ldview
RUN wget https://github.com/tcobbs/ldview/releases/download/v4.3/ldview-osmesa_4.3-stretch_amd64.deb
RUN apt install -y /ldview-osmesa_4.3-stretch_amd64.deb

#install stl2pov
RUN git clone https://github.com/rsmith-nl/stltools.git
WORKDIR stltools
RUN python3 setup.py install
WORKDIR /

#install composer
RUN wget https://getcomposer.org/installer
RUN php installer
RUN mv composer.phar /usr/local/bin/composer

RUN git clone https://github.com/hubnedav/PrintABrick.git
WORKDIR /PrintABrick
RUN composer install

# setup front ned
RUN npm install
RUN npm install bower -g

RUN bower install --allow-root
RUN node_modules/gulp/bin/gulp.js

RUN apt install -y mysql-server
#configure mysql
#start and let root access to server

#RUN php bin/console doctrine:database:create
#RUN php bin/console doctrine:schema:create

#RUN php bin/console doctrine:fixtures:load

#RUN php bin/console app:init