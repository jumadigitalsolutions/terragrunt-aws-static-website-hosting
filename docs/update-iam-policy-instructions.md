# AWS IAM Policy for GitHub Actions

This document provides instructions for updating the IAM role permissions for GitHub Actions workflows in our infrastructure.

## Role Setup

We use AWS IAM roles with OIDC (OpenID Connect) for secure authentication from GitHub Actions. This allows GitHub Actions to assume a role in AWS without storing credentials.

## Required Permissions

The IAM policy attached to the GitHub Actions role needs the following permissions:

1. **S3 Permissions** - For accessing and modifying S3 buckets for static website hosting, Route53 query logs, and Terraform state
2. **CloudFront Permissions** - For creating and updating CloudFront distributions
3. **Route53 Permissions** - For managing DNS records, DNSSEC, and query logging
4. **ACM Permissions** - For managing SSL/TLS certificates
5. **ECS Permissions** - For managing ECS clusters, task definitions, and services
6. **ECR Permissions** - For managing container repositories
7. **Elastic Load Balancing Permissions** - For managing load balancers for ECS
8. **IAM Permissions** - For managing roles required by other services
9. **KMS Permissions** - For managing encryption keys, particularly for DNSSEC
10. **CloudWatch Logs Permissions** - For managing log groups, especially for Route53 query logging

## Steps to Update IAM Role

1. Navigate to the IAM section in the AWS Management Console
2. Select "Roles" and locate the GitHub Actions role (`github-execution-role-terragrunt-aws-static-website-hosting`)
3. Choose "Attach policies" or edit the existing inline policy
4. Update the policy with the JSON content from `github-actions-permissions-policy.json`
5. Review and save the policy

## Important Notes

- The policy follows the principle of least privilege while providing necessary permissions for our infrastructure workflows
- S3 permissions are restricted to specific bucket patterns (hippo-website-* and route53-query-logs-*)
- Wildcard permissions have been removed in favor of explicit permissions
- Route53 permissions are centralized in the new Route53 module
- KMS permissions are required for Route53 DNSSEC key management
- CloudWatch Logs permissions are needed for Route53 query logs
