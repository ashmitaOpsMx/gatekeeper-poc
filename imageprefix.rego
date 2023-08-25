package system

# Rule to check if image starts with the required prefix.
check_image_prefix {
    some i
    input.request.kind.kind == "Pod"
    image := input.request.object.spec.containers[i].image
    not startswith(image, "opsmx11")
}

# If check_image_prefix evaluates to true, then set the main response to disallow the request.
main = {
    "apiVersion": "admission.k8s.io/v1",
    "kind": "AdmissionReview",
    "response": {
        "uid": input.request.uid,
        "allowed": false,
        "status": {
            "message": "The image must start with 'opsmx11'."
        }
    }
} {
    check_image_prefix
}

# Default to allowing the admission request when check_image_prefix is false.
main = {
    "apiVersion": "admission.k8s.io/v1",
    "kind": "AdmissionReview",
    "response": {
        "uid": input.request.uid,
        "allowed": true
    }
} {
    not check_image_prefix
}