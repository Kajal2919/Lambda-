provider "aws" {
  region = "eu-west-1"
}
resource "aws_dynamodb_table" "SourceTable" {
  "attribute" {
    name = "id"
    type = "S"
  }

  hash_key = "id"
  name = "sourcedemotable"
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  read_capacity = 1
  write_capacity = 1
}

resource "aws_dynamodb_table" "DestTable" {
  "attribute" {
    name = "id"
    type = "S"
  }

  hash_key = "id"
  name = "destdemotable"
  read_capacity = 1
  write_capacity = 1
}

resource "aws_iam_role" "Lambda-role" {
  name = "Lamdba-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "Lambda-role-attach" {
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action":"*",
            "Resource": "*"
        }
    ]
}
EOF
  role = "${aws_iam_role.Lambda-role.id}"
}

resource "aws_lambda_function" "update-table-function" {
  function_name = "update-table-function"
  handler = "demo.lambda.com.Handler"
  role = "${aws_iam_role.Lambda-role.arn}"
  runtime = "java8"
  memory_size = 1024
  timeout = 300
  filename = "../LamdaAPI/target/update-table-1.0-SNAPSHOT.jar"
}
//
resource "aws_lambda_event_source_mapping" "stream_dynamo" {
  event_source_arn = "${aws_dynamodb_table.SourceTable.stream_arn}"
  function_name = "${aws_lambda_function.update-table-function.arn}"
  starting_position = "LATEST"
  batch_size = 100
  enabled = true
}