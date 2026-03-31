resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/ec2/production-web-app"
  retention_in_days = 14
}

# CloudWatch Alarm (Tied to the SNS Topic from Step 8)
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "production-high-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average" # Since CPU goes up and down every second, We tell CloudWatch to calculate the Average over a window of time.
  threshold           = 80
  alarm_description   = "Triggers if ASG CPU exceeds 80% for 4 minutes"

  # What exactly are we measuring? The ASG we built in Step 5.
  # By linking it to the Auto Scaling Group, the alarm automatically averages the CPU of every server in that group, even as servers are added or removed.
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_fleet.name
  }

  # When it triggers, broadcast the alert to our SNS Megaphone!
  # You can also put the ARN of an Auto Scaling Policy here to tell AWS to "Add more servers" automatically when the CPU is high.
  alarm_actions = [aws_sns_topic.system_alerts.arn]
}

# The CloudTrail S3 Bucket
# NOTE: Bucket names must be globally unique. Change 'xyz' if it fails.
resource "aws_s3_bucket" "trail_logs" {
  bucket        = "ss23-cloudtrail-audits-2026-xyz"
  force_destroy = true # This is the "Nuclear Option."
}

# Strict Bucket Policy allowing CloudTrail to write to S3
data "aws_iam_policy_document" "trail_policy" {
  statement {
    # "Permission Check."
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    # without (GetBucketAcl), they will refuse to deliver the package.
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.trail_logs.arn]
  }

  statement {
    # "Delivery Permission."
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.trail_logs.arn}/prefix/AWSLogs/*"] # You are only allowed to put files inside the folder named /prefix/AWSLogs/
    condition {
      # It ensures you always have "Full Control" over the data CloudTrail delivers.
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

# 5. Attach the Policy to the Bucket
resource "aws_s3_bucket_policy" "trail_bucket_policy" {
  bucket = aws_s3_bucket.trail_logs.id
  policy = data.aws_iam_policy_document.trail_policy.json
}

# 6. The CloudTrail (The Auditor)
resource "aws_cloudtrail" "security_audit" {
  name                          = "production-security-audit"
  s3_bucket_name                = aws_s3_bucket.trail_logs.id
  s3_key_prefix                 = "prefix" # it puts a files inside a folder named prefix/
  include_global_service_events = true     # ensures that no matter where a global change happens, it gets recorded.
  is_multi_region_trail         = true     # A "Multi-Region" trail catches them everywhere and sends all the logs to your one central S3 bucket.
  enable_log_file_validation    = true     # Every hour, CloudTrail creates a "Digest File" (a digital fingerprint) of all the logs it just delivered.

  # Strict sequencing: Do not start auditing until the bucket can accept logs
  depends_on = [aws_s3_bucket_policy.trail_bucket_policy]
}