output "public_ip" {
    value = aws_instance.this.public_ip
}

output "subnet_id" {
    value = var.subnet_id
}
