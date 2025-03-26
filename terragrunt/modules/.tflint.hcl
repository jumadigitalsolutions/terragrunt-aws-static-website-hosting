plugin "terraform" {
  enabled = true
}

plugin "aws" {
  enabled = true
  version = "0.38.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
  region  = "us-east-1"
}

config {
  call_module_type = "all"
}

rule "terraform_unused_declarations" {
  enabled = true
}

# Defines rules for naming conventions
rule "terraform_naming_convention" {
  enabled = true
  format = "snake_case"

  variable {
    custom = "^var_"
  }
  output {
    custom = "^out_"
  }
  resource {
    custom = "^[a-z0-9_]+$"
  }
}

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}