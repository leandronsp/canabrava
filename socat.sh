#! /bin/bash

# creating fifo to signal start:
[[ -a "start" ]] && rm "start"
mkfifo start

# creating fifo to signal end:
[[ -a "retorno" ]] && rm "retorno"
mkfifo retorno

# start orquestrador:
(
	./orquestrador.sh
)&
orquestrador_pid="${!}"

# emit start signal to orquestrador.sh
echo "emitindo sinal para orquestrador ..."
: > start

while :
do
	# mantendo escuta socket na porta 3000
#	socat TCP4-LISTEN:"3000",reuseaddr,fork,end-close EXEC:'./receptor.sh' 2>> './socat.log' &
	socat -t 0 TCP4-LISTEN:"3000",reuseaddr,fork,end-close EXEC:'./receptor.sh' 2>> './socat.log'

	PID="${!}"
	echo 'Listening on 3000...'
	wait "${PID}"
done

wait "${orquestrador_pid}"
