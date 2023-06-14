# Instance
resource "aws_instance" "Instance" {
  ami                         = "ami-0b5eea76982371e91"
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  root_block_device {
    volume_size = "8"
  }
  key_name  = ""                        # Add your keypair name here
  count     = 1
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update
    sudo yum install httpd -y
    sudo service httpd start
    sudo service httpd enable
    sudo echo "This was created using Terraform" >> /var/www/html/index.html
    EOF

  tags = {
    Name = "EC2 Instance"
  }
}

