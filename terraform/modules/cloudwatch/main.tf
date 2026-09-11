resource "aws_cloudwatch_log_group" "app" {
  name = "/aws/ec2/${var.common.project}"

  tags = merge(var.common.tags, {
    Name = "${var.common.prefix_name}-cloudwatch-log-group"
  })
}
