docker-compose up -d


chmod 777 post_install.sh


bash post_install.sh


#ssl 443
add certs
mv nginx.conf.ssl nginx.conf


Не забудь поменять секретные ключи...
.sh .yml


docker volume create --driver local --opt type=nfs --opt o=addr=[ip],rw --opt device=:/mnt/docker nfs-volume


SSL 

1. Установи OpenSSL на сервере, если его еще нет.
2. Открой терминал и выполните команду для генерации закрытого ключа:
   
   
   openssl genrsa -out cert.pem 2048
   

3. Затем создай запрос на сертификат (CSR) с помощью команды:
   
   
   openssl req -new -key ключ.pem -out cert.csr
   

4. Следуй инструкциям по заполнению информации о сертификате (Common Name, организация и т.д.).
5. Далее создай самоподписанный сертификат из CSR:
   
   
   openssl x509 -req -days 365 -in запрос.csr -signkey ключ.pem -out cert.pem
   

6. Теперь у тебя есть свой самоподписанный SSL-сертификат!


