#!/bin/sh

redis-cli keys  "*" | while read LINE ; do TTL=`redis-cli ttl $LINE`; if [ $TTL -eq -1 ]; then echo "Del $LINE"; RES=`redis-cli del $LINE`; fi; done;