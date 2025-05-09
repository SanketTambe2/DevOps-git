# Key Pair (optional for SSH access)
resource "aws_key_pair" "sanket-key" {
  key_name   = "s-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHytR9/71L3jn/5Qj9QW6ue2nShgSu3kLUYOVzAJLuZ8 Sanket@LAPTOP-QUR2N0FG"
}

# Public EC2
resource "aws_instance" "public_ec2" {
  ami                         = "ami-0f88e80871fd81e91" # Amazon Linux 2023
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.sanket-key.key_name
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  tags = { Name = "Public-EC2" }
}

# Private EC2
resource "aws_instance" "private_ec2" {
  ami                    = "ami-0f88e80871fd81e91"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  key_name               = aws_key_pair.sanket-key.key_name
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  associate_public_ip_address = false
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = { Name = "Private-EC2" }
}

