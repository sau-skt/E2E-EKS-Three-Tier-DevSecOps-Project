resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = module.eks.nodegroup_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes"
        ]
      },
      {
        rolearn  = var.jenkins-role-arn
        username = "jenkins"
        groups = [
          "system:masters"
        ]
      }
    ])
  }

  force = true

  depends_on = [module.eks]
}
