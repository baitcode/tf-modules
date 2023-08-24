
resource "aws_iam_role" "cloudwatch_logs" {
  count = var.enabled ? 1 : 0
  name  = var.service_account_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

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

resource "aws_iam_policy" "eks_permissions" {
  count = var.enabled ? 1 : 0
  name  = "eks_permissions"


  policy = jsonencode({
    Version = "2012-10-17"

    Statement : [
      {
        Effect : "Allow",
        Action : [
          "logs:CreateLogGroup",
          "logs:PutLogEvents",
        ],
        Resource : "arn:aws:logs::${var.account_id}:/aws/eks/${var.cluster_name}/*"
      },
      {
        Effect : "Allow",
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Resource : "arn:aws:logs::${var.account_id}:/aws/eks/${var.cluster_name}/*:log-stream:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  count      = var.enabled ? 1 : 0
  role       = aws_iam_role.cloudwatch_logs[0].name
  policy_arn = data.aws_iam_policy.cloudwatch_logs.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs2" {
  count      = var.enabled ? 1 : 0
  role       = aws_iam_role.cloudwatch_logs[0].name
  policy_arn = aws_iam_policy.eks_permissions[0].arn
}
