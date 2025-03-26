################################################################################
# CloudWatch Monitoring for WAF
################################################################################
resource "aws_cloudwatch_dashboard" "waf_dashboard" {
  count          = var.enable_wafv2 ? 1 : 0
  dashboard_name = "WAF-Dashboard-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/WAFV2", "BlockedRequests", "WebACL", "cloudfront-web-acl-${var.environment}", "Region", "us-east-1", { "stat" : "Sum" }],
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Blocked Requests"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/WAFV2", "CountedRequests", "WebACL", "cloudfront-web-acl-${var.environment}", "Region", "us-east-1", { "stat" : "Sum" }],
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Counted Requests"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/WAFV2", "AllowedRequests", "WebACL", "cloudfront-web-acl-${var.environment}", "Region", "us-east-1", { "stat" : "Sum" }],
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Allowed Requests"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/WAFV2", "BlockedRequests", "Rule", "rate-limit", "WebACL", "cloudfront-web-acl-${var.environment}", "Region", "us-east-1", { "stat" : "Sum" }],
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Rate Limited Requests"
          period  = 300
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "waf_blocked_requests_alarm" {
  count               = var.enable_wafv2 ? 1 : 0
  alarm_name          = "WAF-BlockedRequests-High-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = 300
  statistic           = "Sum"
  threshold           = 100
  alarm_description   = "This alarm triggers when the number of blocked requests exceeds the threshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    WebACL = "cloudfront-web-acl-${var.environment}"
    Region = "us-east-1"
  }

  alarm_actions = var.sns_alarm_topic_arn != "" ? [var.sns_alarm_topic_arn] : []
  ok_actions    = var.sns_alarm_topic_arn != "" ? [var.sns_alarm_topic_arn] : []

  tags = var.tags
}
