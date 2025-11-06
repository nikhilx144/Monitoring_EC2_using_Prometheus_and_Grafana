resource "aws_security_group" "ec2-sg" {
    name = "ec2-sg"
    description = "Security group for the EC2 instance"

    ingress {
        from_port = 9090
        to_port = 9090
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 9100
        to_port = 9100
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 3000
        to_port = 3000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0 
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "ec2-sg"
    }
}

resource "aws_instance" "ec2-instance" {
    ami = var.ami_id
    instance_type = var.ec2_type
    security_groups = [ aws_security_group.ec2-sg.name ]
    key_name = var.key_name

    user_data = <<-EOF
    #!/bin/bash
    yum update -y

    # Install, enable and start Docker
    yum install -y docker
    systemctl enable docker
    systemctl start docker

    # Add docker to ec2-user group
    usermod -aG docker ec2-user

    # Install docker compose
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    # Create a monitoring directory
    mkdir -p /opt/monitoring

    # Write docker-compose.yml file 
    cat <<'EOT' > /opt/monitoring/docker-compose.yml 
    ${local.docker_compose}
    EOT

    # Write rendered prometheus.yml file
    cat <<'EOT' > /opt/monitoring/prometheus.yml
    ${local.prometheus_config}
    EOT

    # Start monitoring stack i.e. the container using docker compose up command
    cd /opt/monitoring
    /usr/local/bin/docker-compose up -d
    EOF

    tags = {
        Name = "Monitoring-Dashboard-EC2"
    }
}

locals {
    # Load docker-compose.yml from cwd
    docker_compose = file("${path.module}/../docker-compose.yml")

    # Render prometheus.yml from template file
    prometheus_config = file("${path.module}/../prometheus/prometheus.yml")
}