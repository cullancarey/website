"""Lambda to send intake form emails"""
import logging
import json
import os
import base64
import sys
from urllib.parse import unquote
import boto3
import urllib3

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    """Main lambda function for execution"""
    logger.info(f"Event received: {json.dumps(event)}")
    if event["isBase64Encoded"]:
        try:
            string_dict = decode_body_to_dict(event["body"])
        except KeyError as error:
            logger.error(f"Error find key 'body': {error}")
            sys.exit()
        else:
            logger.info(f"Decoded body to dictionary: {string_dict}")
    else:
        string_dict = json.loads(event["body"])
        logger.info(string_dict)

    # Catch bots
    if string_dict.get("BotCheck", False):
        logger.info("Honeypot field filled out, bot detected.")
        return html_response("Ha!<br> Found ya!<br> Get lost, bot.")

    source_ip = event["requestContext"]["http"]["sourceIp"]
    captcha = string_dict["g-recaptcha-response"]
    response_body, captcha_success = verify_captcha(captcha, source_ip)

    customer_email = string_dict.get("CustomerEmail", "")
    customer_message = string_dict.get("MessageDetails", "")
    if captcha_success:
        logger.info("Captcha successful, sending email...")
        send_email(customer_email, customer_message)

    return html_response(response_body)


def decode_body_to_dict(encoded_body):
    """function to decode message"""
    base64_bytes = encoded_body.encode("utf8")
    encoded_body_bytes = base64.b64decode(base64_bytes)
    decoded_body = encoded_body_bytes.decode("utf8")

    string_dict = {
        key: unquote(value.replace("+", " "))
        for key, value in [
            map(str.strip, item.split("=", 1))
            for item in decoded_body.split("&")
            if "=" in item
        ]
    }
    return string_dict


def html_response(body_content):
    """function to create html response"""
    return {
        "statusCode": 200,
        "body": f"""\
<html>
<head></head>
  <body>
    <p>{body_content}</p>
  </body>
</html>
""",
        "headers": {
            "Content-Type": "text/html",
        },
    }


def send_email(customer_email, customer_message):
    """Sends email to myself with details of message from contact form"""
    client = boto3.client("ses")
    text_email = f"""Hi Cullan!\n
    You've received a message from {customer_email}.\n
    They said: "{customer_message}".\n
    To reply, just reply to this email!"""

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

    client.send_email(
        Source=f"noreply@{os.environ['website']}",
        Destination={
            "ToAddresses": [
                "cullancareyconsulting@gmail.com",
            ]
        },
        Message={
            "Subject": {"Data": f"Inquiry from {os.environ['website']}"},
            "Body": {"Text": {"Data": text_email}, "Html": {"Data": html_email}},
        },
        ReplyToAddresses=[
            customer_email,
        ],
    )


def verify_captcha(captcha_response, source_ip):
    """Function to verify the google captcha response"""
    http = urllib3.PoolManager()
    captcha_secret = get_param()
    request_response = http.request(
        "POST",
        "https://www.google.com/recaptcha/api/siteverify",
        fields={
            "secret": captcha_secret,
            "response": captcha_response,
            "remoteip": source_ip,
        },
    )
    request_values = json.loads(request_response.data.decode("utf-8"))
    if not request_values.get("success"):
        logger.error(
            f"Captcha failed due to error: {request_values.get('error-codes')}"
        )
        response_body = "Oops!<br> You did not pass captcha.<br> Get lost, bot!"
        captcha_success = False
        return response_body, captcha_success
    response_body = f"""Thank you!<br>
                       Cullan will get back to you shortly.<br>
                       In the meantime, let's go <a href="https://{os.environ['website']}">back</a> to the website."""
    captcha_success = True
    return response_body, captcha_success


def get_param():
    """Function to get parameter value from parameter store for captcha verification"""
    client = boto3.client("ssm")
    logger.info("Getting captcha parameter...")
    response = client.get_parameter(
        Name=f"{os.environ['environment']}_google_captcha_secret", WithDecryption=True
    )
    return response["Parameter"]["Value"]
