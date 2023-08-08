#!/bin/bash

export VAULT_ADDR="https://vlt.rwx.dev"
export VAULT_TOKEN=""

vault policy write gitea - <<EOF
path "secrets/data/gitea" {
  capabilities = ["read", "list"]
}
EOF

vault write auth/k8s-skydive/role/gitea \
    bound_service_account_names=gitea \
    bound_service_account_namespaces=gitea \
    policies=gitea \
    ttl=24h

# vault secrets enable -version=2 -path=secrets kv

vault kv put secrets/gitea @secret.json
