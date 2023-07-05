FROM debian:bookworm
LABEL maintainer="Lon Kaut <lonkaut@gmail.com>"
ARG DEBIAN_FRONTEND=noninteractive

COPY check_cert_expire.sh / 

ENV LANG C.UTF-8
SHELL ["/bin/bash", "-c"]

RUN  \
  apt-get update \
  && apt-get install -y -q curl bc \
  && apt-get install -y -q python3-certbot-nginx python3-certbot-dns-google vim \
  && apt-get update \
  && apt-get clean \
  && chown 1000:1000 /check_cert_expire.sh \
  && useradd -Um -u 1000 -d /home/certbot -s /bin/bash certbot \
  && echo "alias k=kubectl" >> /home/certbot/.bashrc

RUN \
    if [[ $(uname -m) == "aarch64" ]] ; then arch="arm64" ; \
    elif [[ $(uname -m) == "armv7l" ]] ; then arch="arm" ; \
    else arch="amd64" ; \
    fi \
  && curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$arch/kubectl \
  && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl 


USER certbot
WORKDIR /home/certbot/

CMD ["/check_cert_expire.sh"]
