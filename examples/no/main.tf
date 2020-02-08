# -------------------------------
#  Setting
# -------------------------------
terraform {
  required_version = ">= 0.12"
}

provider aws {
  region = "ap-northeast-1"
}

variable service_subnet_id {}

# -------------------------------
#  Fargate Module
# -------------------------------
module fargate {
  source              = "../../"
  service_name        = "FargateNoTestService"
  cluster_name        = aws_ecs_cluster.main.name
  task_definition_arn = aws_ecs_task_definition.main.arn
  container_name      = "ecs_demo_app"
  assign_public_ip    = "true"
  type                = "no"
  service_subnets     = [var.service_subnet_id]
  is_cpu_scale        = "true"
  add_tags = {
    "ManagedBy"   = "Terraform"
    "Environment" = "test"
  }
}

# -------------------------------
#  ECS Cluster
# -------------------------------
resource aws_ecs_cluster main {
  name = "FargateNoTest"
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
  name               = "FargateNoTestTaskExcuteRoll"
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
  name              = "FargateNoTest"
  retention_in_days = "1"
}

