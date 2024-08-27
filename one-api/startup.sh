#!/bin/bash

#git clone https://github.com/songquanpeng/one-api.git
# 构建前端
#cd one-api
# docker-compose up -d


#cd ./web/default
#npm install
#npm run build

# 构建后端
#cd ../..
#go mod download
#go build -ldflags "-s -w" -o one-api

#chmod u+x one-api
./one-api --port 3002 --log-dir ./logs
