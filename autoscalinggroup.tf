#define ami
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
#define autoscaling launch configuration

resource "aws_launch_configuration" "as_conf" {
  name            = "frontend_config"
  security_groups = [module.frontend_service_sg.security_group_id]
  image_id        = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  key_name        = "user1"

}

#define autoscaling group
resource "aws_autoscaling_group" "frontend-group-autoscaling" {
  name                      = "frontend-group-autoscaling"
  vpc_zone_identifier       = [aws_subnet.front-end.id]
  launch_configuration      = aws_launch_configuration.as_conf.name
  min_size                  = 1
  max_size                  = 3
  health_check_grace_period = 100
  health_check_type         = "EC2"
  force_delete              = true
  tag {
    key                 = "Name"
    value               = "frontend-instance"
    propagate_at_launch = true
  }

}

#define autoscaling configuration policy
resource "aws_autoscaling_policy" "frontend-cpu-policy" {
  name                   = "frontend-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.frontend-group-autoscaling.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
  policy_type            = "SimpleScaling"
}

#define cloud watch monitoring
resource "aws_cloudwatch_metric_alarm" "frontend-cpu-alarm" {
  alarm_name          = "frontend-cpu-alarm"
  alarm_description   = "alarm once cpu usage increases"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 20

  dimensions = {
    "AutoScalingGroupName" : aws_autoscaling_group.frontend-group-autoscaling.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.frontend-cpu-policy.arn]
}

#define auto descaling policy
resource "aws_autoscaling_policy" "frontend-cpu-policy-scaledown" {
  name                   = "frontend-cpu-policy-scaledown"
  autoscaling_group_name = aws_autoscaling_group.frontend-group-autoscaling.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
  policy_type            = "SimpleScaling"

}

#define descaling cloud watch
resource "aws_cloudwatch_metric_alarm" "frontend-cpu-alarm-scaledown" {
  alarm_name          = "frontend-cpu-alarm-scaledown"
  alarm_description   = "alarm once cpu usage decreases"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 20

  dimensions = {
    "AutoScalingGroupName" : aws_autoscaling_group.frontend-group-autoscaling.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.frontend-cpu-policy-scaledown.arn]
}


############################################################################################
#backend autoscaling group

#define autoscaling launch configuration

resource "aws_launch_configuration" "as_conf-2" {
  name            = "backend_config"
  security_groups = [module.backend_service_sg.security_group_id]
  image_id        = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  key_name        = "user1"

}

#define autoscaling group
resource "aws_autoscaling_group" "backend-group-autoscaling" {
  name                      = "backend-group-autoscaling"
  vpc_zone_identifier       = [aws_subnet.back-end.id]
  launch_configuration      = aws_launch_configuration.as_conf-2.name
  min_size                  = 1
  max_size                  = 3
  health_check_grace_period = 100
  health_check_type         = "EC2"
  force_delete              = true
  tag {
    key                 = "Name"
    value               = "backend-instance"
    propagate_at_launch = true
  }

}

#define autoscaling configuration policy
resource "aws_autoscaling_policy" "backend-cpu-policy" {
  name                   = "backend-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.backend-group-autoscaling.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
  policy_type            = "SimpleScaling"
}

#define cloud watch monitoring
resource "aws_cloudwatch_metric_alarm" "backend-cpu-alarm" {
  alarm_name          = "backend-cpu-alarm"
  alarm_description   = "alarm once cpu usage increases"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 20

  dimensions = {
    "AutoScalingGroupName" : aws_autoscaling_group.backend-group-autoscaling.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.backend-cpu-policy.arn]
}

#define auto descaling policy
resource "aws_autoscaling_policy" "backend-cpu-policy-scaledown" {
  name                   = "backend-cpu-policy-scaledown"
  autoscaling_group_name = aws_autoscaling_group.backend-group-autoscaling.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
  policy_type            = "SimpleScaling"

}

#define descaling cloud watch
resource "aws_cloudwatch_metric_alarm" "backend-cpu-alarm-scaledown" {
  alarm_name          = "backend-cpu-alarm-scaledown"
  alarm_description   = "alarm once cpu usage decreases"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 20

  dimensions = {
    "AutoScalingGroupName" : aws_autoscaling_group.backend-group-autoscaling.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.backend-cpu-policy-scaledown.arn]
}

#########################################################################################################
#database autoscaling group

#define autoscaling launch configuration

resource "aws_launch_configuration" "as_conf-3" {
  name            = "database_config"
  security_groups = [module.database_service_sg.security_group_id]
  image_id        = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  key_name        = "user1"

}

#define autoscaling group
resource "aws_autoscaling_group" "database-group-autoscaling" {
  name                      = "database-group-autoscaling"
  vpc_zone_identifier       = [aws_subnet.database.id]
  launch_configuration      = aws_launch_configuration.as_conf-3.name
  min_size                  = 1
  max_size                  = 3
  health_check_grace_period = 100
  health_check_type         = "EC2"
  force_delete              = true
  tag {
    key                 = "Name"
    value               = "Database-instance"
    propagate_at_launch = true
  }

}

#define autoscaling configuration policy
resource "aws_autoscaling_policy" "database-cpu-policy" {
  name                   = "database-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.database-group-autoscaling.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
  policy_type            = "SimpleScaling"
}

#define cloud watch monitoring
resource "aws_cloudwatch_metric_alarm" "database-cpu-alarm" {
  alarm_name          = "database-cpu-alarm"
  alarm_description   = "alarm once cpu usage increases"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 20

  dimensions = {
    "AutoScalingGroupName" : aws_autoscaling_group.database-group-autoscaling.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.database-cpu-policy.arn]
}

#define auto descaling policy
resource "aws_autoscaling_policy" "database-cpu-policy-scaledown" {
  name                   = "database-cpu-policy-scaledown"
  autoscaling_group_name = aws_autoscaling_group.database-group-autoscaling.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
  policy_type            = "SimpleScaling"

}

#define descaling cloud watch
resource "aws_cloudwatch_metric_alarm" "database-cpu-alarm-scaledown" {
  alarm_name          = "database-cpu-alarm-scaledown"
  alarm_description   = "alarm once cpu usage decreases"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 20

  dimensions = {
    "AutoScalingGroupName" : aws_autoscaling_group.database-group-autoscaling.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.database-cpu-policy-scaledown.arn]
}
