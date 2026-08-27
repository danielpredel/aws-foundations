data "aws_iam_policy_document" "ec2_app_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_app" {
  name               = "${var.common.prefix_name}-ec2-app-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_app_assume_role_policy.json

  tags = merge(
    var.common.tags,
    {
      Name = "${var.common.prefix_name}-ec2-app-role"
    }
  )
}

data "aws_iam_policy_document" "ec2_app_s3_policy" {
  statement {
    sid = "EC2AppS3ReadWrite"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${var.s3.bucket_name}/*",
    ]
  }
}

resource "aws_iam_policy" "ec2_app_s3" {
  name   = "${var.common.prefix_name}-ec2-s3-app-policy"
  policy = data.aws_iam_policy_document.ec2_app_s3_policy.json
}

resource "aws_iam_role_policy_attachment" "ec2_app_s3" {
  role       = aws_iam_role.ec2_app.name
  policy_arn = aws_iam_policy.ec2_app_s3.arn
}

resource "aws_iam_instance_profile" "ec2_app" {
  name = "${var.common.prefix_name}-ec2-app-instance-profile"
  role = aws_iam_role.ec2_app.name
}
