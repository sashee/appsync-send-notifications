data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "/tmp/lambda.zip"
  source {
    content  = <<EOF
module.exports.handler = async (event, context) => {
	console.log(JSON.stringify(event, undefined, 4));
	return event;
};
EOF
    filename = "main.js"
  }
}

resource "aws_lambda_function" "lambda" {
  function_name = "${random_id.id.hex}-function"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  handler = "main.handler"
  runtime = "nodejs16.x"
  role    = aws_iam_role.lambda_exec.arn
	reserved_concurrent_executions = 1
}

data "aws_iam_policy_document" "lambda_exec_role_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
  statement {
    actions = [
			"sqs:ReceiveMessage",
			"sqs:DeleteMessage",
			"sqs:GetQueueAttributes"
    ]
    resources = [
			aws_sqs_queue.queue.arn
    ]
  }
}

resource "aws_cloudwatch_log_group" "loggroup_lambda" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 14
}

resource "aws_iam_role_policy" "lambda_exec_role" {
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.lambda_exec_role_policy.json
}

resource "aws_iam_role" "lambda_exec" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}
