locals {
  enabled = module.this.enabled
  tags    = module.this.tags

  # One alias record per (name, type) pair, e.g. A + AAAA for each domain name.
  records = {
    for pair in setproduct(toset(var.record_names), toset(var.record_types)) :
    "${pair[0]}:${pair[1]}" => {
      name = pair[0]
      type = pair[1]
    }
  }
}
