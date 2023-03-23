##################################################################################
# DATA
##################################################################################

data "aws_ssm_parameter" "anjlab_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# Web INSTANCES #
resource "aws_instance" "anjlab_webvm1" {
  ami                    = nonsensitive(data.aws_ssm_parameter.anjlab_ami.value)
  instance_type          = var.ec2_instance_type
  subnet_id              = aws_subnet.anjlab_pubsubnet1.id
  vpc_security_group_ids = [aws_security_group.anjlab_nginx_sg.id]

  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo rm /usr/share/nginx/html/index.html
echo '<html><head><title>AnjLan Web Server</title></head><body><p>Hello Ashu VM1</p></body></html>' | sudo tee /usr/share/nginx/html/index.html
sudo service nginx start
EOF
  tags = {
    Name = "${var.name_prefix}-WEB-VM1"
  }

}

resource "aws_instance" "anjlab_webvm2" {
  ami                    = nonsensitive(data.aws_ssm_parameter.anjlab_ami.value)
  instance_type          = var.ec2_instance_type
  subnet_id              = aws_subnet.anjlab_pubsubnet2.id
  vpc_security_group_ids = [aws_security_group.anjlab_nginx_sg.id]

  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo rm /usr/share/nginx/html/index.html
echo '<html><head><title>AnjLan Web Server</title></head><body><p>Hello Ashu VM2</p></body></html>' | sudo tee /usr/share/nginx/html/index.html
sudo service nginx start
EOF
  tags = {
    Name = "${var.name_prefix}-WEB-VM2"
  }

}