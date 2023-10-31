#!/bin/bash
CORE_COUNT=$(cat /proc/cpuinfo  | grep processor | wc -l)
PREFIX=$(cat /prefix)
WORKERS=${WORKERS:-$CORE_COUNT}
sed -i "s|#WORKERS#|$WORKERS|" ${PREFIX}/nginx.conf
nginx