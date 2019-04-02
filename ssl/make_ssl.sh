#!/bin/bash

rep_exec=$(dirname $(readlink -f $0))
rep_ssl="${rep_exec}/ssl"

#####################
####> à modifier ####
#####################
cert_code_pays="FR"
cert_nom_pays="FRANCE"
cert_ville="HARFLEUR"
cert_nom_organisatoion="Sebastien COTTARD"
cert_nom_service="Sebatien COTTARD"
#####################
####< à modifier ####
#####################

mkdir -p "${rep_ssl}"

domaine=""
bit_enc=""
arg=( $@ )
for (( i=0; i<=${#arg[@]} ; i++ ))
do
    if [[ "${arg[$i]}" =~ ^domaine=(([a-z0-9]+|\*)\.){0,1}[a-z0-9]+\.[a-z]{2,6}$ ]]
    then
        eval ${arg[$i]}
    elif [[ "${arg[$i]}" =~ ^bit_enc=[2-4][0-9]{3}$ ]]
    then
        eval ${arg[$i]}
    fi
done
if [ "${domaine}" = "" ] || [ "${bit_enc}" = "" ]
then
    echo "####"
    echo "#### apache_make_ssl.sh domaine=<NOM_DE_DOMAINE> bit_enc=<LONGUEUR D'ENCODAGE>"
    echo "####"
    exit
fi
echo "Remplir le sujet avec les valeurs suivantes :
C=${cert_code_pays}
ST=${cert_nom_pays}
L=${cert_ville}
O=${cert_nom_organisatoion}
OU=${cert_nom_service}
CN=${domaine}

oui ou non ? "

while read -s -n 1 choix
do
if [ "${choix}" = "n" ] || [ "${choix}" = "o" ]
then
    break
fi    
done 
echo
if [ "${choix}" = "o" ]
then
    openssl genrsa -out "${rep_ssl}/${bit_enc}.${domaine}.key" ${bit_enc}
    
    openssl req -new \
    -key "${rep_ssl}/${bit_enc}.${domaine}.key" \
    -out "${rep_ssl}/${bit_enc}.${domaine}.csr" \
    -subj "/C=${cert_code_pays}/ST=${cert_nom_pays}/L=${cert_ville}/O=${cert_nom_organisatoion}/OU=${cert_nom_service}/CN=${domaine}"

    openssl x509 -req -days 3650 \
    -in "${rep_ssl}/${bit_enc}.${domaine}.csr" \
    -signkey "${rep_ssl}/${bit_enc}.${domaine}.key" \
    -out "${rep_ssl}/${bit_enc}.${domaine}.crt"
 
elif [ "${choix}" = "n" ]
then
    openssl genrsa -out "${rep_ssl}/${bit_enc}.${domaine}.key" ${bit_enc}

    openssl req -new \
    -key "${rep_ssl}/${bit_enc}.${domaine}.key" \
    -out "${rep_ssl}/${bit_enc}.${domaine}.csr"

    openssl x509 -req -days 3650 \
    -in "${rep_ssl}/${bit_enc}.${domaine}.csr" \
    -signkey "${rep_ssl}/${bit_enc}.${domaine}.key" \
    -out "${rep_ssl}/${bit_enc}.${domaine}.crt"
fi
