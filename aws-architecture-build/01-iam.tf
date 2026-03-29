resource "aws_iam_user" "admin_user" {
  name = "ss23-admin"

  tags = {
    Environment = "Production"
    Role        = "Cloud Engineer"
  }
}

resource "aws_iam_group" "cloud_engineers" {
  name = "cloud-Engineer-team"
}

resource "aws_iam_user_group_membership" "team_assignmanet" {
  user = aws_iam_user.admin_user.name

  groups = [
    aws_iam_group.cloud_engineers.name
  ]
}

data "aws_iam_policy_document" "admin_policy_doc" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "custom_admin_policy" {
  name        = "team-admin-access"
  description = "Grants fully administrative access to the AWS account"
  policy      = data.aws_iam_policy_document.admin_policy_doc.json

}

resource "aws_iam_group_policy_attachment" "admin_attachment" {
  group      = aws_iam_group.cloud_engineers.name
  policy_arn = aws_iam_policy.custom_admin_policy.arn
}