# tf-modules

Terraform modules I use to stand up an AWS EKS cluster and deploy applications
to it. They were written in 2023 against AWS provider 4.32 and Kubernetes
provider 2.13 or later.

## Modules

| Module | What it creates |
| --- | --- |
| `vpc` | VPC with public and private subnets spread across availability zones, an internet gateway and a NAT gateway |
| `eks` | EKS cluster, its IAM roles, an OIDC provider and managed node groups |
| `eks-logging` | Fluent Bit (the `aws-for-fluent-bit` Helm chart) shipping container logs to CloudWatch Logs |
| `eks-metrics` | CloudWatch agent daemonset with its service account, IAM role and log group |
| `eks-secrets` | Secrets Store CSI driver with the AWS secrets provider |
| `eks-storage` | AWS EBS CSI driver: controller, node daemonset, IAM roles and RBAC |
| `k8s-app-stateless` | A Deployment with its own service account and IAM role (IRSA), environment, volumes and resource limits |
| `k8s-app-loadbalancer` | A Network Load Balancer service for an app, with an ACM certificate and Route 53 records |

Each module keeps its variables in `_inputs.tf`, its outputs in `_outputs.tf`
and its provider requirements in `_versions.tf` or `main.tf`.

## Usage

Reference a module by its folder:

```hcl
module "vpc" {
  source = "github.com/baitcode/tf-modules//vpc"

  aws_profile  = "default"
  aws_region   = "eu-west-1"
  cluster_name = "demo"
  vpc_name     = "demo"
  tags         = { project = "demo" }
}

module "eks" {
  source = "github.com/baitcode/tf-modules//eks"

  aws_profile        = "default"
  aws_region         = "eu-west-1"
  cluster_name       = "demo"
  cluster_version    = "1.27"
  new_node_group     = "1.27"
  subnet_ids         = module.vpc.subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  tags               = { project = "demo" }
}
```

The `eks` outputs (`kubernetes_host`, `kubernetes_cluster_ca_certificate`,
`kubernetes_token`, `cluster_oidc_issuer_url`) configure the Kubernetes and Helm
providers and feed the `eks-*` and `k8s-app-*` modules.

## Upgrading nodes

`eks` manages up to two node groups, named after the Kubernetes version of their
AMI. To roll nodes onto a new version, set `new_node_group` to the new version
and `old_node_group` to the current one, apply, then clear `old_node_group` once
workloads have moved.

## Notes

- `vpc` and `eks` declare their own `aws` provider from `aws_profile` and `aws_region`.
- Several modules pin exact provider versions (`aws` 4.32.0, `helm` 2.7.0).
- `k8s-app-loadbalancer` looks up its certificate under a hard-coded domain, so change `service.tf` before using it.

## License

MIT
