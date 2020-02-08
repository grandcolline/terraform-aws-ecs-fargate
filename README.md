# ECS FARGATE

![Terraform](https://github.com/grandcolline/terraform-aws-ecs-fargate/workflows/Terraform/badge.svg)

## Description

This is Minimal ECS Fargate Service Module.
These types of resources are supported:

* [aws\_ecs\_service](https://www.terraform.io/docs/providers/aws/r/ecs_service.html)
* [aws\_security\_group](https://www.terraform.io/docs/providers/aws/r/security_group.html)

### Type

#### Load Balancer

`type = lb` is create target group and connect to ecs\_service.

* [aws\_lb\_target\_group](https://www.terraform.io/docs/providers/aws/r/lb_target_group.html)

#### Private Service Discovery

`type = sd` is create private service discovery and connect to ecs\_service.

* [aws\_service\_discovery\_service](https://www.terraform.io/docs/providers/aws/r/service_discovery_service.html)

#### Nothing

`type = no` is not create more resources.

### Auto Scalling

`is_mem_scale = true` or `is_cpu_scale = true`

* [aws\_appautoscaling\_target](https://www.terraform.io/docs/providers/aws/r/appautoscaling_target.html)
* [aws\_appautoscaling\_policy](https://www.terraform.io/docs/providers/aws/r/appautoscaling_policy.html)

## Usage

```hcl
module "fargate" {
  source              = "grandcolline/ecs-fargate/aws"
  version             = "1.0.0"
  service_name        = "FargateTestService"
  cluster_name        = aws_ecs_cluster.main.name
  task_definition_arn = aws_ecs_task_definition.main.arn
  container_name      = "ecs_demo_app"
  assign_public_ip    = "true"
  type                = "lb"
  service_subnets     = ["${var.service_subnet_id}"]
  lb_dns              = aws_alb.main.dns_name
}
```

## Inputs

### Common Variables

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| region | AWS Region | string | `"ap-northeast-1"` | no |
| add\_tags | Additional tags | map(string) | `{}` | no |

### Fargate Variables

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| service\_name | fargate service name | string | n/a | yes |
| cluster\_name | ECS cluster name | string | n/a | yes |
| task\_count | task's desired count & minimum capacity | string | `"1"` | no |
| task\_definition\_arn | task definition's arn | string | n/a | yes |
| type | fargate service type. load balancer or service discovery or nothing (lb/sd/no) | string | `"no"` | no |
| deployment\_maximum\_percent | maximum percent when deploy | string | `"200"` | no |
| deployment\_minimum\_healthy\_percent | minimum percent when deploy | string | `"50"` | no |
| assign\_public\_ip | assign public ip to the task | bool | `"false"` | no |

### Network Variables

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| service\_subnets | List of subnet id's to put the task on | list | n/a | yes |

### Load Balancer Variables (`type = lb`)

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| container\_name | container's name to which target group connect | string | `""` | no |
| container\_port | container's port to which target group connect | string | `"8080"` | no |
| deregistration\_delay | time for load balancing to wait before deregistering a target | string | `"300"` | no |
| lb\_dns | load balancer's dns | string | `""` | no |
| healthy\_threshold | | string | `"2"` | no |
| unhealthy\_threshold | | string | `"5"` | no |
| healthcheck\_timeout | | string | `"5"` | no |
| healthcheck\_protocol | | string | `"HTTP"` | no |
| healthcheck\_path | | string | `"/hc"` | no |
| healthcheck\_interval | | string | `"30"` | no |
| healthcheck\_matcher | | string | `"200"` | no |

### Service Discovery Variables (`type = sd`)

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| dns\_namespace\_id || string | `""` | no |
| dns\_ttl || string | `"10"` | no |

### Auto Scalling Variables

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| task\_max\_count | task's maximum capacity | string | `"2"` | no |
| is\_mem\_scale | scale task by memory usage | bool | `"false"` | no |
| mem\_target\_value | target value of scale task by memory usage (%) | string | `"40"` | no |
| mem\_scale\_in\_cooldown | cool down time of scale in task by memory usage | string | `"300"` | no |
| mem\_scale\_out\_cooldown | cool down time of scale out task by memory usage | string | `"300"` | no |
| is\_cpu\_scale | scale task by cpu usage | bool | `"false"` | no |
| cpu\_target\_value | target value of scale task by cpu usage (%) | string | `"40"` | no |
| cpu\_scale\_in\_cooldown | cool down time of scale in task by cpu usage | string | `"300"` | no |
| cpu\_scale\_out\_cooldown | cool down time of scale out task by cpu usage | string | `"300"` | no |

## Outputs

| Name | Description |
|------|-------------|
| target\_group\_arn | target group's arn |
| target\_group\_arn\_suffix | target group's arn suffix |

