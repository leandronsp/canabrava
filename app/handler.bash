#!/bin/bash

declare -A params

HEADLINE_REGEX='([A-Z]{1,})\ ([^\ ]*)\ ([A-Z][^\ ]*)'
REQUEST="${TYPE}${ROTA}/:id/${PARAMETRO}"

function handleRequest() {
  ## Read the HTTP request until \r\n
  while read line; do
    trline=$(tr -d '[\r\n]' <<< $line)

    ## Breaks the loop when line is empty
    [ "$trline" ] || break

    ## Parses the headline
    ## e.g GET /clientes/1/extrato HTTP/1.1 -> GET /clientes/1/extrato
    [[ "${trline}" =~ ${HEADLINE_REGEX} ]] && {
      REQUEST="${BASH_REMATCH[1]} ${BASH_REMATCH[2]}"
      
      ## Parses the path parameter (integer)
      # e.g GET /clientes/1/extrato HTTP/1.1 -> GET /clientes/:id/extrato -> 1
      IFS="/" read -r TYPE ROTA ID PARAMETRO <<< "${REQUEST}"
      PARAMS["id"]="${ID}"
      REQUEST="${TYPE}/${ROTA}/:id/${PARAMETRO}"
    }

    # ## Parses the Content-Length header
    # ## e.g Content-Length: 42 -> 42
    [[ "${trline}" = *"Content-Length"* ]] && CONTENT_LENGTH="${trline##*:\ }"
  done

  BODY=""

  ## Read the remaining HTTP request body
  if [ ! -z "$CONTENT_LENGTH" ]; then
    read -n$CONTENT_LENGTH BODY
  fi

  ## Fixme: This is a hacky way to finish the request body (JSON)
  ## For some weird reason, the last character is being removed
  #BODY+="}"

  ## Route request to the response handler
  source ./app/bank_statement.bash
  source ./app/transactions.bash
  source ./app/not-found.bash

  ## Route request to the response handler
  case "$REQUEST" in
    "GET /clientes/:id/extrato")     handle_GET_bank_statement ;;
    "POST /clientes/:id/transacoes") handle_POST_transactions ;;
    *) 			             handle_not_found ;;
  esac

  echo -e "$RESPONSE"
}

handleRequest
