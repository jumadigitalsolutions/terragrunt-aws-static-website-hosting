# Creates an ECR repository for the hippo website
resource "aws_ecr_repository" "hippo" {
  name                 = "hippo-website-${var.environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Creates an ECS cluster for the hippo website
resource "aws_ecs_cluster" "hippo" {
  name = "hippo-cluster-${var.environment}"
}

# Creates a CloudWatch log group for the hippo website
resource "aws_cloudwatch_log_group" "hippo" {
  name = "/ecs/hippo-website-${var.environment}"
}

# Creates an IAM role for the hippo website
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "hippo-ecs-task-execution-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Attaches the AmazonECSTaskExecutionRolePolicy to the ECS task execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Creates a VPC for the hippo website
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "hippo-vpc-${var.environment}"
    Environment = var.environment
  }
}

# Creates a public subnet for the hippo website
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "hippo-public-a-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name        = "hippo-public-b-${var.environment}"
    Environment = var.environment
  }
}

# Creates an internet gateway for the hippo website
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "hippo-igw-${var.environment}"
    Environment = var.environment
  }
}

# Creates a route table for the hippo website
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "hippo-public-rt-${var.environment}"
    Environment = var.environment
  }
}

# Associates the public subnet with the route table
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

# Associates the public subnet with the route table
resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# Creates a security group for the ALB
resource "aws_security_group" "alb" {
  name        = "hippo-alb-sg-${var.environment}"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "hippo-alb-sg-${var.environment}"
    Environment = var.environment
  }
}

# Creates a security group for the ECS tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "hippo-ecs-tasks-sg-${var.environment}"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "hippo-ecs-tasks-sg-${var.environment}"
    Environment = var.environment
  }
}

# Creates an ALB for the hippo website
resource "aws_lb" "main" {
  name               = "hippo-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name        = "hippo-alb-${var.environment}"
    Environment = var.environment
  }
}

# Creates a target group for the hippo website
resource "aws_lb_target_group" "main" {
  name        = "hippo-tg-${var.environment}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name        = "hippo-tg-${var.environment}"
    Environment = var.environment
  }
}

# Creates a listener for the ALB
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Creates a task definition for the hippo website that will contain the container definition
resource "aws_ecs_task_definition" "hippo" {
  family                   = "hippo-website-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "hippo-website"
      image     = "${aws_ecr_repository.hippo.repository_url}:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.hippo.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "hippo-task-def-${var.environment}"
    Environment = var.environment
  }
}

# Creates an ECS service for the hippo website
resource "aws_ecs_service" "hippo" {
  name            = "hippo-service-${var.environment}"
  cluster         = aws_ecs_cluster.hippo.id
  task_definition = aws_ecs_task_definition.hippo.arn
  desired_count   = var.service_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "hippo-website"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.main]

  tags = {
    Name        = "hippo-service-${var.environment}"
    Environment = var.environment
  }
}
