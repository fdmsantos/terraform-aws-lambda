variable "layer_name" {
  type        = string
  description = "Layer Name"
}


variable "layer_path" {
  description = "The absolute path to a local file or directory containing your Layer source code"
  type        = string
}

variable "runtime" {
  type = string
}


variable "s3_bucket_upload_layer_zip" {
  type = string
  description = "S3 Bucket to upload Lambda layer Zip"
}

# Optional variables specific to this module.

variable "build_command" {
  description = "The command to run to create the Lambda package zip file"
  type        = string
  default     = "python build.py '$filename' '$runtime' '$source'"
}

variable "build_paths" {
  description = "The files or directories used by the build command, to trigger new Lambda package builds whenever build scripts change"
  type        = list(string)
  default     = ["build.py"]
}