# Checkov Security Scan Results
By Prisma Cloud | Version: 3.2.390
> Update available 3.2.390 -> 3.2.391 (Run `pip3 install -U checkov` to update)

## Summary
- Passed checks: 37
- Failed checks: 18 
- Skipped checks: 0

## Failed Checks

### ECR Repository Encryption
- **Resource**: aws_ecr_repository.hippo
- **Check**: CKV_AWS_136 - Ensure ECR repositories are encrypted using KMS
- **File**: /ecs-fargate/main.tf:2-9

### ECS Cluster Monitoring
- **Resource**: aws_ecs_cluster.hippo  
- **Check**: CKV_AWS_65 - Enable container insights on ECS cluster
- **File**: /ecs-fargate/main.tf:12-14

### CloudWatch Log Groups
- **Resource**: aws_cloudwatch_log_group.hippo
- **File**: /ecs-fargate/main.tf:17-19
- **Issues**:
  - CKV_AWS_66: No retention period specified
  - CKV_AWS_338: Logs should be retained for at least 1 year
  - CKV_AWS_158: Not encrypted with KMS

### Security Groups
#### ALB Security Group (aws_security_group.alb)
- **File**: /ecs-fargate/main.tf:46-76
- **Issues**:
  - CKV_AWS_260: Allows ingress from 0.0.0.0/0 to port 80
  - CKV_AWS_23: Missing rule descriptions
  - CKV_AWS_382: Allows unrestricted egress (-1)

#### ECS Tasks Security Group (aws_security_group.ecs_tasks)  
- **File**: /ecs-fargate/main.tf:79-105
- **Issues**:
  - CKV_AWS_23: Missing rule descriptions
  - CKV_AWS_382: Allows unrestricted egress (-1)

### Load Balancer
- **Resource**: aws_lb.main
- **File**: /ecs-fargate/main.tf:108-116
- **Issues**:
  - CKV_AWS_150: Deletion protection not enabled
  - CKV_AWS_91: Access logging not enabled
  - CKV_AWS_131: Not configured to drop HTTP headers

### ECS Service
- **Resource**: aws_ecs_service.hippo
- **Check**: CKV_AWS_333 - Public IP addresses automatically assigned
- **File**: /ecs-fargate/main.tf:198-226

### CloudFront Distribution
- **Resource**: aws_cloudfront_distribution.cloudfront
- **File**: /s3-cloudfront/main.tf:103-158
- **Issues**:
  - CKV_AWS_86: Access logging not enabled
  - CKV_AWS_68: WAF not enabled
  - CKV_AWS_310: Origin failover not configured
  - CKV_AWS_374: Geo restriction not enabled

## Passed Checks
37 checks passed across ECR, ECS, IAM, Security Groups, Load Balancers, ACM Certificates, S3 and CloudFront resources. See full report for details.
