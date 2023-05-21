#!/bin/bash
exec 2>&1

certbotcommand="certbot certonly --dns-google --dns-google-credentials /etc/letsencrypt/googlekey.json -d *.$DOMAIN --email $EMAIL --work-dir $HOME/letsencryptlib  --logs-dir $HOME/letsencryptlogs --config-dir $HOME/letsencrypt --agree-tos -n"
k8sapply="kubectl create secret tls $CERTNAME --dry-run=client --cert=$HOME/letsencrypt/live/$DOMAIN/fullchain.pem --key=$HOME/letsencrypt/live/$DOMAIN/privkey.pem -oyaml"
RENEWBEFORE=`bc<<<"$RENEW_BEFORE_DAYS*86400"`

if $TEST ; then
	certbotcommand="$certbotcommand --test-cert"
fi

check_cert () {
	# kubectl get secret $CERTNAME -o "jsonpath={.data['tls\.crt']}" | base64 -d | openssl x509 -checkend $RENEWBEFORE -noout 
	kubectl get secret $CERTNAME -o "jsonpath={.data['tls\.crt']}" | base64 -d | openssl verify -
	if [ $? -eq 1 ] ; then
		echo "---===`date`===--- attempting to renewing now"
		until $certbotcommand ; do
			echo "---===`date`===--- Something went wrong renewing the cert. Trying tomorrow"
			sleep 86400
		done	

		echo "---===`date`===--- applying cert to K8s secret store"
		until $k8sapply | kubectl apply -f - ; do
			echo "---===`date`===--- Something went wrong applying the cert. Trying tomorrow"
			sleep 86400
		done	

		EXPDATE=`kubectl get secret $CERTNAME -o "jsonpath={.data['tls\.crt']}" | base64 -d | openssl x509 -enddate -noout | awk -F= '{print $2}'`
		kubectl annotate --overwrite=true secret $CERTNAME Expiration="`date -d "$EXPDATE"`"

		return 0
	else
		echo "---===`date`===--- no renewal needed"
		return 0
	fi
}

check_cert
exit $?

# kubectl get secret letsencrypt-test -o "jsonpath={.data['tls\.crt']}" | base64 -d | openssl x509 -enddate -noout
# kubectl get secret letsencrypt-test -o "jsonpath={.data['tls\.crt']}" | base64 -d | openssl x509 -enddate -noout | awk -F= '{print $2}' 

# certbot certonly --dns-google --dns-google-credentials /etc/letsencrypt/googlekey.json -d \*.kaut.io --email lonkaut@gmail.com --test-cert --config-dir $HOME/letsencrypt --agree-tos -n
# kubectl create secret tls letsencrypt-test --dry-run=client --cert=$HOME/letsencrypt/live/kaut.io/fullchain.pem --key=$HOME/letsencrypt/live/kaut.io/privkey.pem -oyaml  | kubectl apply -f -
