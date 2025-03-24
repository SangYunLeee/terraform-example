# Security Group for EKS Node Group - Placeholder file
# EKS Cluster Security Group
# resource "aws_security_group" "eks_cluster_sg" {
#   name        = "${local.name}-cluster-sg"
#   description = "EKS Cluster Security Group"
#   vpc_id      = module.vpc.vpc_id

#   # 인바운드 규칙 - 모든 트래픽 허용
#   ingress {
#     description = "Allow all inbound traffic"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # 아웃바운드 규칙 - 모든 트래픽 허용
#   egress {
#     description = "Allow all outbound traffic"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${local.name}-cluster-sg"
#   }
# }