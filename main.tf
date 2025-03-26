#  Create AWS IPAM
resource "aws_vpc_ipam" "example" {
  description = "My AWS IPAM"
  operating_regions {
    region_name = "us-east-1"
  }
}

# Create an IPAM Pool
resource "aws_vpc_ipam_pool" "example_pool" {
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.example.private_default_scope_id
  locale         = "us-east-1"
  allocation_default_netmask_length = 24
}

# Allocate an IP Range to the Pool
resource "aws_vpc_ipam_pool_cidr" "example_cidr" {
  ipam_pool_id = aws_vpc_ipam_pool.example_pool.id
  cidr         = "10.0.0.0/16"
}


# Create a VPC Using the IPAM Pool
resource "aws_vpc" "example_vpc" {
  ipv4_ipam_pool_id = aws_vpc_ipam_pool.example_pool.id
  cidr_block        = "10.0.0.0/16"  # Must match the allocated range
  tags = {
    Name = "MyIPAMVPC"
  }
}


# Enable AWS CloudWatch Metrics for IPAM
resource "aws_cloudwatch_metric_alarm" "ipam_usage_alert" {
  alarm_name          = "ipam-high-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "IpamPoolAvailableCidrs"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Minimum"
  threshold           = 1
  alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:ipam-alerts"]
}
