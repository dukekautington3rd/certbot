FROM debian:buster
LABEL maintainer="Lon Kaut <lonkaut@gmail.com>"

ENV LANG C.UTF-8
RUN  \
  apt-get update \
  && apt-get install -y -q curl bc \
  && apt-get install -y -q python3-certbot-nginx python3-certbot-dns-google \
  && apt-get update \
  && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
  && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
  && apt-get clean \
  && mkdir /tmp/log

COPY check_cert_expire.sh / 

CMD ["/check_cert_expire.sh"]
