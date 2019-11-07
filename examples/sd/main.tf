# -------------------------------
#  Setting
# -------------------------------
terraform {
  required_version = ">= 0.12"
}

provider aws {
  region = "ap-northeast-1"
}

variable vpc_id {}
variable service_subnet_id {}

# -------------------------------
#  Fargate Module
# -------------------------------
module fargate {
  source              = "../../"
  service_name        = "FargateSdTestService"
  cluster_name        = aws_ecs_cluster.main.name
  task_definition_arn = aws_ecs_task_definition.main.arn
  container_name      = "ecs_demo_app"
  assign_public_ip    = "true"
  type                = "sd"
  service_subnets     = [var.service_subnet_id]
  dns_namespace_id    = aws_service_discovery_private_dns_namespace.main.id
}

# -------------------------------
#  ECS Cluster
# -------------------------------
resource aws_ecs_cluster main {
  name = "FargateSdTest"
}

# -------------------------------
#  Task Definition
# -------------------------------
resource aws_ecs_task_definition main {
  family                   = "ecs_demo_app"
  network_mode             = "awsvpc"
  container_definitions    = data.template_file.app.rendered
  execution_role_arn       = aws_iam_role.fargate.arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
}

data template_file app {
  template = file("./container_definition.tpl.json")

  vars = {
    image          = "grandcolline/ecs_demo_app:latest"
    logs_group     = aws_cloudwatch_log_group.main.name
    container_name = "ecs_demo_app"
  }
}

resource aws_iam_role fargate {
  name               = "FargateSdTestTaskExcuteRoll"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.fargate.json
}

data aws_iam_policy_document fargate {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource aws_iam_role_policy_attachment fargate {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.fargate.name
}

# -------------------------------
#  Log Group
# -------------------------------
resource aws_cloudwatch_log_group main {
  name              = "FargateSdTestService"
  retention_in_days = "1"
}

# -------------------------------
#  Service Discovery
# -------------------------------
resource aws_service_discovery_private_dns_namespace main {
  name        = "fargatesdtest.internal"
  description = "fargate sd test"
  vpc         = var.vpc_id
}

# -------------------------------
#  Output
# -------------------------------
output target_group_arn {
  value = module.fargate.target_group_arn
}

output target_group_arn_suffix {
  value = module.fargate.target_group_arn_suffix
}

