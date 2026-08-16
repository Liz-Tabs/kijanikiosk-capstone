provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "aws" {
  region = "eu-north-1"
}
