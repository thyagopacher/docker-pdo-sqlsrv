# Docker SQL Server com PHP #

Maneira mais fácil de usar o docker para SQL Server ele tem o host para navegar nos scripts. Use a pasta /web para por qualquer script PHP novo criado

 - Ele é composto por VirtualHost pode ser visto no arquivo vhost.conf
 - Caso queira mudar a versão do PHP só ir no Dockerfile no começo do arquivo.

para rodar usa: 
```
docker-compose build
docker-compose up -d
```