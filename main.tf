# Call Spot API to create the Spot Account
resource "null_resource" "account" {
    triggers = {
        cmd     = "${path.module}/scripts/spot-account-aws"
        name    = local.name
        token   = var.spotinst_token
    }
    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        command     = "${self.triggers.cmd} create ${self.triggers.name} --token=${var.spotinst_token}"
    }
    provisioner "local-exec" {
        when        = destroy
        interpreter = ["/bin/bash", "-c"]
        command = <<-EOT
            ID=$(${self.triggers.cmd} get --filter=name=${self.triggers.name} --attr=account_id --token=${self.triggers.token}) &&\
            ${self.triggers.cmd} delete "$ID" --token=${self.triggers.token}
        EOT
    }
}

# Create AWS Role for Spot
resource "aws_iam_role" "spot"{
    name = var.role_name == null ? "SpotRole-${local.account_id}" : var.role_name
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
                    "sts:ExternalId": "${data.aws_ssm_parameter.external-id.value}"
                    }
                }
                }
            ]
        }
    EOT
    tags = var.tags
    lifecycle {
        ignore_changes = [tags]
    }
}

# Create IAM Policy
resource "aws_iam_policy" "spot" {
    name        = var.policy_name == null ? "Spot-Policy-${local.account_id}" : var.policy_name
    path        = "/"
    description = "Spot by NetApp IAM policy to manage resources"
    policy      = templatefile(var.policy_file == null ? "${path.module}/spot_policy.json" : var.policy_file, {})
    tags        = var.tags
    lifecycle {
        ignore_changes = [tags]
    }
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "spot" {
    role       = aws_iam_role.spot.name
    policy_arn = aws_iam_policy.spot.arn
}

resource "time_sleep" "wait_05_seconds" {
    depends_on = [aws_iam_role_policy_attachment.spot]
    create_duration = "5s"
}

# Link the Role ARN to the Spot Account
resource "null_resource" "account_association" {
    depends_on = [aws_iam_role_policy_attachment.spot, time_sleep.wait_05_seconds]
    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        command = "${local.cmd} set-cloud-credentials ${local.account_id} ${aws_iam_role.spot.arn} --token=${var.spotinst_token}"
    }
}


