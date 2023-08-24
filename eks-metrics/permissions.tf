resource "aws_cloudwatch_log_group" "group" {
  name = "/aws/containerinsights/${var.cluster_name}/performance"

  retention_in_days = 60
  // TODO: TAGS
}

resource "aws_iam_policy" "policies" {
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect : "Allow",
        Action : [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
        ],
        Resource : [
          "arn:aws:logs:${var.cloudwatch_region}:${var.account_id}:log-group:/aws/containerinsights/${var.cluster_name}/performance:*"
        ]
      },
      {
        Effect : "Allow",
        Action : [
          "logs:DescribeLogGroups",
          "logs:CreateLogGroup",
        ],
        Resource : [
          "arn:aws:logs:${var.cloudwatch_region}:${var.account_id}:log-group:/aws/containerinsights/${var.cluster_name}/performance"
        ]
      },
      {
        Effect : "Allow",
        Action : "cloudwatch:PutMetricData",
        Resource : [
          "*",
          "arn:aws:logs:${var.cloudwatch_region}:${var.account_id}:metric:${var.cluster_name}/*"
        ]
      },
      {
        Effect : "Allow",
        Action : [
          "ssm:GetParameter"
        ],
        Resource : [
          "arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*"
        ]
      },
      {
        Effect : "Allow",
        Action : [
          "ec2:DescribeTags",
          "ec2:DescribeVolumes",
        ],
        Resource : [
          "*"
        ]
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_iam_role" "app-role" {
  name = "eks-cloudwatch-role"

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
            "${var.oidc_provider}:sub" : "system:serviceaccount:${var.namespace}:${var.service_account_name}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy-attachment" {
  policy_arn = aws_iam_policy.policies.arn
  role       = aws_iam_role.app-role.name
}
