package block_wildcard_ingress

contains_wildcard(hostname) = true {
  hostname == ""
}

contains_wildcard(hostname) = true {
  contains(hostname, "*")
}

block_widlcard_ingress {
  input.review.kind.kind == "Ingress"
  # object.get is required to detect omitted host fields
  hostname := object.get(input.review.object.spec.rules[_], "host", "")
  contains_wildcard(hostname)
  msg := sprintf("Hostname '%v' is not allowed since it counts as a wildcard, which can be used to intercept traffic from other applications.", [hostname])
}

# Return a decision based on image prefix
decision = {
    "allowed": false,
    "reason": sprintf("Hostname '%v' is not allowed since it counts as a wildcard, which can be used to intercept traffic from other applications.", [hostname])
} {
    block_widlcard_ingress
}

decision = {
    "allowed": true
} {
    not block_widlcard_ingress
}
