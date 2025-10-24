Purpose: Resources that span across multiple AWS accounts

global/
├── organizations/     # AWS Org, OUs, SCPs (affects ALL accounts)
├── iam-identity-center/ # Single Sign-On for ALL accounts
└── terraform.tfvars   # Global variables