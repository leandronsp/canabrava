function handle_GET_bank_statement() {
  ID=${PARAMS["id"]}

  if [ ! -z "$ID" ]; then
    QUERY="
WITH ten_transactions AS (
    SELECT * FROM transactions 
    WHERE account_id = $ID 
    ORDER BY date DESC
    LIMIT 10
)
SELECT 
  json_build_object('saldo', json_build_object(
    'total', accounts.balance,
    'data_extrato', NOW()::date,
    'limite', accounts.limit_amount,
    'ultimas_transacoes', 
      CASE 
      WHEN COUNT(ten_transactions.id) = 0 THEN '[]'
      ELSE
        json_agg(
          json_build_object(
            'valor', ten_transactions.amount,
            'tipo', ten_transactions.transaction_type,
            'descricao', ten_transactions.description,
            'realizada_em', date(ten_transactions.date)
          )
        )
      END
  ))
FROM accounts
LEFT JOIN ten_transactions ON ten_transactions.account_id = accounts.id
WHERE accounts.id = $ID
GROUP BY accounts.id, accounts.balance, accounts.limit_amount"

    RESULT=`psql -t -h pgbouncer -U postgres -d postgres -p 6432 -c "$QUERY" | tr -d '[:space:]'` 

    if [ ! -z "$RESULT" ]; then
      RESPONSE=$(cat views/bank_statement.jsonr | sed "s/{{data}}/$RESULT/")
    else
      RESPONSE=$(cat views/404.htmlr)
    fi
  fi
}
