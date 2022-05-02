#AWS ELB config

resource "aws_elb" "frontend-elb" {
  name            = "frontend-elb"
  subnets         = [aws_subnet.front-end.id]
  security_groups = [module.elb_service_sg.security_group_id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 443
    lb_protocol       = "https"
  }

  health_check {
    #(required) The number of checks before the instance declared healthy
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "Frontend-elb"
  }

}


#AWS ELB security group


module "elb_service_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name                = "elb-service"
  description         = "Security group for user-service with elb"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]

}
#inbound rule
resource "aws_security_group_rule" "https-rule" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.elb_service_sg.security_group_id
}
#outbound rule
resource "aws_security_group_rule" "https_out_rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "-1"
  security_group_id = module.elb_service_sg.security_group_id
}
