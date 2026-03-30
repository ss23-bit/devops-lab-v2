resource "aws_launch_template" "web_template" {
  name_prefix   = "production-web-template-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ASG-managed-web-server"
    }
  }

  # --- The Bootstrapping Script ---
  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Update packages
              dnf update -y
              # Install Apache Web Server
              dnf install -y httpd
              # Start the service and enable it on boot
              systemctl start httpd
              systemctl enable httpd
              # Create a custom application page
              echo "<h1>Application Server Online. Deployed via Terraform ASG.</h1>" > /var/www/html/index.html
              EOF
  )
}

resource "aws_autoscaling_group" "web_fleet" {
  name = "production-web-asg"

  vpc_zone_identifier = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

  desired_capacity = 2
  min_size         = 2
  max_size         = 4

  target_group_arns = [aws_lb_target_group.frontend_tg.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.web_template.id
    version = "$Latest"
  }
}