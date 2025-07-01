# 🚀 EKS with Terraform

A production-ready infrastructure setup for deploying and upgrading an **Amazon EKS (Elastic Kubernetes Service)** cluster using **Terraform** and **GithubActions**. This repository follows Infrastructure-as-Code (IaC) best practices to provision, configure, and manage your Kubernetes environment on AWS.

---

## 🧱 Project Structure

```bash
eks-with-terraform/
├── modules/                # Custom Terraform modules
│   ├── vpc/                # VPC and networking resources
│   ├── eks/                # EKS cluster and node groups
│   └── ...                 # Add other modules (e.g. EBS, IAM, etc.)
├── regions/
│   ├── us-east-1/          # Different AWS Regions
├── main.tf                 # Root Terraform config
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── terraform.tfvars        # Default variable values
└── README.md               # You're here 😎
```

---

## 🚀 Features

- 🌐 Custom VPC with public/private subnets
- ⚙️ Fully managed EKS cluster with node groups and Karpenter
- 🔐 Secure IAM roles for nodes and Kubernetes control plane
- 📆 Modular and reusable Terraform code
- 🌍 Multi-region ready eks cluster
- ✅ Fully Automated EKS Upgrade

---

## 📦 Prerequisites

- [Terraform CLI](https://www.terraform.io/downloads.html)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) with configured credentials
- `kubectl` CLI
- Optional: [Helm](https://helm.sh/)

---

## 🚀 Getting Started

```bash
# 1. Clone the repo
git clone https://github.com/yourusername/eks-with-terraform.git
cd eks-with-terraform

# 2. Initialize Terraform
terraform init

# 3. Preview changes
terraform plan

# 4. Apply changes to deploy
terraform apply
```

> ⚠️ Make sure you have your AWS credentials set via `~/.aws/credentials` or environment variables.

---

## 📅 Inputs

| Name            | Description                        | Type   | Default |
|-----------------|------------------------------------|--------|---------|
| `region`        | AWS region                         | string | `"us-west-2"` |
| `vpc_cidr`      | VPC CIDR block                     | string | `"10.0.0.0/16"` |
| `cluster_name`  | EKS cluster name                   | string | `"eks-cluster"` |
| ...             | ...                                | ...    | ...     |

---

## 📄 Outputs

| Name              | Description                      |
|-------------------|----------------------------------|
| `vpc_id`          | The ID of the created VPC        |
| `eks_cluster_id`  | EKS cluster name                 |
| `kubeconfig`      | Kubeconfig file content (optional) |

---

## 🪩 Clean Up

```bash
terraform destroy
```

---

## ✨ TODO

- [ ] Add Helm support
- [ ] Add GitOps integration (ArgoCD or Flux)
- [ ] Add monitoring with Prometheus + Grafana
- [ ] Set up CI/CD using GitHub Actions

---

## 📄 License

MIT License. See [LICENSE](./LICENSE) for details.

---

## 🙌 Author

Made with ❤️ by [Ravi](https://github.com/tripathiravi07)

