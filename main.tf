# -----------------------------------------------------------------------------
# Molecule: Route53 Alias Records (dual-stack)
#
# Creates one alias record per (name, type) pair by composing the
# tf-atom-route53-record-aws atom, so a single CloudFront/ALB target can serve
# both IPv4 (A) and IPv6 (AAAA) aliases for every domain name.
# -----------------------------------------------------------------------------
module "record" {
  for_each = local.enabled ? local.records : {}

  source = "git::https://github.com/PlatformStackPulse/tf-atom-route53-record-aws.git?ref=941bb87c37fcd6f7678eea2fb642eb0545e5bc82"

  context                = module.this.context
  zone_id                = var.zone_id
  record_name            = each.value.name
  record_type            = each.value.type
  is_alias               = true
  alias_name             = var.alias_name
  alias_zone_id          = var.alias_zone_id
  evaluate_target_health = var.evaluate_target_health
}
