resource "aws_instance" "private-instance" {
  ami                  = var.amazon2_ami
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.ssm_managed_profile.name
  key_name             = var.keyname
  network_interface {
    network_interface_id = aws_network_interface.private-nic.id
    device_index         = 0
  }
  user_data = "private"
  tags = {
    Name = "PrivateInstance"
  }
}

resource "aws_network_interface" "private-nic" {
  subnet_id       = aws_subnet.private.id
  security_groups = [aws_security_group.instance_sg.id]
}

resource "aws_security_group" "instance_sg" {
  name        = "ssm-managed-instance-sg"
  description = "For Instances managed via SSM"
  vpc_id      = aws_vpc.private.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "private_instance" {
  value = aws_instance.private-instance.id
}