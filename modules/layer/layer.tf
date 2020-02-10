# Generates a filename for the zip archive based on the contents of the files
# in source_path. The filename will change when the source code changes.
data "external" "archive" {
  program = ["python", "${path.module}/../../hash.py"]

  query = {
    build_command   = var.build_command
    build_paths     = jsonencode(var.build_paths)
    module_realpath = abspath("${path.module}/../../")
    runtime         = var.runtime
    source_path     = var.layer_path
  }
}


# Build the zip archive whenever the filename changes.
resource "null_resource" "archive" {
  triggers = {
    filename = lookup(data.external.archive.result, "filename")
  }

  provisioner "local-exec" {
    command     = lookup(data.external.archive.result, "build_command")
    working_dir = path.module
  }
}


# Check that the null_resource.archive file has been built. This will rebuild
# it if missing. This is used to catch situations where the Terraform state
# does not match the Lambda function in AWS, e.g. after someone manually
# deletes the Lambda function. If the file is rebuilt here, the build
# output is unfortunately invisible.
data "external" "built" {
  program = ["python", "${path.module}/../../built.py"]

  query = {
    build_command   = lookup(data.external.archive.result, "build_command")
    filename_old    = lookup(null_resource.archive.triggers, "filename")
    filename_new    = lookup(data.external.archive.result, "filename")
    module_realpath = abspath("${path.module}/../../")
  }
}

resource "aws_s3_bucket_object" "layer_s3_object" {
  depends_on = [null_resource.archive]
  bucket = var.s3_bucket_upload_layer_zip
  key    = "${var.layer_name}.zip"
  source = data.external.built.result.filename
  etag   = filemd5(data.external.built.result.filename)
}


# Provides a Lambda Layer Version resource. Lambda Layers allow you to reuse shared bits of code across multiple lambda functions.
resource "aws_lambda_layer_version" "layer" {
  depends_on = [
    aws_s3_bucket_object.layer_s3_object
  ]

  layer_name          = var.layer_name
  s3_bucket           = aws_s3_bucket_object.layer_s3_object.bucket
  s3_key              = aws_s3_bucket_object.layer_s3_object.key
  source_code_hash    = data.external.built.result.filename
  compatible_runtimes = [var.runtime]
}
