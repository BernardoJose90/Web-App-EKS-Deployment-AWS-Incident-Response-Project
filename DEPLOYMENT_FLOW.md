# Deployment Sequence

## Phase 1: Foundation
1. Deploy global/organizations/ (AWS Org + SCPs)
2. Deploy accounts/security/ (Security tools)
3. Deploy accounts/network/ (Network hub)
4. Deploy accounts/shared-services/ (ArgoCD + ECR)

## Phase 2: Workload Clusters  
5. Deploy environments/dev/ (EKS clusters)
6. Deploy environments/prod/ (EKS clusters)

## Phase 3: Application Delivery
7. Configure ArgoCD applications
8. Deploy via GitOps pipelines

## Phase 4: Security & Monitoring
9. Enable security automation
10. Configure monitoring dashboards