provider "aws" {
  region="us-east-1"
}

######  jenkins server


data "aws_security_group" "sg" {
  name = "default"
}


resource "aws_instance" "jenkins" {
  ami           = "ami-0083662ba17882949"
  instance_type = "t2.medium"
#  iam_instance_profile = "grafana-server-role"
  key_name = "bynet"
  vpc_security_group_ids = ["${data.aws_security_group.sg.id}"]
#  subnet_id = "${aws_subnet.externalsub.id}"
  associate_public_ip_address = true
  root_block_device {
    volume_size = 30
  }
  connection {
    type = "ssh"
    user = "centos"
    private_key = file("../aws/bynet.pem")
    host = aws_instance.jenkins.public_dns
  }
  provisioner "remote-exec" {
    inline = [
	"sudo yum install -y yum-utils device-mapper-persistent-data lvm2",
	"sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
	"sudo yum install -y docker-ce docker-ce-cli containerd.io",
	"sudo systemctl start docker",
	"sudo systemctl enable docker",
	"sudo usermod -aG docker centos",
	"sudo curl -L https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
	"sudo chmod +x /usr/local/bin/docker-compose",
	"sudo docker pull jenkins/jenkins",
	"mkdir jenkins",
	"cd jenkins",
	"mkdir jenkins_home",
	"mkdir centos7",
	"sudo chown 1000:1000 jenkins_home -R",
	"curl -OL https://raw.githubusercontent.com/ronengilboa/jenkins/master/docker-compose.yml",
#	"docker-compose up -d",
    ]
  }

}


output "public_dns" {
  value       = aws_instance.jenkins.public_dns
  description = "The public dns of the jenkins server instance."
}

