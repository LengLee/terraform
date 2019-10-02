provider "aws" {
    profile = "default" 
    region = "${var.region}"
}


resource "aws_instance" "example"{
    ami = "${var.amis[var.region]}"
    instance_type = "t2.micro"  

    depends_on = ["aws_s3_bucket.example"]
    
    provisioner "local-exec" {
        command = "echo ${aws_instance.example.public_ip} > ip_address.txt"
    }
    provisioner "remote-exec" {
        inline = [
            "sudo apt-get update",
            "sudo apt-get install docker-ce docker-ce-cli containerd.io",
            "sudo docker run -d -p 8080:80 nginx"
        ]
    }
}

resource "aws_s3_bucket" "example" {
  bucket = "ll-terraform-test"
  acl ="private"
}


resource "aws_eip" "ip" {
    vpc = true
    instance = "${aws_instance.example.id}"
}

output "ip" {
  value = "${aws_eip.ip.public_ip}"
}

