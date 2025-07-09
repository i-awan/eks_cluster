
output "cluster_name" {
  value = module.eks_cluster.cluster_name
}

output "cluster_endpoint" {
  value = module.eks_cluster.cluster_endpoint
}

output "node_security_group_id" {
  value = module.eks_cluster.node_security_group_id
}
