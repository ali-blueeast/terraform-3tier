rovider "aws" {
  region     = "eu-west-1"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}
#vpc

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name               = "my-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  enable_nat_gateway = true
  enable_vpn_gateway = true


  tags = {
    Terraform   = "true"
    Environment = "development"
  }
}

resource "aws_subnet" "front-end" {
  vpc_id            = module.vpc.vpc_id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "fron-end-private-subnet"
  }
}

resource "aws_subnet" "back-end" {
  vpc_id            = module.vpc.vpc_id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "back-end-private-subnet"
  }

}

resource "aws_subnet" "database" {
  vpc_id            = module.vpc.vpc_id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-1c"

  tags = {
    Name = "database-private-subnet"
  }

}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = module.vpc.vpc_id


  tags = {
    Name = "my-igw-vpc"
  }
}

resource "aws_route_table" "my-rt" {
  vpc_id = module.vpc.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }

}

resource "aws_route_table_association" "my-rta-frontend" {
  route_table_id = aws_route_table.my-rt.id
  subnet_id      = aws_subnet.front-end.id
}

resource "aws_route_table_association" "my-rta-backend" {
  route_table_id = aws_route_table.my-rt.id
  subnet_id      = aws_subnet.back-end.id
}

resource "aws_route_table_association" "my-rta-database" {
  route_table_id = aws_route_table.my-rt.id
  subnet_id      = aws_subnet.database.id
}

