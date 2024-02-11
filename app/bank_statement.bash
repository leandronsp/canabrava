function handle_GET_bank_statement() {
  ID=${PARAMS["id"]}

  if [ ! -z "$ID" ]; then
    # Construindo a consulta SQL
    QUERY="
WITH ten_transactions AS (
    SELECT * FROM transactions 
    WHERE account_id = $ID 
    ORDER BY date DESC
    LIMIT 10
)
SELECT 
  json_object('saldo', json_object(
    'total', balances.amount,
    'data_extrato', date('now'),
    'limite', accounts.limit_amount,
    'ultimas_transacoes', 
      CASE 
      WHEN COUNT(ten_transactions.id) = 0 THEN '[]'
      ELSE
        json_group_array(
          json_object(
            'valor', ten_transactions.amount,
            'tipo', ten_transactions.transaction_type,
            'descricao', ten_transactions.description,
            'realizada_em', date(ten_transactions.date)
          )
        )
      END
  ))
FROM accounts
LEFT JOIN balances ON balances.account_id = accounts.id
LEFT JOIN ten_transactions ON ten_transactions.account_id = accounts.id
WHERE accounts.id = $ID
GROUP BY accounts.id, balances.amount, accounts.limit_amount;"

    # Executando a consulta SQL
    RESULT=$(echo "$QUERY" | sqlite3 "$DB_FILE")

    if [ ! -z "$RESULT" ]; then
      RESPONSE=$(cat views/bank_statement.jsonr | sed "s/{{data}}/$RESULT/")
    else
      RESPONSE=$(cat views/404.htmlr)
    fi
  fi
}
