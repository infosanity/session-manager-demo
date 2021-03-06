resource "aws_instance" "public_noNAT_instance" {
  ami                  = var.amazon2_ami
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.ssm_manage_profile_public.name
  network_interface {
    network_interface_id = aws_network_interface.public_nic.id
    device_index         = 0
  }
  key_name  = var.keyname
  user_data = "hostname viaEIP"
  tags = merge(
    var.tags,
    {
      Name = "publicInstance_viaEIP"
    }
  )
}

resource "aws_network_interface" "public_nic" {
  subnet_id       = aws_subnet.public_noNAT.id
  security_groups = [aws_security_group.instance_sg.id]
  tags = merge(
    var.tags,
    {
      Name = "publicInstance_NIC"
    }
  )
}

resource "aws_security_group" "instance_sg" {
  name        = "ssm-managed-instance-sg"
  description = "For Instances managed via SSM"
  vpc_id      = aws_vpc.public.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(
    var.tags,
    {
      Name = "sg_AllowEgress"
    }
  )
}

resource "aws_eip" "instance_eip" {
  vpc      = true
  instance = aws_instance.public_noNAT_instance.id
  tags = merge(
    var.tags,
    {
      Name = "publicInstanceEIP"
    }
  )
}

output "public_noNAT_instance" {
  value = aws_instance.public_noNAT_instance.id
}

###############################################################
# Via Linux NAT Gateway
resource "aws_instance" "public_NAT_instance" {
  ami                  = var.amazon2_ami
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.ssm_manage_profile_public.name
  key_name             = var.keyname
  network_interface {
    network_interface_id = aws_network_interface.nat_nic.id
    device_index         = 0
  }
  user_data = "hostname viaNAT"
  tags = merge(
    var.tags,
    {
      Name = "publicInstance_viaNAT"
    }
  )
}

resource "aws_network_interface" "nat_nic" {
  subnet_id       = aws_subnet.public_viaNAT.id
  security_groups = [aws_security_group.instance_sg.id]
  tags = merge(
    var.tags,
    {
      Name = "publicInstance_NATNIC"
    }
  )
}

output "public_NAT_instance" {
  value = aws_instance.public_NAT_instance.id
}

###############################################################
# Windows Via NAT Gateway
resource "aws_instance" "public_windows_instance" {
  ami                  = var.windows_ami
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.ssm_manage_profile_public.name
  key_name             = var.keyname
  network_interface {
    network_interface_id = aws_network_interface.windows_nat_nic.id
    device_index         = 0
  }
  user_data = "hostname windowsVIANAT"
  tags = merge(
    var.tags,
    {
      Name = "WindowsInstance_viaNAT"
    }
  )
}

resource "aws_network_interface" "windows_nat_nic" {
  subnet_id       = aws_subnet.public_viaNAT.id
  security_groups = [aws_security_group.instance_sg.id]
  tags = merge(
    var.tags,
    {
      Name = "windowsInstance_NATNIC"
    }
  )
}

output "public_windows_instance" {
  value = aws_instance.public_windows_instance.id
}
