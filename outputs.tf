output "ec2_instance_id" {
  value = aws_instance.ec2.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

