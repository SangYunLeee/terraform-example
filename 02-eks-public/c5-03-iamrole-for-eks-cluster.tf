# Create IAM Role
resource "aws_iam_role" "eks_master_role" {
  name = "${local.name}-eks-master-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Associate IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_master_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_master_role.name
}

/*
# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_master_role.name
}
*/

/*
------------------------------------------------
*/
# EKS 관리자 역할 생성
resource "aws_eks_access_entry" "eks_admin" {
  cluster_name      = aws_eks_cluster.eks_cluster.name
  principal_arn     = data.aws_caller_identity.current.arn
  type              = "STANDARD"
}

# EKS 관리자 역할 연결
resource "aws_eks_access_policy_association" "example" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = data.aws_caller_identity.current.arn

  access_scope {
    type       = "cluster"
  }
  depends_on = [aws_eks_access_entry.eks_admin]
}

# EKS 관리자 역할 연결 (kubectl get node 권한 이슈 해결)
resource "aws_eks_access_policy_association" "cluster_admin" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = data.aws_caller_identity.current.arn

  access_scope {
    type       = "cluster"
  }
  depends_on = [aws_eks_access_entry.eks_admin]
}

data "aws_caller_identity" "current" {}
