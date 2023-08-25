package image_check

check_image_prefix {
    some i
    input.request.kind.kind == "Pod"
    image := input.request.object.spec.containers[i].image
    not startswith(image, "opsmx11")
}

# Return a decision based on image prefix
decision = {
    "allowed": false,
    "reason": "Image prefix check"
} {
    check_image_prefix
}

decision = {
    "allowed": true
} {
    not check_image_prefix
}