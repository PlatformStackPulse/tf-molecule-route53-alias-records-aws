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

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

### Providers

No providers.

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_record"></a> [record](#module\_record) | git::https://github.com/PlatformStackPulse/tf-atom-route53-record-aws.git | 941bb87c37fcd6f7678eea2fb642eb0545e5bc82 |
| <a name="module_this"></a> [this](#module\_this) | git::https://github.com/PlatformStackPulse/tf-label.git | v1.0.0 |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alias_name"></a> [alias\_name](#input\_alias\_name) | DNS name of the alias target (e.g. CloudFront domain name). | `string` | n/a | yes |
| <a name="input_alias_zone_id"></a> [alias\_zone\_id](#input\_alias\_zone\_id) | Hosted zone ID of the alias target. | `string` | n/a | yes |
| <a name="input_record_names"></a> [record\_names](#input\_record\_names) | DNS names to create alias records for (e.g. ["example.com", "www.example.com"]). | `list(string)` | n/a | yes |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Route53 hosted zone ID that owns the records. | `string` | n/a | yes |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>in the order they appear in the list. New attributes are appended to the<br/>end of the list. The elements of the list are joined by the `delimiter`<br/>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes and tags, which are merged. | <pre>object({<br/>    enabled             = optional(bool, true)<br/>    namespace           = optional(string, null)<br/>    tenant              = optional(string, null)<br/>    environment         = optional(string, null)<br/>    stage               = optional(string, null)<br/>    name                = optional(string, null)<br/>    delimiter           = optional(string, null)<br/>    attributes          = optional(list(string), [])<br/>    tags                = optional(map(string), {})<br/>    label_order         = optional(list(string), null)<br/>    regex_replace_chars = optional(string, null)<br/>    id_length_limit     = optional(number, null)<br/>    label_key_case      = optional(string, null)<br/>    label_value_case    = optional(string, null)<br/>    labels_as_tags      = optional(set(string), null)<br/>    descriptor_formats = optional(map(object({<br/>      format = string<br/>      labels = list(string)<br/>    })), {})<br/>  })</pre> | `{}` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br/>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br/>Map of maps. Keys are names of descriptors. Values are maps of the form<br/>`{<br/>   format = string<br/>   labels = list(string)<br/>}`<br/>`format` is a Terraform format string to be passed to the `format()` function.<br/>`labels` is a list of labels, in order, to pass to `format()` function.<br/>Label values will be normalized before being passed to `format()` so they will be<br/>identical to how they appear in `id`.<br/>Default is `{}` (`descriptors` output will be empty). | <pre>map(object({<br/>    format = string<br/>    labels = list(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources. | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'. | `string` | `null` | no |
| <a name="input_evaluate_target_health"></a> [evaluate\_target\_health](#input\_evaluate\_target\_health) | Whether to evaluate target health for the alias records. | `bool` | `false` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br/>Set to `0` for unlimited length.<br/>Set to `null` to keep the existing setting, which defaults to `0`.<br/>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>Does not affect keys of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper`.<br/>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br/>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br/>set as tag values, and output by this module individually.<br/>Does not affect values of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br/>Default is to include all labels.<br/>Tags with empty values will not be included in the `tags` output.<br/>Set to `[]` to suppress all generated tags.<br/>Note: The value of the `name` tag, if included, will be the `id`, not the `name`. | `set(string)` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>This is the only ID element not also included as a `tag`.<br/>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique. | `string` | `null` | no |
| <a name="input_record_types"></a> [record\_types](#input\_record\_types) | Alias record types to create for each name. Defaults to dual-stack A + AAAA. | `set(string)` | <pre>[<br/>  "A",<br/>  "AAAA"<br/>]</pre> | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br/>Characters matching the regex will be removed from the ID elements.<br/>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element. A customer identifier, indicating who this instance of a resource is for. | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_enabled"></a> [enabled](#output\_enabled) | Whether the module is enabled. |
| <a name="output_fqdns"></a> [fqdns](#output\_fqdns) | Map of '<name>:<type>' to the created record FQDN. |
| <a name="output_record_names"></a> [record\_names](#output\_record\_names) | Distinct DNS names managed by this molecule. |
<!-- END_TF_DOCS -->

## Tests

Unit tests live in `tests/unit/` and use a **mock AWS provider** (`mock_provider "aws" {}`),
so no real AWS calls or credentials are required.

```bash
terraform init -backend=false
terraform test -test-directory=tests/unit
```
