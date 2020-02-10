terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "random_id" "name" {
  byte_length = 6
  prefix      = "terraform-aws-lambda-cwtrigger-cron-"
}

resource "aws_sqs_queue" "dlq" {
  name = random_id.name.hex
}

module "lambda" {
  source = "../../"

  function_name = random_id.name.hex
  description   = "Test cloud watch cron trigger in terraform-aws-lambda"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.6"
  timeout       = 30

  source_path = "${path.module}/lambda.py"

  event_trigger_cron = {
    rule_name           = "cron-rule",
    rule_description    = "Fires api-branch_io api every day",
    schedule_expression = "cron(00 23 * * ? *)"
  }


  event_trigger_pattern = {
    rule_name           = "ecs-task-stop",
    rule_description    = "ecs task stop trigger",
    event_pattern       = <<PATTERN
    {
      "source": ["aws.ecs"],
      "detail-type": ["ECS Task State Change"],
      "detail": {
        "lastStatus": ["STOPPED"],
        "clusterArn": ["<arn>"]
      }
    }
    PATTERN
  }
}
