

####################################################################################
# NATS
####################################################################################

FROM debian:stretch
WORKDIR /app/nats
ADD . /app/nats
EXPOSE 4222 8222 6222

####################################################################################

# ulimit incrase (set in docker templats/aws ecs-task-definition too!!)
RUN bash -c 'echo "root hard nofile 16384" >> /etc/security/limits.conf' \
 && bash -c 'echo "root soft nofile 16384" >> /etc/security/limits.conf' \
 && bash -c 'echo "* hard nofile 16384" >> /etc/security/limits.conf' \
 && bash -c 'echo "* soft nofile 16384" >> /etc/security/limits.conf'

# ip/tcp tweaks
RUN bash -c 'echo "net.core.somaxconn = 8192" >> /etc/sysctl.conf' \
 && bash -c 'echo "net.ipv4.tcp_max_tw_buckets = 1440000" >> /etc/sysctl.conf' \
 && bash -c 'echo "net.ipv4.ip_local_port_range = 5000 65000" >> /etc/sysctl.conf' \
 && bash -c 'echo "net.ipv4.tcp_fin_timeout = 15" >> /etc/sysctl.conf' \
 && bash -c 'echo "net.ipv4.tcp_window_scaling = 1" >> /etc/sysctl.conf' \
 && bash -c 'echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf' \
 && bash -c 'echo "net.ipv4.tcp_max_syn_backlog = 8192" >> /etc/sysctl.conf' \
 && bash -c 'echo "net.ipv4.tcp_syn_retries = 2" >> /etc/sysctl.conf' \
 && bash -c 'echo "fs.file-max=65536" >> /etc/sysctl.conf'

####################################################################################

# update packages and install required ones
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
  supervisor 
#  nginx \
# python-pip \
#  jq

# install latest AWS CLI
#RUN pip install awscli --upgrade

# build nodejs app in production mode
#RUN npm install --production

####################################################################################

# copy files to other locations
COPY supervisor.conf /etc/supervisor.conf
#COPY .setup/nginx.bbs.conf /etc/nginx/conf.d/nginx.bbs.conf
#COPY .setup/nginx.conf /etc/nginx/nginx.conf
COPY nats.supervisor.conf /etc/supervisor/conf.d/nats.supervisor.conf
#COPY .setup/nginx.supervisor.conf /etc/supervisor/conf.d/nginx.supervisor.conf

# disable nginx default website
#RUN rm /etc/nginx/sites-available/default \
# && rm /etc/nginx/sites-enabled/default

# prepare nginx cache
#RUN mkdir /tmp/nginx_cache_ms \
# && chown www-data:www-data /tmp/nginx_cache_ms

####################################################################################

# startup command
CMD bash dockercmd.sh
#CMD ["-config ./seed.conf -D"]

####################################################################################
####################################################################################
#OLD MANUAL PUSH:
#sudo docker build -t nats .
#sudo docker run -p 4222:4222 -p 8222:8222 -p 6222:6222 nats
#aws ecr get-login
#sudo docker login -u AWS -p xxxsdfsdfsdfsdf= -e none https://735245989296.dkr.ecr.eu-central-1.amazonaws.com
#sudo docker images
#sudo docker tag 9b8f5081d3c5 735245989296.dkr.ecr.eu-central-1.amazonaws.com/gls
#sudo docker push 735245989296.dkr.ecr.eu-central-1.amazonaws.com/gls
## sudo docker rmi 9b8f5081d3c5 --force
