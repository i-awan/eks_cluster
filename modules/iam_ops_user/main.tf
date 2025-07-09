data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [var.eks_oidc_provider]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(var.eks_oidc_provider, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account_name}"]
    }
  }

  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:user/ops-alice"]
    }

    actions = ["sts:AssumeRole"]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = ["52.94.236.248/32"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.name}-ops-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "kubernetes_service_account" "this" {
  metadata {
    name      = var.service_account_name
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.this.arn
    }
  }
}

resource "kubernetes_role" "ops_viewer" {
  metadata {
    name      = "ops-view"
    namespace = var.namespace
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "endpoints", "configmaps"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "ops_bind" {
  metadata {
    name      = "ops-bind"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.ops_viewer.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.service_account_name
    namespace = var.namespace
  }
}
