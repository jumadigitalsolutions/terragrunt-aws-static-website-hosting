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
- EC2 permissions now explicitly list all necessary actions rather than using wildcards
- Resource ARNs are scoped appropriately where possible to limit permissions
- The policy has been optimized to stay under the AWS 6144 character limit

## Optimization Techniques Used

1. **Using Action Wildcards**: Instead of listing every individual action, we use patterns like `service:*Operation*`
   - Example: `cloudfront:*Distribution*` instead of listing CreateDistribution, DeleteDistribution, etc.

2. **Separating Resource Types**: Bucket-level vs object-level permissions are separated for better security
   - Example: S3BucketPermissions for bucket operations, S3ObjectPermissions for object operations

3. **Scoped PassRole Permissions**: The iam:PassRole permission is restricted to specific services
   - Only allows passing roles to ECS, Firehose, and S3 services
   - Limited to roles starting with "hippo-"

4. **Explicit Service-Linked Role Permissions**: CreateServiceLinkedRole is limited to specific service roles
   - Only allows creation of specific service-linked roles for ECS, ELB, Firehose, and Route53
   - Prevents unintended creation of other service-linked roles

5. **Resource Grouping**: Related resources are grouped together with appropriate patterns
   - Example: `arn:aws:s3:::jumads-hippo-terraform-state*` covers both the bucket and all objects

6. **Service-Specific Statements**: Each AWS service has its own policy statement for better clarity and management

## Recent Updates

The following permissions were recently added or expanded:

### IAM
- Explicit list of role and policy permissions instead of wildcards
- Separate statement for iam:PassRole with resource restriction and service conditions
- New IAMServiceLinkedRolePermission statement with specific service role ARNs

### EC2
- Explicit list of EC2 actions instead of wildcards
- Focused on only the necessary operations for VPC management
- Maintains all required functionality while being more secure

### S3
- Added comprehensive bucket configuration permissions (ownership controls, encryption, public access block)
- Added permissions for replication, tagging, and lifecycle management
- Added permissions for WAF logs buckets

### CloudFront
- Added permissions for origin access control management
- Added permissions for response headers policies
- Added tagging and invalidation permissions

### Route53
- Added tagging permissions
- Added permissions for updating hosted zone comments

### ACM
- Added comprehensive certificate management permissions

### ECS/ECR
- Added tagging permissions
- Added permissions for task monitoring
- Added permissions for image scanning

### KMS
- Added permissions for key operations (encryption, decryption, grants)

### CloudWatch Logs
- Added permissions for log stream management
- Added retention policy management

### WAFv2
- Added comprehensive permissions for Web ACL management
- Added IP set and regex pattern set management
- Added logging configuration permissions

### Kinesis Firehose
- Added permissions for delivery stream management for WAF logging

### Terraform State
- Added comprehensive bucket and DynamoDB table permissions for state management
