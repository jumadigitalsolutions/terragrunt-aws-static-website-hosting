# AWS Static Website Hosting Solutions

This repository demonstrates two different approaches for hosting static websites on AWS, comparing their benefits and tradeoffs.

Check out the Medium Article I published on this topic: [AWS Static Website Hosting Solutions](https://medium.com/juma-digital-solutions/aws-static-website-hosting-with-terragrunt-and-github-actions-4199e88f5063) comparing the solutions in-depth, including cost analysis, security considerations, and deployment strategies.

## Documentation

[ Docs under construction ]

- [Infrastructure as Code](docs/iac.md)
  - [S3 + CloudFront Detailed Guide](docs/s3-cloudfront.md)
  - [ECS + Fargate Detailed Guide](docs/ecs-fargate.md)
- [Multi-Account Strategy](docs/multi-account.md)
- [Zero Downtime Deployments && Rollback Strategies](docs/deployments.md)
- [Monitoring & Logging](docs/monitoring.md)
- [CI/CD Pipelines](docs/cicd.md)
- [Infrastructure as Code](docs/iac.md)
- [Cost Analysis](docs/costs.md)
- [Security Best Practices](docs/security.md)

## Solution Comparison

### 1. S3 + CloudFront
This is a serverless solution ideal for static websites with:
- **Cost Efficiency**: Pay only for storage and data transfer
- **High Scalability**: CloudFront's global CDN ensures fast content delivery
- **Zero Maintenance**: No servers to manage
- **Simple Deployment**: Direct upload to S3
- **Built-in Security**: CloudFront provides HTTPS and WAF integration

### 2. ECS + Fargate
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

## Getting Started

### Prerequisites
