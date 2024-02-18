# Create an AWS autoscaling group based instance on the CPU Utilization  of the instances. 

## Steps: 
## 1. Creating an autoscaling group in AWS with min 2 and max five instances. 

### 1.1 Create load balancer with two different Availability Zones.

## 2. When the 5 mins CPU Utilization of the machines reaches 75%, add a new instance.

## 3. When the 5-minute CPU Utilization of the machines reaches 50%, remove a machine.

## 4. Everyday at UTC 12am, refresh all the machines in the group (remove all the old machines and add new machines).

## 5. Sends email alerts on the scaling and refresh events
### Blog: https://karthick-dk.hashnode.dev/terraform-iac-automation-end-to-end-project

![Terraform-karthick](https://github.com/karthick-dkk/Terraform/assets/128692563/675fef15-5710-4952-8056-d61b28e659c4)


### Pre-Requests

#### 1. Install AWS-CLI and configure the keys

### Initialize plugins for terraform 
```
terraform init
```
### Test the config
```
terraform plan -var-file=app.tfvars
```

### Apply the Terraform  config
```
terraform apply -var-file=app.tfvars
```
### Delete the Terraform config
```
terraform destroy  -var-file=app.tfvars
```


################################################

#MAINTAIN BY: https://github.com/karthick-dkk 

#Support: https://www.linkedin.com/in/karthick-dkk/

################################################