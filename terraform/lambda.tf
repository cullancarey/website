#############################################
#########invalidation_lambda#################
#############################################

data "archive_file" "invalidation_lambda_zip" {
    type        = "zip"
    source_dir  = "../Lambdas/invalidate_lambda"
    output_path = "invalidation_lambda.zip"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "website-invalidation-role"
  path          = "/service-role/"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}

POLICY
}

resource "aws_lambda_function" "invalidation_lambda" {
  filename      = "invalidation_lambda.zip"
  function_name = "website-invalidation"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "invalidate.lambda_handler"

  source_code_hash = "${data.archive_file.invalidation_lambda_zip.output_base64sha256}"

  runtime = "python3.9"
  timeout = 300

  environment {
    variables = {
      CF_DIST_ID = aws_cloudfront_distribution.website_distribution.id
    }
  }
}

resource "aws_iam_policy" "lambda_iam_policy" {
  name = "website-invalidation-role-policy"
  path = "/service-role/"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "codepipeline:PutJobFailureResult",
                "codepipeline:PutJobSuccessResult",
                "cloudfront:ListDistributions"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "cloudfront:CreateInvalidation",
                "logs:CreateLogGroup"
            ],
            "Resource": [
                "arn:aws:cloudfront::${local.account_id}:distribution/${aws_cloudfront_distribution.website_distribution.id}",
                "arn:aws:logs:us-east-2:${local.account_id}:*"
            ]
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:us-east-2:${local.account_id}:log-group:/aws/lambda/${aws_lambda_function.invalidation_lambda.function_name}:*"
        }
    ]
}

POLICY
}

resource "aws_iam_role_policy_attachment" "lambda-attach" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_iam_policy.arn
}


#############################################
#########contact_form_intake_lambda##########
#############################################

data "archive_file" "contact_form_lambda_zip" {
    type        = "zip"
    source_dir  = "../Lambdas/contact_form_lambda"
    output_path = "contact_form_intake.zip"
}

resource "aws_iam_role" "iam_for_contact_intake_lambda" {
  name = "website-contact-form-intake-role"
  path          = "/service-role/"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}

POLICY
}

resource "aws_lambda_function" "contact_form_intake_lambda" {
  filename      = "contact_form_intake.zip"
  function_name = "contact_form_intake"
  role          = aws_iam_role.iam_for_contact_intake_lambda.arn
  handler       = "contact_form_intake.lambda_handler"

  source_code_hash = "${data.archive_file.contact_form_lambda_zip.output_base64sha256}"

  runtime = "python3.9"
  timeout = 300
}

resource "aws_iam_policy" "contact_form_lambda_iam_policy" {
  name = "website-contact-form-intake-role-policy"
  path = "/service-role/"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ses:SendEmail",
                "logs:CreateLogGroup"
            ],
            "Resource": [
                "arn:aws:ses:us-east-2:${local.account_id}:identity/cullancarey.com",
                "arn:aws:ses:us-east-2:${local.account_id}:identity/cullancarey@yahoo.com",
                "arn:aws:logs:us-east-2:${local.account_id}:*"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:us-east-2:${local.account_id}:log-group:/aws/lambda/${aws_lambda_function.contact_form_intake_lambda.function_name}:*"
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:us-east-2:${local.account_id}:parameter/google_captcha_secret"
        }
    ]
}

POLICY
}

resource "aws_iam_role_policy_attachment" "contact-form-lambda-attach" {
  role       = aws_iam_role.iam_for_contact_intake_lambda.name
  policy_arn = aws_iam_policy.contact_form_lambda_iam_policy.arn
}

resource "aws_lambda_permission" "intake_form_api_lambda_perms" {
  statement_id  = "AllowAPIgatewayInvokation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.contact_form_intake_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.form_intake_api.execution_arn}/*/*/"
}