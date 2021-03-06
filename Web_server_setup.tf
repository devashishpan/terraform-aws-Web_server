
resource "aws_security_group" "sg_web" {
  name = "sg_web"
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server" {
  ami                    = "ami-06cffe063efe892ad"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.sg_web.id}"]
  key_name               = var._keyname_
  tags = {
    Name = "Webserver"
  }
}

resource "null_resource" "config_webserver" {
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("${var._key_file_}")
    host        = aws_instance.web_server.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd -yy",
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd",
      "sudo yum install git -y",
      "sudo git clone ${var._git_url_} > /var/www/html",
      "sudo systemctl restart httpd"
    ]
  }
  provisioner "local-exec" {
    command = "google-chrome ${aws_instance.web_server.public_ip}"
  }
}
