locals {
  name_prefix = "${var.project}-${var.environment}"
}
resource "aws_s3_bucket" "learning" {
  bucket = "${local.name_prefix}-logs"
}
resource "aws_s3_bucket" "backups" {
  bucket = "${local.name_prefix}-backups"
}
resource "aws_s3_bucket" "audit" {
  bucket = "${local.name_prefix}-audit"
  tags = {
    source_bucket = aws_s3_bucket.learning.arn
  }
}
