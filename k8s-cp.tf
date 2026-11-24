module "k8s_cp" {
  source = "./modules/ec2-instance"

  ami_id                 = var.ubuntu_ami_id
  subnet_id              = data.aws_subnets.default.ids[0]
  instance_type          = var.worker_instance_type
  key_name               = aws_key_pair.k8s_key.key_name
  vpc_security_group_ids = [aws_security_group.k8s-sg.id]
  name                   = var.control_plane
  volume_size            = var.volume_size
  volume_type            = var.volume_type
  instance_name          = "control-plane"
}

resource "null_resource" "copy_k8s_cp_script" {
  depends_on = [module.k8s_cp]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = module.k8s_cp.public_ip
    private_key = file(pathexpand("~/.ssh/id_rsa"))
  }

  provisioner "file" {
    source      = "${path.module}/scripts/cp-setup.sh"
    destination = "/home/ubuntu/cp-setup.sh"
  }


  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait || true",
      "sed -i 's/\\r$//' /home/ubuntu/cp-setup.sh",
      "chmod +x /home/ubuntu/cp-setup.sh",
      "sudo bash -ex /home/ubuntu/cp-setup.sh"
    ]
  }

}