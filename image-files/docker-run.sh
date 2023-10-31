CORE_COUNT=$(cat /proc/cpuinfo  | grep processor | wc -l)
WORKERS=${WORKERS:-$CORE_COUNT}
PREFIX=$(cat /prefix)
sed -i "s|#WORKERS#|$WORKERS|" ${PREFIX}/conf/nginx.conf
nginx