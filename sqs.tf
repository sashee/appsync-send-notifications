data "aws_arn" "sqs" {
  arn = aws_sqs_queue.queue.arn
}

resource "aws_appsync_datasource" "sqs" {
  api_id           = aws_appsync_graphql_api.appsync.id
  name             = "sqs"
  service_role_arn = aws_iam_role.appsync.arn
  type             = "HTTP"
	http_config {
		endpoint = "https://sqs.${data.aws_arn.sqs.region}.amazonaws.com"
		authorization_config {
			authorization_type = "AWS_IAM"
			aws_iam_config {
				signing_region = data.aws_arn.sqs.region
				signing_service_name = "sqs"
			}
		}
	}
}

resource "aws_appsync_resolver" "Mutation_sqs" {
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Mutation"
  field       = "sqs"
  data_source = aws_appsync_datasource.sqs.name
	request_template = <<EOF
{
	"version": "2018-05-29",
	"method": "POST",
	"params": {
		"body": "Action=SendMessage&MessageBody=$util.urlEncode($ctx.args.message)&Version=2012-11-05",
		"headers": {
			"Content-Type" : "application/x-www-form-urlencoded"
		},
	},
	"resourcePath": "/${data.aws_arn.sqs.account}/${aws_sqs_queue.queue.name}/"
}
EOF

	response_template = <<EOF
#if ($ctx.error)
	$util.error($ctx.error.message, $ctx.error.type)
#end
#if ($ctx.result.statusCode < 200 || $ctx.result.statusCode >= 300)
	$util.error($ctx.result.body, "StatusCode$ctx.result.statusCode")
#end
$util.toJson($util.xml.toMap($ctx.result.body).SendMessageResponse.SendMessageResult.MessageId)
EOF
}

