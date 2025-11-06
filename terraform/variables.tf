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