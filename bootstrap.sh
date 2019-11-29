#!/bin/bash

mkcert -install
mkcert localhost db vault public-mq private-mq
openssl pkcs12 -export -out localhost+4.p12 -in localhost+4.pem -inkey localhost+4-key.pem -passout pass:"${CERT_PASSWORD}"
mkcert -client localhost db vault public-mq private-mq
openssl pkcs8 -topk8 -inform PEM -in localhost+4-client-key.pem -outform DER -nocrypt -out localhost+4-client-key.der

docker swarm init
docker config create rootCA.pem "$(mkcert -CAROOT)/rootCA.pem"
docker config create server.pem localhost+4.pem
docker config create server-key.pem localhost+4-key.pem
docker config create server.p12 localhost+4.p12
docker config create client.pem localhost+4-client.pem
docker config create client-key.pem localhost+4-client-key.pem
docker config create client-key.der localhost+4-client-key.der
docker config create jwt.pub.pem jwt.pub.pem

echo "${KEY_PASSWORD}" > ega.sec.pass
crypt4gh -g ega -kf crypt4gh -kp "${KEY_PASSWORD}"
docker config create ega.sec.pem ega.sec.pem
docker config create ega.sec.pass ega.sec.pass
docker config create ega.pub.pem ega.pub.pem

cp default.conf.ini conf.ini
perl -i -pe 's!KEY_PASSWORD!$ENV{"KEY_PASSWORD"}!g' conf.ini
perl -i -pe 's!MINIO_ACCESS_KEY!$ENV{"MINIO_ACCESS_KEY"}!g' conf.ini
perl -i -pe 's!MINIO_SECRET_KEY!$ENV{"MINIO_SECRET_KEY"}!g' conf.ini
perl -i -pe 's!DB_HOST!$ENV{"DB_HOST"}!g' conf.ini
perl -i -pe 's!DB_LEGA_IN_PASSWORD!$ENV{"DB_LEGA_IN_PASSWORD"}!g' conf.ini
perl -i -pe 's!MQ_CONNECTION!$ENV{"MQ_CONNECTION"}!g' conf.ini
docker config create conf.ini conf.ini
