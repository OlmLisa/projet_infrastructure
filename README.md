# Build services though Terraform to provision infrastructure with GCP.

## Objectives : 
- A GKE cluster running a nginx server and a grafana module to
monitor the cluster.
- Deploy a CloudFunction triggered by a Scheduler that will have to run once a day at 7am.
- This CloudFunction will perform a simple CURL of the index page of the nginx.
- Moreover, this cloudfunction is secured by a dedicated serviceAccount (only this service account
service will be allowed to call this cloudfunction).
- Apart from that, the nginx server will have to be accessible from the outside (via its public ip address).
- The necessary docker images should be built locally and pushed to dockerhub. (using a private
private docker registry will)

### Commands
```
Terraform init
```

```
Terraform plan
```

```
Terraform apply
```

```
Terraform destroy
```
