output "sns_topic_arn" { 
    value = aws_sns_topic.incident_alerts.arn 
    description = "The ARN of the SNS topic for incident alerts"
}

output "sns_subscription_id" { 
    value = aws_sns_topic_subscription.email_alert.id 
    description = "The ID of the SNS topic subscription for email alerts"
}

