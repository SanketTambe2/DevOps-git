resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.us-east-1.s3"
  route_table_ids = [
    aws_route_table.private.id
  ]
  vpc_endpoint_type = "Gateway"
  tags = {
    Name = "S3-VPC-Endpoint"
  }
}


