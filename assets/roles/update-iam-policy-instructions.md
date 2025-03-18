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
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:GetBucketLocation",
                "s3:GetBucketPolicy",
                "s3:PutBucketPolicy",
                "s3:GetBucketAcl",
                "s3:PutBucketAcl",
                "s3:GetBucketOwnershipControls",
                "s3:PutBucketOwnershipControls",
                "s3:GetBucketPublicAccessBlock",
                "s3:PutBucketPublicAccessBlock",
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
                "cloudfront:CreateDistribution",
                "cloudfront:GetDistribution",
                "cloudfront:UpdateDistribution",
                "cloudfront:DeleteDistribution",
                "cloudfront:TagResource",
                "cloudfront:UntagResource",
                "cloudfront:ListTagsForResource",
                "cloudfront:CreateOriginAccessControl",
                "cloudfront:GetOriginAccessControl",
                "cloudfront:UpdateOriginAccessControl",
                "cloudfront:DeleteOriginAccessControl",
                "cloudfront:ListOriginAccessControls"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:CreateHostedZone",
                "route53:GetHostedZone",
                "route53:ListHostedZones",
                "route53:DeleteHostedZone",
                "route53:ChangeResourceRecordSets",
                "route53:ListResourceRecordSets",
                "route53:GetChange",
                "route53:TagResource",
                "route53:UntagResource",
                "route53:ListTagsForResource"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "acm:RequestCertificate",
                "acm:DescribeCertificate",
                "acm:DeleteCertificate",
                "acm:ListCertificates",
                "acm:ListTagsForCertificate",
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
                "ec2:DescribeVpcs",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeRouteTables",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeNatGateways",
                "ec2:CreateVpc",
                "ec2:DeleteVpc",
                "ec2:CreateSubnet",
                "ec2:DeleteSubnet",
                "ec2:CreateRouteTable",
                "ec2:DeleteRouteTable",
                "ec2:CreateRoute",
                "ec2:DeleteRoute",
                "ec2:CreateInternetGateway",
                "ec2:DeleteInternetGateway",
                "ec2:AttachInternetGateway",
                "ec2:DetachInternetGateway",
                "ec2:AllocateAddress",
                "ec2:ReleaseAddress",
                "ec2:AssociateRouteTable",
                "ec2:DisassociateRouteTable",
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams"
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
2. Check that the updated policy includes the new permissions
   - S3 bucket ownership controls
   - S3 bucket public access block
   - CloudFront origin access control
   - Route53 tags

## 5. Run the GitHub Actions Workflow Again

1. Return to your GitHub repository
2. Go to the Actions tab
3. Rerun the failed workflow
4. The permissions errors should now be resolved

## Explanation of Added Permissions

This policy update adds essential permissions that were missing:

- **S3 Permissions**:
  - `s3:GetBucketOwnershipControls` - To view the ownership controls settings
  - `s3:PutBucketOwnershipControls` - To modify ownership controls
  - `s3:GetBucketPublicAccessBlock` - To view public access block settings
  - `s3:GetBucketAcl`/`s3:PutBucketAcl` - To manage bucket ACLs

- **CloudFront Permissions**:
  - `cloudfront:CreateOriginAccessControl` - To create OAC
  - `cloudfront:GetOriginAccessControl` - To view OAC settings
  - `cloudfront:UpdateOriginAccessControl` - To modify OAC
  - `cloudfront:DeleteOriginAccessControl` - To remove OAC

- **Route53 Permissions**:
  - `route53:ListTagsForResource` - To view tags for Route53 resources
  - `route53:TagResource`/`route53:UntagResource` - To manage tags 