### ECO Resources ###
resource "aws_s3_bucket" "cur_bucket" {
  count         = var.eco ? 1 : 0
  bucket        = var.bucket_name == null ? "spot-finops-cur-${random_id.random_string.hex}" : var.bucket_name
  force_destroy = true
}

#Bucket policy
resource "aws_s3_bucket_policy" "cur_bucket_policy" {
  count         = var.eco ? 1 : 0
  bucket = aws_s3_bucket.cur_bucket[0].id

  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "billingreports.amazonaws.com"
      },
      "Action": [
        "s3:GetBucketAcl",
        "s3:GetBucketPolicy"
      ],
      "Resource": "arn:aws:s3:::${aws_s3_bucket.cur_bucket[0].id}"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "billingreports.amazonaws.com"
      },
      "Action": [
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::${aws_s3_bucket.cur_bucket[0].id}/*"
    }
  ]
}
POLICY
}

#Create the CUR report and store in created bucket
resource "aws_cur_report_definition" "spot_cur_report" {
  count         = var.eco ? 1 : 0
  report_name                = "spot-hourly-cur"
  time_unit                  = "HOURLY"
  format                     = "Parquet"
  compression                = "Parquet"
  s3_prefix                  = "spot"
  additional_schema_elements = ["RESOURCES"]
  s3_bucket                  = aws_s3_bucket.cur_bucket[0].id
  s3_region                  = "us-east-1"
  additional_artifacts       = ["ATHENA"]
  report_versioning          = "OVERWRITE_REPORT"
}

# Create AWS Role for Spot Eco
resource "aws_iam_role" "eco" {
  count              = var.eco ? 1 : 0
  name               = var.eco_role_name == null ? var.eco_full ?  "SpotByNetApp_Finops_FullPermission" : "SpotByNetApp_Finops_ReadOnly" : var.eco_role_name
  description        = var.eco_role_description == null ? var.eco_full ? "Spot by NetApp FullPermissions Finops IAM Role" : "Spot by NetApp ReadOnly Finops IAM Role" : var.eco_policy_name
  assume_role_policy = <<-EOT
        {
            "Version": "2012-10-17",
            "Statement": [
            {
              "Action": "sts:AssumeRole",
              "Principal": {
                "AWS": ["arn:aws:iam::884866656237:root",
                        "arn:aws:iam::627743545735:root"]
              },
              "Effect": "Allow"
            }
          ]
        }
    EOT
  tags               = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}


# Create IAM Policy for Eco
resource "aws_iam_policy" "eco" {
  count       = var.eco ? 1 : 0
  name        = var.eco_policy_name == null ? var.eco_full ? "SpotByNetApp_Finops_FullPermission_Policy" : "SpotByNetApp_Finops_ReadOnly_Policy" : var.eco_policy_name
  description = var.eco_policy_description == null ? var.eco_full ? "Spot by NetApp Finops Full Policy" : "Spot by NetApp Finops ReadOnly Policy" : var.eco_policy_description
  path        = "/"
  policy      = var.eco_policy_file == null ? var.eco_full ? templatefile("${path.module}/eco_full_policy.json.tftpl",
    { cur_bucket = aws_s3_bucket.cur_bucket[0].id }) : templatefile("${path.module}/eco_readonly_policy.json.tftpl",
    { cur_bucket = aws_s3_bucket.cur_bucket[0].id }) : var.eco_policy_file
  tags        = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# Attach the policy to the role for Eco
resource "aws_iam_role_policy_attachment" "eco" {
  count      = var.eco ? 1 : 0
  role       = aws_iam_role.eco[0].name
  policy_arn = aws_iam_policy.eco[0].arn
}
resource "aws_iam_role_policy_attachment" "eco_AWSCloudFormationReadOnlyAccess" {
  count      = var.eco ? 1 : 0
  role       = aws_iam_role.eco[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudFormationReadOnlyAccess"
}