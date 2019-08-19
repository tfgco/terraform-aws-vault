# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
# AWS_DEFAULT_REGION

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "ami_id" {
  description = "The ID of the AMI to run in the cluster. This should be an AMI built from the Packer template under examples/vault-consul-ami/vault-consul.json."
}

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair."
}

variable "auto_unseal_kms_key_alias" {
  description = "The alias of AWS KMS key used for encryption and decryption"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "role_name" {
  description = "The name of the vault role"
  type        = string
}

variable "vault_cluster_name" {
  description = "What to name the Vault server cluster and all of its associated resources"
  type        = string
  default     = "vault-ddb"
}

variable "vault_cluster_size" {
  description = "The number of Vault server nodes to deploy. We strongly recommend using 3 or 5."
  type        = number
  default     = 3
}

variable "vault_instance_type" {
  description = "The type of EC2 Instance to run in the Vault ASG"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to deploy into. Leave an empty string to use the Default VPC in this region."
  type        = string
}

variable "dynamo_table_name" {
  description = "The name of an dynamo table to create and use as a storage backend (if configured). Note: Consul will not be configured"
  type        = string
}

variable "subnet_ids" {
  description = "The ID of the subnets to deploy instances into"
  type        = set(string)
}
