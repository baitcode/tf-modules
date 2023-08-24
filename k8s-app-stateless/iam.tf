locals {
  oidc_provider = replace(data.aws_eks_cluster.current.identity[0].oidc[0].issuer, "https://", "")
}

resource "aws_iam_policy" "policies" {
  count = var.additional_policy_statements != null ? 1 : 0

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : var.additional_policy_statements
  })
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_iam_role" "app-role" {
  name = "${var.app_name}-role"

  assume_role_policy = jsonencode({
    Version : "2008-10-17"
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Federated : "arn:aws:iam::${local.account_id}:oidc-provider/${local.oidc_provider}"
        },
        Action : "sts:AssumeRoleWithWebIdentity",
        Condition : {
          "StringEquals" : {
            "${local.oidc_provider}:aud" : "sts.amazonaws.com",
            "${local.oidc_provider}:sub" : "system:serviceaccount:${var.namespace}:${var.app_name}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy-attachment" {
  count = var.additional_policy_statements != null ? 1 : 0

  policy_arn = aws_iam_policy.policies[0].arn
  role       = aws_iam_role.app-role.name
}
