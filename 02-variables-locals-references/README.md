# 02 — Terraform Variables: Hardcoded to Parameterized

Replaced hardcoded values with declared variables, derived names with locals, and
linked two resources by reference against a local Floci emulator.

## Concepts covered

* **Variable** — an input declared in the config (`variables.tf`) and committed to git.
  Value supplied from outside: `terraform.tfvars`, a `-var` flag, or an environment
  variable. Declaring and assigning are separate steps.
* **Local** — a value computed inside the config, usually from variables. Cannot be
  overridden externally. `var` is an input knob; `local` is a calculation.
* **`terraform.tfvars`** — holds the actual values. Gitignored, since it carries the
  private Floci endpoint. `terraform.tfvars.example` ships with placeholders so the
  repo stays clonable.
* **Referencing** — `var.project`, `local.name_prefix`,
  `aws_s3_bucket.learning.arn`. Interpolation `${}` is required inside a quoted
  string, unnecessary outside one.
* **Label as identity** — the resource label is how state tracks a resource. The
  `bucket` argument is just an attribute. Changing the label makes it a different
  resource; changing the name attribute may force replacement depending on whether
  the provider allows an in-place edit.
* **Config is directory-scoped** — Terraform loads every `.tf` file in the working
  directory as one configuration. Filenames are convention only. Labels must be
  unique across the whole directory, and subdirectories are not read.
* **Implicit dependency** — one resource referencing another's attribute creates
  ordering automatically. No `depends_on` needed.
* **The plan mechanism** — plan reads state, refreshes it against live
  infrastructure, then diffs config against the refreshed state. It never compares
  config to live directly. Apply creates the infrastructure first, then records the
  result to state.
* **Losing state vs losing config** — deleting state orphans resources (Terraform
  proposes recreating them, the API rejects the duplicate, `terraform import`
  reconnects them). Deleting a resource block from config destroys the resource.

## What this builds

Three S3 buckets named from `local.name_prefix` (`thuc-dev`): `thuc-dev-logs`,
`thuc-dev-backups`, and `thuc-dev-audit`. The audit bucket carries a
`source_bucket` tag holding the learning bucket's ARN, which is what creates the
dependency between them. Two outputs: `learning_bucket_arn` and `name_prefix`.

## How to run it

cp terraform.tfvars.example terraform.tfvars # set floci_endpoint, project, environment
terraform init
terraform plan
terraform apply
terraform output

Clean up:

terraform destroy


## What broke and how it got fixed

* Pasted the `backups` resource over the `learning` block instead of adding it
  alongside. Config lost the resource while state still held it, so the plan
  proposed `1 to add, 1 to destroy`. Re-adding the block with the same label and the
  same bucket name restored the match and the plan returned to `1 to add`. State was
  never wrong; the config was.
* The `audit` bucket's tag rendered as a literal ARN rather than
  `(known after apply)`, because `learning` already existed in state. On a fresh
  apply the same line would show `(known after apply)`, since the value is not
  knowable until the dependency is built.
