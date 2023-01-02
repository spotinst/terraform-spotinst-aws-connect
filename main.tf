# Call Spot API to create the Spot Account
resource "null_resource" "account" {
  count = var.eco ? 0 : 1
  triggers = {
    cmd    = local.cmd
    name   = local.name
    token  = local.spotinst_token
    random = local.random
  }
  provisioner "local-exec" {
    command = "python3 ${path.module}/scripts/setup.py install"
  }
  provisioner "local-exec" {
    command = "${self.triggers.cmd} create ${self.triggers.name} --token=${self.triggers.token}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
            ID=$(${self.triggers.cmd} get --filter=name=${self.triggers.name} --attr=account_id --token=${self.triggers.token}) &&\
            ${self.triggers.cmd} delete "$ID" --token=${self.triggers.token} ${self.triggers.random}
        EOT
  }
}

resource "time_sleep" "wait_05" {
  count           = var.eco ? 0 : 1
  depends_on      = [data.external.external_id]
  create_duration = "5s"
}

resource "aws_ssm_parameter" "external-id" {
  depends_on = [time_sleep.wait_05]
  name       = "Spot-External-ID-${random_id.random_string.hex}"
  type       = "String"
  value      = data.external.external_id.result["external_id"]

  lifecycle {
    ignore_changes = [value, tags]
  }
}


resource "aws_s3_bucket" "cur_bucket" {
  count         = var.eco ? 0 : 1
  bucket        = "Spot-Finops-CUR-${random_id.random_string.hex}"
  force_destroy = true
}


resource "aws_s3_bucket_policy" "cur_bucket_policy" {
  count  = var.eco ? 0 : 1
  bucket = aws_s3_bucket.cur_bucket.id

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
      "Resource": "arn:aws:s3:::${aws_s3_bucket.cur_bucket.id}"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "billingreports.amazonaws.com"
      },
      "Action": [
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::${aws_s3_bucket.cur_bucket.id}/*"
    }
  ]
}
POLICY
}


resource "aws_cur_report_definition" "spot_cur_report" {
  count                      = var.eco ? 0 : 1
  report_name                = "spot-hourly-cur"
  time_unit                  = "HOURLY"
  format                     = "Parquet"
  compression                = "Parquet"
  s3_prefix                  = "spot"
  additional_schema_elements = ["RESOURCES"]
  s3_bucket                  = aws_s3_bucket.cur_bucket
  s3_region                  = "us-east-1"
  additional_artifacts       = ["ATHENA"]
  report_versioning          = "OVERWRITE_REPORT"
}


# Create AWS Role for Spot EG/Ocean
resource "aws_iam_role" "spot" {
  count = var.eco ? 0 : 1
  name  = var.role_name == null ? "SpotRole-${local.account_id}-${random_id.random_string.hex}" : var.role_name
  provisioner "local-exec" {
    # Without this set-cloud-credentials fails
    command = "sleep 10"
  }
  assume_role_policy = <<-EOT
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                "Effect": "Allow",
                "Principal": {
                    "AWS": "arn:aws:iam::922761411349:root"
                },
                "Action": "sts:AssumeRole",
                "Condition": {
                    "StringEquals": {
                    "sts:ExternalId": "${aws_ssm_parameter.external-id.value}"
                    }
                }
                }
            ]
        }
    EOT
  tags               = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# Create AWS Role for Spot Eco
resource "aws_iam_role" "eco" {
  count              = var.eco ? 1 : 0
  name               = var.eco_full ? "SpotByNetApp_Finops_FullPermission" : "SpotByNetApp_Finops_ReadOnly"
  description        = var.eco_full ? "Spot by NetApp FullPermissions Finops IAM Role" : "Spot by NetApp ReadOnly Finops IAM Role"
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

# Create IAM Policy for EG/Ocean
resource "aws_iam_policy" "spot" {
  count       = var.eco ? 0 : 1
  name        = var.policy_name == null ? "Spot-Policy-${local.account_id}-${random_id.random_string.hex}" : var.policy_name
  description = "Spot by NetApp IAM policy to manage resources"
  path        = "/"
  policy      = var.policy_file == null ? templatefile("${path.module}/spot_policy.json", {}) : var.policy_file
  tags        = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# Create IAM Policy for Eco
resource "aws_iam_policy" "eco" {
  count       = var.eco ? 1 : 0
  name        = var.eco ? "SpotByNetApp_Finops_FullPermission_Policy" : "SpotByNetApp_Finops_ReadOnly_Policy"
  description = var.eco_full ? "Spot by NetApp Finops Full Policy" : "Spot by NetApp Finops ReadOnly Policy"
  path        = "/"
  policy      = var.eco_full ? templatefile("${path.module}/eco_full_policy.json.tftpl", { cur_bucket = aws_s3_bucket.cur_bucket.id }) : templatefile("${path.module}/eco_readonly_policy.json.tftpl", { cur_bucket = aws_s3_bucket.cur_bucket.id })
  tags        = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# Attach the policy to the role for EG/Ocean
resource "aws_iam_role_policy_attachment" "spot" {
  count      = var.eco ? 0 : 1
  role       = aws_iam_role.spot.name
  policy_arn = aws_iam_policy.spot.arn
}

resource "time_sleep" "wait_05_seconds" {
  depends_on      = [aws_iam_role_policy_attachment.spot]
  create_duration = "5s"
}

# Attach the policy to the role for Eco
resource "aws_iam_role_policy_attachment" "eco" {
  count      = var.eco ? 1 : 0
  role       = aws_iam_role.eco.name
  policy_arn = aws_iam_policy.eco.arn
}


resource "aws_iam_role_policy_attachment" "eco_AWSCloudFormationReadOnlyAccess" {
  count      = var.eco ? 1 : 0
  role       = aws_iam_role.eco.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudFormationReadOnlyAccess"
}


# Link the Role ARN to the Spot Account
resource "null_resource" "account_association" {
  count      = var.eco ? 0 : 1
  depends_on = [aws_iam_role_policy_attachment.spot, time_sleep.wait_05_seconds]
  provisioner "local-exec" {
    command = "${local.cmd} set-cloud-credentials ${local.account_id} ${aws_iam_role.spot.arn} --token=${local.spotinst_token}"
  }
}