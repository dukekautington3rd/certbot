#!/bin/bash

LOG=/tmp/log/certbot_update.log
RENEWBEFORE=`bc<<<"$RENEW_BEFORE_DAYS*86400"`
CHECK_EVERY_SECONDS=86400
exec 2>&1

while true ; do 
	openssl x509 -checkend $RENEWBEFORE -noout -in /etc/letsencrypt/live/$DOMAIN/cert.pem
	if [ $? -eq 1 ] ; then
		echo "renewing now"
		certbot certonly --dns-google --dns-google-credentials /etc/letsencrypt/googlekey.json -d \*.$DOMAIN --email $EMAIL 
		# Insert command here to restart nginx

		sleep 604800
	else
		echo "---===`date`===--- no renewal needed"
		sleep $CHECK_EVERY_SECONDS
	fi
done
exit 127

