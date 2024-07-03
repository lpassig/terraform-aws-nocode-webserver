# This terraform and the aws provider here is _only_ used to create the role
# that doormat will use below. It is usually invoked directly with developer
# credentials for sandbox accounts.
#
# For example, you may be copying and pasting your credentials from the doormat
# UI or running something like the following in your shell:
#   `eval $(doormat aws export --role arn:aws:iam::123456789012:role/aws_mysandbox_test-developer)`

output "doormat_role_arn" {
  value = aws_iam_role.sample.arn
  description = <<-EOT
  This output value must be copied and pasted into the configuration of the
  terraform workspace that will be using it.
  EOT
}

resource "aws_iam_role" "www-prod" {
  name = "sample_dev-custom_role"
  tags = {
    hc-service-uri = "app.terraform.io/lennart-org/terraform-aws-nocode-webserver"
  }
  max_session_duration = 43200
  assume_role_policy   = data.aws_iam_policy_document.assume_sample.json
  inline_policy {
    name   = "SampleRolePermissions"
    policy = data.aws_iam_policy_document.sample.json
  }
}

data "aws_iam_policy_document" "assume_sample" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:SetSourceIdentity",
      "sts:TagSession"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::685425109301:role/aws_lennart_test-developer"] # infrasec_prod
    }
  }
}

# The following is just for completeness of the sample
data "aws_iam_policy_document" "sample" {
  statement {
    actions   = ["ec2:DescribeRegions"]
    resources = ["*"]
  }
}
