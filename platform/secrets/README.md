# Local Secrets

Application secrets are created by Terraform for the local demonstration and are stored in the
local Terraform state, which is intentionally ignored by Git. Before a shared environment is
introduced, replace this local-only source with a SOPS-encrypted Secret. Copy
`.sops.yaml.example` to `.sops.yaml` and replace its recipient with the team's real age public key
before creating an encrypted secret.

The age private key must be distributed through an approved secure channel and never committed.
