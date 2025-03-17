# 🚀 Infrastructure - S3 CloudFront GitHub Actions Workflow

This repository contains a **GitHub Actions workflow** that automates the deployment of AWS infrastructure using **Terragrunt** and **Terraform**. The workflow supports **S3 + CloudFront**, **VPC**, and **ECS Fargate** deployments.

## 📌 Features
- **Automated Infrastructure Deployment** via GitHub Actions
- **Environment-Specific Configurations** (Dev & Prod)
- **Security Scanning** with Checkov
- **Infrastructure Code Format Validation**
- **Terraform Plan & Apply Automation**
- **SARIF Security Reports** for GitHub Security Dashboard

---

## 🛠️ Workflow Triggers
The workflow is triggered by:
- **Manual Execution** (`workflow_dispatch`)
- **Code Pushes & Pull Requests** (`push` & `pull_request` events on `main` & `dev` branches) with **Infrastructure Code Changes** on:
  - `.github/workflows/infra-s3-cloudfront.yml`
  - `terragrunt/live/**` 
  - `terragrunt/modules/**`

---

## 🏗️ Workflow Structure
The GitHub Actions workflow follows a structured process:

| Stage             | Description |
|------------------|------------|
| **Code Checks**  | Validates **Terragrunt HCL format** in Dev & Prod |
| **Security Scan** | Runs **Checkov** to detect misconfigurations |
| **Terraform Plan** | Creates a **Terraform Plan** and uploads as an artifact |
| **Terraform Apply** | Applies the changes if approved |

---

## 🔐 Security Scanning with SARIF Reports
The workflow integrates [**Checkov**](https://www.checkov.io/) for security scanning. Results are uploaded to **GitHub Security Dashboard** via [**SARIF reports**](https://www.checkov.io/8.Outputs/SARIF.html).

```yaml
- name: Run Checkov
  uses: bridgecrewio/checkov-action@v12
  with:
    directory: terragrunt/live/${{ vars.AWS_REGION }}/dev/${{ inputs.deploy_module }}
    output_format: cli,sarif
    output_file_path: checkov-dev-results.sarif
    soft_fail: true

- name: Upload SARIF file
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: checkov-dev-results.sarif
```
✅ **Benefits**:
- Direct security insights in **GitHub UI**
- Automated PR security reviews
- Continuous **compliance & governance**

---

## 📂 Directory Structure
```
.
├── terragrunt/
│   ├── live/
│   │   ├── us-east-1/
│   │   │   ├── dev/
│   │   │   ├── prod/
│   ├── modules/
├── .github/workflows/
│   ├── infra-s3-cloudfront.yml
```

---

## 🏗️ Deployment Steps
1. **Trigger Workflow Manually**
   - Navigate to `Actions` → Select `Infrastructure - S3 CloudFront` workflow → Click `Run Workflow`
2. **Push Changes to Main/Dev**
   - GitHub Actions will **automatically validate, scan, and deploy** based on branch policies.
3. **Review Security Scan Results**
   - Check the **Security tab** for potential vulnerabilities.

---

## ⚙️ Required Environment Variables
Ensure the following **GitHub Secrets** and **Environment Variables** are set:

| Name             | Type      | Description |
|------------------|-----------|-------------|
| `AWS_ACCOUNT_ID` | Secret    | AWS Account for authentication |
| `AWS_REGION`     | Variable  | Deployment region (`us-east-1` by default) |
| `GITHUB_TOKEN`   | Secret    | GitHub token for authentication |


## 🔒 Environment Protection & Approvals

The workflow leverages GitHub Environments to implement:
- **Manual Approvals** between environments
- **Environment-Specific Variables**
- **Access Control** for sensitive deployments

## 🚀 DNS Management with GoDaddy & AWS Route 53

This project leverages **GoDaddy's domain registration** while managing DNS records using **AWS Route 53**. To enable this setup, you must configure the **nameservers** in GoDaddy to point to the AWS **Hosted Zone**.

### **Configuring GoDaddy to Use AWS Route 53**
1. **Create a Hosted Zone in AWS Route 53**:
   - Go to the AWS Console → Route 53 → "Hosted Zones"
   - Click **"Create hosted zone"** and enter your domain name.
   - Copy the **NS (Name Server) records** provided by AWS.

2. **Update Nameservers in GoDaddy**:
   - Log in to [GoDaddy](https://www.godaddy.com/)
   - Go to **"My Products"** → Select your domain → Click **"Manage DNS"**
   - Locate the **"Nameservers"** section and click **"Change"**
   - Select **"Enter my own nameservers"** and replace them with the AWS NS records.
   - Save the changes and wait for **DNS propagation**
  
  >_This process can take up to 48 hours, so certificate validation may fail during this process. Hence, we're using the variable use_custom_domain to disable custom domains until GoDady confirms the changes._

### 🎯 **Summary**
✅ **Domain remains registered with GoDaddy**
✅ **DNS records are managed in AWS Route 53**
✅ **GoDaddy’s nameservers must be updated to Route 53’s NS records**



---

## 📌 Best Practices
- ✅ Use **feature branches** for safe testing.
- ✅ Regularly review **SARIF security reports**.
- ✅ Ensure **least privilege IAM roles** for GitHub Actions.

---

## 📞 Support
For any issues or suggestions, open an **issue** in this repository.

📧 **Contact:** [guilherme@jumads.com](mailto:guilherme@jumads.com)
