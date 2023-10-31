FROM almalinux/8-minimal
ARG PREFIX=/etc/nginx
RUN microdnf update && microdnf install -y git tar make gcc pcre-devel openssl-devel
ADD https://nginx.org/download/nginx-1.25.3.tar.gz /tmp/
WORKDIR "/tmp"
RUN git clone https://github.com/arut/nginx-rtmp-module.git
RUN git clone https://github.com/openresty/headers-more-nginx-module.git
RUN git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git
RUN tar -xzvf nginx-1.25.3.tar.gz
WORKDIR "/tmp/nginx-1.25.3"
RUN CORE_COUNT=$(cat /proc/cpuinfo  | grep processor | wc -l) && ./configure --prefix=${PREFIX} --sbin-path=/usr/sbin/nginx --add-module=../nginx-rtmp-module --add-module=../headers-more-nginx-module --add-module=../ngx_http_substitutions_filter_module && make -j ${CORE_COUNT} && make install
RUN microdnf remove tar make gcc pcre-devel openssl-devel && microdnf clean all
COPY ./image-files/docker-run.sh /
COPY ./nginx/ ${PREFIX}/
RUN sed -i "s|#PREFIX#|${PREFIX}|g" ${PREFIX}/conf/nginx.conf
RUN useradd nginx
RUN mkdir ${PREFIX}/sock && chown nginx:nginx ${PREFIX}/sock
RUN echo "${PREFIX}" >/prefix
CMD ["/usr/bin/bash", "/docker-run.sh"]