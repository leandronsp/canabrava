function handle_POST_transactions() {
  ID=${PARAMS["id"]}
  if [ -z "$BODY" ]; then
    RESPONSE="400 Bad Request: Corpo da solicitação ausente"
    return
  fi

  AMOUNT=$(echo "$BODY" | jq -r '.valor')
  TRANSACTION_TYPE=$(echo "$BODY" | jq -r '.tipo')
  DESCRIPTION=$(echo "$BODY" | jq -r '.descricao')

  echo "$ID $AMOUNT $TRANSACTION_TYPE $DESCRIPTION"

  if [ "$TRANSACTION_TYPE" == "c" ]; then
    OPERATION="+"
  elif [ "$TRANSACTION_TYPE" == "d" ]; then
    OPERATION="-"
  else
    RESPONSE="400 Bad Request: Tipo de transação inválido"
  fi

  if [ ! -z "$ID" ]; then
    # Construindo a consulta SQL
    QUERY="BEGIN TRANSACTION;
      INSERT INTO transactions (account_id, amount, description, transaction_type)
      VALUES ($ID, $AMOUNT, '$DESCRIPTION', '$TRANSACTION_TYPE');

      UPDATE balances
      SET amount = amount $OPERATION $AMOUNT
      WHERE balances.account_id = $ID;

      SELECT 
        json_object('limite', accounts.limit_amount, 'saldo', balances.amount)
      FROM accounts 
      LEFT JOIN balances ON balances.account_id = accounts.id
      WHERE account_id = $ID;
    COMMIT;"

    # Executando a consulta SQL
    RESULT=$(echo "$QUERY" | sqlite3 "$DB_FILE")

    if [ ! -z "$RESULT" ]; then
      RESPONSE=$(cat views/bank_statement.jsonr | sed "s/{{data}}/$RESULT/")
    else
      RESPONSE=$(cat views/404.htmlr)
    fi
  fi
}
