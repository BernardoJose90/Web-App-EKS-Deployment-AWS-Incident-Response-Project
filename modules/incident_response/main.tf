/*
modules/incident_response/
├── main.tf                    # Core resources
├── lambda_remediation.tf      # Automated response functions
├── forensics.tf              # Evidence collection
├── alerting.tf               # Notifications
├── iam.tf                    # IR team access
├── variables.tf
├── outputs.tf
└── scripts/                  # Lambda function code
    ├── security_automation.py
    ├── requirements.txt
    └── package.sh
*/
