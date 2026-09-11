resource "aws_cloudwatch_log_group" "app" {
  name = var.cloudwatch.log_group_name

  tags = merge(var.common.tags, {
    Name = "${var.common.prefix_name}-cloudwatch-log-group"
  })
}
