ARCHITECTURE OVERVIEW

COMPLETE DEPLOYMENT FLOW:

1. ORGANIZATION LAYER (global/)
   • AWS Organizations & SCPs
   • IAM Identity Center
   • Centralized Policies

2. FOUNDATION ACCOUNTS (accounts/)
   • Security Account: GuardDuty, Security Hub, CloudTrail
   • Network Account: Transit Gateway, VPCs
   • Shared Services: ArgoCD Control Plane, ECR

3. WORKLOAD ENVIRONMENTS (environments/)
   • Development: eu-west-1, eu-west-2
   • Production: eu-west-1, eu-west-2

4. GITOPS DELIVERY
   • ArgoCD (Shared Services) → Manages all EKS clusters
   • Application deployment via Git repositories

5. SECURITY AUTOMATION
   • Real-time monitoring & automated incident response
   • Cross-account security findings aggregation

6. MONITORING & OBSERVABILITY
   • Prometheus/Grafana for application metrics
   • CloudWatch for AWS service monitoring