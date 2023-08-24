resource "aws_iam_policy" "driver_service_account_role_policy" {
  name = "AmazonEBSCSIDriverPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Decrypt",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:CreateGrant"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "driver_service_account_role" {
  name = "eks-ebs-driver-role"

  assume_role_policy = jsonencode({
    Version : "2008-10-17"
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Federated : "arn:aws:iam::${var.account_id}:oidc-provider/${var.oidc_provider}"
        },
        Action : "sts:AssumeRoleWithWebIdentity",
        Condition : {
          "StringEquals" : {
            "${var.oidc_provider}:aud" : "sts.amazonaws.com",
            "${var.oidc_provider}:sub" : "system:serviceaccount:${var.namespace}:${var.driver_service_account_name}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "driver_service_policy_attachment" {
  policy_arn = aws_iam_policy.driver_service_account_role_policy.arn
  role       = aws_iam_role.driver_service_account_role.name
}

resource "aws_iam_role" "controller_service_account_role" {
  name = "eks-ebs-controller-role"

  assume_role_policy = jsonencode({
    Version : "2008-10-17"
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Federated : "arn:aws:iam::${var.account_id}:oidc-provider/${var.oidc_provider}"
        },
        Action : "sts:AssumeRoleWithWebIdentity",
        Condition : {
          "StringEquals" : {
            "${var.oidc_provider}:aud" : "sts.amazonaws.com",
            "${var.oidc_provider}:sub" : "system:serviceaccount:${var.namespace}:${var.controller_service_account_name}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "controller_service_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.controller_service_account_role.name
}
