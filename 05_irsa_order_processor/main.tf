module "irsa_order_processor" {
  source = "../modules/irsa_order_processor"

  name                 = "order-processor"
  namespace            = "orders"
  service_account_name = "order-processor-sa"
  eks_oidc_provider    = data.terraform_remote_state.cluster.outputs.oidc_provider_url
  account_id           = var.account_id
  s3_bucket_arn        = "arn:aws:s3:::incomingorders"
}
