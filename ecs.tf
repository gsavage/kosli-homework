# Create a cluster 
resource "aws_ecs_cluster" "cluster" {
  name = "kosli-${var.env}-cluster"
}

# And setup the necessary IAM permissions to let Fargate
# pull images, and run the tasks
resource "aws_iam_role" "allow_ecs_access" {
  name               = "ecs-access-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.allow_ecs_access.json
}

resource "aws_iam_role_policy_attachment" "attach_managed_ecs_policy" {
  role       = aws_iam_role.allow_ecs_access.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "attach_task_policy" {
  role       = aws_iam_role.allow_ecs_access.name
  policy_arn = aws_iam_policy.app_policy.arn
}

resource "aws_iam_policy" "app_policy" {
  name   = "${var.env}-app-policy"
  policy = data.aws_iam_policy_document.task_actions.json
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

# The task needs to be able to write to Cloudwatch for logging
data "aws_iam_policy_document" "task_actions" {
  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken", "ecr:BatchCheckLayerAvailability", "ecr:GetDownloadUrlForLayer", "ecr:BatchGetImage"]
    resources = ["arn:aws:ecr:eu-west-2:359024362939:repository/*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:eu-west-2:359024362939:log-group:dev-app-logs:**"]
  }
}

# The task definition, to be consumed by the Service, further down in this file.
# The CPU and Memory options are the smallest that Fargate supports, and are sufficient
# for this nginx container
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
      image     = "359024362939.dkr.ecr.eu-west-2.amazonaws.com/kosli-site:app" # using the latest image - see README
      cpu       = 256
      memory    = 512
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = "eu-west-2"
          awslogs-group         = aws_cloudwatch_log_group.app_logs.name
          awslogs-stream-prefix = "app-nginx"
        }
      }
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
      }]
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://127.0.0.1/ || exit 1"]
        startPeriod = 20
      }
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
  }

}

resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "${var.env}-app-logs"
  retention_in_days = 3 # I don't need a lot of logs for testing this app
}

# The service runs in a security group
resource "aws_security_group" "service_sg" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-app-sg"
  }
}

# The service can accept traffic from the ALB on port 80
resource "aws_vpc_security_group_ingress_rule" "service_ingress" {
  security_group_id            = aws_security_group.service_sg.id
  referenced_security_group_id = aws_security_group.lb_sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

# This adds the service to the default security group's ingress, so that 
# the VPC endpoints (e.g ECR) can be reached. There is a better way to 
# arrange this, one that doesn't rely on the default group, but this works
# and I want to submit to Kosli :-)
resource "aws_vpc_security_group_ingress_rule" "default_from_service_ingress" {
  referenced_security_group_id = aws_security_group.service_sg.id
  security_group_id            = aws_vpc.main.default_security_group_id
  ip_protocol                  = "-1"
}

# The service can reach out to the Internet
resource "aws_vpc_security_group_egress_rule" "service_egress" {
  security_group_id = aws_security_group.service_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# The ECS service that runs the task definition
resource "aws_ecs_service" "nginx_service" {
  name = "kosli-${var.env}-nginx-service"

  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn

  desired_count = 1

  launch_type = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.a.id, aws_subnet.b.id]
    security_groups = [aws_security_group.service_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group_ip.arn
    container_name   = "kosli_app"
    container_port   = 80
  }
}
