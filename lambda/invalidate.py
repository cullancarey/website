import boto3
from datetime import datetime

def put_job_success(job):
    """Notify CodePipeline of a successful job
    
    Args:
        job: The CodePipeline job ID
        message: A message to be logged relating to the job status
        
    Raises:
        Exception: Any exception thrown by .put_job_success_result()
    
    """
    print('Putting job success')
    code_pipeline.put_job_success_result(jobId=job)
  
def put_job_failure(job):
    """Notify CodePipeline of a failed job
    
    Args:
        job: The CodePipeline job ID
        message: A message to be logged relating to the job status
        
    Raises:
        Exception: Any exception thrown by .put_job_failure_result()
    
    """
    print('Putting job failure')
    code_pipeline.put_job_failure_result(jobId=job, failureDetails={'message': message, 'type': 'JobFailed'})


def lambda_handler(event, context):
    #Create clients
    cloudfront = boto3.client('cloudfront')
    code_pipeline = boto3.client('codepipeline')
    
    #Get Cloudfront distribution id
    response = cloudfront.list_distributions()
    dist_id = response['DistributionList']['Items'][0]['Id']
    
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
    try:
        # Extract the Job ID
        job_id = event['CodePipeline.job']['id']
        put_job_success(job_id)
    except Exception as e:
        # If any other exceptions which we didn't expect are raised
        # then fail the job and log the exception message.
        print('Function failed due to exception.') 
        print(e)
        traceback.print_exc()
        put_job_failure(job_id, 'Function exception: ' + str(e))