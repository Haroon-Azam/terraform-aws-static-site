# Terraform AWS Static Website

This is a beginner-friendly cloud infrastructure project where I used **Terraform** to deploy a static website on **Amazon S3**.

The main goal of this project was to practice **Infrastructure as Code (IaC)** by creating AWS resources through Terraform instead of manually creating them from the AWS Console.

---

## Project Overview

In this project, I created a simple static website and hosted it on AWS S3 using Terraform.

Terraform was used to create and manage the AWS infrastructure, including the S3 bucket, website configuration, public access settings, bucket policy, and website files.

---

## Architecture

```text
User Browser
     |
     v
Amazon S3 Static Website Endpoint
     |
     v
index.html / error.html


Tools and Services Used
AWS
Terraform
Amazon S3
VS Code
PowerShell



AWS Resources Created

Terraform created the following AWS resources:

S3 bucket
S3 static website configuration
S3 public access block configuration
S3 bucket policy for public read access
index.html object
error.html object


Terraform Concepts Practiced

Through this project, I practiced:

terraform init
terraform plan
terraform apply
Terraform providers
Terraform resources
Terraform variables
Terraform outputs
Terraform state
Infrastructure drift detection
Resource recreation using Terraform


terraform-aws-static-site
├── provider.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── index.html
├── error.html
├── .gitignore
└── README.md

Commands Used
Initialize Terraform
terraform init
Preview the infrastructure changes
terraform plan -var="bucket_name=haroon-terraform-static-site-2026"
Create the AWS resources
terraform apply -var="bucket_name=haroon-terraform-static-site-2026"
Check Terraform state
terraform state list
Show Terraform output
terraform output
Destroy the AWS resources
terraform destroy -var="bucket_name=haroon-terraform-static-site-2026"
Terraform Output

After running terraform apply, Terraform returned the static website endpoint:

website_url = "haroon-terraform-static-site-2026.s3-website-us-east-1.amazonaws.com"

The website can be opened using:

http://haroon-terraform-static-site-2026.s3-website-us-east-1.amazonaws.com

Important Learning: Terraform Drift

During this project, I also learned about infrastructure drift.

Infrastructure drift happens when real cloud resources are changed outside Terraform. For example, if an S3 bucket is deleted manually from the AWS Console, Terraform state may still remember it, but the real AWS resource no longer exists.

When I ran terraform plan, Terraform detected that the resource had changed outside Terraform and planned to recreate it.

This helped me understand why cloud resources created with Terraform should usually be managed through Terraform, not manually from the AWS Console.