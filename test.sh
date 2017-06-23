#!/bin/bash

set -e
set -x

docker-compose stop -t 0
docker-compose rm -f

rm -f key.pem cert.pem
go run generate_cert.go -ca -host "127.0.0.1,test.localhost.23c.se,test2.localhost.23c.se,localhost"
mkdir -p ~/.mc/certs/CAs/
cp -f cert.pem ~/.mc/certs/CAs/TEST.pem

docker-compose up -d
mc config host add test1t https://test.localhost.23c.se testTESTtest testTESTtest
mc config host add test2t https://test2.localhost.23c.se testTESTtest testTESTtest
mc config host add test1 http://localhost:9000 testTESTtest testTESTtest
mc config host add test1n https://test.localhost.23c.se:8000 testTESTtest testTESTtest

sleep 5
mc mb test1t/testbucket
mc mb test2t/testbucket

mc cp docker-compose.yml test1t/testbucket/some/dir
mc cp docker-compose.yml test1n/testbucket/some/dir2

# this fails
mc --debug mirror test1n/testbucket test2t/testbucket
# mc --debug mirror test2t/testbucket test1n/testbucket

# exit 0



# clean up

rm -f ~/.mc/certs/CAs/TEST.pem
rm -f key.pem cert.pem
mc config host rm test1
mc config host rm test1t
mc config host rm test1n
mc config host rm test2t
