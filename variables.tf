# -----------------------------------------------------------------------------
# Module-Specific Variables
#
# Standard labeling variables (enabled, namespace, environment, stage, name,
# attributes, tags, context, ...) are provided by context.tf via tf-label.
# -----------------------------------------------------------------------------

variable "zone_id" {
  description = "Route53 hosted zone ID that owns the records."
  type        = string
  validation {
    condition     = length(var.zone_id) > 0
    error_message = "zone_id must not be empty."
  }
}

variable "record_names" {
  description = "DNS names to create alias records for (e.g. [\"example.com\", \"www.example.com\"])."
  type        = list(string)
  validation {
    condition     = length(var.record_names) > 0
    error_message = "record_names must contain at least one name."
  }
}

variable "record_types" {
  description = "Alias record types to create for each name. Defaults to dual-stack A + AAAA."
  type        = set(string)
  default     = ["A", "AAAA"]
  validation {
    condition     = alltrue([for t in var.record_types : contains(["A", "AAAA"], t)])
    error_message = "record_types may only contain A and/or AAAA."
  }
}

variable "alias_name" {
  description = "DNS name of the alias target (e.g. CloudFront domain name)."
  type        = string
}

variable "alias_zone_id" {
  description = "Hosted zone ID of the alias target."
  type        = string
}

variable "evaluate_target_health" {
  description = "Whether to evaluate target health for the alias records."
  type        = bool
  default     = false
}
