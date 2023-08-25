package system

# Function to make HTTP POST request to the API and get the response.
api_response = output {
    endpoint := "https://opa-gate-poc.oes.opsmx.org/api/v1/poc"
    response := http.send({"method": "POST", "url": endpoint})
    output = response.body
}

# Main decision that always allows.
main = {"allow": api_response.allow}