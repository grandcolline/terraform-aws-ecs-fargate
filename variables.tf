# ----------------------------
#  Common Setting
# ----------------------------
variable region {
  type        = string
  default     = "ap-northeast-1"
  description = "AWS Region"
}

variable add_tags {
  type        = map(string)
  default     = {}
  description = "Additional tags"
}

# ----------------------------
#  Fargate Service Variables
# ----------------------------
variable cluster_name {
  type        = string
  description = "ECS cluster name"
}

variable service_name {
  type        = string
  description = "fargate service name"
}

variable task_definition_arn {
  type        = string
  description = "task definition's arn"
}

variable type {
  type        = string
  default     = "no"
  description = "fargate service type. load balancer or service discovery or nothing (lb/sd/no)"
}

variable assign_public_ip {
  type        = bool
  default     = false
  description = "assign public ip to the task"
}

variable deployment_minimum_healthy_percent {
  type        = number
  default     = 50
  description = "minimum percent when deploy"
}

variable deployment_maximum_percent {
  type        = number
  default     = 200
  description = "maximum percent when deploy"
}

variable task_count {
  type        = number
  default     = 1
  description = "task's desired count & minimum capacity"
}

variable task_max_count {
  type        = number
  default     = 2
  description = "task's maximum capacity"
}

# ----------------------------
#  Network Variables
# ----------------------------
variable service_subnets {
  type        = list(string)
  description = "List of subnet id's to put the task on"
}

# ----------------------------
#  Load Balancer Variables
# ----------------------------
variable container_port {
  type        = string
  default     = "8080"
  description = "container's port to which target group connect"
}

variable container_name {
  type        = string
  default     = ""
  description = "container's name to which target group connect"
}

variable lb_dns {
  type        = string
  default     = ""
  description = "load balancer's dns"
}

variable deregistration_delay {
  type        = number
  default     = 300
  description = "time for load balancing to wait before deregistering a target"
}

variable healthy_threshold {
  type    = number
  default = 2
}

variable unhealthy_threshold {
  type    = number
  default = 5
}

variable healthcheck_timeout {
  type    = number
  default = 5
}

variable healthcheck_protocol {
  type    = string
  default = "HTTP"
}

variable healthcheck_path {
  type    = string
  default = "/hc"
}

variable healthcheck_interval {
  type    = number
  default = 30
}

variable healthcheck_matcher {
  type    = number
  default = 200
}

# ----------------------------
#  Service Discovery Variables
# ----------------------------
variable dns_namespace_id {
  type    = string
  default = ""
}

variable dns_ttl {
  type    = number
  default = 10
}

# ----------------------------
#  Auto Scale Variables
# ----------------------------
variable is_mem_scale {
  type        = bool
  default     = false
  description = "scale task by memory usage"
}

variable mem_target_value {
  type        = number
  default     = 40
  description = "target value of scale task by memory usage (%)"
}

variable mem_scale_in_cooldown {
  type        = number
  default     = 300
  description = "cool down time of scale in task by memory usage"
}

variable mem_scale_out_cooldown {
  type        = number
  default     = 300
  description = "cool down time of scale out task by memory usage"
}

variable is_cpu_scale {
  type        = bool
  default     = false
  description = "scale task by cpu usage"
}

variable cpu_target_value {
  type        = number
  default     = 40
  description = "target value of scale task by cpu usage (%)"
}

variable cpu_scale_in_cooldown {
  type        = number
  default     = 300
  description = "cool down time of scale in task by cpu usage"
}

variable cpu_scale_out_cooldown {
  type        = number
  default     = 300
  description = "cool down time of scale out task by cpu usage"
}

