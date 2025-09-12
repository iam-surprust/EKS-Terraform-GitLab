## 📂 Repository Structure

```plaintext
EKS-Terraform-GitLab/
│── modules/                # (Optional) If you later modularize the code
│
├── provider.tf             # Terraform block and AWS provider configuration
├── eks-backend-terra.tf    # Remote backend (S3 + DynamoDB) configuration
├── vpc.tf                  # VPC creation
├── subnets.tf              # Public & private subnets
├── internetgw.tf           # Internet Gateway
├── route.tf                # Route tables and associations
├── sg.tf                   # Security groups for cluster and nodes
├── iam_role.tf             # IAM roles and policies (cluster + nodes)
├── eks_cluster.tf          # EKS control plane definition
├── eks_node_group.tf       # EKS managed node group(s)
├── variables.tf            # Input variables (if missing, define inline or via tfvars)
├── outputs.tf              # Output values (cluster details, node group info, etc.)
├── README.md               # Project documentation



# EKS-Terraform-GitLab
This is the final version of EKS deployment using Terraform
1) What’s in the repo (by filename)

From the repository root:

Provider.tf – declares the Terraform block and AWS provider (region, version constraints), and often configures default tags.

eks-backend-terra.tf – very likely configures the remote backend (S3 + DynamoDB) or at least contains variables for it; some teams also place the actual terraform { backend "s3" { ... } } block here.

vpc.tf – creates an AWS VPC for the cluster.

subnets.tf – creates public/private subnets; usually tagged for EKS and load balancers.

Internetgw.tf – creates an Internet Gateway (IGW).

route.tf – route tables, associations, possibly NAT Gateway & its routes (if present).

sg.tf – security groups (cluster and node group SGs).

iam_role.tf – IAM roles and instance profiles (EKS cluster role, node group role, and common policies).

eks_cluster.tf – the EKS control plane (cluster) itself.

eks_node_group.tf – one or more EKS managed node groups (node instance type, scaling, AMI type, etc.).

README.md – brief description today; I’ll provide a fuller one below. 
GitHub

2) What each file typically contains & why it matters

Below is what these files generally represent in a clean, modular EKS Terraform layout. If your local copy differs, the intent still applies:

Provider.tf

terraform block: required and recommended provider versions (e.g., required_version = ">= 1.5.0", provider constraints).

provider "aws": region (ap-south-1 for Mumbai, if that’s your target), and optionally default tags like Project = "EKS".

Why it matters: pins versions to avoid breaking changes and tells Terraform which cloud and region to talk to.

eks-backend-terra.tf

Often used to define the S3 backend and DynamoDB table for state locking, e.g.:

terraform { backend "s3" { bucket, key, region, dynamodb_table } }

Why it matters: enables team collaboration, state locking, and safe, reproducible plans.

vpc.tf

aws_vpc: CIDR (e.g., 10.0.0.0/16), DNS hostnames/support = true.

EKS requires specific VPC settings; DNS must be enabled so worker nodes can resolve cluster endpoints.

Why it matters: foundational network boundary for all EKS resources.

subnets.tf

aws_subnet resources for private (workloads) and public (ingress/load balancers, NAT egress) subnets, across at least 2 AZs.

EKS & AWS Load Balancer Controller rely on tags:

kubernetes.io/cluster/<cluster-name> = shared (or owned)

kubernetes.io/role/elb = 1 for public subnets

kubernetes.io/role/internal-elb = 1 for private subnets

Why it matters: correct subnet types & tags are mandatory for EKS data plane and Load Balancers to function.

Internetgw.tf

aws_internet_gateway attached to the VPC.

Why it matters: provides public egress/ingress for public subnets (and indirectly for private subnets via NAT, if configured).

route.tf

aws_route_table(s) + aws_route_table_association(s).

Public route table routes 0.0.0.0/0 → IGW.

If you use NAT Gateways: private route tables route 0.0.0.0/0 → NAT.

Why it matters: routes define how nodes/pods reach the internet (images, OS updates) and how LBs are exposed.

sg.tf

aws_security_group for:

EKS cluster (control plane <-> nodes)

Node groups (node-to-node traffic, kubelet, cluster API endpoint)

Why it matters: least-privilege traffic rules reduce blast radius while enabling required ports (e.g., 443, nodeport ranges if needed).

iam_role.tf

aws_iam_role for:

EKS cluster role (trusts eks.amazonaws.com).

Node group role (trusts ec2.amazonaws.com), with managed policies like:

AmazonEKSWorkerNodePolicy

AmazonEKS_CNI_Policy

AmazonEC2ContainerRegistryReadOnly

May also include instance profiles for nodes.

Why it matters: EKS and nodes won’t create or join the cluster without correct IAM roles/policies.

eks_cluster.tf

aws_eks_cluster:

name, version (e.g., 1.29), role_arn (cluster role),

vpc_config with subnet IDs and SGs.

Optional enabled_cluster_log_types (api, audit, authenticator, controllerManager, scheduler).

Why it matters: this is the EKS control plane endpoint and brain of your cluster.

eks_node_group.tf

aws_eks_node_group:

references the cluster name,

node IAM role,

subnet IDs (typically private),

scaling config (desired/min/max),

instance type(s) or Launch Template,

disk size, AMI type (e.g., AL2_x86_64 or Bottlerocket).

Why it matters: managed groups handle node lifecycle, upgrades, and health.

3) A full, drop-in README for your repo

Copy everything between the lines into README.md in your repo.

EKS-Terraform-GitLab

This repository provisions an Amazon EKS cluster and its supporting AWS infrastructure using Terraform.
It covers networking (VPC, subnets, routes, IGW), security (SGs, IAM), the EKS control plane, and one or more EKS managed node groups.

Repository layout

Provider.tf – Terraform & AWS provider configuration.

eks-backend-terra.tf – Remote state backend (S3 + DynamoDB) configuration (or variables for it).

vpc.tf – VPC definition.

subnets.tf – Public and private subnets (tagged for EKS/LB).

Internetgw.tf – Internet Gateway.

route.tf – Route tables, routes, and associations; NAT if present.

sg.tf – Security groups for cluster and nodes.

iam_role.tf – IAM roles/policies for EKS cluster and node groups.

eks_cluster.tf – EKS control plane.

eks_node_group.tf – EKS managed node group(s).

README.md – this guide.

If you don’t see variables.tf and outputs.tf, the variables may be inline in these files or coming from a *.tfvars. Adjust the steps below accordingly.

Prerequisites

Terraform ≥ 1.5

AWS CLI ≥ 2.x with credentials that can create VPC, IAM, and EKS

An S3 bucket and DynamoDB table for remote state (recommended)

kubectl (and optionally aws-iam-authenticator if needed for your OS)

An AWS account with sufficient limits (ENIs, EIPs, NATs, EC2, EKS
