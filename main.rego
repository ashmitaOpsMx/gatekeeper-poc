package system

import data.api_check.decision as api_decision
import data.image_check.decision as image_decision

# Default decision
main = {
    "apiVersion": "admission.k8s.io/v1",
    "kind": "AdmissionReview",
    "response": {
        "uid": input.request.uid,
        "allowed": true
    }
}

# If api_check denies
main = {
    "apiVersion": "admission.k8s.io/v1",
    "kind": "AdmissionReview",
    "response": {
        "uid": input.request.uid,
        "allowed": api_decision.allowed,
        "status": {
            "message": api_decision.reason
        }
    }
} {
    not api_decision.allowed
}

# If image_check denies
main = {
    "apiVersion": "admission.k8s.io/v1",
    "kind": "AdmissionReview",
    "response": {
        "uid": input.request.uid,
        "allowed": image_decision.allowed,
        "status": {
            "message": image_decision.reason
        }
    }
} {
    not image_decision.allowed
}