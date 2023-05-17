FROM debian:buster
LABEL maintainer="Lon Kaut <lonkaut@gmail.com>"

COPY check_cert_expire.sh / 

ENV LANG C.UTF-8
RUN  \
  apt-get update \
  && apt-get install -y -q curl bc \
  && apt-get install -y -q python3-certbot-nginx python3-certbot-dns-google vim \
  && apt-get install -y -q ruby \
  && apt-get update \
  && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
  && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
  && apt-get clean \
  && chown 1000:1000 /check_cert_expire.sh \
  && useradd -Um -u 1000 -d /home/certbot -s /bin/bash certbot \
  && echo "alias k=kubectl" >> /home/certbot/.bashrc

USER certbot
WORKDIR /home/certbot/

CMD ["/check_cert_expire.sh"]
