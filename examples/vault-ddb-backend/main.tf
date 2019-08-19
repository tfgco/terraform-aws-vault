# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A VAULT SERVER CLUSTER WITH DYNAMODB BACKEND IN AWS
# This is an example of how to use the vault-cluster module to deploy a Vault cluster in AWS. This cluster uses DynamoDB,
# running separately (built within the vault-cluster module), as its storage backend.
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.12"
}

data "aws_kms_alias" "vault" {
  name = "alias/${var.auto_unseal_kms_key_alias}"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE VAULT SERVER CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "vault_cluster" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "github.com/hashicorp/terraform-aws-consul.git/modules/vault-cluster?ref=v0.0.1"
  source = "../../modules/vault-cluster"

  cluster_name  = var.vault_cluster_name
  cluster_size  = var.vault_cluster_size
  instance_type = var.vault_instance_type

  ami_id    = var.ami_id
  user_data = data.template_file.user_data_vault_cluster.rendered

  # This setting will create the AWS policy that allows the vault cluster to
  # access KMS and use this key for encryption and decryption
  enable_auto_unseal = true

  auto_unseal_kms_key_arn = data.aws_kms_alias.vault.target_key_arn

  enable_dynamo_backend = true
  dynamo_table_name     = var.dynamo_table_name

  vpc_id     = data.aws_vpc.default.id
  subnet_ids = var.subnet_ids

  # To make testing easier, we allow requests from any IP address here but in a production deployment, we *strongly*
  # recommend you limit this to the IP address ranges of known, trusted servers inside your VPC.

  allowed_ssh_cidr_blocks              = ["0.0.0.0/0"]
  allowed_inbound_cidr_blocks          = ["0.0.0.0/0"]
  allowed_inbound_security_group_ids   = []
  allowed_inbound_security_group_count = 0
  ssh_key_name                         = var.ssh_key_name
}

# ---------------------------------------------------------------------------------------------------------------------
# ADDS A POLICY TO THE VAULT CLUSTER ROLE SO VAULT CAN QUERY AWS IAM USERS AND ROLES
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy" "vault_iam" {
  name   = "vault_iam"
  role   = module.vault_cluster.iam_role_id
  policy = data.aws_iam_policy_document.vault_iam.json
}

data "aws_iam_policy_document" "vault_iam" {
  statement {
    effect  = "Allow"
    actions = ["iam:GetRole", "iam:GetUser"]

    # List of arns it can query, for more security, it could be set to specific roles or user
    # resources = ["${aws_iam_role.instance_role.arn}"]
    resources = [
      "arn:aws:iam::*:user/*",
      "arn:aws:iam::*:role/*",
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["sts:GetCallerIdentity"]
    resources = ["*"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH VAULT SERVER WHEN IT'S BOOTING
# This script will configure and start Vault
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_vault_cluster" {
  template = "${file("${path.module}/user-data-vault.sh")}"

  vars = {
    aws_region        = data.aws_region.current.name
    kms_key_id        = data.aws_kms_alias.vault.target_key_id
    dynamo_table_name = var.dynamo_table_name
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE CLUSTERS IN THE DEFAULT VPC AND AVAILABILITY ZONES
# Using the default VPC and subnets makes this example easy to run and test, but it means Consul and Vault are
# accessible from the public Internet. In a production deployment, we strongly recommend deploying into a custom VPC
# and private subnets.
# ---------------------------------------------------------------------------------------------------------------------

data "aws_vpc" "default" {
  default = var.vpc_id == "" ? true : false
  id      = var.vpc_id
}

data "aws_region" "current" {}
