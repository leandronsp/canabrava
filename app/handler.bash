#!/bin/bash

declare -A params

function handleRequest() {
  ## Read the HTTP request until \r\n
  while IFS= read -r line; do
    #echo $line
    trline="$(tr -d '[\r\n]' <<< "${line}")" ## Removes the \r\n from the EOL

    ## Breaks the loop when line is empty
    [[ "${trline}" ]] && break

    ## Parses the headline
    ## e.g GET /clientes/1/extrato HTTP/1.1 -> GET /clientes/1/extrato
    HEADLINE_REGEX='([A-Z]{1,})\ ([^\ ]*)\ ([A-Z][^\ ]*)'

    [[ "${trline}" =~ ${HEADLINE_REGEX} ]] && {
      REQUEST="${BASH_REMATCH[1]} ${BASH_REMATCH[2]}"
      echo "${BASH_REMATCH[1]} ${BASH_REMATCH[2]}" >&2
      
      ## Parses the path parameter (integer)
      # e.g GET /clientes/1/extrato HTTP/1.1 -> GET /clientes/:id/extrato -> 1
      IFS="/" read -r ROTA ID PARAMETRO<<< "${REQUEST#*\/}"
      PARAMS["id"]="${id}"
      REQUEST="${ROTA}/:id/${OARAMETRO}"
    }

    ## Parses the Content-Length header
    ## e.g Content-Length: 42 -> 42
    [[ "${trline}" = *"Content-Length"* ]] && CONTENT_LENGTH="${trline##*:\ }"
  done

  ## Read the remaining HTTP request body
  [[ "$CONTENT_LENGTH" ]] && {
    read -n$CONTENT_LENGTH BODY
  }

  ## Route request to the response handler
  source ./app/bank_statement.bash
  source ./app/transactions.bash
  source ./app/not-found.bash

  ## Route request to the response handler
  case "${REQUEST}" in
    "GET /clientes/:id/extrato")     handle_GET_bank_statement ;;
    "POST /clientes/:id/transacoes") handle_POST_transactions ;;
    *) 			             handle_not_found ;;
  esac

  echo -e "${RESPONSE}" > $FIFO_PATH
}
