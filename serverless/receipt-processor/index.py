import json
import os
import urllib.parse
import boto3

s3 = boto3.client("s3")

def lambda_handler(event, context):
    print(json.dumps({
        "message": "Receipt processor triggered",
        "records": len(event.get("Records", []))
    }))

    for record in event.get("Records", []):
        bucket = record["s3"]["bucket"]["name"]
        key = urllib.parse.unquote_plus(
            record["s3"]["object"]["key"]
        )

        response = s3.get_object(Bucket=bucket, Key=key)
        receipt = json.loads(response["Body"].read())

        print(json.dumps({
            "message": "Receipt processed",
            "bucket": bucket,
            "key": key,
            "receipt_id": receipt.get("receipt_id"),
            "amount": receipt.get("amount"),
            "currency": receipt.get("currency")
        }))

    return {
        "statusCode": 200,
        "body": json.dumps({"processed": True})
    }
