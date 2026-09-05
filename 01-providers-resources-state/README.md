# 01 — Terraform Fundamentals: Provider to State

Learned Terraform's core building blocks (providers, resources, state, drift, and the
plan/apply workflow) by building and breaking a real S3 bucket against a local Floci
emulator.

## Concepts covered

- **Provider** — plugin that talks to a platform's API (AWS here). Declared once per
  directory, applies to every resource with a matching type prefix.
- **Resource** — one thing to exist. `type "label" { }`. Referenced elsewhere as
  `type.label.attribute`.
- **State** (`terraform.tfstate`) — Terraform's record of what it believes exists.
  Inspected with `terraform state list`, `terraform state show <resource>`,
  `terraform show`. Never hand-edited.
- **Drift** — when real infrastructure no longer matches state. `terraform plan`
  refreshes against the real API before diffing, which is how it's caught.
- **Core workflow** — `terraform init` → `terraform plan` → `terraform apply`.
- **Plan symbols** — `+` create, `-` destroy, `~` update in place, `-/+` destroy then
  recreate (check the `# forces replacement` comment to see which attribute caused it).
- **Saved plans** (`-out=tfplan`) — freezes diff + state snapshot + resolved config.
  `apply tfplan` ignores any `.tf` edits made after planning. Stale plans (state
  changed since) are rejected automatically.
- **Outputs** — explicit values printed after apply; the only way a module exposes
  values to a caller.
- **`prevent_destroy`** — hard block against deletion. Reserved for irreplaceable
  resources, not a blanket default (commented out here since this bucket is meant to
  be destroyed/recreated freely).
- **Remote state + locking** — shared state (e.g. S3 backend) plus a lock (e.g.
  DynamoDB) so concurrent applies don't collide. Not implemented in this module, just
  understood conceptually.
- **Troubleshooting order** — `terraform validate` → `terraform plan` (read bottom
  line first, then scan for `-/+`) → read errors bottom to top → `terraform state
  list` vs `.tf` declarations → `TF_LOG=DEBUG` if stuck.

## What this builds

One S3 bucket (`my-first-bucket`) against Floci, plus two outputs (`bucket_arn`,
`bucket_name`).

## How to run it

```bash
cp terraform.tfvars.example terraform.tfvars   # set floci_endpoint to your real address
terraform init
terraform plan -out=tfplan
terraform apply tfplan
terraform output
```

Clean up:

```bash
terraform destroy
```

## What broke and how it got fixed

- Initially pointed the AWS CLI at a Floci console URL (`/console/aws` on port 4500)
  instead of the actual API port. Floci's API lives on `4566`, same port used for
  every service — fixed by confirming with `curl .../_localstack/health`.
- Renamed the bucket (`my-first-bucket` → a new name) to see plan behavior: bucket
  name is part of the resource's identity, so it triggered `-/+` (destroy and
  recreate), not an in-place update. Confirmed via the `# forces replacement`
  annotation on the `bucket` attribute.
