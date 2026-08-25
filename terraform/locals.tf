locals {
  prefix_name = "${var.project}-${var.environment}-${var.region_abbreviation}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
  }
}
