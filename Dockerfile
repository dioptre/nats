

####################################################################################
# NATS
####################################################################################

FROM debian:latest
EXPOSE 4222 8222 6222

# update packages and install required ones
RUN apt update && apt upgrade -y && apt install -y \
#  golang \
#  git \
#  libssl-dev \
#  python-pip \
  dnsutils \
  && apt autoclean -y \
  && apt autoremove -y

# apt cleanup
# RUN apt autoclean -y && apt autoremove -y

# build app instead of just publishing
# RUN go get github.com/dioptre/tracker
# RUN go install github.com/dioptre/tracker
# RUN go build


####################################################################################

# ulimit increase (set in docker templats/aws ecs-task-definition too!!)
RUN bash -c 'echo "root hard nofile 16384" >> /etc/security/limits.conf' \
 && bash -c 'echo "root soft nofile 16384" >> /etc/security/limits.conf' \
 && bash -c 'echo "* hard nofile 16384" >> /etc/security/limits.conf' \
 && bash -c 'echo "* soft nofile 16384" >> /etc/security/limits.conf'

# ip/tcp tweaks, disable ipv6
RUN bash -c 'echo "net.core.somaxconn = 8192" >> /etc/sysctl.conf' \
 && bash -c 'echo "net.ipv4.tcp_max_tw_buckets = 1440000" >> /etc/sysctl.conf' \
 && bash -c 'echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf' \ 
 && bash -c 'echo "net.ipv4.ip_local_port_range = 5000 65000" >> /etc/sysctl.conf' \
 && bash -c 'echo "net.ipv4.tcp_fin_timeout = 15" >> /etc/sysctl.conf' \
 && bash -c 'echo "net.ipv4.tcp_window_scaling = 1" >> /etc/sysctl.conf' \
 && bash -c 'echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf' \
 && bash -c 'echo "net.ipv4.tcp_max_syn_backlog = 8192" >> /etc/sysctl.conf' \
 && bash -c 'echo "fs.file-max=65536" >> /etc/sysctl.conf'

####################################################################################


WORKDIR /app/nats
ADD . /app/nats


####################################################################################

# startup command
CMD ["/usr/bin/nice", "-n 5", "/app/nats/nats-server -c seed.conf"]
# Can also clean logs > /dev/null 2>&1

####################################################################################
####################################################################################
#Deploy notes:
#sudo docker build -t nats .
#sudo docker run -p 4222:4222 -p 8222:8222 -p 6222:6222 nats
#aws ecr get-login
#sudo docker login -u AWS -p xxxsdfsdfsdfsdf= -e none https://735245989296.dkr.ecr.eu-central-1.amazonaws.com
#sudo docker images
#sudo docker tag 9b8f5081d3c5 735245989296.dkr.ecr.eu-central-1.amazonaws.com/gls
#sudo docker push 735245989296.dkr.ecr.eu-central-1.amazonaws.com/gls
## sudo docker rmi 9b8f5081d3c5 --force
