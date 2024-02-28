# IAM Role and Instance Profile
resource "aws_iam_role" "ssm_role" {
  name = "role-${var.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
      },
    ],
  })
}

# Policy to allow pulling secrets
resource "aws_iam_policy" "ssm_policy" {
  name        = "ssm_policy-${var.name}"
  description = "Policy to allow access to SSM"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ssm:GetParameter",
        ],
        Effect   = "Allow",
        Resource = "*"
      },
    ],
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = aws_iam_policy.ssm_policy.arn
}

# Attach role to profile
resource "aws_iam_instance_profile" "instance_profile" {
  name = "profile-${var.name}"
  role = aws_iam_role.ssm_role.name
}
