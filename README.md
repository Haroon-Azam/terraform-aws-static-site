# Terraform AWS Static Website with CloudFront + HTTPS

> **Infrastructure as Code project** — provision a secure, HTTPS-enabled static website on AWS using Terraform. A private S3 bucket served globally through a CloudFront CDN, locked down with Origin Access Control. One command deploys everything.

![Terraform](https://img.shields.io/badge/Terraform-1.x-7B42BC?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-S3%20%7C%20CloudFront-FF9900?logo=amazonaws&logoColor=white)
![HTTPS](https://img.shields.io/badge/HTTPS-Enabled-success?logo=letsencrypt&logoColor=white)
![IaC](https://img.shields.io/badge/IaC-Infrastructure%20as%20Code-blue)
![Status](https://img.shields.io/badge/Status-Completed-success)

---

## What This Project Does

This project uses **Terraform** to automatically provision a production-shaped AWS website setup — no AWS Console clicking required.

Running `terraform apply` creates:

- A **private S3 bucket** (no public access at all) that stores the website files
- A **CloudFront distribution** (CDN) that serves the site globally over **HTTPS**
- An **Origin Access Control (OAC)** so that *only* CloudFront can read the bucket
- A **bucket policy** scoped to this exact CloudFront distribution by ARN
- **Custom error handling** that returns `error.html` for 403/404 responses
- Automatic upload of `index.html` and `error.html`

Running `terraform destroy` tears it all down cleanly.

---

## Architecture

```
                User's browser
                      │  HTTPS (TLS)
                      ▼
        ┌──────────────────────────────┐
        │      CloudFront (CDN)         │
        │  • Forces HTTP → HTTPS        │
        │  • Caches at edge locations   │
        │  • Default root: index.html   │
        │  • Custom 403/404 → error.html│
        └──────────────┬───────────────┘
                       │  Origin Access Control (SigV4 signed)
                       ▼
        ┌──────────────────────────────┐
        │   S3 Bucket (PRIVATE)         │
        │   • No public access          │
        │   • Readable ONLY by this     │
        │     CloudFront distribution   │
        │   ┌────────────┐              │
        │   │ index.html │              │
        │   │ error.html │              │
        │   └────────────┘              │
        └──────────────────────────────┘
```

---

## Security Design (Why This Matters)

This project deliberately uses the **private bucket + Origin Access Control** pattern, which is how real teams serve static sites securely:

- The S3 bucket has **all four public access blocks enabled** — it is never exposed to the internet directly.
- CloudFront authenticates to S3 using **Origin Access Control (OAC)** with **AWS SigV4 request signing**.
- The S3 bucket policy grants `s3:GetObject` **only** to the CloudFront *service principal*, and only when the request's `AWS:SourceArn` matches **this specific distribution**. No other CloudFront distribution — and no member of the public — can read the bucket.
- All viewer traffic is forced to **HTTPS** via `redirect-to-https`.

> *In a production environment I would scope the deploying IAM user to least-privilege permissions rather than a broad managed policy, and store Terraform state remotely. See "Planned Improvements".*

---

## Project Structure

```
terraform-aws-static-site/
│
├── provider.tf       # AWS provider + Terraform version config
├── main.tf           # S3 bucket, OAC, CloudFront, policy, file uploads
├── variables.tf      # Input variables (region, bucket name)
├── outputs.tf        # CloudFront HTTPS URL printed after apply
├── index.html        # Static website homepage
├── error.html        # Custom error page
├── .gitignore        # Excludes tfstate, .terraform/, secrets
└── README.md         # This file
```

---

## AWS Resources Provisioned

| Resource | Purpose |
|---|---|
| `aws_s3_bucket` | Creates the private S3 bucket |
| `aws_s3_bucket_public_access_block` | Blocks ALL public access to the bucket |
| `aws_cloudfront_origin_access_control` | Secure identity (OAC) for CloudFront → S3 |
| `aws_cloudfront_distribution` | Global CDN with HTTPS, caching, custom errors |
| `aws_s3_bucket_policy` | Grants read access ONLY to this CloudFront distribution |
| `aws_s3_object` (x2) | Uploads `index.html` and `error.html` |

---

## Prerequisites

- [AWS Account](https://aws.amazon.com/free/) (free tier works)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) installed and configured (`aws configure`)
- [Terraform](https://developer.hashicorp.com/terraform/install) installed (v1.x+)
- [Git](https://git-scm.com/) installed
- IAM user with **S3** and **CloudFront** permissions

---

## How to Deploy

**1. Clone the repository**

```bash
git clone https://github.com/Haroon2012126/terraform-aws-static-site.git
cd terraform-aws-static-site
```

**2. Configure AWS credentials**

```bash
aws configure
```

**3. Initialise, plan, and apply**

```bash
terraform init
terraform plan  -var="bucket_name=your-unique-bucket-name-2026"
terraform apply -var="bucket_name=your-unique-bucket-name-2026"
```

Type `yes` when prompted.

> ⏳ **Note:** CloudFront distributions take **5–15 minutes** to deploy globally. Terraform will appear to pause on the CloudFront resource — this is expected.

**4. Open your website**

Copy the `cloudfront_url` from the output and open it. Your site is live over HTTPS.

---

## Example Output

```bash
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

cloudfront_url = "https://d1234abcd5678.cloudfront.net"
```

---

## How to Destroy (Avoid AWS Charges)

```bash
terraform destroy -var="bucket_name=your-unique-bucket-name-2026"
```

Type `yes`. CloudFront also takes several minutes to delete.

---

## Key Concepts Demonstrated

| Concept | How It's Used |
|---|---|
| **Infrastructure as Code** | All AWS resources defined in `.tf` files — zero manual setup |
| **CloudFront CDN** | Global content delivery with edge caching (TTL configured) |
| **HTTPS / TLS** | All traffic forced to HTTPS via `redirect-to-https` |
| **Origin Access Control** | CloudFront authenticates to S3 with SigV4 signing |
| **Least-exposure security** | Private S3 bucket, readable only by this distribution |
| **IAM Policy Conditions** | Bucket policy scoped by `AWS:SourceArn` to one distribution |
| **Terraform Variables / Outputs** | Parameterised inputs; CloudFront URL surfaced as output |
| **State Management** | `terraform.tfstate` gitignored; never committed |

---

## What I Learned

- How CloudFront sits in front of S3 as an origin and serves content over HTTPS
- How Origin Access Control replaces public buckets with a secure, signed access pattern
- How to scope an S3 bucket policy to a single CloudFront distribution using `AWS:SourceArn`
- Why CloudFront deployments take minutes (global edge propagation) while S3 is instant
- How IAM permissions gate Terraform actions — and how to diagnose `AccessDenied` errors

---

## Planned Improvements

- [x] ~~Add CloudFront CDN for HTTPS and global edge caching~~ ✅ Done
- [ ] Add **custom domain** via Route 53 + ACM certificate
- [ ] Add **GitHub Actions CI/CD** to auto-deploy on push
- [ ] Store Terraform state remotely in **S3 + DynamoDB** (production pattern)
- [ ] Scope deploying IAM user to **least-privilege** permissions

---

## Author

**Muhammad Haroon Azam**
M.Eng. Software Engineering — Concordia University, Montreal

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?logo=linkedin)](https://linkedin.com/in/haroon-azam)
[![GitHub](https://img.shields.io/badge/GitHub-Haroon2012126-181717?logo=github)](https://github.com/Haroon2012126)

---

> *This project is part of my hands-on cloud portfolio. I build, document, and destroy AWS infrastructure to develop real DevOps skills.*
