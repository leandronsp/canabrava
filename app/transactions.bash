function handle_POST_transactions() {
  ID="${PARAMS["id"]}"
  AMOUNT=$(jq -r '.valor' <<< "${BODY}")
  TRANSACTION_TYPE=$(jq -r '.tipo' <<< "${BODY}")
  DESCRIPTION=$(jq -r '.descricao' <<< "${BODY}")

  [[ "${TRANSACTION_TYPE}" = "c" ]] && {
    OPERATION="+"
  }||{
    OPERATION="-"
  }

  [[ "${ID}" ]] && {
    QUERY="
INSERT INTO transactions (account_id, amount, description, transaction_type)
VALUES (${ID}, ${AMOUNT}, '${DESCRIPTION}', '${TRANSACTION_TYPE}');

UPDATE accounts
SET balance = balance ${OPERATION} ${AMOUNT}
WHERE accounts.id = ${ID};

SELECT 
  json_build_object(
    'limite', accounts.limit_amount,
    'saldo', accounts.balance
  )
FROM accounts 
WHERE id = ${ID}
FOR UPDATE"

    RESULT=$(psql -t -h pgbouncer -U postgres -d postgres -p 6432 -c "${QUERY}")

    [[ "${RESULT// }" ]] && {
      RESPONSE="$(< views/bank_statement.jsonr)"
      RESPONSE="${RESPONSE//\{\{data\}\}/$RESULT}"
    }||{
      RESPONSE="$(< views/404.htmlr)"
    }
  }
}
