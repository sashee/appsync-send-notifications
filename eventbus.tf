data "aws_arn" "eventbus" {
  arn = aws_cloudwatch_event_bus.eventbus.arn
}

resource "aws_appsync_datasource" "eventbus" {
  api_id           = aws_appsync_graphql_api.appsync.id
  name             = "eventbus"
  service_role_arn = aws_iam_role.appsync.arn
  type             = "HTTP"
	http_config {
		endpoint = "https://events.${data.aws_arn.eventbus.region}.amazonaws.com"
		authorization_config {
			authorization_type = "AWS_IAM"
			aws_iam_config {
				signing_region = data.aws_arn.eventbus.region
				signing_service_name = "events"
			}
		}
	}
}

resource "aws_appsync_resolver" "Mutation_eventbus" {
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Mutation"
  field       = "eventbus"
  data_source = aws_appsync_datasource.eventbus.name
	request_template = <<EOF
{
	"version": "2018-05-29",
	"method": "POST",
	"params": {
		"headers": {
			"Content-Type": "application/x-amz-json-1.1",
			"X-Amz-Target": "AWSEvents.PutEvents"
		},
		"body":$util.toJson({
			"Entries":[
				{
					"Source":"test",
					"Detail": $util.toJson({"Message": $ctx.args.message}),
					"DetailType":"test",
					"EventBusName": "${aws_cloudwatch_event_bus.eventbus.name}"
				}
			]
		}),
	},
	"resourcePath": "/"
}
EOF

	response_template = <<EOF
#if ($ctx.error)
	$util.error($ctx.error.message, $ctx.error.type)
#end
#if ($ctx.result.statusCode < 200 || $ctx.result.statusCode >= 300)
	$util.error($ctx.result.body, "StatusCode$ctx.result.statusCode")
#end
#if($util.parseJson($ctx.result.body).FailedEntryCount > 0)
	$util.error($ctx.result.body)
#end
$util.toJson($util.parseJson($ctx.result.body).Entries[0].EventId)
EOF
}

