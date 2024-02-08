function handle_GET_bank_statement() {
  ID=${PARAMS["id"]}
  RESPONSE=$(cat views/bank_statement.jsonr)
}
