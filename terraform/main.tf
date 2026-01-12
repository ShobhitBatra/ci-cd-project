# Creating key_pair
resource "aws_key_pair" "key_ec2" {
  key_name   = "terraform"
  public_key = file("~/.ssh/terraform.pub")
}


# Creating security group
resource "aws_security_group" "sg_ec2" {
  name        = "ec2-sg"
  description = "Creating security group for my ec2 instance"
  #   vpc_id = "It will use default vpc"
}

# Creating security group rules: (inbound + outbound)
resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_ec2.id
}

resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_ec2.id
}

resource "aws_security_group_rule" "all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_ec2.id
}

# Creating EC2 instance 
resource "aws_instance" "ec2" {
  ami                    = "ami-02b8269d5e85954ef"
  instance_type          = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  key_name               = aws_key_pair.key_ec2.key_name
  vpc_security_group_ids = [aws_security_group.sg_ec2.id]
  user_data              = file("./userdata.sh")

  tags = {
    Name = "ec2"
  }
}

# Creating IAM Role for EC2 to acccess ECR
resource "aws_iam_role" "iam_role_ec2" {
  name = "ec2-ecr-read-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach ECR ReadOnly Policy
resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.iam_role_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ecr-instance-profile"
  role = aws_iam_role.iam_role_ec2.name
}

# Because EC2 can only attach IAM roles via an Instance Profile — it’s the container that passes the role’s credentials to the instance.