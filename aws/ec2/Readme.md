# Create an AWS autoscaling group based instance on the network traffic load average of the instances. 

## Steps: 
## 1. Creating an autoscaling group in AWS with min 2 and max five instances. 

### 1.1 Create load balancer and two subnets in two different Availability Zones.

## 2. When the 5 mins network traffic load average of the machines reaches 75%, add a new instance.

## 3. When the 5-minute network traffic load average of the machines reaches 50%, remove a machine.

## 4. Everyday at UTC 12am, refresh all the machines in the group (remove all the old machines and add new machines).

## 5. Sends email alerts on the scaling and refresh events

![Screenshot 2024-01-15 231824](https://github.com/karthick-dkk/Terraform/assets/128692563/5ae199d0-d814-4ed2-b172-8c7d8f595ca8)


### Initialize plugins for terraform
```
terraform init
```
### Test trerraform 
```
terraform plan -var=file=app_tfvars
```
### Apply the Terraform 
```
terraform apply -var=file=app_tfvars
```

