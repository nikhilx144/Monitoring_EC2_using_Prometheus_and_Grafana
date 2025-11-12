variable "aws_region" {
  type    = string
  default = "ap-south-2"
}

variable "app_name" {
  type    = string
  default = "monitoring-dashboard"
}

# ECR repo base (without tag). This is the repo you push to / pull from.
variable "ecr_repo" {
  type    = string
  default = "661979762009.dkr.ecr.ap-south-2.amazonaws.com/devops_ci_cd_final_prac_6_clean"
}

# image_tag will be passed from Jenkins (commit short); default uses 'latest' for manual runs
variable "image_tag" {
  type    = string
  default = "latest"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

# Optional: restrict ALB inbound to your IP if required
variable "admin_ip" {
  type    = string
  default = ""
}
