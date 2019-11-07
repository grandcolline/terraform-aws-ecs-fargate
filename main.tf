# -------------------------------
#  Setting
# -------------------------------
terraform {
  required_version = ">= 0.12"
}

provider aws {
  region = var.region
}

# get subnet data for getting vpc
data aws_subnet main {
  id = var.service_subnets.0
}

data aws_vpc main {
  id = data.aws_subnet.main.vpc_id
}

# -------------------------------
#  Service Of Fargate
# -------------------------------
# Application Load Balancer Service
resource aws_ecs_service lb {
  count = var.type == "lb" ? 1 : 0

  name            = var.service_name
  cluster         = var.cluster_name
  task_definition = var.task_definition_arn
  launch_type     = "FARGATE"

  desired_count                      = var.task_count
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  network_configuration {
    security_groups  = [aws_security_group.service.id]
    subnets          = var.service_subnets
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main[0].arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  # desired_count: ignore for autoscale
  # task_definition: ignore for deploy
  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition,
    ]
  }

  tags = merge(var.add_tags, {
    Name    = var.service_name
    DnsName = var.lb_dns
  })

  depends_on = [aws_alb_target_group.main]
}

# Service Discovery Service
resource aws_ecs_service sd {
  count = var.type == "sd" ? 1 : 0

  name            = var.service_name
  cluster         = var.cluster_name
  task_definition = var.task_definition_arn
  launch_type     = "FARGATE"

  desired_count                      = var.task_count
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  network_configuration {
    security_groups  = [aws_security_group.service.id]
    subnets          = var.service_subnets
    assign_public_ip = var.assign_public_ip
  }

  service_registries {
    registry_arn = aws_service_discovery_service.main[0].arn
  }

  # desired_count: ignore for autoscale
  # task_definition: ignore for deploy
  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition,
    ]
  }

  tags = merge(var.add_tags, {
    Name = var.service_name
  })
}

# Non Connect Service
resource aws_ecs_service no {
  count = var.type == "no" ? 1 : 0

  name            = var.service_name
  cluster         = var.cluster_name
  task_definition = var.task_definition_arn
  launch_type     = "FARGATE"

  desired_count                      = var.task_count
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  network_configuration {
    security_groups  = [aws_security_group.service.id]
    subnets          = var.service_subnets
    assign_public_ip = var.assign_public_ip
  }

  # desired_count: ignore for autoscale
  # task_definition: ignore for deploy
  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition,
    ]
  }

  tags = merge(var.add_tags, {
    Name = var.service_name
  })
}

# --------------------------------------
#  Security Group For Fargate Service
# --------------------------------------
resource aws_security_group service {
  name        = var.service_name
  description = "Security Group For Fargate Of ${var.service_name}"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.add_tags, {
    Name = var.service_name
  })
}

#-------------------------------
# Target Group
#-------------------------------
resource aws_alb_target_group main {
  count = var.type == "lb" ? 1 : 0

  name                 = var.service_name
  port                 = var.container_port
  protocol             = "HTTP"
  vpc_id               = data.aws_vpc.main.id
  target_type          = "ip"
  deregistration_delay = var.deregistration_delay

  health_check {
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    timeout             = var.healthcheck_timeout
    protocol            = var.healthcheck_protocol
    path                = var.healthcheck_path
    interval            = var.healthcheck_interval
    matcher             = var.healthcheck_matcher
  }
}

#-------------------------------
# Service Discovery
#-------------------------------
resource aws_service_discovery_service main {
  count = var.type == "sd" ? 1 : 0

  name = var.service_name

  dns_config {
    namespace_id   = var.dns_namespace_id
    routing_policy = "MULTIVALUE"

    dns_records {
      ttl  = var.dns_ttl
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

# -------------------------------------
#  Auto Scaling Target
# -------------------------------------
resource aws_appautoscaling_target main {
  count = var.is_mem_scale || var.is_cpu_scale ? 1 : 0

  max_capacity       = var.task_max_count
  min_capacity       = var.task_count
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [
    aws_ecs_service.lb,
    aws_ecs_service.sd,
    aws_ecs_service.no,
  ]
}

# -------------------------------------
#  Auto Scaling Policy (Memory)
# -------------------------------------
resource aws_appautoscaling_policy mem {
  count = var.is_mem_scale ? 1 : 0

  name               = "memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.main[0].resource_id
  scalable_dimension = aws_appautoscaling_target.main[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.main[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = var.mem_target_value
    scale_in_cooldown  = var.mem_scale_in_cooldown
    scale_out_cooldown = var.mem_scale_out_cooldown
  }

  depends_on = [aws_appautoscaling_target.main]
}

# -------------------------------------
#  Auto Scaling Policy (CPU)
# -------------------------------------
resource aws_appautoscaling_policy cpu {
  count = var.is_cpu_scale ? 1 : 0

  name               = "cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.main[0].resource_id
  scalable_dimension = aws_appautoscaling_target.main[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.main[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.cpu_target_value
    scale_in_cooldown  = var.cpu_scale_in_cooldown
    scale_out_cooldown = var.cpu_scale_out_cooldown
  }

  depends_on = [aws_appautoscaling_target.main]
}

