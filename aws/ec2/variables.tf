variable "aws_region" {
  description = "AWS e region"
  type        = string
 default      = "ap-south-1"
}
variable "image_id" {
  description = "AMI ID for the instances"
  type        = string
}
variable "key_name" {
  description = "Security key"
  type        = string
}
variable "project"{
 description = "Project name"
  type        = string

}
variable "createdby"{
 description = "Project created by "
  type        = string

}
variable "instance_type" {
  description = "Instance type for the autoscaling group"
   type       = string
}

variable "availability_zone1" {
  description = " availability zones1 for the autoscaling group"
  type        = string
}
variable "availability_zone2" {
  description =  " availability zones1 for the autoscaling group"
  type        = string
}

variable "sns_email" {
  description = "Email address for SNS notifications"
type        = string

}

variable "min_size" {
  description = "Min Instanse"
  type        = string
}

variable "max_size" {
  description = "Max Instanse"
  type        = string
}

variable "metric_name" {
  description = "Metrics for auto scale"
  type        = string
}

variable "desired_capacity" {
  description = "desired_capacity capacity Instanse"
  type        = string
}

variable "period" {
  description = "desired_capacity capacity Instanse"
  type        = string
}

variable "threshold_high" {
  description = "Threshold Percentage % "
  type        = string
}

variable "threshold_low" {
  description = "Threshold Percentage % "
  type        = string
}

variable "namespace" {
  description = "Metric Name space"
  type        = string
}

# Loab Balancer

variable "load_balancer_type" {
  description = "Application or Network type LB"
  type        = string
  default     = "application"
}


variable "start_time" {
  description = "Start auto scale time "
  type        = string
}

variable "recurrence" {
  description = "Auto Scale instance"
  type        = string
}
