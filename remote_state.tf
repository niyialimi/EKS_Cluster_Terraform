terraform {
  backend "s3" {
    bucket         = "niyi-alimi-state-file"
    key            = "s3_and_dynamo.tfstate"
    region         = "ap-southeast-2"
    encrypt        = true
    dynamodb_table = "niyi-alimi-state-lock"
  }
}