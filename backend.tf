terraform {
  backend "s3" {
    bucket = ""
    key    = "kosli/state"
    region = "eu-west-2"
  }
}
