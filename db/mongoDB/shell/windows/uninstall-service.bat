@echo off


call stop-service.bat

sc delete  mongodb27017
sc delete  mongodb27018
sc delete  mongodb27019
sc delete  mongodb27020
sc delete  mongodb27021