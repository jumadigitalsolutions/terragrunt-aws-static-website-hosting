

       _               _
   ___| |__   ___  ___| | _______   __
  / __| '_ \ / _ \/ __| |/ / _ \ \ / /
 | (__| | | |  __/ (__|   < (_) \ V /
  \___|_| |_|\___|\___|_|\_\___/ \_/

By Prisma Cloud | version: 3.2.390 
Update available 3.2.390 -> 3.2.391
Run pip3 install -U checkov to update 


terraform scan results:

Passed checks: 37, Failed checks: 18, Skipped checks: 0

Check: CKV_AWS_163: "Ensure ECR image scanning on push is enabled"
	PASSED for resource: aws_ecr_repository.hippo
	File: /ecs-fargate/main.tf:2-9
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/general-8
Check: CKV_AWS_51: "Ensure ECR Image Tags are immutable"
	PASSED for resource: aws_ecr_repository.hippo
	File: /ecs-fargate/main.tf:2-9
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/bc-aws-general-24
Check: CKV_AWS_223: "Ensure ECS Cluster enables logging of ECS Exec"
	PASSED for resource: aws_ecs_cluster.hippo
	File: /ecs-fargate/main.tf:12-14
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/ensure-aws-ecs-cluster-enables-logging-of-ecs-exec
Check: CKV_AWS_274: "Disallow IAM roles, users, and groups from using the AWS AdministratorAccess policy"
	PASSED for resource: aws_iam_role.ecs_task_execution_role
	File: /ecs-fargate/main.tf:22-37
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-iam-policies/bc-aws-274
Check: CKV_AWS_61: "Ensure AWS IAM policy does not allow assume role permission across all services"
	PASSED for resource: aws_iam_role.ecs_task_execution_role
	File: /ecs-fargate/main.tf:22-37
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-iam-policies/bc-aws-iam-45
Check: CKV_AWS_60: "Ensure IAM role allows only specific services or principals to assume it"
	PASSED for resource: aws_iam_role.ecs_task_execution_role
	File: /ecs-fargate/main.tf:22-37
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-iam-policies/bc-aws-iam-44
Check: CKV_AWS_274: "Disallow IAM roles, users, and groups from using the AWS AdministratorAccess policy"
	PASSED for resource: aws_iam_role_policy_attachment.ecs_task_execution_role_policy
	File: /ecs-fargate/main.tf:40-43
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-iam-policies/bc-aws-274
Check: CKV_AWS_24: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 22"
	PASSED for resource: aws_security_group.alb
	File: /ecs-fargate/main.tf:46-76
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/networking-1-port-security
Check: CKV_AWS_277: "Ensure no security groups allow ingress from 0.0.0.0:0 to port -1"
	PASSED for resource: aws_security_group.alb
	File: /ecs-fargate/main.tf:46-76
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/ensure-aws-security-group-does-not-allow-all-traffic-on-all-ports
Check: CKV_AWS_25: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 3389"
	PASSED for resource: aws_security_group.alb
	File: /ecs-fargate/main.tf:46-76
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/networking-2
Check: CKV_AWS_260: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 80"
	PASSED for resource: aws_security_group.ecs_tasks
	File: /ecs-fargate/main.tf:79-105
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/ensure-aws-security-groups-do-not-allow-ingress-from-00000-to-port-80
Check: CKV_AWS_24: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 22"
	PASSED for resource: aws_security_group.ecs_tasks
	File: /ecs-fargate/main.tf:79-105
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/networking-1-port-security
Check: CKV_AWS_277: "Ensure no security groups allow ingress from 0.0.0.0:0 to port -1"
	PASSED for resource: aws_security_group.ecs_tasks
	File: /ecs-fargate/main.tf:79-105
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/ensure-aws-security-group-does-not-allow-all-traffic-on-all-ports
Check: CKV_AWS_25: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 3389"
	PASSED for resource: aws_security_group.ecs_tasks
	File: /ecs-fargate/main.tf:79-105
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/networking-2
Check: CKV_AWS_328: "Ensure that ALB is configured with defensive or strictest desync mitigation mode"
	PASSED for resource: aws_lb.main
	File: /ecs-fargate/main.tf:108-116
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/bc-aws-328
Check: CKV_AWS_261: "Ensure HTTP HTTPS Target group defines Healthcheck"
	PASSED for resource: aws_lb_target_group.main
	File: /ecs-fargate/main.tf:119-147
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/ensure-aws-kendra-index-server-side-encryption-uses-customer-managed-keys-cmks
Check: CKV_AWS_336: "Ensure ECS containers are limited to read-only access to root filesystems"
	PASSED for resource: aws_ecs_task_definition.hippo
	File: /ecs-fargate/main.tf:150-195
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/bc-aws-336
Check: CKV_AWS_249: "Ensure that the Execution Role ARN and the Task Role ARN are different in ECS Task definitions"
	PASSED for resource: aws_ecs_task_definition.hippo
	File: /ecs-fargate/main.tf:150-195
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-iam-policies/ensure-the-aws-execution-role-arn-and-task-role-arn-are-different-in-ecs-task-definitions
Check: CKV_AWS_97: "Ensure Encryption in transit is enabled for EFS volumes in ECS Task definitions"
	PASSED for resource: aws_ecs_task_definition.hippo
	File: /ecs-fargate/main.tf:150-195
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/bc-aws-general-39
Check: CKV_AWS_332: "Ensure ECS Fargate services run on the latest Fargate platform version"
	PASSED for resource: aws_ecs_service.hippo
	File: /ecs-fargate/main.tf:198-226
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/bc-aws-332
Check: CKV_AWS_2: "Ensure ALB protocol is HTTPS"
	PASSED for resource: aws_lb_listener.main
	File: /ecs-fargate/main.tf:229-242
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/networking-29
Check: CKV_AWS_2: "Ensure ALB protocol is HTTPS"
	PASSED for resource: aws_lb_listener.https
	File: /ecs-fargate/main.tf:245-258
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/networking-29
Check: CKV_AWS_234: "Verify logging preference for ACM certificates"
	PASSED for resource: aws_acm_certificate.ecs
	File: /ecs-fargate/main.tf:274-284
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/ensure-aws-acm-certificates-has-logging-preference
Check: CKV_AWS_233: "Ensure Create before destroy for ACM certificates"
	PASSED for resource: aws_acm_certificate.ecs
	File: /ecs-fargate/main.tf:274-284
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/ensure-aws-acm-certificate-enables-create-before-destroy
Check: CKV_AWS_93: "Ensure S3 bucket policy does not lockout all but root user. (Prevent lockouts needing root account fixes)"
	PASSED for resource: aws_s3_bucket.cloudfront
	File: /s3-cloudfront/main.tf:6-10
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/s3-policies/bc-aws-s3-24
Check: CKV_AWS_53: "Ensure S3 bucket has block public ACLS enabled"
	PASSED for resource: aws_s3_bucket_public_access_block.cloudfront
	File: /s3-cloudfront/main.tf:20-27
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/s3-policies/bc-aws-s3-19
Check: CKV_AWS_54: "Ensure S3 bucket has block public policy enabled"
	PASSED for resource: aws_s3_bucket_public_access_block.cloudfront
	File: /s3-cloudfront/main.tf:20-27
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/s3-policies/bc-aws-s3-20
Check: CKV_AWS_55: "Ensure S3 bucket has ignore public ACLs enabled"
	PASSED for resource: aws_s3_bucket_public_access_block.cloudfront
	File: /s3-cloudfront/main.tf:20-27
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/s3-policies/bc-aws-s3-21
Check: CKV_AWS_56: "Ensure S3 bucket has 'restrict_public_buckets' enabled"
	PASSED for resource: aws_s3_bucket_public_access_block.cloudfront
	File: /s3-cloudfront/main.tf:20-27
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/s3-policies/bc-aws-s3-22
Check: CKV_AWS_70: "Ensure S3 bucket does not allow an action with any Principal"
	PASSED for resource: aws_s3_bucket_policy.cloudfront
	File: /s3-cloudfront/main.tf:39-61
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/s3-policies/bc-aws-s3-23
Check: CKV_AWS_93: "Ensure S3 bucket policy does not lockout all but root user. (Prevent lockouts needing root account fixes)"
	PASSED for resource: aws_s3_bucket_policy.cloudfront
	File: /s3-cloudfront/main.tf:39-61
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/s3-policies/bc-aws-s3-24
Check: CKV_AWS_234: "Verify logging preference for ACM certificates"
	PASSED for resource: aws_acm_certificate.cloudfront
	File: /s3-cloudfront/main.tf:64-77
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/ensure-aws-acm-certificates-has-logging-preference
Check: CKV_AWS_233: "Ensure Create before destroy for ACM certificates"
	PASSED for resource: aws_acm_certificate.cloudfront
	File: /s3-cloudfront/main.tf:64-77
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/ensure-aws-acm-certificate-enables-create-before-destroy
Check: CKV_AWS_216: "Ensure CloudFront distribution is enabled"
	PASSED for resource: aws_cloudfront_distribution.cloudfront
	File: /s3-cloudfront/main.tf:103-158
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/ensure-aws-cloudfront-distribution-is-enabled
Check: CKV_AWS_34: "Ensure CloudFront distribution ViewerProtocolPolicy is set to HTTPS"
	PASSED for resource: aws_cloudfront_distribution.cloudfront
	File: /s3-cloudfront/main.tf:103-158
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/networking-32
Check: CKV_AWS_174: "Verify CloudFront Distribution Viewer Certificate is using TLS v1.2"
	PASSED for resource: aws_cloudfront_distribution.cloudfront
	File: /s3-cloudfront/main.tf:103-158
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/bc-aws-networking-63
Check: CKV_AWS_305: "Ensure CloudFront distribution has a default root object configured"
	PASSED for resource: aws_cloudfront_distribution.cloudfront
	File: /s3-cloudfront/main.tf:103-158
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/bc-aws-305
Check: CKV_AWS_136: "Ensure that ECR repositories are encrypted using KMS"
	FAILED for resource: aws_ecr_repository.hippo
	File: /ecs-fargate/main.tf:2-9
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/ensure-that-ecr-repositories-are-encrypted

		2 | resource "aws_ecr_repository" "hippo" {
		3 |   name                 = "hippo-website-${var.environment}"
		4 |   image_tag_mutability = "IMMUTABLE"
		5 | 
		6 |   image_scanning_configuration {
		7 |     scan_on_push = true
		8 |   }
		9 | }

Check: CKV_AWS_65: "Ensure container insights are enabled on ECS cluster"
	FAILED for resource: aws_ecs_cluster.hippo
	File: /ecs-fargate/main.tf:12-14
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-logging-policies/bc-aws-logging-11

		12 | resource "aws_ecs_cluster" "hippo" {
		13 |   name = "hippo-cluster-${var.environment}"
		14 | }

Check: CKV_AWS_66: "Ensure that CloudWatch Log Group specifies retention days"
	FAILED for resource: aws_cloudwatch_log_group.hippo
	File: /ecs-fargate/main.tf:17-19
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-logging-policies/logging-13

		17 | resource "aws_cloudwatch_log_group" "hippo" {
		18 |   name = "/ecs/hippo-website-${var.environment}"
		19 | }

Check: CKV_AWS_338: "Ensure CloudWatch log groups retains logs for at least 1 year"
	FAILED for resource: aws_cloudwatch_log_group.hippo
	File: /ecs-fargate/main.tf:17-19
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-logging-policies/bc-aws-338

		17 | resource "aws_cloudwatch_log_group" "hippo" {
		18 |   name = "/ecs/hippo-website-${var.environment}"
		19 | }

Check: CKV_AWS_158: "Ensure that CloudWatch Log Group is encrypted by KMS"
	FAILED for resource: aws_cloudwatch_log_group.hippo
	File: /ecs-fargate/main.tf:17-19
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/ensure-that-cloudwatch-log-group-is-encrypted-by-kms

		17 | resource "aws_cloudwatch_log_group" "hippo" {
		18 |   name = "/ecs/hippo-website-${var.environment}"
		19 | }

Check: CKV_AWS_260: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 80"
	FAILED for resource: aws_security_group.alb
	File: /ecs-fargate/main.tf:46-76
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/ensure-aws-security-groups-do-not-allow-ingress-from-00000-to-port-80

		46 | resource "aws_security_group" "alb" {
		47 |   name        = "hippo-alb-${var.environment}"
		48 |   description = "Security group for the ALB"
		49 |   vpc_id      = var.vpc_id
		50 | 
		51 |   # Allow inbound HTTP traffic
		52 |   ingress {
		53 |     protocol    = "tcp"
		54 |     from_port   = 80
		55 |     to_port     = 80
		56 |     cidr_blocks = ["0.0.0.0/0"]
		57 |   }
		58 | 
		59 |   # Allow inbound HTTPS traffic
		60 |   ingress {
		61 |     protocol    = "tcp"
		62 |     from_port   = 443
		63 |     to_port     = 443
		64 |     cidr_blocks = ["0.0.0.0/0"]
		65 |   }
		66 | 
		67 |   # Allow all outbound traffic
		68 |   egress {
		69 |     protocol    = "-1"
		70 |     from_port   = 0
		71 |     to_port     = 0
		72 |     cidr_blocks = ["0.0.0.0/0"]
		73 |   }
		74 | 
		75 |   tags = var.tags
		76 | }

Check: CKV_AWS_23: "Ensure every security group and rule has a description"
	FAILED for resource: aws_security_group.alb
	File: /ecs-fargate/main.tf:46-76
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/networking-31

		46 | resource "aws_security_group" "alb" {
		47 |   name        = "hippo-alb-${var.environment}"
		48 |   description = "Security group for the ALB"
		49 |   vpc_id      = var.vpc_id
		50 | 
		51 |   # Allow inbound HTTP traffic
		52 |   ingress {
		53 |     protocol    = "tcp"
		54 |     from_port   = 80
		55 |     to_port     = 80
		56 |     cidr_blocks = ["0.0.0.0/0"]
		57 |   }
		58 | 
		59 |   # Allow inbound HTTPS traffic
		60 |   ingress {
		61 |     protocol    = "tcp"
		62 |     from_port   = 443
		63 |     to_port     = 443
		64 |     cidr_blocks = ["0.0.0.0/0"]
		65 |   }
		66 | 
		67 |   # Allow all outbound traffic
		68 |   egress {
		69 |     protocol    = "-1"
		70 |     from_port   = 0
		71 |     to_port     = 0
		72 |     cidr_blocks = ["0.0.0.0/0"]
		73 |   }
		74 | 
		75 |   tags = var.tags
		76 | }

Check: CKV_AWS_382: "Ensure no security groups allow egress from 0.0.0.0:0 to port -1"
	FAILED for resource: aws_security_group.alb
	File: /ecs-fargate/main.tf:46-76
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/bc-aws-382

		46 | resource "aws_security_group" "alb" {
		47 |   name        = "hippo-alb-${var.environment}"
		48 |   description = "Security group for the ALB"
		49 |   vpc_id      = var.vpc_id
		50 | 
		51 |   # Allow inbound HTTP traffic
		52 |   ingress {
		53 |     protocol    = "tcp"
		54 |     from_port   = 80
		55 |     to_port     = 80
		56 |     cidr_blocks = ["0.0.0.0/0"]
		57 |   }
		58 | 
		59 |   # Allow inbound HTTPS traffic
		60 |   ingress {
		61 |     protocol    = "tcp"
		62 |     from_port   = 443
		63 |     to_port     = 443
		64 |     cidr_blocks = ["0.0.0.0/0"]
		65 |   }
		66 | 
		67 |   # Allow all outbound traffic
		68 |   egress {
		69 |     protocol    = "-1"
		70 |     from_port   = 0
		71 |     to_port     = 0
		72 |     cidr_blocks = ["0.0.0.0/0"]
		73 |   }
		74 | 
		75 |   tags = var.tags
		76 | }

Check: CKV_AWS_23: "Ensure every security group and rule has a description"
	FAILED for resource: aws_security_group.ecs_tasks
	File: /ecs-fargate/main.tf:79-105
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/networking-31

		79  | resource "aws_security_group" "ecs_tasks" {
		80  |   name        = "hippo-ecs-tasks-sg-${var.environment}"
		81  |   description = "Security group for ECS tasks"
		82  |   vpc_id      = var.vpc_id
		83  | 
		84  |   ingress {
		85  |     from_port       = 80
		86  |     to_port         = 80
		87  |     protocol        = "tcp"
		88  |     security_groups = [aws_security_group.alb.id]
		89  |   }
		90  | 
		91  |   egress {
		92  |     from_port   = 0
		93  |     to_port     = 0
		94  |     protocol    = "-1"
		95  |     cidr_blocks = ["0.0.0.0/0"]
		96  |   }
		97  | 
		98  |   tags = merge(
		99  |     {
		100 |       Name        = "hippo-ecs-tasks-sg-${var.environment}"
		101 |       Environment = var.environment
		102 |     },
		103 |     var.tags
		104 |   )
		105 | }

Check: CKV_AWS_382: "Ensure no security groups allow egress from 0.0.0.0:0 to port -1"
	FAILED for resource: aws_security_group.ecs_tasks
	File: /ecs-fargate/main.tf:79-105
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/bc-aws-382

		79  | resource "aws_security_group" "ecs_tasks" {
		80  |   name        = "hippo-ecs-tasks-sg-${var.environment}"
		81  |   description = "Security group for ECS tasks"
		82  |   vpc_id      = var.vpc_id
		83  | 
		84  |   ingress {
		85  |     from_port       = 80
		86  |     to_port         = 80
		87  |     protocol        = "tcp"
		88  |     security_groups = [aws_security_group.alb.id]
		89  |   }
		90  | 
		91  |   egress {
		92  |     from_port   = 0
		93  |     to_port     = 0
		94  |     protocol    = "-1"
		95  |     cidr_blocks = ["0.0.0.0/0"]
		96  |   }
		97  | 
		98  |   tags = merge(
		99  |     {
		100 |       Name        = "hippo-ecs-tasks-sg-${var.environment}"
		101 |       Environment = var.environment
		102 |     },
		103 |     var.tags
		104 |   )
		105 | }

Check: CKV_AWS_150: "Ensure that Load Balancer has deletion protection enabled"
	FAILED for resource: aws_lb.main
	File: /ecs-fargate/main.tf:108-116
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/bc-aws-150

		108 | resource "aws_lb" "main" {
		109 |   name               = "hippo-alb-${var.environment}"
		110 |   internal           = false
		111 |   load_balancer_type = "application"
		112 |   security_groups    = [aws_security_group.alb.id]
		113 |   subnets            = var.public_subnet_ids
		114 | 
		115 |   tags = var.tags
		116 | }

Check: CKV_AWS_91: "Ensure the ELBv2 (Application/Network) has access logging enabled"
	FAILED for resource: aws_lb.main
	File: /ecs-fargate/main.tf:108-116
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-logging-policies/bc-aws-logging-22

		108 | resource "aws_lb" "main" {
		109 |   name               = "hippo-alb-${var.environment}"
		110 |   internal           = false
		111 |   load_balancer_type = "application"
		112 |   security_groups    = [aws_security_group.alb.id]
		113 |   subnets            = var.public_subnet_ids
		114 | 
		115 |   tags = var.tags
		116 | }

Check: CKV_AWS_131: "Ensure that ALB drops HTTP headers"
	FAILED for resource: aws_lb.main
	File: /ecs-fargate/main.tf:108-116
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/ensure-that-alb-drops-http-headers

		108 | resource "aws_lb" "main" {
		109 |   name               = "hippo-alb-${var.environment}"
		110 |   internal           = false
		111 |   load_balancer_type = "application"
		112 |   security_groups    = [aws_security_group.alb.id]
		113 |   subnets            = var.public_subnet_ids
		114 | 
		115 |   tags = var.tags
		116 | }

Check: CKV_AWS_333: "Ensure ECS services do not have public IP addresses assigned to them automatically"
	FAILED for resource: aws_ecs_service.hippo
	File: /ecs-fargate/main.tf:198-226
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-logging-policies/bc-aws-333

		198 | resource "aws_ecs_service" "hippo" {
		199 |   name            = "hippo-service-${var.environment}"
		200 |   cluster         = aws_ecs_cluster.hippo.id
		201 |   task_definition = aws_ecs_task_definition.hippo.arn
		202 |   desired_count   = var.service_desired_count
		203 |   launch_type     = "FARGATE"
		204 | 
		205 |   # Use deployment circuit breaker to detect and roll back failed deployments
		206 |   deployment_circuit_breaker {
		207 |     enable   = true
		208 |     rollback = true
		209 |   }
		210 | 
		211 |   network_configuration {
		212 |     subnets          = var.public_subnet_ids
		213 |     security_groups  = [aws_security_group.ecs_tasks.id]
		214 |     assign_public_ip = true
		215 |   }
		216 | 
		217 |   load_balancer {
		218 |     target_group_arn = aws_lb_target_group.main.arn
		219 |     container_name   = "hippo-website"
		220 |     container_port   = 80
		221 |   }
		222 | 
		223 |   depends_on = [aws_lb_listener.https]
		224 | 
		225 |   tags = var.tags
		226 | }

Check: CKV_AWS_86: "Ensure CloudFront distribution has Access Logging enabled"
	FAILED for resource: aws_cloudfront_distribution.cloudfront
	File: /s3-cloudfront/main.tf:103-158
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-logging-policies/logging-20

		Code lines for this resource are too many. Please use IDE of your choice to review the file.
Check: CKV_AWS_68: "CloudFront Distribution should have WAF enabled"
	FAILED for resource: aws_cloudfront_distribution.cloudfront
	File: /s3-cloudfront/main.tf:103-158
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/bc-aws-general-27

		Code lines for this resource are too many. Please use IDE of your choice to review the file.
Check: CKV_AWS_310: "Ensure CloudFront distributions should have origin failover configured"
	FAILED for resource: aws_cloudfront_distribution.cloudfront
	File: /s3-cloudfront/main.tf:103-158
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/bc-aws-310

		Code lines for this resource are too many. Please use IDE of your choice to review the file.
Check: CKV_AWS_374: "Ensure AWS CloudFront web distribution has geo restriction enabled"
	FAILED for resource: aws_cloudfront_distribution.cloudfront
	File: /s3-cloudfront/main.tf:103-158
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/bc-aws-374

		Code lines for this resource are too many. Please use IDE of your choice to review the file.

