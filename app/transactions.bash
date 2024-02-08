function handle_POST_transactions() {
  ID="${PARAMS["id"]}"
  RESPONSE="$(< "views/transactions.jsonr")"
}
