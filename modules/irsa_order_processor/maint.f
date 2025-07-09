data "aws_iam_openid_connect_provider" "eks" {
  url = "https://${var.oidc_url}"
}

resource "aws_iam_policy" "s3_read_orders" {
  name        = "${var.name}-s3-read-orders"
  description = "Policy to allow access to incomingorders S3 bucket"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      Resource = [
        "arn:aws:s3:::incomingorders",
        "arn:aws:s3:::incomingorders/*"
      ]
    }]
  })
}

resource "aws_iam_role" "irsa_role" {
  name = "${var.name}-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.eks.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${var.oidc_url}:sub" = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.irsa_role.name
  policy_arn = aws_iam_policy.s3_read_orders.arn
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

resource "kubernetes_service_account" "order_processor" {
  metadata {
    name      = var.service_account_name
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.irsa_role.arn
    }
  }
}

resource "kubernetes_cluster_role" "order_processor_view" {
  metadata {
    name = "${var.name}-view-role"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "configmaps", "secrets"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "order_processor_view_binding" {
  metadata {
    name = "${var.name}-view-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.order_processor_view.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.order_processor.metadata[0].name
    namespace = var.namespace
  }
}
