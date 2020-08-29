## All configuration values here are linked to the variables file

# Define the provider
provider "aws" {
    profile = "default" 
    region = "${var.region}"
}

# Create a EC2 Resource in AWS
resource "aws_instance" "example"{
    ami = "${var.amis[var.region]}"
    instance_type = "t2.micro"  

# This depends_on will make the creation of the EC2 dependent on the existance of the S3 bucket already
#    depends_on = ["aws_s3_bucket.example"]
    
# Locally executes the commands in the EC2 when it has spun up
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

# Create a S3 Bucket
resource "aws_s3_bucket" "example" {
  bucket = "terraform-test"
  acl ="private"
}

# Create a Elastic IP and associate it with the EC2 created named example above
resource "aws_eip" "ip" {
    vpc = true
    instance = "${aws_instance.example.id}"
}

# Output the Elastic IP
output "ip" {
  value = "${aws_eip.ip.public_ip}"
}

