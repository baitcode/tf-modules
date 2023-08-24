resource "aws_iam_role" "cluster_node_role" {
  name = "eks-node-group"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "cluster_node_role_attach_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.cluster_node_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_node_role_attach_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.cluster_node_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_node_role_attach_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.cluster_node_role.name
}

data "aws_ssm_parameter" "eks_ami_release_version_old" {
  count = var.old_node_group != "" ? 1 : 0
  name  = "/aws/service/eks/optimized-ami/${var.old_node_group}/amazon-linux-2/recommended/release_version"
}

data "aws_ssm_parameter" "eks_ami_release_version_new" {
  count = var.new_node_group != "" ? 1 : 0
  name  = "/aws/service/eks/optimized-ami/${var.new_node_group}/amazon-linux-2/recommended/release_version"
}

locals {
  new_node_group_name = replace(var.new_node_group, ".", "_")
  old_node_group_name = replace(var.old_node_group, ".", "_")
}

resource "aws_eks_node_group" "new" {
  count = var.new_node_group != "" ? 1 : 0

  node_group_name = "${var.cluster_name}_node_group_${local.new_node_group_name}"

  # From here to end of resource should be identical in both node groups
  cluster_name    = aws_eks_cluster.cluster.name
  node_role_arn   = aws_iam_role.cluster_node_role.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = [var.instance_type]
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version_new[0].value)

  scaling_config {
    desired_size = var.cluster_size
    max_size     = max(2, var.cluster_size + 1)
    min_size     = 1
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_node_role_attach_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.cluster_node_role_attach_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.cluster_node_role_attach_AmazonEKS_CNI_Policy,
  ]
}

resource "aws_eks_node_group" "old" {
  count           = var.old_node_group != "" ? 1 : 0
  node_group_name = "${var.cluster_name}_node_group_${local.old_node_group_name}"

  # From here to end of resource should be identical in both node groups
  cluster_name    = aws_eks_cluster.cluster.name
  node_role_arn   = aws_iam_role.cluster_node_role.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = [var.instance_type]
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version_old[0].value)


  scaling_config {
    desired_size = var.cluster_size
    max_size     = max(2, var.cluster_size + 1)
    min_size     = 1
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_node_role_attach_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.cluster_node_role_attach_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.cluster_node_role_attach_AmazonEKS_CNI_Policy,
  ]
}
