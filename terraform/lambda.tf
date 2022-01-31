data "archive_file" "lambda_zip" {
    type        = "zip"
    source_dir  = "../lambda"
    output_path = "invalidation_lambda.zip"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "website-invalidation-role-itw5jhl3"
  path          = "/service-role/"

  assume_role_policy = file("lambda_policy.json") 
}

resource "aws_lambda_function" "invalidation_lambda" {
  filename      = "invalidation_lambda.zip"
  function_name = "website-invalidation"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "invalidate.lambda_handler"

  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"

  runtime = "python3.9"
}

resource "aws_iam_policy" "lambda_iam_policy" {
  name = "AWSLambdaBasicExecutionRole-21a06576-1f41-41d1-a52c-cb2aa08b1ddc"
  path = "/service-role/"
  policy = file("lambda_execution_policy.json")
}