# ----------------------------
#  Fargate Service Variables
# ----------------------------
variable "cluster_name" {
  type        = "string"
  description = "ECS cluster name"
}

variable "service_name" {
  type        = "string"
  description = "fargate service name"
}

variable "task_definition_arn" {
  type        = "string"
  description = "task definition's arn"
}

variable "type" {
  type        = "string"
  default     = "no"
  description = "fargate service type. load balancer or service discovery or nothing (lb/sd/no)"
}

variable "assign_public_ip" {
  type        = "string"
  default     = "false"
  description = "assign public ip to the task (true/false)"
}

variable "deployment_minimum_healthy_percent" {
  type        = "string"
  default     = "50"
  description = "minimum percent when deploy"
}

variable "deployment_maximum_percent" {
  type        = "string"
  default     = "200"
  description = "maximum percent when deploy"
}

variable "task_count" {
  type        = "string"
  default     = "1"
  description = "task's desired count & minimum capacity"
}

variable "task_max_count" {
  type        = "string"
  default     = "2"
  description = "task's maximum capacity"
}

# ----------------------------
#  Network Variables
# ----------------------------
variable "vpc_id" {
  type        = "string"
  description = "vpc's id"
}

variable "service_subnets" {
  type        = "list"
  description = "List of subnet id's to put the task on"
}

# ----------------------------
#  Load Balancer Variables
# ----------------------------
variable "container_port" {
  type        = "string"
  default     = "8080"
  description = "container's port to which target group connect"
}

variable "container_name" {
  type        = "string"
  default     = ""
  description = "container's name to which target group connect"
}

# TODO: hayashi
variable "lb_dns" {
  type        = "string"
  default     = ""
  description = "load balancer's dns"
}

variable "deregistration_delay" {
  type        = "string"
  default     = "300"
  description = "time for load balancing to wait before deregistering a target"
}

variable "healthcheck" {
  type = "map"

  default = {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
    protocol            = "HTTP"
    path                = "/hc"
    interval            = 30
    matcher             = 200
  }

  description = "target group healthcheck configration"
}

# ----------------------------
#  Service Discovery Variables
# ----------------------------
variable "dns_namespace_id" {
  type    = "string"
  default = ""
}

variable "dns_ttl" {
  type    = "string"
  default = "10"
}

# ----------------------------
#  Auto Scale Variables
# ----------------------------
variable "is_mem_scale" {
  type        = "string"
  default     = false
  description = "scale task by memory usage (true/false)"
}

variable "mem_target_value" {
  type        = "string"
  default     = "40"
  description = "target value of scale task by memory usage (%)"
}

variable "mem_scale_in_cooldown" {
  type        = "string"
  default     = "300"
  description = "cool down time of scale in task by memory usage"
}

variable "mem_scale_out_cooldown" {
  type        = "string"
  default     = "300"
  description = "cool down time of scale out task by memory usage"
}

variable "is_cpu_scale" {
  type        = "string"
  default     = false
  description = "scale task by cpu usage (true/false)"
}

variable "cpu_target_value" {
  type        = "string"
  default     = "40"
  description = "target value of scale task by cpu usage (%)"
}

variable "cpu_scale_in_cooldown" {
  type        = "string"
  default     = "300"
  description = "cool down time of scale in task by cpu usage"
}

variable "cpu_scale_out_cooldown" {
  type        = "string"
  default     = "300"
  description = "cool down time of scale out task by cpu usage"
}
