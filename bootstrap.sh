#!/bin/bash

mkcert -install
cp "$(mkcert -CAROOT)/rootCA.pem" rootCA.pem
cp "$(mkcert -CAROOT)/rootCA-key.pem" rootCA-key.pem
openssl pkcs12 -export -out rootCA.p12 -in rootCA.pem -inkey rootCA-key.pem -passout pass:"${ROOT_CERT_PASSWORD}"
mkcert localhost db vault public-mq private-mq tsd proxy kibana logstash elasticsearch
openssl pkcs12 -export -out localhost+9.p12 -in localhost+9.pem -inkey localhost+9-key.pem -passout pass:"${SERVER_CERT_PASSWORD}"
mkcert -client localhost db vault public-mq private-mq tsd proxy kibana logstash elasticsearch
openssl pkcs12 -export -out localhost+9-client.p12 -in localhost+9-client.pem -inkey localhost+9-client-key.pem -passout pass:"${CLIENT_CERT_PASSWORD}"
openssl pkcs8 -topk8 -inform PEM -in localhost+9-client-key.pem -outform DER -nocrypt -out localhost+9-client-key.der

docker swarm init
docker config create rootCA.pem rootCA.pem
docker config create rootCA.p12 rootCA.p12
docker config create server.pem localhost+9.pem
docker config create server-key.pem localhost+9-key.pem
docker config create server.p12 localhost+9.p12
docker config create client.pem localhost+9-client.pem
docker config create client-key.pem localhost+9-client-key.pem
docker config create client-key.der localhost+9-client-key.der
docker config create client.p12 localhost+9-client.p12
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

cp default.elasticsearch.yml elasticsearch.yml
docker config create elasticsearch.yml elasticsearch.yml

cp default.kibana.yml kibana.yml
perl -i -pe 's!ELASTIC_PASSWORD!$ENV{"ELASTIC_PASSWORD"}!g' kibana.yml
docker config create kibana.yml kibana.yml

cp default.logstash.yml logstash.yml
perl -i -pe 's!ELASTIC_PASSWORD!$ENV{"ELASTIC_PASSWORD"}!g' logstash.yml
docker config create logstash.yml logstash.yml

cp default.logstash.conf logstash.conf
perl -i -pe 's!ELASTIC_PASSWORD!$ENV{"ELASTIC_PASSWORD"}!g' logstash.conf
docker config create logstash.conf logstash.conf

docker-compose config > docker-stack.yml
