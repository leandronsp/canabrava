GATLING_BIN_DIR="${HOME}/gatling/bin"
WORKSPACE="${PWD}/stress-test"

runGatling() {
    "${GATLING_BIN_DIR}/gatling.sh" -rm local -s RinhaBackendSimulation \
        -rd "Rinha de Backend - 2024/Q1: Crébito" \
        -rf "${WORKSPACE}/user-files/results" \
        -sf "${WORKSPACE}/user-files/simulations"
}

startTest() {
    for((i=1;i<=20;i++));do # I changed it to not scroll memory consumption, nothing so significant
        # 2 requests to wake the 2 api instances up :)
        curl --fail http://localhost:9999/clientes/1/extrato && \
        echo "" && \
        curl --fail http://localhost:9999/clientes/1/extrato && \
        echo "" && \
        runGatling && \
        break || sleep 2;
    done
}

startTest
