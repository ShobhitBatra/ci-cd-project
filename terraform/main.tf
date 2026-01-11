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
  key_name               = aws_key_pair.key_ec2.key_name
  vpc_security_group_ids = [aws_security_group.sg_ec2.id]
  user_data              = file("./userdata.sh")

  tags = {
    Name = "ec2"
  }
}