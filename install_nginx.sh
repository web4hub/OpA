#!/bin/bash
# PCRE version 10.40
wget https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.40/pcre2-10.40.tar.gz && tar xzvf pcre2-10.40.tar.gz

# zlib version 1.2.13
wget https://www.zlib.net/zlib-1.2.13.tar.gz && tar xzvf zlib-1.2.13.tar.gz

# OpenSSL version 1.1.0h
wget https://www.openssl.org/source/openssl-1.1.0h.tar.gz && tar xzvf openssl-1.1.0h.tar.gz
sudo add-apt-repository -y ppa:maxmind/ppa
sudo apt autoremove -y
sudo apt update && sudo apt upgrade -y
apt-get install -y curl build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev perl libperl-dev libgd3 libgd-dev libgeoip1 libgeoip-dev geoip-bin libxml2 libxml2-dev libxslt1.1 libxslt1-dev -y
echo "Downloading NGINX FROM Source"
curl http://nginx.org/download/nginx-1.23.2.tar.gz --output nginx
echo "Download complete, extracting now.."
tar -xvf nginx
rm -r nginx
cd nginx-1.23.2
echo "Configuring now"
sudo ./configure \
            --sbin-path=/usr/bin/nginx \
            --modules-path=/usr/lib/nginx/modules \
            --conf-path=/etc/nginx/nginx.conf \
            --error-log-path=/var/log/nginx/error.log \
            --pid-path=/var/run/nginx.pid \
            --lock-path=/var/run/nginx.lock \
            --user=nginx \
            --group=nginx \
            --build=Ubuntu \
            --builddir=nginx-1.23.2 \
            --with-select_module \
            --with-poll_module \
            --with-threads \
            --with-file-aio \
            --with-http_ssl_module \
            --with-http_v2_module \
            --with-http_realip_module \
            --with-http_addition_module \
            --with-http_xslt_module=dynamic \
            --with-http_image_filter_module=dynamic \
            --with-http_geoip_module=dynamic \
            --with-http_sub_module \
            --with-http_dav_module \
            --with-http_flv_module \
            --with-http_mp4_module \
            --with-http_gunzip_module \
            --with-http_gzip_static_module \
            --with-http_auth_request_module \
            --with-http_random_index_module \
            --with-http_secure_link_module \
            --with-http_degradation_module \
            --with-http_slice_module \
            --with-http_stub_status_module \
            --with-http_perl_module=dynamic \
            --with-perl_modules_path=/usr/share/perl/5.36.0 \
            --with-perl=/usr/bin/perl \
            --http-log-path=/var/log/nginx/access.log \
            --http-client-body-temp-path=/var/cache/nginx/client_temp \
            --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
            --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
            --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
            --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
            --with-mail=dynamic \
            --with-mail_ssl_module \
            --with-stream=dynamic \
            --with-stream_ssl_module \
            --with-stream_realip_module \
            --with-stream_geoip_module=dynamic \
            --with-stream_ssl_preread_module \
            --with-compat \
            --with-pcre=../pcre2-10.40 \
            --with-pcre-jit \
            --with-zlib=../zlib-1.2.13 \
            --with-openssl=../openssl-1.1.0h \
            --with-openssl-opt=no-nextprotoneg \
            --with-debug
echo "NGINX Congifured Compiling now"
sudo make
echo "Compiled, installing now"
sudo make install
cd ~
sudo ln -s /usr/lib/nginx/modules /etc/nginx/modules
# Create NGINX System group and user
sudo adduser --system --home /nonexistent --shell /bin/false --no-create-home --disabled-login --disabled-password --gecos "nginx user" --group nginx
sudo nginx -t
# Create NGINX cache directories and set proper permissions
sudo mkdir -p /var/cache/nginx/client_temp /var/cache/nginx/fastcgi_temp /var/cache/nginx/proxy_temp /var/cache/nginx/scgi_temp /var/cache/nginx/uwsgi_temp
sudo chmod 700 /var/cache/nginx/*
sudo chown nginx:root /var/cache/nginx/*
echo "Creating systemd script"
sudo touch /lib/systemd/system/nginx.service
sudo echo '[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/bin/nginx -t
ExecStart=/usr/bin/nginx
ExecReload=/usr/bin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target' \ > /lib/systemd/system/nginx.service
echo "Init script created, reloading daemon"
sudo systemctl daemon-reload
echo "Daemon reload, starting nginx"
hostnames=$(hostname -I)
ipaddress=$(echo $hostnames | cut --delimiter " " --fields 1)
sudo systemctl start nginx
sudo systemctl enable nginx
echo "Success, NGINX is now running on http://$ipaddress"
sudo systemctl status nginx
