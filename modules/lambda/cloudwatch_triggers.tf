// Cloudwatch event rule - Schedule Expression
resource "aws_cloudwatch_event_rule" "cron_event_rule" {
  count               = lookup(var.event_trigger_cron, "schedule_expression", "0") == "0" ? 0 : 1
  name                = lookup(var.event_trigger_cron, "rule_name", "${var.function_name}-cloudwatch-event-rule")
  description         = lookup(var.event_trigger_cron, "rule_description", "Event rule based on Cron expression")
  schedule_expression = lookup(var.event_trigger_cron, "schedule_expression", "")
}

resource "aws_cloudwatch_event_target" "cron_event_target" {
  count      = lookup(var.event_trigger_cron, "schedule_expression", "0") == "0" ? 0 : 1
  depends_on = [aws_lambda_function.lambda]
  rule       = aws_cloudwatch_event_rule.cron_event_rule[count.index].name
  arn        = aws_lambda_function.lambda.arn
}

resource "aws_lambda_permission" "cron_event_rule_permission" {
  count         = lookup(var.event_trigger_cron, "schedule_expression", "0") == "0" ? 0 : 1
  depends_on    = [aws_cloudwatch_event_target.cron_event_target]
  action        = "lambda:invokeFunction"
  principal     = "events.amazonaws.com"
  function_name = var.function_name
  source_arn    = aws_cloudwatch_event_rule.cron_event_rule[count.index].arn
}


// Cloudwatch event rule - Event Pattern
resource "aws_cloudwatch_event_rule" "event_pattern_event_rule" {
  count               = lookup(var.event_trigger_pattern, "event_pattern", "0") == "0" ? 0 : 1
  name                = lookup(var.event_trigger_pattern, "rule_name", "${var.function_name}-cloudwatch-event-rule")
  description         = lookup(var.event_trigger_pattern, "rule_description", "Event rule based on Cron expression")
  event_pattern       = lookup(var.event_trigger_pattern, "event_pattern", "")
}

resource "aws_cloudwatch_event_target" "event_pattern_event_target" {
  count      = lookup(var.event_trigger_pattern, "event_pattern", "0") == "0" ? 0 : 1
  depends_on = [aws_lambda_function.lambda]
  rule       = aws_cloudwatch_event_rule.event_pattern_event_rule[count.index].name
  arn        = aws_lambda_function.lambda.arn
}


resource "aws_lambda_permission" "event_pattern_event_rule_permission" {
  count         = lookup(var.event_trigger_pattern, "event_pattern", "0") == "0" ? 0 : 1
  depends_on    = [aws_cloudwatch_event_target.event_pattern_event_target]
  action        = "lambda:invokeFunction"
  principal     = "events.amazonaws.com"
  function_name = var.function_name
  source_arn    = aws_cloudwatch_event_rule.event_pattern_event_rule[count.index].arn
}
