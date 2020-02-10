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
