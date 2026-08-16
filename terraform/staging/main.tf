resource "kubernetes_namespace" "staging" {
  metadata {
    name = "kijani-staging"

    labels = {
      "app.kubernetes.io/part-of" = "kijanikiosk"
      environment                 = "staging"
      managed-by                  = "terraform"
    }
  }
}

resource "aws_s3_bucket" "receipts_staging" {
  bucket = "kk-payments-receipts-staging-840986438351"

  tags = {
    Name        = "kk-payments-receipts-staging-840986438351"
    Environment = "staging"
    ManagedBy   = "terraform"
    Project     = "kijanikiosk"
  }
}

resource "aws_s3_bucket_public_access_block" "receipts_staging" {
  bucket = aws_s3_bucket.receipts_staging.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "receipts_staging" {
  bucket = aws_s3_bucket.receipts_staging.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "archive_file" "receipt_processor" {
  type        = "zip"
  source_file = "${path.module}/../../serverless/receipt-processor/index.py"
  output_path = "${path.module}/receipt-processor.zip"
}

resource "aws_iam_role" "receipt_processor" {
  name = "kijanikiosk-receipt-processor"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "receipt_processor" {
  name = "kijanikiosk-receipt-processor-policy"
  role = aws_iam_role.receipt_processor.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.receipts_staging.arn}/*"
      }
    ]
  })
}

resource "aws_lambda_function" "receipt_processor" {
  function_name = "kijanikiosk-receipt-processor-staging"
  role          = aws_iam_role.receipt_processor.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.receipt_processor.output_path
  source_code_hash = data.archive_file.receipt_processor.output_base64sha256

  environment {
    variables = {
      ENVIRONMENT = "staging"
      RECEIPT_BUCKET = aws_s3_bucket.receipts_staging.bucket
    }
  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.receipt_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.receipts_staging.arn
}

resource "aws_s3_bucket_notification" "receipts_staging" {
  bucket = aws_s3_bucket.receipts_staging.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.receipt_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_lambda_permission.allow_s3
  ]
}
