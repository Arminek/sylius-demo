terraform {
  backend "remote" {
    organization = "xyz"

    workspaces {
        name = "swibeco"
    }
  }
}
