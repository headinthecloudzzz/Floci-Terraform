# Floci-Terraform

Testing and learning Terraform against [Floci](https://floci.io), a free local AWS
emulator (drop-in LocalStack replacement, no auth token required).

Each module is a self-contained Terraform working directory, numbered in the order
they were learned.

## Modules

| Module | Focus |
|---|---|
| [01-providers-resources-state](./01-providers-resources-state) | Providers, resources, state, drift, plan/apply workflow, saved plans, outputs |
| 02-variables-locals-references | Variables, locals, cross-resource references *(in progress)* |

## Environment

- Local AWS emulator: Floci, reachable over Tailscale
- Endpoint is not hardcoded. Set it via an environment variable before running any module:

```bash
export TF_VAR_floci_endpoint="http://<your-floci-address>:4566"
```

- AWS credentials used against Floci are LocalStack's public dummy values
  (`test` / `test`), safe to see in the code, they carry no real access.

## Running a module

```bash
cd 01-providers-resources-state
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

See each module's own README for what it builds and what broke along the way.
