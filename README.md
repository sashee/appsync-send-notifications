# Example code to show how to send notifications to SNS, SQS, and EventBridge from AppSync

## Deploy

* ```terraform init```
* ```terraform apply```

## Use

There is a Lambda function that gets all events and writes them to its log. To watch the logs, use:

```npx watch-lambda-logs```

### SNS

Send a mutation:

```graphql
mutation MyMutation {
  sns(message: "testmsg")
}
```

Then in the logs see that the event is received:

```
{
    "Records": [
        {
            "EventSource": "aws:sns",
            "EventVersion": "1.0",
            "EventSubscriptionArn": "arn:aws:sns:eu-central-1:278868411450:terraform-20220723073114080300000004:0899e30c-1f08-4144-8dda-423e6ccf2c7d",
            "Sns": {
                "Type": "Notification",
                "MessageId": "432e191e-3825-5e1b-989f-424b829e3ade",
                "TopicArn": "arn:aws:sns:eu-central-1:278868411450:terraform-20220723073114080300000004",
                "Subject": null,
                "Message": "testmsg",
                "Timestamp": "2022-07-23T08:59:39.282Z",
                "SignatureVersion": "1",
                "Signature": "LJXCCnEcnlCCQWJujz+bZVdGCEsRoZIWL+JLjs9WobWP+sZcDxgi37MrPoqFSH5FTAmEo40fWoTaRsfldQkTUkhhFnRizeS3J1wSSxXCDuGegt0d8sIIRLw0YPHVZgz5lyQ2N8wssoC2QyA
3ewFpS/PrbNFRQqoRPjHDz6kW4HPo8hj2G6ZRUlXD2p90J1kW3orh/Vhl67JfgK1GXCh0XaOVSYSOOGYNp8V63aDx3IPkA154zaCqCUQr5tKIrL3FxpYqjH5SRh0BIReyH5c8pT1eUmMfZ0nw4Dderqu3niSBE5S+f5Xyv97me/KH
BqB4+8wgIYQ86JXuxV8ILd+iLg==",
                "SigningCertUrl": "https://sns.eu-central-1.amazonaws.com/SimpleNotificationService-7ff5318490ec183fbaddaa2a969abfda.pem",
                "UnsubscribeUrl": "https://sns.eu-central-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:eu-central-1:278868411450:terraform-202207230731140
80300000004:0899e30c-1f08-4144-8dda-423e6ccf2c7d",
                "MessageAttributes": {}
            }
        }
    ]
}
```

### SQS

```graphql
mutation MyMutation {
  sqs(message: "testmsg")
}
```

```
{
    "Records": [
        {
            "messageId": "fbd73eb1-1faa-4dee-a269-53c049f349df",
            "receiptHandle": "AQEBeQc+6pE98pqXm6W8lsTM2VZmyJapq8acxhxKcvj29qVkrbwgfVLdMVxkjU7JjKWYkOGgA6k2evlTEseXbxI0lD3SyNb6/lzTqlUdrPh9j1YTUMoyNSfZ8ErOM8Hey771OgT1MAbl9Az
amH+Nr4Zaw5r5HspK8DT9Nyv4SOaD2x27FCMQ5w5f/Q57Xb/6jDBKWoueaeV3QIQGBrFMJwbT/SqQPR+FmmLv3n8JRmspWxQTSjVIU/GhtnF76JEWpHPNkyTnmQGQO7ZmILx9hdvv8aWxY+YYq3Ak8+WfdRg+YOqVgCQ7rPZ7tvHK
cSrCtVrlUughi54Iwpq2tmE9CiNPzGekPPFuwuVriUjsVaT6jBVjlX1Qh/UK57IvQ/rUvM9k1m+1LZWXaw6gKOyKAf2vNTZpGbCxCsaIpucFlSy6JXI=",
            "body": "testmsg",
            "attributes": {
                "ApproximateReceiveCount": "1",
                "SentTimestamp": "1658566842444",
                "SenderId": "AROAUB3O2IQ5MJG3Z3LKN:APPSYNC_ASSUME_ROLE",
                "ApproximateFirstReceiveTimestamp": "1658566842449"
            },
            "messageAttributes": {},
            "md5OfBody": "bad44ae996b8b7aec1ded43d7cb079b1",
            "eventSource": "aws:sqs",
            "eventSourceARN": "arn:aws:sqs:eu-central-1:278868411450:terraform-20220723075144842600000002",
            "awsRegion": "eu-central-1"
        }
    ]
}
```

### EventBridge

```graphql
mutation MyMutation {
  eventbus(message: "testmsg")
}
```

```
{
    "version": "0",
    "id": "b41cd580-ae85-cd2e-401e-57a5151dbc86",
    "detail-type": "test",
    "source": "test",
    "account": "278868411450",
    "time": "2022-07-23T09:01:43Z",
    "region": "eu-central-1",
    "resources": [],
    "detail": {
        "Message": "testmsg"
    }
}
```
