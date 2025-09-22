data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets  = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnets = ["10.0.10.0/24", "10.0.11.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  map_public_ip_on_launch = true

  tags = { Project = var.cluster_name }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                   = var.cluster_name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  eks_managed_node_groups = {
    default = {
      min_size       = 2
      max_size       = 4
      desired_size   = 2
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      key_name   = "ssh-aws-test"
    }
  }

  tags = { Project = var.cluster_name
    ChangeTrigger = "refresh-${timestamp()}"

  }
}

resource "aws_security_group_rule" "allow_egress_to_nexus" {
  type              = "egress"
  from_port         = 8082
  to_port           = 8082
  protocol          = "tcp"
  cidr_blocks       = ["10.0.1.222/32"]
  security_group_id = module.eks.node_security_group_id
  description       = "Allow EKS nodes to reach Nexus on port 8082"

}
resource "aws_security_group_rule" "allow_ssh_to_nodes" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["95.98.221.78/32"]
  security_group_id = module.eks.node_security_group_id
  description       = "Allow SSH to EKS nodes"
}
resource "aws_iam_user" "eks_admin" {
  name = "eks-tf-admin"
}

resource "aws_iam_access_key" "eks_admin" {
  user = aws_iam_user.eks_admin.name
}

resource "aws_iam_user_policy_attachment" "eks_admin_access" {
  user       = aws_iam_user.eks_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# -------- Grant cluster admin using the new EKS access API --------
resource "aws_eks_access_entry" "eks_admin_entry" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_user.eks_admin.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "eks_admin_policy" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_user.eks_admin.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
}

# -------------------- Outputs --------------------
output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_admin_user_arn" {
  value = aws_iam_user.eks_admin.arn
}

output "eks_admin_access_key" {
  value     = aws_iam_access_key.eks_admin.id
  sensitive = true
}

output "eks_admin_secret_key" {
  value     = aws_iam_access_key.eks_admin.secret
  sensitive = true
}
