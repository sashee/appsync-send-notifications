# SNS topic

resource "aws_sns_topic" "topic" {
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambda.arn
}

resource "aws_lambda_permission" "sns" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "sns.amazonaws.com"

  source_arn = aws_sns_topic.topic.arn
}

# SQS queue
resource "aws_sqs_queue" "queue" {
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = aws_sqs_queue.queue.arn
  function_name    = aws_lambda_function.lambda.arn
}

# Event bus

resource "aws_cloudwatch_event_bus" "eventbus" {
  name = "eventbus-${random_id.id.hex}"
}

resource "aws_cloudwatch_event_rule" "all" {
	event_bus_name = aws_cloudwatch_event_bus.eventbus.name
	event_pattern = <<EOF
{
	"source": [{"prefix": ""}]
}
EOF
}

resource "aws_cloudwatch_event_target" "eventbus" {
  arn = aws_lambda_function.lambda.arn
  rule = aws_cloudwatch_event_rule.all.name
	event_bus_name = aws_cloudwatch_event_bus.eventbus.name
}

resource "aws_lambda_permission" "eventbus" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.all.arn
}
