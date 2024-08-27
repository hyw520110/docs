#!/bin/bash

if [ "$1" == "-f" ]; then 
    docker-compose down && rm -rf ./mongo/ ./mysql/ ./oneapi/ ./pg/
else
    docker-compose stop
fi
