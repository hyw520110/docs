@echo off
%~d0
set mongodb_base=%cd%
echo  %mongodb_base%


if not exist %mongodb_base%\db\27017 mkdir %mongodb_base%\db\27017
if not exist %mongodb_base%\db\27018 mkdir %mongodb_base%\db\27018
if not exist %mongodb_base%\db\27019 mkdir %mongodb_base%\db\27019
if not exist %mongodb_base%\db\27020 mkdir %mongodb_base%\db\27020
if not exist %mongodb_base%\db\27021 mkdir %mongodb_base%\db\27021

if not exist %mongodb_base%\logs\27017 mkdir %mongodb_base%\logs\27017
if not exist %mongodb_base%\logs\27018 mkdir %mongodb_base%\logs\27018
if not exist %mongodb_base%\logs\27019 mkdir %mongodb_base%\logs\27019
if not exist %mongodb_base%\logs\27020 mkdir %mongodb_base%\logs\27020
if not exist %mongodb_base%\logs\27021 mkdir %mongodb_base%\logs\27021

cd bin
mongod -f %mongodb_base%\conf\27017.cfg --install --serviceName mongodb27017 --serviceDisplayName mongodb27017
mongod -f %mongodb_base%\conf\27018.cfg --install --serviceName mongodb27018 --serviceDisplayName mongodb27018
mongod -f %mongodb_base%\conf\27019.cfg --install --serviceName mongodb27019 --serviceDisplayName mongodb27019
mongod -f %mongodb_base%\conf\27020.cfg --install --serviceName mongodb27020 --serviceDisplayName mongodb27020
mongod -f %mongodb_base%\conf\27021.cfg --install --serviceName mongodb27021 --serviceDisplayName mongodb27021

cd ..

start-service.bat