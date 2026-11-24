resource "aws_instance" "this" {
  ami                    = var.ami_id
  subnet_id              = var.subnet_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids

  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type             = "one-time"
      instance_interruption_behavior = "terminate"
    }
  }

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = var.instance_name
  }
}