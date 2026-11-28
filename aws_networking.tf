data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_internet_gateway" "default" {

  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.default.id]
  }

}

data "aws_route_table" "default" {
  route_table_id = data.aws_vpc.default.main_route_table_id
}

resource "aws_security_group" "k8s-sg" {
  vpc_id = data.aws_vpc.default.id
  name   = "k8s-sg"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      data.aws_vpc.default.cidr_block,
      "0.0.0.0/0"
    ]
  }

  ingress {

    from_port = 6443
    to_port   = 6443
    protocol  = "tcp"
    cidr_blocks = [
      data.aws_vpc.default.cidr_block
    ]
  }

  ingress {
    from_port = 10250
    to_port   = 10250
    protocol  = "tcp"
    cidr_blocks = [
      data.aws_vpc.default.cidr_block
    ]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }


  # Calico VXLAN overlay networking
  ingress {
    description = "Calico VXLAN"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"

    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  # Calico Typha - if deployed by the operator
  ingress {
    description = "Calico Typha"
    from_port   = 5473
    to_port     = 5473
    protocol    = "tcp"

    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  # Traefik HTTP NodePort
  ingress {
    description = "Traefik HTTP"
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Traefik HTTPS NodePort
  ingress {
    description = "Traefik HTTPS"
    from_port   = 30443
    to_port     = 30443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 1389
    to_port   = 1389
    protocol  = "tcp"
    cidr_blocks = [
      data.aws_vpc.default.cidr_block
    ]

  }

  ingress {
    from_port = 8472
    to_port   = 8472
    protocol  = "udp"
    cidr_blocks = [
      data.aws_vpc.default.cidr_block
    ]
  }

  ingress {

    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      data.aws_vpc.default.cidr_block
    ]


  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-sg"
  }
}

