terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = "eu-central-1"
}

module "layer" {
  source                     = "../../../modules/layer"
  layer_name                 = "terraform-aws-lambda-test-build-command"
  layer_path                 = "${path.cwd}/layer/src"
  s3_bucket_upload_layer_zip = "fsantos-lambda-layers"
  runtime                    = "python3.7"
  build_command              = "${path.cwd}/layer/build.sh '$filename' '$runtime' '$source'"
  build_paths                 = ["${path.cwd}/layer/build.sh"]
}
