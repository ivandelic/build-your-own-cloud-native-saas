# Deploy Your Own SaaS in 1 Hour

## Preparation
Position yourself in ```infrastructure/setups/saas``` folder. Initialize terraform with:
```
terraform init
```

## 1. Create Virtual Cloud Network (VCN)
Uncomment ```Virtual Cloud Network (VCN)``` block and execute Terraform Apply from ```infrastructure/setups/saas``` folder:
```
terraform apply -var-file=.tfvars
```

## 2. Create Bastion
Uncomment ```Bastion``` block and execute Terraform Apply from ```infrastructure/setups/saas``` folder:
```
terraform apply -var-file=.tfvars
```

## 3. Create Oracle Container Engine for Kubernetes (OKE)
Uncomment ```Oracle Container Engine for Kubernetes (OKE)``` block and execute Terraform Apply from ```infrastructure/setups/saas``` folder:
```
terraform apply -var-file=.tfvars
```
Setup the local access for the OKE cluster by following [docs](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengdownloadkubeconfigfile.htm#localdownload).

## 4. Configure Container Registry (OCIR)
Create OCIR secret so that OKE can pull private images for execution in a cluster. Make sure to replace string %REPLACE% with Auth Token you [generated](https://docs.oracle.com/en-us/iaas/Content/Registry/Tasks/registrygettingauthtoken.htm) for a particular user.
```
kubectl create secret docker-registry ocirsecret --docker-server=eu-frankfurt-1.ocir.io --docker-username='frsxwtjslf35/oracleidentitycloudservice/ivan.delic@oracle.com' --docker-password='%REPLACE%' --docker-email='ivan.delic@oracle.com'
```

## 5. Deploy Ingress Nginx
Deploy Ingress Nginx using Helm
```
helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace \
   --set controller.service.annotations.service\\.beta\\.kubernetes\\.io/oci-load-balancer-shape=flexible \
   --set controller.service.annotations.service\\.beta\\.kubernetes\\.io/oci-load-balancer-shape-flex-min=10 \
   --set controller.service.annotations.service\\.beta\\.kubernetes\\.io/oci-load-balancer-shape-flex-max=10
```
More information on Ingress Nginx installation is located [here](https://kubernetes.github.io/ingress-nginx/deploy/)

## 6. Deploy ExternalDNS
Generate API Key for a particular user following the [guide](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#two). Make note of ```region```, ```tenancy```, ```user```, ```key``` and ```fingerprint``` and fill [oci.yaml](/kubernetes/oci.yaml). More detail on the ExternalDNS configuration is [here](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengconfiguringdnsserver.htm).
Execute the following command to create Kubernetes secret for ExternalDNS based on filled [oci.yaml](/kubernetes/oci.yaml).
```
kubectl create secret generic external-dns-config --from-file=oci.yaml
```
Install ExternalDNS with Helm:
```
helm upgrade --install external-dns external-dns --repo https://kubernetes-sigs.github.io/external-dns/ \
   --set provider=oci \
   --set "extraVolumes[0].name=config" \
   --set "extraVolumes[0].secret.secretName=external-dns-config" \
   --set "extraVolumeMounts[0].name=config" \
   --set "extraVolumeMounts[0].mountPath=/etc/kubernetes/"
```
## 7. Deploy Hello World
Position terminal in ```/application``` folder. Observe [hello-world.yaml](/application/hello-world.yaml) and execute: 
```
kubectl apply -f hello-world.yaml
```
## 8. Create Autonomous JSON Database with Mongo API
Uncomment ```Autonomous JSON Database``` block and execute Terraform Apply from ```infrastructure/setups/saas``` folder:
```
terraform apply -var-file=.tfvars
```
Position terminal in ```/kubernetes``` folder. Edit [mongo-secret.yaml](/kubernetes/mongo-secret.yaml) and fill in the right values. Execute kubectl to generate MongoDB secret for your future microservices:
```
kubectl apply -f mongo-secret.yaml
```
## 9. Create DevOps
Uncomment ```DevOps``` block and execute Terraform Apply from ```infrastructure/setups/saas``` folder:
```
terraform apply -var-file=.tfvars
```
## 10. Deploy microservice - Department
Position terminal in ```/application/departments-backend``` folder. Observe code and push it to Git repo from DevOps project.
```
git init
git remote add origin https://devops.scmservice.eu-frankfurt-1.oci.oraclecloud.com/namespaces/frsxwtjslf35/projects/byos/repositories/departments-backend
git fetch
git checkout origin/main -ft
git add .
git commit -m "Adding Departments Microservice"
git push
```
## 11. Deploy microfrontend - UI
Position terminal in ```/application/general-frontend``` folder. Observe code and push it to Git repo form DevOps project.
```
git init
git remote add origin https://devops.scmservice.eu-frankfurt-1.oci.oraclecloud.com/namespaces/frsxwtjslf35/projects/byos/repositories/general-frontend
git fetch
git checkout origin/main -ft
git add .
git commit -m "Adding Micro Frontend"
git push
```

## 12. Create API Gateway
Uncomment ```API Gateway``` block and execute Terraform Apply from ```infrastructure/setups/saas``` folder:
```
terraform apply -var-file=.tfvars
```

## 13. Configure WAF
Use UI and attach WAF rate limit policy on Load Balancer defined as Service in [departments-backend-cicd.yaml](/application/departments-backend/departments-backend-cicd.yaml)