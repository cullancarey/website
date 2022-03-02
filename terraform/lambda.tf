data "archive_file" "lambda_zip" {
    type        = "zip"
    source_dir  = "../lambda"
    output_path = "invalidation_lambda.zip"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "website-invalidation-role-itw5jhl3"
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

  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"

  runtime = "python3.9"
  timeout = 300
}

resource "aws_iam_policy" "lambda_iam_policy" {
  name = "AWSLambdaBasicExecutionRole-21a06576-1f41-41d1-a52c-cb2aa08b1ddc"
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


