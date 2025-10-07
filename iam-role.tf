# Create IAM Role for VPC Lattice Controller
resource "aws_iam_role" "lattice_role" {
  name = "VPCLatticeRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = [
            module.eks_blue.oidc_provider_arn,
            module.eks_green.oidc_provider_arn,
            module.eks_red.oidc_provider_arn
          ]
        },
        Action = "sts:AssumeRoleWithWebIdentity"
      }
    ]
  })
}

# Attach AWS Managed Policy
resource "aws_iam_role_policy_attachment" "lattice_full_access" {
  role = aws_iam_role.lattice_role.name
  # policy_arn = "arn:aws:iam::aws:policy/VPCLatticeFullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
