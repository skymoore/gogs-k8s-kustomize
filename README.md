## Gogs K8s Kustomize

#### To Deploy
- Requirements:
  - GKE Kubernetes Cluster
  - [Ingress Nginx](https://kubernetes.github.io/ingress-nginx)
- Recommended:
  - [Vault for Secrets Management](https://www.hashicorp.com/products/vault)
  - [External DNS](https://kubernetes-sigs.github.io/external-dns/)
  - [Cert Manager](https://charts.jetstack.io)

1. Create a new environment and kustomize it as desired:  
    `mkdir environments/your.domain.com`
2. Configure values in `environments/your.domain.com/config/app.ini`.
3. Modify the initContainers in `environments/your.domain.com/gogs-statefulset.yaml` according to your secrets provider.
4. Deploy to your cluster  
   `kustomize build . | k apply -f -`
#### Create Admin User

```bash
kubectl -it -n gogs exec gogs-statefulset-0 -c gogs -- /bin/ash 
```

```bash
USER=git /app/gogs/gogs admin create-user --admin --name admin --password admin123 --email admin@gmail.com
```

#### To Apply a theme see [Kos-M GogsThemes](https://github.com/Kos-M/GogsThemes)

#### To setup SSH ingress on GKE with ingress-nginx via helm
1. Add these values to your chart:
   ```yaml
   controller:
     extraArgs:
       default-ssl-certificate: ingress-nginx/tls-cert
       tcp-services-configmap: ingress-nginx/tcp-services
     config:
       custom-http-errors: "404,503"
   service:
     ports:
       http: 80
       https: 443
       ssh: 22
     targetPorts:
       http: http
       https: https
       ssh: ssh
     nodePorts:
       http: ""
       https: ""
       tcp:
         22: 22
   ```
2. Create this configmap:  
   `kubectl -n ingress-nginx apply -f tcp-services-configmap.yaml`
   ```yaml
   ---
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: tcp-services
     namespace: ingress-nginx
   data:
     22: "gogs/ssh:22"
   ```
3. Patch the ingress-nginx-controller service:  
   ```bash
   kubectl patch svc ingress-nginx-controller -n ingress-nginx --type='json' -p='[{"op": "add", "path": "/spec/ports/-", "value": {"name": "ssh", "port": 22, "targetPort": 22, "protocol": "TCP"}}]'
   ```