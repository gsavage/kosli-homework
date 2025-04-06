resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}-vpc-internet-gateway"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.vpc_cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.env}-route-table"
  }
}

resource "aws_subnet" "a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"
  tags = {
    Name = "${var.env}-subnet-a"
  }
}

resource "aws_subnet" "b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2b"
  tags = {
    Name = "${var.env}-subnet-b"
  }
}

resource "aws_route_table_association" "rt-a" {
  subnet_id      = aws_subnet.a.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "rt-b" {
  subnet_id      = aws_subnet.b.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.eu-west-2.s3"
  vpc_endpoint_type = "Gateway"
}
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.eu-west-2.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
}
resource "aws_vpc_endpoint" "ecs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.eu-west-2.ecs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
}
resource "aws_vpc_endpoint" "ecs_agent" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.eu-west-2.ecs-agent"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
}
resource "aws_vpc_endpoint" "ecs_telemetry" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.eu-west-2.ecs-telemetry"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
}
resource "aws_vpc_endpoint" "ecr_docker" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.eu-west-2.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.eu-west-2.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
}

resource "aws_vpc_endpoint_subnet_association" "ecr_docker" {
  vpc_endpoint_id = aws_vpc_endpoint.ecr_docker.id
  subnet_id       = aws_subnet.a.id
}
resource "aws_vpc_endpoint_subnet_association" "ecr_api" {
  vpc_endpoint_id = aws_vpc_endpoint.ecr_api.id
  subnet_id       = aws_subnet.a.id
}
resource "aws_vpc_endpoint_subnet_association" "logs" {
  vpc_endpoint_id = aws_vpc_endpoint.logs.id
  subnet_id       = aws_subnet.a.id
}
resource "aws_vpc_endpoint_subnet_association" "ecs" {
  vpc_endpoint_id = aws_vpc_endpoint.ecs.id
  subnet_id       = aws_subnet.a.id
}
resource "aws_vpc_endpoint_subnet_association" "ecs_agent" {
  vpc_endpoint_id = aws_vpc_endpoint.ecs_agent.id
  subnet_id       = aws_subnet.a.id
}
resource "aws_vpc_endpoint_subnet_association" "ecs_telemetry" {
  vpc_endpoint_id = aws_vpc_endpoint.ecs_telemetry.id
  subnet_id       = aws_subnet.a.id
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = aws_route_table.route_table.id
}
