output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.app_server.public_dns
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.app_sg.id
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_instance.app_server.public_ip}"
}

output "dns_configuration" {
  description = "DNS A record configuration needed"
  value       = "Create A record: ${var.domain_name} -> ${aws_instance.app_server.public_ip}"
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    instance_ip = aws_instance.app_server.public_ip
    key_name    = var.key_name
  })
  filename = "${path.module}/../ansible/inventory.ini"

  depends_on = [aws_instance.app_server]
}
