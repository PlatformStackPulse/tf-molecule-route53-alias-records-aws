# Unit Tests — Route53 Alias Records (dual-stack) Molecule
#
# Uses a mock AWS provider — no real AWS calls are made.
#   terraform init -backend=false
#   terraform test -test-directory=tests/unit

mock_provider "aws" {}

variables {
  namespace = "eg"
  stage     = "test"
  name      = "thing"

  zone_id       = "Z1234567890ABCDEFGHIJ"
  record_names  = ["example.com", "www.example.com"]
  alias_name    = "d111111abcdef8.cloudfront.net"
  alias_zone_id = "Z2FDTNDATAQYW2"
}

# ---------------------------------------------------------------------------
# Test: dual-stack default creates A + AAAA per name
# ---------------------------------------------------------------------------
run "creates_dual_stack_records" {
  command = plan

  assert {
    condition     = output.enabled == true
    error_message = "Module should be enabled by default."
  }

  assert {
    condition     = module.this.id == "eg-test-thing"
    error_message = "tf-label id should be composed as namespace-stage-name (eg-test-thing)."
  }

  assert {
    condition     = length(module.record) == 4
    error_message = "2 names x 2 default types (A, AAAA) should yield 4 records."
  }
}

# ---------------------------------------------------------------------------
# Test: single record type override
# ---------------------------------------------------------------------------
run "single_type_override" {
  command = plan

  variables {
    record_types = ["A"]
  }

  assert {
    condition     = length(module.record) == 2
    error_message = "2 names x 1 type should yield 2 records."
  }
}

# ---------------------------------------------------------------------------
# Test: disabling the module creates nothing
# ---------------------------------------------------------------------------
run "disabled_creates_nothing" {
  command = plan

  variables {
    enabled = false
  }

  assert {
    condition     = output.enabled == false
    error_message = "When enabled = false, the module should report enabled = false."
  }

  assert {
    condition     = length(module.record) == 0
    error_message = "When disabled, no record instances should be created."
  }
}
