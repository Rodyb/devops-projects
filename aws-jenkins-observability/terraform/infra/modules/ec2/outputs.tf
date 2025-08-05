output "public_ip" {
  value = aws_instance.ec2.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_instance.ec2.public_ip}"
}
