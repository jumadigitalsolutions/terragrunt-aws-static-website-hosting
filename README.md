# Hippo - AWS Static Website Hosting Solutions

This repository demonstrates two different approaches for hosting static websites on AWS, comparing their benefits and tradeoffs. The project implements infrastructure as code using Terragrunt/Terraform and provides CI/CD pipelines with GitHub Actions.

## Architecture Overview

This project implements two distinct hosting architectures:

### 1. S3 + CloudFront Architecture
- **Amazon S3**: Hosts the static website files
- **CloudFront**: CDN for fast global content delivery
- **Route53**: DNS management with custom domain support
- **ACM**: SSL/TLS certificates for secure HTTPS connections

### 2. ECS + Fargate Architecture
- **Amazon ECR**: Container registry for Docker images
- **ECS + Fargate**: Serverless container hosting
- **Application Load Balancer**: HTTP/HTTPS traffic routing
- **Route53**: DNS management with custom domain support
- **ACM**: SSL/TLS certificates for secure HTTPS connections

## Prerequisites

- AWS Account
- GitHub Account for CI/CD
- Terraform >= 1.0.0
- Terragrunt >= 0.36.0
- AWS CLI >= 2.0.0
- Docker (for local testing and building the container image)

## Setup Instructions

### 1. GitHub Repository Configuration

1. Fork this repository to your GitHub account
2. Configure GitHub repository secrets:
   - `AWS_ACCOUNT_ID`: Your AWS account ID
3. Configure GitHub repository variables:
   - `AWS_REGION`: The AWS region to deploy to (e.g., `us-east-1`)

### 2. AWS Configuration

#### Set up GitHub OIDC Authentication with AWS

1. Create OIDC provider in AWS IAM:
   ```
   aws iam create-open-id-connect-provider \
     --url https://token.actions.githubusercontent.com \
     --client-id-list sts.amazonaws.com \
     --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
   ```

2. Create IAM role with trust policy:
   - Trust policy: `assets/roles/github-actions-trust-policy.json`
   - Permissions policy: `assets/roles/github-actions-permissions-policy.json`

3. Create Route53 hosted zone for your domain (if not already existing)

### 3. Deployment Options

Choose one or both deployment options:

#### S3 + CloudFront Deployment
```bash
cd terragrunt/live/us-east-1/dev/s3-cloudfront
terragrunt init
terragrunt plan
terragrunt apply
```

#### ECS + Fargate Deployment
```bash
cd terragrunt/live/us-east-1/dev/ecs-fargate
terragrunt init
terragrunt plan
terragrunt apply
```

## CI/CD Workflows

### S3 + CloudFront CI/CD
The workflow in `.github/workflows/deploy-s3-cloudfront.yml` performs the following steps:
1. Authenticates with AWS using OIDC
2. Uploads website files to the S3 bucket
3. Creates CloudFront invalidation to refresh the cache
4. Deploys to both dev and prod environments (with prod requiring approval)

### ECS + Fargate CI/CD
The workflow in `.github/workflows/deploy-ecs-fargate.yml` performs:
1. Authenticates with AWS using OIDC
2. Builds and pushes the Docker image to ECR
3. Updates the ECS task definition with the new image
4. Deploys to the ECS service
5. Deploys to both dev and prod environments (with prod requiring approval)

## Infrastructure Components

### Terragrunt Structure
```
terragrunt/
├── common/             # Common configuration files
├── live/               # Live environments
│   └── us-east-1/      # Region-specific configurations
│       ├── dev/        # Development environment
│       │   ├── ecs-fargate/   # ECS Fargate module instance
│       │   └── s3-cloudfront/ # S3 CloudFront module instance
│       └── prod/       # Production environment
└── modules/            # Terraform modules
    ├── ecs-fargate/    # ECS Fargate module
    └── s3-cloudfront/  # S3 CloudFront module
```

### Module Components

#### S3-CloudFront Module
- S3 bucket with website configuration
- CloudFront distribution
- Route53 DNS records
- ACM certificate for HTTPS

#### ECS-Fargate Module
- ECS cluster and service
- ECR repository
- Task definition
- Application Load Balancer
- Security groups
- Route53 DNS records
- ACM certificate for HTTPS

## Security Considerations

1. **IAM Best Practices**:
   - Limited permission policies with least privilege
   - OIDC authentication for GitHub Actions
   - No long-term AWS credentials

2. **Network Security**:
   - Private subnets for infrastructure when possible
   - Security groups with limited access
   - HTTPS-only connections with modern TLS

3. **Container Security**:
   - Using lightweight alpine-based images
   - Running nginx as non-root user when possible
   - No sensitive data in container images

## Troubleshooting

### Common Issues

#### CloudFront Access Denied
- Check S3 bucket policy
- Ensure CloudFront OAC is properly configured
- Verify CloudFront distribution is deployed

#### ECS Service Not Available (503 Error)
- Check ECS service health
- Verify container health checks passing
- Review load balancer target group health
- Check security group rules

#### GitHub Actions Failures
- Verify IAM policy permissions
- Check GitHub secrets and variables
- Ensure CloudFront distribution exists before invalidation

## Documentation

### Key Components

- **Infrastructure as Code**:
  - Terragrunt for DRY configurations
  - Terraform modules for reusable components
  - Environment separation for dev/prod

- **S3 + CloudFront Solution**:
  - Optimized for static websites
  - Global content delivery
  - Cost-effective for high-traffic sites

- **ECS + Fargate Solution**:
  - Container-based deployment
  - Automated scaling
  - Support for more complex applications

- **CI/CD Pipelines**:
  - GitHub Actions workflows
  - Secure AWS authentication via OIDC
  - Automated deployment to multiple environments

- **Security Features**:
  - HTTPS with managed certificates
  - Least-privilege IAM policies
  - Secure container configurations

### Solution Comparison

#### 1. S3 + CloudFront
This is a serverless solution ideal for static websites with:
- **Cost Efficiency**: Pay only for storage and data transfer
- **High Scalability**: CloudFront's global CDN ensures fast content delivery
- **Zero Maintenance**: No servers to manage
- **Simple Deployment**: Direct upload to S3
- **Built-in Security**: CloudFront provides HTTPS and WAF integration

#### 2. ECS + Fargate
This container-based solution offers:
- **More Control**: Custom server configurations possible
- **Advanced Features**: Server-side processing if needed
- **Flexible Scaling**: Auto-scaling based on demand
- **Isolation**: Containerized environments
- **Modern Architecture**: Microservices-ready

### Comparison with Other AWS Solutions

#### EC2
- More management overhead
- Requires manual scaling
- Higher operational costs
- Better for complex applications

#### Amplify
- Good for full-stack applications
- Built-in CI/CD
- Limited customization
- Higher cost for simple static sites

#### Elastic Beanstalk
- More suitable for dynamic applications
- Additional abstraction layer
- Higher operational costs
- Better for traditional web applications
