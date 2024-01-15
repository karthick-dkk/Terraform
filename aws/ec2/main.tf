locals {
  tags = {
    Project     = var.project
    createdby   = var.createdby
    CreatedOn   = timestamp()
  }
}
# Define the provider and region
provider "aws" {
  region = var.aws_region
}
#Create VPC
# Create a VPC with a public subnet and an internet gateway
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "autoscaling-vpc"
  }
}
#Create Subnet
resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.availability_zone1
  map_public_ip_on_launch = true
  tags = {
    Name = "autoscaling-subnet1"
  }
}
#Create Subnet
resource "aws_subnet" "subnet2" {
vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = var.availability_zone2
  map_public_ip_on_launch = true
  tags = {
    Name = "autoscaling-subnet2"
  }
}
# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "autoscaling-igw"
  }
}
# Create route table 
resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "autoscaling-rt1"
  }
}
# Create route table 
resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.vpc.id
    route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.igw.id
   }
   tags = {
     Name = "autoscaling-rt2"
   }
 }
#Route table Association 
resource "aws_route_table_association" "rta1" {
  subnet_id = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "rta2" {
    subnet_id = aws_subnet.subnet2.id
   route_table_id = aws_route_table.rt2.id
 }

# Create a security group that allows inbound HTTP traffic and SSH access
resource "aws_security_group" "sg" {
  name = "autoscaling-sg"
  description = "Allow HTTP and SSH access"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "autoscaling-sg"
  }
}

# Create a launch template that specifies the instance type, AMI, user data, and security group
resource "aws_launch_template" "lt" {
  name = "autoscaling-lt"
#  image_id = "ami-020f3ca563c92097b" # Ubuntu 18.04 with Java application
  image_id = var.image_id # Ubuntu 22
  instance_type = var.instance_type
  key_name = var.key_name
  user_data = base64encode(file("startup.sh")) # A script that installs nginx and sets up a test page
  vpc_security_group_ids = [aws_security_group.sg.id]
}

# Create an autoscaling group that uses the launch template and the subnet
resource "aws_autoscaling_group" "asg" {
  name = "autoscaling-asg"
  min_size = var.min_size
  max_size = var.max_size
  desired_capacity = var.desired_capacity
  launch_template {
    id = aws_launch_template.lt.id
    version = "$Latest"
  }
  
vpc_zone_identifier = [aws_subnet.subnet1.id,aws_subnet.subnet2.id]
 health_check_type = "EC2"
 tag  {
      key = "Name"
      value = "autoscaling-instance"
      propagate_at_launch = true
    }
}

# Create a target group that registers the instances in the autoscaling group
resource "aws_lb_target_group" "tg" {
  name = "autoscaling-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id
  target_type = "instance"
  health_check {
    path = "/test.html"
  }
}

# Create an application load balancer that distributes traffic to the target group
resource "aws_lb" "alb" {
  name = "autoscaling-alb"
  load_balancer_type = var.load_balancer_type
  subnets = [aws_subnet.subnet1.id,aws_subnet.subnet2.id]
 security_groups = [aws_security_group.sg.id]
}

# Create a listener that forwards requests to the target group
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# Attach the target group to the autoscaling group
resource "aws_autoscaling_attachment" "attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn = aws_lb_target_group.tg.arn
}

# Create a cloudwatch metric alarm that triggers when the average load of the instances exceeds 75%
resource "aws_cloudwatch_metric_alarm" "high_load" {
  alarm_name = "autoscaling-high-load"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 1  
  metric_name = var.metric_name       # Metric for CPU or Network
  namespace = var.namespace          # Metric From ELB or EC2
  period = var.period                # 5 mins 300s
  statistic = "Average"
  threshold = var.threshold_high     # Threshold value 75%
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
  alarm_description = "This alarm triggers when the average load of the instances exceeds 75%"
  alarm_actions = [aws_autoscaling_policy.scale_up.arn]
}

# Create a cloudwatch metric alarm that triggers when the average load of the instances falls below 50%
resource "aws_cloudwatch_metric_alarm" "low_load" {
  alarm_name = "autoscaling-low-load"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = 1
  metric_name = var.metric_name      #  Metric for CPU or Network
  namespace = var.namespace          # Metric From ELB or EC2
  period = var.period                # Period 5 mins
  statistic = "Average"
  threshold = var.threshold_low      # Threshold value 50%
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
  alarm_description = "This alarm triggers when the average load of the instances falls below 50%"
  alarm_actions = [aws_autoscaling_policy.scale_down.arn]
}

# Create an autoscaling policy that adds one instance when the high load alarm is triggered
resource "aws_autoscaling_policy" "scale_up" {
  name = "autoscaling-scale-up"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

# Create an autoscaling policy that removes one instance when the low load alarm is triggered
resource "aws_autoscaling_policy" "scale_down" {
  name = "autoscaling-scale-down"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

# Create a scheduled action that refreshes all the instances in the autoscaling group every day at UTC 12am
resource "aws_autoscaling_schedule" "refresh" {
  scheduled_action_name = "autoscaling-refresh"
  min_size = var.min_size
  max_size = var.max_size
  desired_capacity = var.desired_capacity
  start_time = var.start_time
  recurrence = var.recurrence
  autoscaling_group_name = aws_autoscaling_group.asg.name
}
# Create an SNS topic that receives notifications from the autoscaling group
resource "aws_sns_topic" "topic" {
  name = "autoscaling-topic"
}

# Create an SNS subscription that sends email alerts to a given address
resource "aws_sns_topic_subscription" "subscription" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "email"
  endpoint  = var.sns_email
}

# Create an autoscaling notification that publishes events to the SNS topic
resource "aws_autoscaling_notification" "notification" {
  group_names    = [aws_autoscaling_group.asg.name]
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]
  topic_arn = aws_sns_topic.topic.arn
}

