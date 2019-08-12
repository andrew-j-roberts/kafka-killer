resource "aws_instance" "bbb-kafka-killer-consumer-__NODE_NAME__" {
  ami                     = "ami-07d0cf3af28718ef8" # Ubuntu
  instance_type           = "t2.medium"
  key_name                = "${var.aws_ssh_key_name}"
  vpc_security_group_ids  = ["sg-0305946e4e38f52e4"] # wide open
  subnet_id               = "subnet-8c7d16e9" # us-east-1a

  tags = {
    Name     = "bbb-kafka-killer-consumer-__NODE_NAME__"
    Owner    = "AndrewRoberts" 
    Purpose  = "BBB Kafka replacement demonstration"
    Days     = "7"
  }

  #############################################################################
  # Terraform + Ansible = better together
  # This is the 'local exec' method.  
  # Ansible runs from the same host you run Terraform from
  #############################################################################

  provisioner "remote-exec" {
    inline = ["echo 'SSH ready to rock'"]

    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file("${var.private_key_path}")}"
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ${self.public_ip}, --private-key ${var.private_key_path} ../ansible/provision-consumers.yml --extra-vars \"QUEUE_NAME=Q/__NODE_NAME__\""
  }

}