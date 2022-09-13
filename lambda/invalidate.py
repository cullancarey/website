"""The datetime module supplies classes for manipulating dates and times."""
from datetime import datetime
import os
import boto3
import botocore


def put_job_success(job, client):
    """Sends successful job result to AWS"""
    print("Putting job success")
    client.put_job_success_result(jobId=job)


def put_job_failure(job, message, client):
    """Sends failure job result to AWS"""
    print("Putting job failure")
    print(message)
    client.put_job_failure_result(
        jobId=job, failureDetails={"message": message, "type": "JobFailed"}
    )


def lambda_handler(event, context):  # pylint: disable=unused-argument
    """Main lambda function"""
    # Create clients
    cloudfront = boto3.client("cloudfront")
    code_pipeline = boto3.client("codepipeline")

    # Get Cloudfront distribution id
    dist_id = os.environ["CF_DIST_ID"]

    # Create invalidation
    response = cloudfront.create_invalidation(
        DistributionId=f"{dist_id}",
        InvalidationBatch={
            "Paths": {
                "Quantity": 1,
                "Items": [
                    "/*",
                ],
            },
            "CallerReference": f"{datetime.now()}",
        },
    )
    if response["Invalidation"]["Id"]:
        try:
            # Extract the Job ID
            job_id = event["CodePipeline.job"]["id"]
            put_job_success(job_id, code_pipeline)
        except botocore.exceptions.ClientError as error:
            print("Function failed due to exception.")
            print(error)
            put_job_failure(job_id, f"Function exception: {error}", code_pipeline)
