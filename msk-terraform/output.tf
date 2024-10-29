output "bastion_host_ssh" {
  value = "ssh ec2-user@${aws_instance.bastion_host.public_ip} -i bastion_host.pem"
}