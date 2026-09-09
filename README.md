# Floci-Terraform

Testing and learning Terraform against [Floci](https://floci.io), a free local AWS
emulator (drop-in LocalStack replacement, no auth token required).

Each module is a self-contained Terraform working directory, numbered in the order
they were learned.

## Modules

| Module | Focus |
|---|---|
| [01-providers-resources-state](./01-providers-resources-state) | Providers, resources, state, drift, plan/apply workflow, saved plans, outputs |
| [02-variables-locals-references](./02-variables-locals-references) | Variables, locals, tfvars, cross-resource references, implicit dependencies |
| [02-broken-config-drill](./02-broken-config-drill) | Error-reading exercise: five deliberately planted faults, diagnosed and documented |

## Environment

- Local AWS emulator: Floci, reachable over Tailscale
- The endpoint is not hardcoded. Each module ships a `terraform.tfvars.example`.
  Copy it and fill in your own values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

- `terraform.tfvars` is gitignored, so real endpoints and hostnames never reach the
  repo.
- AWS credentials used against Floci are LocalStack's public dummy values
  (`test` / `test`), safe to see in the code, they carry no real access.

## Running a module

```bash
cd 01-providers-resources-state
cp terraform.tfvars.example terraform.tfvars   # fill in your values
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

Module 02 and the drill folder use the same bucket names. Do not apply both against
the same emulator; the second apply fails with `BucketAlreadyOwnedByYou`.

See each module's own README for what it builds and what broke along the way.
