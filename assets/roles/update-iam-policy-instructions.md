# Updating IAM Permissions for GitHub Actions Role

This document explains how to update the IAM permissions for the GitHub Actions role used in the CI/CD pipelines.

## Overview

The GitHub Actions workflows use an IAM role to perform various AWS operations during infrastructure deployment and application deployment. This role is authenticated using OpenID Connect (OIDC), which provides secure, token-based authentication without the need for long-lived credentials.

## Permission Updates

The IAM policy attached to the GitHub Actions role needs to be updated to include the following permissions:

1. S3 permissions for bucket creation, management, and website hosting
2. CloudFront permissions for distribution management and cache invalidation
3. Route53 permissions for DNS management
4. ACM permissions for certificate management
5. EC2 permissions for VPC and networking resources
6. ECS permissions for container management
7. ECR permissions for container image repositories
8. Elastic Load Balancing permissions for load balancer management
9. IAM permissions for service role management

## Update Steps

Follow these steps to update the IAM policy for the GitHub Actions role:

1. Log in to the AWS Management Console

2. Navigate to the IAM service

3. In the left navigation pane, select "Roles"

4. Search for and select the role named `github-execution-role-terragrunt-aws-static-website-hosting`

5. In the "Permissions" tab, find the inline policy and select "Edit"

6. Replace the policy content with the updated JSON policy document from `github-actions-permissions-policy.json`

7. Review the changes to ensure they match your requirements:
   - The policy includes necessary permissions for S3, CloudFront, Route53, ACM, EC2, ECS, ECR, Elastic Load Balancing, and IAM.
   - Most service APIs have wildcarded `Get*` and `List*` permissions for comprehensive read access.
   - Write permissions are explicitly defined for security reasons.
   - CloudFront permissions include `cloudfront:CreateInvalidation` for cache invalidation.

8. Save the policy changes

## Security Considerations

- The policy follows the principle of least privilege by specifying only the permissions needed for the GitHub Actions workflows.
- OIDC authentication ensures that access is temporary and tied to specific GitHub repository actions.
- Regular review of these permissions is recommended as your infrastructure needs evolve.

## Troubleshooting

If you encounter errors during workflow execution related to IAM permissions:

1. Check the CloudWatch Logs for the specific permission being denied
2. Add the required permission to the IAM policy
3. Update the role's policy using the steps above
4. Re-run the failed workflow 