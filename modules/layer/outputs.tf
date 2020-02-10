output "layer_arn" {
  description = "The ARN of the Lambda Layer"
  value       = aws_lambda_layer_version.layer.arn
}
