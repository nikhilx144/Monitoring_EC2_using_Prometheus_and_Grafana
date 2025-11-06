output "ec2_public_ip" {
    value = aws_instance.ec2-instance.public_ip
    description = "Public IP of the EC2 Instance"
}

output "ec2_public_dns" {
    value = aws_instance.ec2-instance.public_dns
    description = "Public DNS of the EC2 Instance"
}