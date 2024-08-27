FROM nginx:latest

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    unzip

# Download and install lua-resty-http
RUN mkdir -p /tmp/lua-resty-http && \
    cd /tmp/lua-resty-http && \
    curl -L https://github.com/openresty/lua-resty-http/archive/master.zip -o lua-resty-http.zip && \
    unzip lua-resty-http.zip && \
    mv lua-resty-http-master/* /usr/local/openresty/lua/

# Download and install lua-cjson
RUN mkdir -p /tmp/lua-cjson && \
    cd /tmp/lua-cjson && \
    curl -L https://github.com/mpx/lua-cjson/archive/v2.1.0.7.tar.gz -o lua-cjson.tar.gz && \
    tar xzf lua-cjson.tar.gz && \
    cd lua-cjson-2.1.0.7 && \
    make && \
    make install

# Remove temporary files
RUN rm -rf /tmp/lua-resty-http /tmp/lua-cjson

# Copy Nginx configuration
COPY conf /etc/nginx/
