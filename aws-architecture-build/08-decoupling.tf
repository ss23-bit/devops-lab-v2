resource "aws_sns_topic" "system_alerts" {
  name = "production-system-alerts"
}

resource "aws_sqs_queue" "alert_processing_queue" {
  name                      = "alert-processing-queue"
  message_retention_seconds = 345600
}

# The Connection (Subscribe the Queue to the Topic)
resource "aws_sns_topic_subscription" "queue_target" {
  topic_arn = aws_sns_topic.system_alerts.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.alert_processing_queue.arn
}

# The Security Logic (Define the permission document)
data "aws_iam_policy_document" "sns_to_sqs_doc" {
  statement {
    effect    = "Allow"
    actions   = ["sqs:SendMassage"] # Drop a data at sqs
    resources = [aws_sqs_queue.alert_processing_queue.arn]

    # Who is allowed to do this? The SNS Service.
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    # Strict Security
    condition {
      test     = "ArnEquals"                       # Matching Rule
      variable = "aws:SourceArn"                   # What we are checking
      values   = [aws_sns_topic.system_alerts.arn] # Authorized List
    }
  }
}

# Attach the Security Policy to the Queue
resource "aws_sqs_queue_policy" "sns_to_sqs_attachment" {
  queue_url = aws_sqs_queue.alert_processing_queue.id
  policy    = data.aws_iam_policy_document.sns_to_sqs_doc.json
}