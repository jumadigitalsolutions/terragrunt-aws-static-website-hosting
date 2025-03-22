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

# Creates a security group for the ALB
resource "aws_security_group" "alb" {
  name        = "hippo-alb-${var.environment}"
  description = "Security group for the ALB"
  vpc_id      = var.vpc_id

  # Allow inbound HTTP traffic
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound HTTPS traffic
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# Creates a security group for the ECS tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "hippo-ecs-tasks-sg-${var.environment}"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id

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

  tags = merge(
    {
      Name        = "hippo-ecs-tasks-sg-${var.environment}"
      Environment = var.environment
    },
    var.tags
  )
}

# Creates an ALB for the ECS service
resource "aws_lb" "main" {
  name               = "hippo-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  tags = var.tags
}

# Creates a target group for the hippo website
resource "aws_lb_target_group" "main" {
  name        = "hippo-tg-${var.environment}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health" # Use dedicated health check endpoint
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = merge(
    {
      Name        = "hippo-tg-${var.environment}"
      Environment = var.environment
    },
    var.tags
  )

  # Allow time for the target group to be created before attaching it to a listener
  lifecycle {
    create_before_destroy = true
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
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
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

  lifecycle {
    ignore_changes = [
      container_definitions
    ]
  }

  tags = var.tags
}

# Creates an ECS service for the hippo website
resource "aws_ecs_service" "hippo" {
  name            = "hippo-service-${var.environment}"
  cluster         = aws_ecs_cluster.hippo.id
  task_definition = aws_ecs_task_definition.hippo.arn
  desired_count   = var.service_desired_count
  launch_type     = "FARGATE"

  # Use deployment circuit breaker to detect and roll back failed deployments
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "hippo-website"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.https]

  tags = var.tags
}

# Create a proper dependency chain
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Add HTTPS listener to the ALB
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.ecs.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  depends_on = [aws_acm_certificate_validation.ecs, aws_lb_target_group.main]
}

# Create Route53 DNS record pointing to the ALB
resource "aws_route53_record" "ecs" {
  zone_id = data.aws_route53_zone.jumads.zone_id
  name    = "hippo-website-ecs-${var.environment}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = false
  }
}

# Setup DNS for the ECS service
# Use an existing Route53 hosted zone instead of creating a new one
data "aws_route53_zone" "jumads" {
  name = var.domain_name
}

# Create ACM certificate for the ECS service
resource "aws_acm_certificate" "ecs" {
  domain_name               = coalesce(var.acm_certificate_domain, "*.${var.domain_name}")
  subject_alternative_names = ["hippo-website-ecs-${var.environment}.${var.domain_name}"]
  validation_method         = "DNS"

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# Create DNS validation records for the ACM certificate
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.ecs.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.aws_route53_zone.jumads.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60

  allow_overwrite = true
}

# Validate the ACM certificate
resource "aws_acm_certificate_validation" "ecs" {
  certificate_arn         = aws_acm_certificate.ecs.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
