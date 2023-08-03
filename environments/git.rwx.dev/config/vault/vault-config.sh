#!/bin/bash

export VAULT_ADDR="https://vlt.rwx.dev"
export VAULT_TOKEN=""

vault policy write gogs - <<EOF
path "secrets/data/gogs" {
  capabilities = ["read", "list"]
}
EOF

vault write auth/k8s-skydive/role/gogs \
    bound_service_account_names=gogs \
    bound_service_account_namespaces=gogs \
    policies=gogs \
    ttl=24h

# vault secrets enable -version=2 -path=secrets kv

vault kv put secrets/gogs @secret.json
