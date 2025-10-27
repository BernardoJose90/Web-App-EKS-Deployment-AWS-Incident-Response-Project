# Prometheus and Grafana Monitoring Stack
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

# Monitoring Namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      "app.kubernetes.io/name"    = "monitoring"
      "app.kubernetes.io/instance" = "monitoring"
    }
  }
}

# Prometheus Helm Chart
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.prometheus_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    yamlencode({
      prometheus = {
        prometheusSpec = {
          retention = "30d"
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "gp2"
                accessModes = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "50Gi"
                  }
                }
              }
            }
          }
          serviceMonitorSelectorNilUsesHelmValues = false
          ruleSelectorNilUsesHelmValues = false
        }
      }
      
      grafana = {
        enabled = true
        adminPassword = var.grafana_admin_password
        persistence = {
          enabled = true
          storageClassName = "gp2"
          size = "10Gi"
        }
        service = {
          type = "LoadBalancer"
        }
        ingress = {
          enabled = true
          ingressClassName = "nginx"
          annotations = {
            "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
            "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
          }
          hosts = [var.grafana_domain]
          tls = [{
            secretName = "grafana-tls"
            hosts = [var.grafana_domain]
          }]
        }
        grafana.ini = {
          server = {
            root_url = "https://${var.grafana_domain}"
          }
          security = {
            admin_user = "admin"
            admin_password = var.grafana_admin_password
          }
        }
      }
      
      alertmanager = {
        enabled = true
        alertmanagerSpec = {
          storage = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "gp2"
                accessModes = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "10Gi"
                  }
                }
              }
            }
          }
        }
      }
      
      kubeStateMetrics = {
        enabled = true
      }
      
      nodeExporter = {
        enabled = true
      }
      
      kubelet = {
        enabled = true
      }
    })
  ]

  depends_on = [kubernetes_namespace.monitoring]
}

# AWS CloudWatch Exporter for Prometheus
resource "kubernetes_manifest" "cloudwatch_exporter" {
  manifest = {
    apiVersion = "v1"
    kind       = "ConfigMap"
    metadata = {
      name      = "cloudwatch-exporter-config"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
    }
    data = {
      "config.yml" = yamlencode({
        region = var.aws_region
        metrics = [
          {
            aws_namespace = "AWS/EKS"
            aws_metric_name = "cluster_failed_request_count"
            aws_dimensions = ["ClusterName"]
            aws_dimension_select = {
              ClusterName = [var.cluster_name]
            }
          },
          {
            aws_namespace = "AWS/ApplicationELB"
            aws_metric_name = "TargetResponseTime"
            aws_dimensions = ["LoadBalancer"]
          }
        ]
      })
    }
  }

  depends_on = [kubernetes_namespace.monitoring]
}

# CloudWatch Exporter Deployment
resource "kubernetes_manifest" "cloudwatch_exporter_deployment" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "cloudwatch-exporter"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = "cloudwatch-exporter"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "cloudwatch-exporter"
          }
        }
        spec = {
          containers = [
            {
              name  = "cloudwatch-exporter"
              image = "prom/cloudwatch-exporter:latest"
              ports = [
                {
                  containerPort = 9106
                }
              ]
              volumeMounts = [
                {
                  name      = "config"
                  mountPath = "/config"
                }
              ]
              env = [
                {
                  name  = "AWS_REGION"
                  value = var.aws_region
                }
              ]
            }
          ]
          volumes = [
            {
              name = "config"
              configMap = {
                name = "cloudwatch-exporter-config"
              }
            }
          ]
          serviceAccountName = "cloudwatch-exporter"
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.cloudwatch_exporter]
}

# Service Account for CloudWatch Exporter
resource "kubernetes_service_account" "cloudwatch_exporter" {
  metadata {
    name      = "cloudwatch-exporter"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.cloudwatch_exporter_role.arn
    }
  }

  depends_on = [kubernetes_namespace.monitoring]
}

# IAM Role for CloudWatch Exporter
resource "aws_iam_role" "cloudwatch_exporter_role" {
  name = "cloudwatch-exporter-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${var.oidc_provider_url}:sub" = "system:serviceaccount:${kubernetes_namespace.monitoring.metadata[0].name}:cloudwatch-exporter"
            "${var.oidc_provider_url}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy for CloudWatch Exporter
resource "aws_iam_role_policy" "cloudwatch_exporter_policy" {
  name = "cloudwatch-exporter-policy"
  role = aws_iam_role.cloudwatch_exporter_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
      }
    ]
  })
}

# Service for CloudWatch Exporter
resource "kubernetes_manifest" "cloudwatch_exporter_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "cloudwatch-exporter"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
    }
    spec = {
      selector = {
        app = "cloudwatch-exporter"
      }
      ports = [
        {
          port       = 9106
          targetPort = 9106
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.cloudwatch_exporter_deployment]
}

# ServiceMonitor for CloudWatch Exporter
resource "kubernetes_manifest" "cloudwatch_exporter_servicemonitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "cloudwatch-exporter"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
      labels = {
        "app.kubernetes.io/name" = "cloudwatch-exporter"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          app = "cloudwatch-exporter"
        }
      }
      endpoints = [
        {
          port = "9106"
          path = "/metrics"
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.cloudwatch_exporter_service]
}
