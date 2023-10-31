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
RUN CORE_COUNT=$(cat /proc/cpuinfo  | grep processor | wc -l) && ./configure --prefix=${PREFIX} --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib64/nginx/modules --conf-path=${PREFIX}/nginx.conf --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --add-module=../nginx-rtmp-module --add-module=../headers-more-nginx-module --add-module=../ngx_http_substitutions_filter_module && make -j ${CORE_COUNT} && make install
RUN microdnf remove tar make gcc pcre-devel openssl-devel && microdnf clean all
COPY ./image-files/docker-run.sh /
COPY ./nginx/ ${PREFIX}/
RUN sed -i "s|#PREFIX#|${PREFIX}|g" ${PREFIX}/nginx.conf ${PREFIX}/conf/nginx-rtmp.conf
RUN useradd -M nginx
RUN mkdir ${PREFIX}/sock && chown nginx:nginx -R ${PREFIX}
RUN echo "${PREFIX}" >/prefix
USER nginx
CMD ["/usr/bin/bash", "/docker-run.sh"]