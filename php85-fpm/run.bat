docker build --tag=framenetbrasil/php-fpm:8.5 --no-cache --rm .
docker login -u framenetbrasil
docker push framenetbrasil/php-fpm:8.5


