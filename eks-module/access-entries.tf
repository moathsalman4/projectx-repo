resource "aws_eks_access_entry" "nodes_entry" {
  cluster_name  = aws_eks_cluster.projectx_cluster.name
  principal_arn = aws_iam_role.workers_role.arn
  type          = "EC2_LINUX"
}

resource "aws_eks_access_entry" "github_terraform" {
  cluster_name  = aws_eks_cluster.projectx_cluster.name
  principal_arn = "arn:aws:iam::665832051028:role/GitHubActionsTerraformIAMrole"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_terraform_cluster_admin" {
  cluster_name  = aws_eks_cluster.projectx_cluster.name
  principal_arn = "arn:aws:iam::665832051028:role/GitHubActionsTerraformIAMrole"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope { type = "cluster" }

  depends_on = [aws_eks_access_entry.github_terraform]
}

resource "aws_eks_access_entry" "github_eks_deploy" {
  cluster_name  = aws_eks_cluster.projectx_cluster.name
  principal_arn = "arn:aws:iam::665832051028:role/GitHubActionsEKSDeploymentRole"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_eks_deploy_cluster_admin" {
  cluster_name  = aws_eks_cluster.projectx_cluster.name
  principal_arn = "arn:aws:iam::665832051028:role/GitHubActionsEKSDeploymentRole"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope { type = "cluster" }

  depends_on = [aws_eks_access_entry.github_eks_deploy]
}

resource "aws_eks_access_entry" "salman_practice" {
  cluster_name  = aws_eks_cluster.projectx_cluster.name
  principal_arn = "arn:aws:iam::665832051028:user/salman_practice"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "salman_practice_cluster_admin" {
  cluster_name  = aws_eks_cluster.projectx_cluster.name
  principal_arn = "arn:aws:iam::665832051028:user/salman_practice"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope { type = "cluster" }

  depends_on = [aws_eks_access_entry.salman_practice]
}
