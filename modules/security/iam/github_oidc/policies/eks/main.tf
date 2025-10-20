resource "aws_iam_policy" "github_actions_eks_policy" {
  name        = "GitHubActionsPolicy-EKS"
  description = "EKS, Load Balancers, and AutoScaling access for GitHub Actions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "EKSManagement"
        Effect = "Allow"
        Action = [
          "eks:CreateCluster",
          "eks:DescribeCluster",
          "eks:DeleteCluster",
          "eks:ListClusters",
          "eks:UpdateClusterConfig",
          "eks:UpdateClusterVersion",
          "eks:CreateNodegroup",
          "eks:DeleteNodegroup",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:UpdateNodegroupConfig",
          "eks:TagResource",
          "eks:UntagResource",
          "eks:CreateAddon",
          "eks:DescribeAddon",
          "eks:DeleteAddon",
          "eks:ListAddons",
          "eks:UpdateAddon",
          "iam:CreateServiceLinkedRole",
          "iam:GetServiceLinkedRoleDeletionStatus"
        ]
        Resource = "*"
      },
      {
        Sid = "LoadBalancerAndAutoScaling"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "autoscaling:Describe*",
          "autoscaling:CreateAutoScalingGroup",
          "autoscaling:DeleteAutoScalingGroup",
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:CreateLaunchConfiguration",
          "autoscaling:DeleteLaunchConfiguration",
          "ec2:DescribeLaunchTemplates",
          "ec2:CreateLaunchTemplate",
          "ec2:DeleteLaunchTemplate",
          "ec2:ModifyLaunchTemplate",
          "ec2:CreateLaunchTemplateVersion",
          "ec2:DeleteLaunchTemplateVersion"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_eks_policy" {
  role       = var.role
  policy_arn = aws_iam_policy.github_actions_eks_policy.arn
}
