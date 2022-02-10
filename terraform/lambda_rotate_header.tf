data "archive_file" "custom_header_lambda_zip" {
    type        = "zip"
    source_dir  = "../custom_header_lambda"
    output_path = "custom_header_lambda.zip"
}

resource "aws_iam_role" "iam_for_custom_header_lambda" {
  name = "rotate_custom_headers-role-cbkdnk1r"
  path          = "/service-role/"

  assume_role_policy = file("custom_header_lambda_assume_role_policy.json") 
}

resource "aws_lambda_function" "rotate_custom_header_lambda" {
  filename      = "custom_header_lambda.zip"
  function_name = "rotate_custom_headers"
  role          = aws_iam_role.iam_for_custom_header_lambda.arn
  handler       = "rotate_custom_headers.lambda_handler"

  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"

  runtime = "python3.9"
  timeout = 300
}

resource "aws_iam_policy" "custom_header_lambda_iam_policy" {
  name = "AWSLambdaBasicExecutionRole-b169e0d3-a42f-4df6-a06b-ec053e66bb00"
  path = "/service-role/"
  policy = file("custom_header_lambda_execution_policy.json")
}

resource "aws_cloudwatch_event_rule" "rotate_custom_headers" {
  name        = "rotate_custom_header"
  schedule_expression = "cron(0 6 1 * ? *)"

}

resource "aws_cloudwatch_event_target" "custom_header_lambda_target" {
  rule      = aws_cloudwatch_event_rule.rotate_custom_headers.name
  target_id = "Idd82dd148-8ef1-42fa-afa5-3ad61224c39d"
  arn       = aws_lambda_function.rotate_custom_header_lambda.arn
}