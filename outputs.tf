output "enabled" {
  description = "Whether the module is enabled."
  value       = local.enabled
}

output "fqdns" {
  description = "Map of '<name>:<type>' to the created record FQDN."
  value       = { for k, m in module.record : k => m.fqdn }
}

output "record_names" {
  description = "Distinct DNS names managed by this molecule."
  value       = distinct([for r in local.records : r.name])
}
