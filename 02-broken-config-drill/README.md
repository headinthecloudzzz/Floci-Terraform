# 02 — Broken Config Drill

A deliberately faulted copy of module 02, used as an error-reading exercise.
Five faults were planted across the config. This folder holds the repaired
version; the faults are documented below rather than left in the code.

## Why this exists

GameDay scenarios hand you a broken configuration written by someone else.
Reading the error and locating the line quickly is the skill being tested,
separate from knowing how to write the config in the first place.

## The five faults

**1. Interpolation missing on a variable reference**
```hcl
name_prefix = "var.project-${var.environment}"   # broken
name_prefix = "${var.project}-${var.environment}" # fixed
```
Inside a quoted string, `var.project` without `${}` is literal text. No error
at validate; it silently produces the wrong bucket name.

**2. Plural block name used as a reference prefix**
```hcl
bucket = "${locals.name_prefix}-backups"   # broken
bucket = "${local.name_prefix}-backups"    # fixed
```
The block is `locals`. The reference is `local`. Error reads as an undeclared
reference to `locals`, not to `name_prefix`, which is easy to misread.

**3. Reference to a resource label that does not exist**
```hcl
source_bucket = aws_s3_bucket.learn.arn      # broken
source_bucket = aws_s3_bucket.learning.arn   # fixed
```

**4. Variable used but never declared**
`var.team_name` appeared in a tag with no matching `variable` block.

**5. Type mismatch on a variable**
```hcl
variable "environment" {
  type = number   # broken, value is "dev"
  type = string   # fixed
}
```
This one does not surface at `terraform validate`. Validate checks syntax and
references; type evaluation happens at plan.

## Diagnostic order used

1. `terraform validate` — catches faults 2, 3, 4 with no API calls
2. Fix, re-run — errors surface in waves, some hidden behind others
3. `terraform plan` — where fault 5 would surface
4. Fault 1 produces no error at all, only a wrong value

## Side lesson

A declared variable with no default and no `terraform.tfvars` entry makes
Terraform prompt interactively at plan time. Harmless at a terminal, a hang in
a CI pipeline.

## Running it

This config uses the same bucket names as `02-variables-locals-references`.
Do not apply both against the same emulator; the second apply fails with
`BucketAlreadyOwnedByYou`. Plan only.
