import json
import base64
import boto3
import botocore
import urllib3
import os
  


def lambda_handler(event, context):
    print(json.dumps(event))

    encoded_body = event["body"]

    base64_bytes = encoded_body.encode("utf8")

    encoded_body_bytes = base64.b64decode(base64_bytes)
    decoded_body = encoded_body_bytes.decode("utf8")

    print(f"decoded body: {decoded_body}")

    string_dict = []
    for each in decoded_body.split("&"):
        each_item = each.replace("+", " ").replace("%40", "@")
        if "=" in each:
            string_dict.append(map(str.strip, each_item.split("=", 1)))
    string_dict = dict(string_dict)
    print(string_dict)
    
    # Catch dumb bots
    if string_dict.get('contact_me_by_fax_only', False):
        response_body = """\
<html>
  <head></head>
  <body>
    <p>Ha!<br>
       Found ya!.<br>
       Get lost, bot.
    </p>
  </body>
</html>
"""
        return {"statusCode": 200, "body": response_body, "headers": {
        'Content-Type': 'text/html',}}
    
    source_ip = event['requestContext']['http']['sourceIp']
    captcha = string_dict['g-recaptcha-response']
    
    response_body = verify_captcha(captcha, source_ip)
    
    customer_email = string_dict['CustomerEmail']
    customer_message = string_dict['MessageDetails']
    send_email(customer_email, customer_message)

    return {"statusCode": 200, "body": response_body, "headers": {
        'Content-Type': 'text/html',}}
    

def send_email(customer_email, customer_message):
    client = boto3.client('ses')
    
    text_email = f'''Hi Cullan! \n 
    You've received a message from {customer_email}. \n
    They said: "{customer_message}".\n
    To reply, just reply to this email!'''

    html_email = f"""\
<html>
  <head></head>
  <body>
    <p>Hi Cullan!<br>
       You've received a message from {customer_email}<br>
       They said: "{customer_message}".<br>
       To reply, just reply to this email!
    </p>
  </body>
</html>
"""
    
    response = client.send_email(
    Source='noreply@cullancarey.com',
    Destination={
        'ToAddresses': [
            'cullancarey@yahoo.com',
        ]
    },
    Message={
        'Subject': {
            'Data': 'Inquiry from cullancarey.com'
        },
        'Body': {
            'Text': {
                'Data': text_email
            },
            'Html': {
                'Data': html_email
            }
        }
    },
    ReplyToAddresses=[
        customer_email,
    ]
    )
    
def verify_captcha(captcha_response, source_ip):
    http = urllib3.PoolManager()
    captcha_secret = get_param()
    request_response = http.request('POST', 'https://www.google.com/recaptcha/api/siteverify', fields={'secret': captcha_secret, 'response': captcha_response, 'remoteip': source_ip})
    request_values = json.loads(request_response.data.decode('utf-8'))
    print(request_values)
    if request_values['success'] == False:
        response_body = """\
<html>
  <head></head>
  <body>
    <p>Oops!<br>
       You did not pass captcha.<br>
       Get lost, bot!
    </p>
  </body>
</html>
""" 
        return response_body
    else:
        response_body = f"""\
<html>
  <head></head>
  <body>
    <p>Thank you!<br>
       Cullan will get back to you shortly.<br>
       In the meantime, lets go <a href="https://www.cullancarey.com">back</a> to the website.
    </p>
  </body>
</html>
"""
        return response_body
        

def get_param():
    client = boto3.client('ssm')
    response = client.get_parameter(
        Name='google_captcha_secret',
        WithDecryption=True
    )
    return response['Parameter']['Value']
        
        