#security group for frontend service
module "frontend_service_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "Fornt-end-service"
  description = "Security group for user-service with port 443"
  vpc_id      = module.vpc.vpc_id


  ingress_cidr_blocks = ["10.10.0.0/16"]
}
#inbound
resource "aws_security_group_rule" "http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.elb_service_sg.security_group_id
  security_group_id        = module.frontend_service_sg.security_group_id
}
#outbound
resource "aws_security_group_rule" "https_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.frontend_service_sg.security_group_id
}
#security group for backend service

module "backend_service_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "backend-end-service"
  description = "Security group for user-service with port 8080"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = [module.frontend_service_sg.security_group_id]


}
#inbound
resource "aws_security_group_rule" "proxy" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.frontend_service_sg.security_group_id
  security_group_id        = module.backend_service_sg.security_group_id
}
#outbound
resource "aws_security_group_rule" "proxy_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.backend_service_sg.security_group_id
}
#security group for database

module "database_service_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name                = "database-service"
  description         = "Security group for user-service with default mysql"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = [module.backend_service_sg.security_group_id]

}
#inbound rule
resource "aws_security_group_rule" "mysql" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "-1"
  source_security_group_id = module.backend_service_sg.security_group_id
  security_group_id        = module.database_service_sg.security_group_id
}
#outbound rule
resource "aws_security_group_rule" "mysql_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "-1"
  security_group_id = module.database_service_sg.security_group_id
}

