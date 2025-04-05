resource "aws_ecs_cluster" "cluster" {
  name = "kosli-${var.env}-cluster"
}

resource "aws_iam_role" "allow_ecs_access" {
  name               = "ecs-access-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.allow_ecs_access.json
}

resource "aws_iam_role_policy_attachment" "attach_managed_ecs_policy" {
  role       = aws_iam_role.allow_ecs_access.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "allow_ecs_access" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
  }
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "kosli-app-${var.env}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.allow_ecs_access.arn
  container_definitions = jsonencode([
    {
      name      = "kosli_app"
      image     = "359024362939.dkr.ecr.eu-west-2.amazonaws.com/kosli-site:app"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
      }]
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
  }

}

resource "aws_ecs_service" "nginx_service" {
  name            = "kosli-${var.env}-nginx-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 0
  launch_type     = "FARGATE"
  network_configuration {
    subnets = [aws_subnet.a.id, aws_subnet.b.id]
  }

}
