terraform {
 backend "s3" {
 bucket = "cicd-terraform-eks-suraj"
 key = "backend/FILE_NAME_TO_STORE_STATE.tfstate"
 region = "ap-south-1"
 dynamodb_table = "eks-terraform-statefiles"
 }
}