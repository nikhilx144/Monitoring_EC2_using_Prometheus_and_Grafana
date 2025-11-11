variable "key_name" {
    description = "Existing EC2 key pair name"
    default = "devops_key_pair"
}

variable "ami_id" {
    description = "AMI ID for the EC2 instance"
    default = "ami-079934491f5c8de07"
}

variable "ec2_type" {
    description = "Type of the EC2 Instance"
    default = "t3.micro"
}

variable "aws_region" {
    description = "AWS Region"
    default = "ap-south-2"
}

variable "ecr_repo" {
    description = "ECR Repository URL"
    default = "661979762009.dkr.ecr.ap-south-2.amazonaws.com/devops_ci_cd_final_prac_6_clean"
}

variable "my_public_ip" {
    description = "My Public IP"
    default = "183.82.51.10"
}