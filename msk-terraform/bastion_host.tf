#key-pair for bastion-host
##########################

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "private_key" {
  key_name   = var.msk_name
  public_key = tls_private_key.private_key.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.private_key.private_key_pem
  filename = "bastion_host.pem"
}

resource "null_resource" "private_key_permissions" {
  depends_on = [local_file.private_key]
  provisioner "local-exec" {
    command     = "chmod 600 bastion_host.pem"
    interpreter = ["bash", "-c"]
    on_failure  = continue
  }
}

# bastion host
#############
resource "aws_instance" "bastion_host" {
  instance_type          = "t2.micro"
  tags = {
    name = "bastion_host"
  }
  depends_on             = [aws_msk_cluster.msk]
  ami                    = data.aws_ami.amazon_linux.id
  key_name               = aws_key_pair.private_key.key_name
  subnet_id              = module.vpc.aws_public_subnets_id[0]
  vpc_security_group_ids = [aws_security_group.bastion_host.id]
  user_data = templatefile("bastion_host.tpl", 
  {
    bootstrap_server_1 = split(",", aws_msk_cluster.msk.bootstrap_brokers)[0]
    bootstrap_server_2 = split(",", aws_msk_cluster.msk.bootstrap_brokers)[1]
  })
}