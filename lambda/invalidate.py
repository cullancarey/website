import boto3
from datetime import datetime

#Create Cloudfront client
cloudfront = boto3.client('cloudfront')


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