module "eks_red" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.3"

  name               = "eks-red"
  kubernetes_version = "1.34"

  endpoint_public_access = true
  enable_irsa            = true

  enable_cluster_creator_admin_permissions = true

  compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  vpc_id     = module.vpc_red.vpc_id
  subnet_ids = module.vpc_red.private_subnets

  tags = var.tags
}
