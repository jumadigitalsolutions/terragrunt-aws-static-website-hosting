# AWS IAM Policy for GitHub Actions

This document provides instructions for updating the IAM role permissions for GitHub Actions workflows in our infrastructure.

## Role Setup

We use AWS IAM roles with OIDC (OpenID Connect) for secure authentication from GitHub Actions. This allows GitHub Actions to assume a role in AWS without storing credentials.

## Required Permissions

The IAM policy attached to the GitHub Actions role needs the following permissions:

1. **S3 Permissions** - For accessing and modifying S3 buckets for static website hosting, Route53 query logs, WAF logs, and Terraform state
2. **CloudFront Permissions** - For creating and updating CloudFront distributions, origin access controls, and response headers policies
3. **Route53 Permissions** - For managing DNS records, DNSSEC, and query logging
4. **ACM Permissions** - For managing SSL/TLS certificates
5. **ECS Permissions** - For managing ECS clusters, task definitions, and services
6. **ECR Permissions** - For managing container repositories
7. **Elastic Load Balancing Permissions** - For managing load balancers for ECS
8. **IAM Permissions** - For managing roles required by other services
9. **KMS Permissions** - For managing encryption keys, particularly for DNSSEC
10. **CloudWatch Logs Permissions** - For managing log groups, especially for Route53 query logging
11. **EC2 Permissions** - For managing VPC and related resources like subnets, route tables, and security groups
12. **WAFv2 Permissions** - For managing Web Application Firewall protection for CloudFront distributions
13. **Kinesis Firehose Permissions** - For WAF logging to S3
14. **SNS Permissions** - For S3 event notifications

## Steps to Update IAM Role

1. Navigate to the IAM section in the AWS Management Console
2. Select "Roles" and locate the GitHub Actions role (`github-execution-role-terragrunt-aws-static-website-hosting`)
3. Choose "Attach policies" or edit the existing inline policy
4. Update the policy with the JSON content from `github-actions-permissions-policy.json`
5. Review and save the policy

## Important Notes

- The policy follows the principle of least privilege while providing necessary permissions for our infrastructure workflows
- S3 bucket operations and object operations are split into separate statements to better control access
- We use wildcards in actions to reduce policy size (e.g., `s3:Get*` instead of listing every Get action)
- For IAM PassRole, we've restricted permissions to specific services via conditions
- For IAM CreateServiceLinkedRole, we've explicitly listed only the required service role ARNs
- Resource ARNs are scoped appropriately where possible to limit permissions
- The policy has been optimized to stay under the AWS 6144 character limit by consolidating related permissions

## Policy Optimization

To ensure the policy stays under the AWS 6144 character limit, we've implemented the following optimizations:

1. **Consolidated Services**: Combined related services into single statements
   - Example: `LoggingAndMonitoring` statement includes logs, cloudwatch, and sns permissions

2. **Broader Wildcards**: Used broader wildcards for services that require comprehensive access
   - Example: Using `cloudfront:*` instead of multiple specific action patterns
   - Example: Using `kms:*` instead of listing each KMS operation

3. **Action Pattern Grouping**: Grouped similar actions with wildcards
   - Example: `ec2:*Vpc*`, `ec2:*Subnet*`, `ec2:*Route*` instead of listing each action separately

4. **Safety Restrictions**: Added conditions to sensitive permissions
   - Example: IAM permissions have a condition to prevent modification of resources tagged as Protected

5. **Simplified Resource Patterns**: Used simpler resource patterns where appropriate
   - Example: Using `s3:*` for terraform state resources rather than listing each action

These optimizations reduce policy size while maintaining the required functionality.

## Recent Updates

The following permissions were recently added or expanded:

### Policy Structure
- Consolidated 20+ statements into 16 statements to reduce policy size
- Grouped related services (e.g., Logs, CloudWatch, SNS) into single statements
- Added condition to IAM permissions to protect sensitive resources

### CloudWatch & SNS
- Added permissions for dashboard management, alarms, and metrics
- Added permissions for SNS topics and subscriptions
- Combined with Logs permissions for a unified monitoring statement

### EC2 VPC
- Simplified EC2 permissions with action patterns (e.g., *Vpc*, *Route*)
- Maintains all required functionality while being more secure and concise
