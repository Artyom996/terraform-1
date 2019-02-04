#-------------My Not First Terraform template-----------
# WebServers in ASG with ELB
#
# Made by Denis Astahov  on  04-February-2019
#---------------------------------------------------
provider "aws" {
  region = "us-west-2"
}
#----------Variables--------------------
variable "myVPC_id" {
  default = "vpc-dfd21ba7"
}
variable "myPublicSubnetA_id" {
  default = "subnet-4b2b1e11"
}
variable "myPublicSubnetB_id" {
  default = "subnet-820f55fb"
}

# ---- Launch Configuration for ASG ----
resource "aws_launch_configuration" "myLC" {
    image_id        = "ami-01e24be29428c15b2"
    instance_type   = "t3.micro"
    security_groups = ["${aws_security_group.MySecurityGroup.id}"]
    key_name        = "dastahov-oregon"
    user_data       = "${file("WebServer-userdata.sh")}"
    lifecycle {
    create_before_destroy = true
  }
}

# ----  Auto Scaling Group ----
resource "aws_autoscaling_group" "myASG" {
  launch_configuration = "${aws_launch_configuration.myLC.name}"
  min_size             = 2
  max_size             = 4
  vpc_zone_identifier  = ["${var.myPublicSubnetA_id}", "${var.myPublicSubnetB_id}"]
  load_balancers = ["${aws_elb.myELB.name}"]
  health_check_type = "ELB"
  tag {
    key = "Name"
    value = "Terraform-WebServer-in-ASG"
    propagate_at_launch = true
  }
  lifecycle {
  create_before_destroy = true
}
}

# --- Load Balancer
resource "aws_elb" "myELB"{
  name            = "Terraform-ELB"
  security_groups = ["${aws_security_group.MySecurityGroup.id}"]
  subnets         = ["${var.myPublicSubnetA_id}", "${var.myPublicSubnetB_id}"]
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
  }
  health_check {
   healthy_threshold = 2
   unhealthy_threshold = 2
   timeout = 3
   interval = 10
   target = "HTTP:80/index.html"
 }
  tags = {
    Name = "My-Terraform-ELB"
  }
}

resource "aws_security_group" "MySecurityGroup" {
  name = "WebServer"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]
  }

  tags ={
    Name = "SG-for-WebServer"
  }
}

#=======================================
output "elb_dns_name" {
  value = "${aws_elb.myELB.dns_name}"
}
