terraform {
  backend "remote" {
    organization = "Sylius"

    workspaces {
        name = "private-cloud-swibeco"
    }
  }
}
