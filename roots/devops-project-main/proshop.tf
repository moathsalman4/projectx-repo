resource "aws_iam_role" "proshop_secrets" {
  name = "proshop-backend-IRSA-role" # IAM role name (assumed by Kubernetes via IRSA)

  assume_role_policy = jsonencode({
    Version = "2012-10-17" # IAM policy language version
    Statement = [{
      Effect = "Allow"                         # allow this action
      Action = "sts:AssumeRoleWithWebIdentity" # IRSA uses web identity tokens (OIDC)
      Principal = {
        Federated = module.eks-module.oidc_provider_arn # ✅ your EKS OIDC provider ARN (from outputs.tf)
      }
      Condition = {
        StringEquals = {
          # ✅ CRITICAL FIX:
          # AWS expects the key format: "<OIDC_PROVIDER_HOSTPATH>:aud"
          # cluster_oidc_issuer is a URL, so we remove "https://"
          "${replace(module.eks-module.cluster_oidc_issuer, "https://", "")}:aud" = "sts.amazonaws.com" # required audience for IRSA
        }
      }
    }]
  })
}

resource "aws_iam_policy" "proshop_secrets" {
  name = "proshop-secret-read-policy" # IAM policy name (grants read access to Secrets Manager)

  policy = jsonencode({
    Version = "2012-10-17" # IAM policy language version
    Statement = [{
      Effect = "Allow" # allow these actions
      Action = [
        "secretsmanager:GetSecretValue", # read the secret value
        "secretsmanager:DescribeSecret"  # read secret metadata
      ]
      Resource = "arn:aws:secretsmanager:us-east-1:665832051028:secret:proshop*" # your account + region + proshop secret name prefix
    }]
  })
}

resource "aws_iam_role_policy_attachment" "proshop_secrets" {
  role       = aws_iam_role.proshop_secrets.name  # attach to the role we created above
  policy_arn = aws_iam_policy.proshop_secrets.arn # attach the policy we created above
}

resource "aws_secretsmanager_secret" "proshop_backend" {
  name                           = "proshop-dev-backend-app-values" # secret name that will store backend env/config values
  recovery_window_in_days        = 0                                # if deleted, delete immediately (no 7/30 day recovery delay)
  force_overwrite_replica_secret = false                            # leave replicas alone if any exist
}


# proshop.tf creates the IAM permissions needed for the ProShop backend running in Kubernetes to securely access AWS Secrets Manager 
# using IRSA (IAM Roles for Service Accounts). It provisions an IAM role trusted by the EKS OIDC provider, an IAM policy that allows 
# reading ProShop-related secrets, and attaches that policy to the role. It also creates an empty Secrets Manager secret (proshop-dev-backend-app-values) 
# that will later store backend configuration values such as database connection information. When the workflow runs, 
# Terraform will create these IAM resources and the secret in your AWS account so the ProShop application can securely retrieve its secrets at runtime.


# proshop.tf sets up IRSA so the Proshop backend pods can securely read Secrets Manager without hardcoding AWS keys. 
# It creates an IAM role trusted by the cluster’s OIDC provider, a policy that allows GetSecretValue/DescribeSecret 
# for secrets starting with proshop*, and attaches that policy to the role. When the workflow runs, Terraform provisions 
# that role + policy + attachment and also creates an empty Secrets Manager secret called proshop-dev-backend-app-values for 
# backend environment values.