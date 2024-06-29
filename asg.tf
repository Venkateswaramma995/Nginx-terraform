data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_launch_configuration" "nginx_lc" {
  name          = "nginx-launch-configuration"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF
}

resource "aws_autoscaling_group" "nginx_asg" {
  launch_configuration = aws_launch_configuration.nginx_lc.id
  min_size             = 2
  max_size             = 4
  vpc_zone_identifier  = aws_subnet.private_subnet.*.id
  desired_capacity     = 2
  health_check_type    = "EC2"
  tags = [
    {
      key                 = "Name"
      value               = "nginx-server"
      propagate_at_launch = true
    }
  ]
}
