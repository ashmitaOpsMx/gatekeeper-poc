package api_check

api_response = output {
    endpoint := "https://opa-gate-poc.oes.opsmx.org/api/v1/poc"
    response := http.send({"method": "POST", "url": endpoint})
    output = response.body
}

# Return a decision from api_response
decision = {
    "allowed": api_response.allow,
    "reason": "API Check"
} {
    not api_response.allow
}

decision = {
    "allowed": true
} {
    api_response.allow
}