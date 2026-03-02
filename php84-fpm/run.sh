#!/bin/bash
docker build --tag=framenetbrasil/php-fpm:8.4 --no-cache --rm .
docker login -u framenetbrasil
docker push framenetbrasil/php-fpm:8.4


