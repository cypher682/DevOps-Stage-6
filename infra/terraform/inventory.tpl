[app_servers]
app_server ansible_host=${instance_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/${key_name}.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'
