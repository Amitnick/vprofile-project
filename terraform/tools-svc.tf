resource "aws_key_pair" "myrsa-key" {
  key_name   = "myrsa-key"
  public_key = file("key-pair/myrsa-key.pub")
}

resource "aws_security_group" "tools-hosts-sg" {
  name        = "tools-hosts-sg"
  description = "Securoty group for tools host ssh"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "tools-hosts-sg"
  }
}

resource "aws_security_group_rule" "tools-hosts-sg-rule-2" {
  from_port         = 80
  protocol          = "tcp"
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tools-hosts-sg.id

  depends_on = [aws_key_pair.myrsa-key, aws_security_group.tools-hosts-sg]
}

resource "aws_security_group_rule" "tools-hosts-sg-rule-3" {
  from_port         = 8080
  protocol          = "tcp"
  to_port           = 8081
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tools-hosts-sg.id

  depends_on = [aws_key_pair.myrsa-key, aws_security_group.tools-hosts-sg]
}

resource "aws_security_group_rule" "tools-hosts-sg-rule-1" {
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "ingress"
  security_group_id = aws_security_group.tools-hosts-sg.id
  self              = true

  depends_on = [aws_key_pair.myrsa-key, aws_security_group.tools-hosts-sg]
}

resource "aws_instance" "tools-host-jenkins" {
  ami                         = "ami-00978328f54e31526"
  instance_type               = "t2.small"
  availability_zone           = "us-east-2a"
  key_name                    = aws_key_pair.myrsa-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.tools-hosts-sg.id]
  tags = {
    "Name"    = "tools-host-jenkins"
    "project" = "Training"
  }


  provisioner "file" {
    source      = "userdata/"
    destination = "/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod u+x /tmp/jenkins_setup.sh",
      "sudo /tmp/jenkins_setup.sh"
    ]
  }

  connection {
    user        = var.USER
    private_key = file("key-pair/myrsa-key")
    host        = self.public_ip
  }

  depends_on = [aws_key_pair.myrsa-key, aws_security_group.tools-hosts-sg]
}


resource "aws_instance" "tools-host-nexus" {
  ami                         = "ami-092b43193629811af"
  instance_type               = "t2.medium"
  availability_zone           = var.ZONE1
  associate_public_ip_address = true
  key_name                    = aws_key_pair.myrsa-key.key_name
  vpc_security_group_ids      = [aws_security_group.tools-hosts-sg.id]
  tags = {
    "Name"    = "tools-host-nexus"
    "project" = "Training"
  }

  provisioner "file" {
    source      = "userdata/"
    destination = "/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod u+x /tmp/nexus_setup.sh",
      "sudo /tmp/nexus_setup.sh"
    ]
  }

  connection {
    user        = "ec2-user"
    private_key = file("key-pair/myrsa-key")
    host        = self.public_ip
  }

  depends_on = [aws_key_pair.myrsa-key, aws_security_group.tools-hosts-sg]
}


resource "aws_instance" "tools-host-sonarqube" {
  ami                         = "ami-00978328f54e31526"
  instance_type               = "t2.medium"
  availability_zone           = var.ZONE1
  associate_public_ip_address = true
  key_name                    = aws_key_pair.myrsa-key.key_name
  vpc_security_group_ids      = [aws_security_group.tools-hosts-sg.id]
  tags = {
    "Name"    = "tools-host-sonarqube"
    "project" = "Training"
  }

  provisioner "file" {
    source      = "userdata/"
    destination = "/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod u+x /tmp/sonar_setup.sh",
      "sudo /tmp/sonar_setup.sh"
    ]
  }

  connection {
    user        = "ubuntu"
    private_key = file("key-pair/myrsa-key")
    host        = self.public_ip
  }

  depends_on = [aws_key_pair.myrsa-key, aws_security_group.tools-hosts-sg]
}