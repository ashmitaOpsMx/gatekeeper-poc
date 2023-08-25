package system

# Function to make HTTP POST request to the API and get the response.
api_response = output {
    endpoint := "https://opa-gate-poc.oes.opsmx.org/api/v1/poc"
    response := http.send({"method": "POST", "url": endpoint})
    output = response.body
}

# Set the default response as "allowed" in `main`.
main = {
    "apiVersion": "admission.k8s.io/v1",
    "kind": "AdmissionReview",
    "response": {
        "uid": input.request.uid,
        "allowed": true
    }
}

# If api_response doesn't allow, then update the `main` response to disallow the request.
main = {
    "apiVersion": "admission.k8s.io/v1",
    "kind": "AdmissionReview",
    "response": {
        "uid": input.request.uid,
        "allowed": false,
        "status": {
            "message": "Disallowed by external API check"
        }
    }
} {
    not api_response.allow
}