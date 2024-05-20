docker-compose up -d


chmod 777 post_install.sh


bash post_install.sh


#ssl 443
add certs
mv nginx.conf.ssl nginx.conf



docker volume create --driver local --opt type=nfs --opt o=addr=ip,rw --opt device=:/mnt/docker nfs-volume
