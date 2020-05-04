FROM ubuntu:bionic

LABEL maintainer="jesse.goodier@nginx.com"

## Install prerequisite packages, vim for editing, then Install NGINX Plus
  RUN set -x \
  && apt-get update && apt-get upgrade -y \
  && apt-get install --no-install-recommends --no-install-suggests -y apt-transport-https ca-certificates gnupg1 curl python2.7 procps net-tools vim-tiny joe jq less git openssh-server openssh-client sudo \
  && ulimit -c -m -s -t unlimited 

##add ubuntu and workshop users for testing. Why not use the same keys for all users?
RUN useradd --create-home --shell /bin/bash ubuntu && echo "ubuntu:ubuntu" | chpasswd && adduser ubuntu sudo
RUN mkdir -p /home/ubuntu/.ssh
COPY authorized_keys /home/ubuntu/.ssh/authorized_keys
RUN chmod 600 /home/ubuntu/.ssh/authorized_keys
COPY id_rsa /home/ubuntu/.ssh/id_rsa
COPY ssh_config /home/ubuntu/.ssh/config
RUN chmod 400 /home/ubuntu/.ssh/id_rsa
RUN chown -R ubuntu:ubuntu /home/ubuntu/.ssh
RUN echo "ubuntu ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers

RUN useradd --create-home --shell /bin/bash workshop && echo "workshop:workshop" | chpasswd && adduser workshop sudo
RUN mkdir -p /home/workshop/.ssh
COPY authorized_keys /home/workshop/.ssh/authorized_keys
RUN chmod 600 /home/workshop/.ssh/authorized_keys
COPY id_rsa /home/workshop/.ssh/id_rsa
RUN chmod 400 /home/workshop/.ssh/id_rsa
RUN chown -R workshop:workshop /home/workshop/.ssh
RUN git clone https://github.com/jessegoodier/NGINX-101-Workshop-UDF.git /home/ubuntu/udf
RUN echo "workshop ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers

##temporary test
COPY nginx-repo.key /home/ubuntu
COPY nginx-repo.crt /home/ubuntu
RUN chown ubuntu:ubuntu /home/ubuntu/nginx-repo.*

##configure sshd
RUN mkdir /var/run/sshd

RUN echo 'root:root' |chpasswd

RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

RUN mkdir /root/.ssh
COPY authorized_keys /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 22 80 443 8080
STOPSIGNAL SIGTERM
CMD ["/usr/sbin/sshd", "-D"]

