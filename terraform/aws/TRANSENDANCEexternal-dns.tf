# data "aws_iam_policy_document" "external_dns_controller_assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:dns:external-dns"] # Name of the cluster external dns service account
#     }

#     principals {
#       identifiers = [aws_iam_openid_connect_provider.eks.arn]
#       type        = "Federated"
#     }
#   }
# }


# resource "aws_iam_role" "external_dns_controller" {
#   assume_role_policy = data.aws_iam_policy_document.external_dns_controller_assume_role_policy.json
#   name               = "external-dns-controller"
# }


# resource "aws_iam_policy" "external_dns_controller" {
#   policy = file("./templates/ExternalDNSController.json")
#   name   = "AllowExternalDNSUpdates"
# }

# resource "aws_iam_role_policy_attachment" "external_dns_controller_attach" {
#   role       = aws_iam_role.external_dns_controller.name
#   policy_arn = aws_iam_policy.external_dns_controller.arn
# }

# # output "external_dns_controller_role_arn" {
# #   value = aws_iam_role.aws_load_balancer_controller.arn
# # }

# output "external_dns_controller_role_arn" {
#   value = aws_iam_policy.external_dns_controller.arn
# }

# resource "aws_route53_zone" "main" {
#   name = "tferrari92.com"
# }

# output "aws_route53_zone_id" {
#   value = aws_route53_zone.main.zone_id
# }



# # # ----------------- External DNS -----------------

# resource "helm_release" "external_dns" {
#   name       = "external-dns"
#   namespace  = "dns"
#   wait       = true
#   repository = "https://kubernetes-sigs.github.io/external-dns/"
#   chart      = "external-dns"
#   version    = 1.13.1

#   set {
#     name  = "serviceAccount.name"
#     value = "external-dns"
#   }

#   set {
#     name  = "rbac.pspEnabled"
#     value = false
#   }

#   set {
#     name  = "name"
#     value = "${var.cluster_name}-external-dns"
#   }

#   set {
#     name  = "provider"
#     value = "aws"
#   }

#   set_string {
#     name  = "policy"
#     value = "sync"
#   }

#   set_string {
#     name  = "logLevel"
#     value = var.external_dns_chart_log_level
#   }

#   set {
#     name  = "sources"
#     value = "{ingress,service}"
#   }

#   set {
#     name  = "domainFilters"
#     value = ""
#   }

#   set_string {
#     name  = "aws.zoneType"
#     value = "public"
#   }

#   set_string {
#     name  = "aws.region"
#     value = var.aws_region
#   }
# }