output "monitoring_namespace" {
  description = "Namespace where monitoring stack is deployed"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "grafana_url" {
  description = "URL of the Grafana dashboard"
  value       = "https://${var.grafana_domain}"
}

output "prometheus_url" {
  description = "URL of the Prometheus server"
  value       = "http://prometheus-server.${kubernetes_namespace.monitoring.metadata[0].name}.svc.cluster.local"
}

output "cloudwatch_exporter_iam_role_arn" {
  description = "ARN of the IAM role for CloudWatch Exporter"
  value       = aws_iam_role.cloudwatch_exporter_role.arn
}
