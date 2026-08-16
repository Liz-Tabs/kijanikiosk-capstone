resource "kubernetes_namespace" "staging" {
  metadata {
    name = "kijani-staging"

    labels = {
      "app.kubernetes.io/part-of" = "kijanikiosk"
      environment                 = "staging"
      managed-by                  = "terraform"
    }
  }
}
