FROM nginx:1.21
USER root

ENV NGX_CACHE_PURGE_VERSION=2.4.3

RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
        vim \
        wget \
        build-essential \
        libssl-dev \
        libpcre3 \
        libpcre3-dev \
        zlib1g-dev

# download and extract sources
RUN NGINX_VERSION=`nginx -V 2>&1 | grep "nginx version" | awk -F/ '{ print $2}'` && \
    cd /tmp && \
    wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz && \
    wget https://github.com/nginx-modules/ngx_cache_purge/archive/$NGX_CACHE_PURGE_VERSION.tar.gz \
         -O ngx_cache_purge-$NGX_CACHE_PURGE_VERSION.tar.gz && \
    tar -xf nginx-$NGINX_VERSION.tar.gz && \
    mv nginx-$NGINX_VERSION nginx && \
    rm nginx-$NGINX_VERSION.tar.gz && \
    tar -xf ngx_cache_purge-$NGX_CACHE_PURGE_VERSION.tar.gz && \
    mv ngx_cache_purge-$NGX_CACHE_PURGE_VERSION ngx_cache_purge && \
    rm ngx_cache_purge-$NGX_CACHE_PURGE_VERSION.tar.gz

# configure and build
RUN cd /tmp/nginx && \
    BASE_CONFIGURE_ARGS=`nginx -V 2>&1 | grep "configure arguments" | cut -d " " -f 3-` && \
    /bin/sh -c "./configure ${BASE_CONFIGURE_ARGS} --add-module=/tmp/ngx_cache_purge" && \
    make && make install && \
    rm -rf /tmp/nginx*