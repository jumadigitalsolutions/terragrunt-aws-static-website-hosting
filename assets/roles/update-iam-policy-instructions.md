# Updating IAM Permissions for GitHub Actions Role

Follow these steps to update the permissions for your GitHub Actions role to fix the access denied errors:

## 1. Sign in to AWS Console

1. Go to the [AWS IAM Console](https://console.aws.amazon.com/iam/)
2. Sign in with an account that has administrative privileges

## 2. Find the GitHub Actions Role

1. In the navigation pane, choose **Roles**
2. Search for and select the role named `github-execution-role-terragrunt-aws-static-website-hosting`

## 3. Update the Inline Policy

1. In the **Permissions** tab, find the inline policy attached to the role
2. Click on **Edit policy**
3. Select the **JSON** tab
4. Replace the entire policy with the JSON below:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:PutBucketPolicy",
                "s3:PutBucketAcl",
                "s3:PutBucketOwnershipControls",
                "s3:PutBucketPublicAccessBlock",
                "s3:PutBucketVersioning",
                "s3:PutEncryptionConfiguration",
                "s3:CreateBucket",
                "s3:DeleteBucket"
            ],
            "Resource": [
                "arn:aws:s3:::*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:Get*",
                "dynamodb:List*",
                "dynamodb:Describe*",
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:CreateTable"
            ],
            "Resource": "arn:aws:dynamodb:*:*:table/terraform-*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudfront:Get*",
                "cloudfront:List*",
                "cloudfront:CreateDistribution",
                "cloudfront:UpdateDistribution",
                "cloudfront:DeleteDistribution",
                "cloudfront:TagResource",
                "cloudfront:UntagResource",
                "cloudfront:CreateOriginAccessControl",
                "cloudfront:UpdateOriginAccessControl",
                "cloudfront:DeleteOriginAccessControl"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:Get*",
                "route53:List*",
                "route53:CreateHostedZone",
                "route53:DeleteHostedZone",
                "route53:ChangeResourceRecordSets",
                "route53:GetChange",
                "route53:ChangeTagsForResource"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "acm:Get*",
                "acm:List*",
                "acm:Describe*",
                "acm:RequestCertificate",
                "acm:DeleteCertificate",
                "acm:AddTagsToCertificate",
                "acm:RemoveTagsFromCertificate"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*",
                "ec2:Create*",
                "ec2:Delete*",
                "ec2:Attach*",
                "ec2:Detach*",
                "ec2:Allocate*",
                "ec2:Release*",
                "ec2:Associate*",
                "ec2:Disassociate*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:Get*",
                "logs:List*",
                "logs:Describe*",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        }
    ]
}
```

5. Click **Review policy**
6. Click **Save changes**

## 4. Verify the Changes

1. Go back to the role summary page
2. Check that the updated policy includes the necessary permissions
   - S3 read and write access (with wildcards for read operations)
   - DynamoDB access for Terraform state locking
   - CloudFront distribution and origin access control
   - Route53 for DNS management
   - ACM for certificate management
   - EC2 access with pattern-based permissions
   - CloudWatch Logs for logging

## 5. Run the GitHub Actions Workflow Again

1. Return to your GitHub repository
2. Go to the Actions tab
3. Rerun the failed workflow
4. The permissions errors should now be resolved

## Explanation of the Wildcard Approach

This policy update uses wildcard patterns for read permissions to simplify management:

- **S3 Permissions**:
  - `s3:Get*` and `s3:List*` - Cover all read operations on buckets and objects
  - Individual write permissions - More controlled approach for write operations

- **DynamoDB Permissions**:
  - `dynamodb:Get*`, `dynamodb:List*`, `dynamodb:Describe*` - All read operations
  - Specific write permissions - For Terraform state locking

- **CloudFront Permissions**:
  - `cloudfront:Get*` and `cloudfront:List*` - All CloudFront read operations
  - Individual create/update/delete permissions - For controlled distribution management

- **Route53 Permissions**:
  - `route53:Get*` and `route53:List*` - All DNS read operations
  - Specific action permissions - For DNS record management

- **EC2 Permissions**:
  - Pattern-based permissions using wildcards - More maintainable approach
  - Categories include: `Describe*`, `Create*`, `Delete*`, etc.

This approach provides better maintainability while ensuring that the role has all necessary permissions to execute Terraform/Terragrunt operations successfully. 