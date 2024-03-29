################################################
#Welcome to terraform project
#MAINTAIN BY https://github.com/karthick-dkk
#Support: https://www.linkedin.com/in/karthick-dkk/
################################################
project                 = "karthick-dk"
createdby               = "dk-aws"
CreatedOn               = timestamp()

# General
aws_region              = "ap-south-1"   # Replace your region
availability_zone1      = "ap-south-1a"
availability_zone2      = "ap-south-1b"  # Replace with the desired availability zones

# Launch Template
image_id                = "ami-03f4878755434977f" #"ami-03f4878755434977f" ubuntu22 , "ami-06640050dc3f556bb" # RHEL image
instance_type           = "t2.micro"     # Instance Size
key_name                = "karthick-aws" # IAM Key paris
#SNS
sns_email               = "yourmail@email.com" # Replace with your email address
# Auto Scaling
threshold_low           = 50            # Low Threshold 50%
threshold_high          = 75            # High Threshold 75%
load_balancer_type      = "application"
namespace               = "AWS/EC2"     # Metric Namespace "AWS/ELB" -load balancer (or)  "AWS/EC2" -EC2
metric_name             = "CPUUtilization"  # Metric for CPU or Network
period                  = 300           # 5 mins avg
max_size               = 5              # Instance size max
min_size               = 2              # Instance size min
desired_capacity       = 2              # Instance size desired
#aws_autoscaling_schedule Refresh
start_time             = "2024-01-17T00:00:00Z"
recurrence             = "0 0 * * *"
