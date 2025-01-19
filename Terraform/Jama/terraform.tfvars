name                = "jama-prod"
dns_name            = "jama-prod"
alb_subnets         = ["subnet-0aaf736c3e97bd8d3", "subnet-0a4a76ce2a3453b7d"] # This subnets are generated and didn't exist.
alb_security_groups = ["sg-0a1b2c3d4e5f6g7h8", "sg-0f0c937d023a8b315"] # This SG are generated and didn't exist.
app_subnet          = "subnet-0a4a76ce2a3453b7d" # This Subnet are generated and didn't exist.
acm_certificate_arn = "arn:aws:acm:us-west-2:***"
app_security_groups = ["sg-0a1b2c3d4e5f6g7h8"] # This SG are generated and didn't exist.
ec2_key_pair_name   = "irrelevant"

tags = {
  Owner : "devops"
  Requestor : "pmo"
  Environment : "jama_prod"
  CreatedBy : "terraform"
  Project : "jama"
}
