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
                "ec2:Get*",
                "ec2:List*",
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
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecs:Get*",
                "ecs:List*",
                "ecs:Describe*",
                "ecs:CreateCluster",
                "ecs:DeleteCluster",
                "ecs:CreateService",
                "ecs:DeleteService",
                "ecs:UpdateService",
                "ecs:RegisterTaskDefinition",
                "ecs:DeregisterTaskDefinition"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:Get*",
                "ecr:List*",
                "ecr:Describe*",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:CreateRepository",
                "ecr:DeleteRepository",
                "ecr:GetRepositoryPolicy",
                "ecr:SetRepositoryPolicy",
                "ecr:GetAuthorizationToken"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:Get*",
                "elasticloadbalancing:Describe*",
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:DeleteRule",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DeregisterTargets",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:ModifyRule",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:RemoveTags"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:Get*",
                "iam:List*",
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:PassRole",
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy",
                "iam:PutRolePolicy",
                "iam:DeleteRolePolicy"
            ],
            "Resource": [
                "arn:aws:iam::*:role/hippo-*"
            ]
        }
    ]
}
```

5. Click **Review policy**
6. Click **Save changes**

## 4. Verify the Changes

1. Go back to the role summary page
2. Check that the updated policy includes the necessary permissions:
   - Most services have wildcarded `Get*`, `List*`, and `Describe*` permissions for comprehensive read access
   - ELB uses `Describe*` and `Get*` patterns as `List*` is not a valid wildcard for this service
   - Write permissions are explicitly defined for better security control
   - Resource-level restrictions are applied where appropriate (IAM and DynamoDB)

## 5. Update the GitHub OIDC Trust Relationship

1. In the role summary page, go to the **Trust relationships** tab
2. Click **Edit trust relationship**
3. Update the policy document to:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:<GITHUB_ORG>/<REPO_NAME>:*"
        }
      }
    }
  ]
}
```

Replace:
- `<ACCOUNT_ID>` with your AWS account ID
- `<GITHUB_ORG>` with your GitHub organization name
- `<REPO_NAME>` with your repository name

4. Click **Update Trust Policy**

## 6. Run the GitHub Actions Workflow Again

1. Return to your GitHub repository
2. Go to the Actions tab
3. Rerun the failed workflow
4. The permissions errors should now be resolved

## Explanation of the Wildcard Permissions Approach

This updated policy uses a comprehensive wildcard approach for read permissions:

- **Consistent Pattern**: Most services use wildcarded `Get*`, `List*`, and where applicable, `Describe*` patterns
- **ELB Service Exception**: Elastic Load Balancing uses `Describe*` and `Get*` as it doesn't support `List*` wildcards
- **Explicit Write Operations**: All write/modify operations remain explicitly defined for better security control
- **Resource Scoping**: IAM permissions remain scoped to `hippo-*` roles for security
- **Service Coverage**: Full coverage for S3, CloudFront, EC2, ECS, ECR, Load Balancing, and other required services

This approach ensures that Terraform/Terragrunt can fully discover and inspect all resources without permissions errors, while still maintaining appropriate security boundaries for write operations. 