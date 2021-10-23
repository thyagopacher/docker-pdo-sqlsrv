### Docker SQL Server com PHP ###

Maneira mais fácil de usar o docker para SQL Server ele tem o host para navegar nos scripts. Use a pasta /web para por qualquer script PHP novo criado

 - Ele é composto por VirtualHost pode ser visto no arquivo vhost.conf
 - Caso queira mudar a versão do PHP só ir no Dockerfile no começo do arquivo.
 - Suporte a Mailhog no docker-compose, ele é muito útil como um falso SMTP interceptando todas as mensagens enviadas em localhost, ambiente de DEV. Pode ser visto através do host = http://localhost:8025/

para rodar usa: 
```
docker-compose build
docker-compose up -d
```