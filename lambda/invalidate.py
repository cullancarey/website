import boto3
from datetime import datetime
import os

def put_job_success(job, client):
    print('Putting job success')
    client.put_job_success_result(jobId=job)
  
def put_job_failure(job, message, client):
    print('Putting job failure')
    print(message)
    client.put_job_failure_result(jobId=job, failureDetails={'message': message, 'type': 'JobFailed'})

def lambda_handler(event, context):
    #Create clients
    cloudfront = boto3.client('cloudfront')
    code_pipeline = boto3.client('codepipeline')
    
    #Get Cloudfront distribution id
    dist_id = os.environ['CF_DIST_ID']
    
    #Create invalidation
    response = cloudfront.create_invalidation(
        DistributionId=f'{dist_id}',
        InvalidationBatch={
            'Paths': {
                'Quantity': 1,
                'Items': [
                    '/*',
                ]
            },
            'CallerReference': f'{datetime.now()}'
        }
    )
    if response['Invalidation']['Id']:
	    try:
	        # Extract the Job ID
	        job_id = event['CodePipeline.job']['id']
	        put_job_success(job_id, code_pipeline)
	    except Exception as e:
	        # If any other exceptions which we didn't expect are raised
	        # then fail the job and log the exception message.
	        print('Function failed due to exception.') 
	        print(e)
	        put_job_failure(job_id, 'Function exception: ' + str(e), code_pipeline)