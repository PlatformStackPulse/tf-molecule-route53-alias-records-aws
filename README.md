# tf-molecule-route53-alias-records-aws

[![License](https://img.shields.io/badge/license-MIT-blue?logo=opensourceinitiative)](LICENSE)

Terraform molecule that creates **dual-stack (A + AAAA) Route53 alias records** for one
or more domain names, all pointing at a single AWS target (CloudFront, ALB, S3 website,
API Gateway, etc.) via its target DNS name and hosted zone ID.

It composes the [`tf-atom-route53-record-aws`](https://github.com/PlatformStackPulse/tf-atom-route53-record-aws)
atom once per `(name, type)` pair using `for_each`, so a single apex + `www` CloudFront
target yields four alias records (`A` and `AAAA` for each name) with no manual IP
management.

## Features

- **Dual-stack by default** — creates both `A` (IPv4) and `AAAA` (IPv6) alias records for
  every name; override via `record_types` (e.g. `["A"]`).
- **Multiple names, one target** — pass `record_names = ["example.com", "www.example.com"]`
  to alias several hostnames at the same target.
- **Alias records** — `is_alias = true` is set on every record, so no manual IP management
  is required.
- **tf-label context chaining** — full [tf-label](https://github.com/PlatformStackPulse/tf-label)
  interface for consistent naming and tagging.
- **Enable/disable switch** — set `enabled = false` (directly or via `context`) to create
  no resources while keeping the module in the configuration.
- **SHA-pinned atom source** — the underlying record atom is pinned to an immutable commit
  for reproducible builds.

## Usage

```hcl
module "dns_aliases" {
  source = "git::https://github.com/PlatformStackPulse/tf-molecule-route53-alias-records-aws.git?ref=<commit-sha>"

  namespace   = "psp"
  environment = "prod"
  name        = "site"

  zone_id       = "Z1234567890ABCDEFGHIJ"                  # hosted zone that owns the records
  record_names  = ["example.com", "www.example.com"]       # names to alias
  alias_name    = module.cdn.cloudfront_domain_name        # target's DNS name
  alias_zone_id = "Z2FDTNDATAQYW2"                         # CloudFront's fixed hosted zone ID

  # optional — defaults to dual-stack ["A", "AAAA"]
  # record_types = ["A"]
}
```

<!-- BEGIN_TF_DOCS -->

### Requirements

| Name      | Version   |
| --------- | --------- |
| terraform | >= 1.11.3 |
| aws       | >= 5.0.0  |

### Providers

No providers.

### Modules

| Name   | Source                                                                    | Version                                  |
| ------ | ------------------------------------------------------------------------- | ---------------------------------------- |
| record | git::https://github.com/PlatformStackPulse/tf-atom-route53-record-aws.git | 941bb87c37fcd6f7678eea2fb642eb0545e5bc82 |
| this   | git::https://github.com/PlatformStackPulse/tf-label.git                   | v1.0.0                                   |

### Resources

No resources.

### Inputs

| Name                   | Description                                                                  | Type           | Default         | Required |
| ---------------------- | ---------------------------------------------------------------------------- | -------------- | --------------- | :------: |
| zone_id                | Route53 hosted zone ID that owns the records.                                | `string`       | n/a             |   yes    |
| record_names           | DNS names to create alias records for.                                       | `list(string)` | n/a             |   yes    |
| alias_name             | DNS name of the alias target (e.g. CloudFront domain name).                  | `string`       | n/a             |   yes    |
| alias_zone_id          | Hosted zone ID of the alias target.                                          | `string`       | n/a             |   yes    |
| record_types           | Alias record types to create for each name. Defaults to dual-stack A + AAAA. | `set(string)`  | `["A", "AAAA"]` |    no    |
| evaluate_target_health | Whether to evaluate target health for the alias records.                     | `bool`         | `false`         |    no    |
| context                | tf-label context object for naming/tagging.                                  | `object`       | `{}`            |    no    |

### Outputs

| Name         | Description                                          |
| ------------ | ---------------------------------------------------- |
| enabled      | Whether the module is enabled.                       |
| fqdns        | Map of `'<name>:<type>'` to the created record FQDN. |
| record_names | Distinct DNS names managed by this molecule.         |

<!-- END_TF_DOCS -->

## Tests

Unit tests live in `tests/unit/` and use a **mock AWS provider** (`mock_provider "aws" {}`),
so no real AWS calls or credentials are required.

```bash
terraform init -backend=false
terraform test -test-directory=tests/unit
```
