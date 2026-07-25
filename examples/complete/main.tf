terraform {
  required_version = ">= 1.11.3"
}

# Dual-stack (A + AAAA) alias records pointing the apex and www at a CloudFront
# distribution.
module "dns_aliases" {
  source = "../.."

  namespace   = "psp"
  environment = "prod"
  name        = "site"

  zone_id       = "Z1234567890ABCDEFGHIJ"
  record_names  = ["example.com", "www.example.com"]
  alias_name    = "d111111abcdef8.cloudfront.net"
  alias_zone_id = "Z2FDTNDATAQYW2" # CloudFront's fixed hosted zone ID
}
