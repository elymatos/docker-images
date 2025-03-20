docker build --tag=framenetbrasil/apache-php:v3.7 --no-cache --rm .
docker build --tag=framenetbrasil/apache-php:v3.6 --no-cache --rm .
docker run -d -p 9500:80 --name apache-php8 -v E:/Ely/devel/fnbr/lutma/backend:/var/www/html php:8.0-rc-apache
docker run -d -p 9500:80 --name apache-php8 -v E:/Ely/devel/fnbr/lutma/backend:/var/www/html framenetbrasil/apache-php:v3.4
docker build --tag=framenetbrasil/apache-php:v3.5.1 --no-cache --rm .
