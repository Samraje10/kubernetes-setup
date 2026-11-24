
module "k8s_worker" {
  for_each = toset(var.workers)
  source   = "./modules/ec2-instance"

  ami_id                 = var.ubuntu_ami_id
  subnet_id              = data.aws_subnets.default.ids[0]
  instance_type          = var.worker_instance_type
  key_name               = aws_key_pair.k8s_key.key_name
  vpc_security_group_ids = [aws_security_group.k8s-sg.id]
  name                   = var.worker_1
  volume_size            = var.volume_size
  volume_type            = var.volume_type
  instance_name          = each.value

}

resource "null_resource" "copy_k8s_worker_script" {

  for_each   = module.k8s_worker
  depends_on = [module.k8s_worker]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = each.value.public_ip
    private_key = file(pathexpand("~/.ssh/id_rsa"))
  }

  provisioner "file" {
    source      = "${path.module}/scripts/worker-setup.sh"
    destination = "/home/ubuntu/worker-setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod u+x /home/ubuntu/worker-setup.sh",
      "sudo /home/ubuntu/worker-setup.sh"
    ]
  }
}
