#!/bin/bash

declare -A params

function handleRequest() {
  ## Read the HTTP request until \r\n
  while read line; do
    #echo $line
    trline=$(echo $line | tr -d '[\r\n]') ## Removes the \r\n from the EOL

    ## Breaks the loop when line is empty
    [ -z "$trline" ] && break

    ## Parses the headline
    ## e.g GET /clientes/1/extrato HTTP/1.1 -> GET /clientes/1/extrato
    HEADLINE_REGEX='(.*?)\s(.*?)\sHTTP.*?'

    if [[ "$trline" =~ $HEADLINE_REGEX ]]; then
      REQUEST=$(echo $trline | sed -E "s/$HEADLINE_REGEX/\1 \2/")
      echo $REQUEST >&2
      
      ## Parses the path parameter (integer)
      # e.g GET /clientes/1/extrato HTTP/1.1 -> GET /clientes/:id/extrato -> 1
      PATH_PARAMETER_REGEX='(.*?\s\/.*?)\/(.*?)\/(.*?)$'
      if [[ "$REQUEST" =~ $PATH_PARAMETER_REGEX ]]; then
        PARAMS["id"]=$(echo $REQUEST | sed -E "s/$PATH_PARAMETER_REGEX/\2/")
        REQUEST=$(echo $REQUEST | sed -E "s/$PATH_PARAMETER_REGEX/\1\/:id\/\3/")
      fi
    fi

    ## Parses the Content-Length header
    ## e.g Content-Length: 42 -> 42
    CONTENT_LENGTH_REGEX='Content-Length:\s(.*?)'
    [[ "$trline" =~ $CONTENT_LENGTH_REGEX ]] &&
      CONTENT_LENGTH=$(echo $trline | sed -E "s/$CONTENT_LENGTH_REGEX/\1/")
  done

  ## Read the remaining HTTP request body
  if [ ! -z "$CONTENT_LENGTH" ]; then
    read -n$CONTENT_LENGTH BODY
  fi

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

  echo -e "$RESPONSE" > $FIFO_PATH
}
