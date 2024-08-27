#!/bin/bash
#docker run -d -name sandbox registry.cn-hangzhou.aliyuncs.com/fastgpt/fastgpt-sandbox:latest
docker-compose up -d && docker-compose logs -f
