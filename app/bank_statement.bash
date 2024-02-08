function handle_GET_bank_statement() {
  ID="${PARAMS["id"]}"
  RESPONSE="$(< "views/bank_statement.jsonr")"
}
