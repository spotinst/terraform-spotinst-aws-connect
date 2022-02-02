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
    name = "SpotRole-${local.account_id}"
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
                    "sts:ExternalId": "${local.external_id}"
                    }
                }
                }
            ]
        }
    EOT
}

# Create IAM Policy
resource "aws_iam_policy" "spot" {
    name        = "Spot-Policy-${local.account_id}"
    path        = "/"
    description = "Spot by NetApp IAM policy to manage resources"
    policy = templatefile(var.policy_file == null ? "${path.module}/spot_policy.json" : var.policy_file, {})
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "spot" {
    role       = aws_iam_role.spot.name
    policy_arn = aws_iam_policy.spot.arn
}

# Create local file to store externalID
resource "local_file" "external-id" {
    filename = "${path.module}/scripts/external_id.txt"
    sensitive_content = true
}

# Call Spot API to generate external ID
resource "null_resource" "create_external_id" {
    depends_on = [null_resource.account, local_file.external-id]
    triggers = {
        account_id  = local.account_id
    }
    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        command = "${local.cmd} create-external-id ${self.triggers.account_id} --token=${var.spotinst_token} > ${path.module}/scripts/external_id.txt"
    }
}

# Link the Role ARN to the Spot Account
resource "null_resource" "account_association" {
    depends_on = [aws_iam_role.spot]
    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        command = "${local.cmd} set-cloud-credentials ${local.account_id} ${aws_iam_role.spot.arn} --token=${var.spotinst_token}"
    }
}


