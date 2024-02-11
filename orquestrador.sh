#!/bin/bash

echo "orquestrador iniciado!"

# import the functions:
source ./app/handler.bash

# waiting to signal start:
while :
do
	[[ -a start ]] && {
		break
	} || sleep 0.001s
done

echo "aguardando sinal do socat ..."
: < start

echo "sinal de socat recebido!
iniciando escuta pelo túnel ..."

# waiting to request to the receptor:

while :
do
	req="$(< start)"
	[[ "${req}" ]] && {
		handleRequest "${req}"
	}
done
