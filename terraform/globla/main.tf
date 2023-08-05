terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  region  = var.region
  profile = var.profile
}
module "fithealth_vpc_module" {
  source   = "../module/services/network/vpc"
  vpc_cidr = var.vpc_cidr
}
module "fithealth_subnet_module" {
  count            = length(var.subnet_cidr)
  source           = "../module/services/network/subnet"
  vpc_id           = module.fithealth_vpc_module.vpc_id
  subnet_cidr      = element(var.subnet_cidr, count.index)
  availabilty_zone = element(var.availability_zone, count.index % 2)
  subnet_name      = "fithealth_${count.index}"
  

}
module "fithealth_ig_module" {
  source    = "../module/services/network/gateways/ig"
  vpc_id    = module.fithealth_vpc_module.vpc_id
  subnet_id = [module.fithealth_subnet_module[4].subnet_id, module.fithealth_subnet_module[5].subnet_id]

}
module "fihealth_nat_module" {
  source           = "../module/services/network/gateways/ng"
  vpc_id           = module.fithealth_vpc_module.vpc_id
  subnet_id        = [module.fithealth_subnet_module[0].subnet_id, module.fithealth_subnet_module[1].subnet_id]
  public_subnet_id = module.fithealth_subnet_module[4].subnet_id
  depends_on = [
    module.fithealth_ig_module
  ]

}

module "fithealth_public_key_module" {
  source     = "../module/services/compute/keypair"
  key_name   = var.key_name
  public_key = var.public_key

}

module "fithealthec2_instance_module" {
  count              = 2
  source             = "../module/services/compute/ec2"
  vpc_id             = module.fithealth_vpc_module.vpc_id
  ami                = var.ami
  ingress_cidr_block = var.vpc_cidr
  instance_type      = var.instance_type
  key_name           = module.fithealth_public_key_module.key_name
  #subnet_id = [module.fithealth_subnet_module[0].subnet_ids,module.fithealth_subnet_module[1].subnet_ids]
  subnet_id = module.fithealth_subnet_module[count.index].subnet_id
  depends_on = [
    module.fihealth_nat_module,
    module.rds_module
  ]
  instance_name = "fithealth2_${count.index+1}"

}
module "jumpboxec2_module" {

  source             = "../module/services/compute/jumpbox"
  vpc_id             = module.fithealth_vpc_module.vpc_id
  ami                = var.ami
  ingress_cidr_block = var.vpc_cidr
  instance_type      = var.instance_type
  key_name           = module.fithealth_public_key_module.key_name
  subnet_id          = module.fithealth_subnet_module[5].subnet_id
  depends_on = [
    module.fithealthec2_instance_module,
    module.rds_module
  ]
}
resource "null_resource" "db_endpoint_replace" {
  provisioner "local-exec" {
    command = "sed -i 's/connectstring/${module.rds_module.db_instance_endpoint}/g' ../../src/main/resources/db.properties && mvn -f ../../pom.xml clean verify"


  }
  depends_on = [module.rds_module]

}
resource "null_resource" "copy_ssh" {
  provisioner "file" {
    connection {
      type        = "ssh"
      host        = module.jumpboxec2_module.jumpboxec2_public_ip
      user        = "ubuntu"
      private_key = file("~/.ssh/terraform")
    }
    source      = "../config/terraform"
    destination = "/home/ubuntu/.ssh/terraform"
  }
  # provisioner "file" {
  #   connection {
  #     type        = "ssh"
  #     host        = module.jumpboxec2_module.jumpboxec2_public_ip
  #     user        = "ubuntu"
  #     private_key = file("~/.ssh/terraform")
  #   }
  #   source      = "../../ansible"
  #   destination = "/tmp/"
  # }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = module.jumpboxec2_module.jumpboxec2_public_ip
      user        = "ubuntu"
      private_key = file("~/.ssh/terraform")
    }
    inline = [
      "sudo rm -rf /tmp/fithealth2/",
      "sudo mkdir /tmp/fithealth2",
      "sudo apt update -y"
    ]
  }
  provisioner "local-exec" {
    command = "tar -cvf ../../fithealth2.tar ../../src/ ../../ansible/"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      host        = module.jumpboxec2_module.jumpboxec2_public_ip
      user        = "ubuntu"
      private_key = file("~/.ssh/terraform")
    }
    source      = "../../fithealth2.tar"
    destination = "/tmp/fithealth.tar"

  }
  provisioner "file" {
    connection {
      type        = "ssh"
      host        = module.jumpboxec2_module.jumpboxec2_public_ip
      user        = "ubuntu"
      private_key = file("~/.ssh/terraform")
    }
    source      = "../../target/fithealth2.war"
    destination = "/tmp/fithealth2.war"

  }
  depends_on = [
    module.jumpboxec2_module,
    resource.null_resource.db_endpoint_replace
  ]
}

resource "null_resource" "ansible_remote_exe" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = module.jumpboxec2_module.jumpboxec2_public_ip
      user        = "ubuntu"
      private_key = file("~/.ssh/terraform")
    }
    inline = [
      "sudo chmod 600 /home/ubuntu/.ssh/terraform",
      "sudo apt update -y",
      "sudo apt install ansible -y",
      "sudo apt install mysql-client -y",
      "sudo tar -xvf /tmp/fithealth.tar --directory /tmp/fithealth2/",
      "printf '%s\n%s'  ${module.fithealthec2_instance_module[0].fithealthec2_private_ip}  ${module.fithealthec2_instance_module[1].fithealthec2_private_ip} > /tmp/fithealthhosts",
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --private-key ~/.ssh/terraform -i /tmp/fithealthhosts /tmp/fithealth2/ansible/tomcat-playbook.yml",
      "mysql -h ${module.rds_module.db_instance_address} -u${var.db_username} -p${var.db_password} < /tmp/fithealth2/src/main/db/db-schema.sql"
    ]

  }
  depends_on = [
    #module.jumpboxec2_module,
    resource.null_resource.copy_ssh
  
  ]
}


module "rds_module" {
  source                           = "../module/services/database/rds"
  vpc_id                           = module.fithealth_vpc_module.vpc_id
  fithealth_db_securtiy_cidr_block = [var.vpc_cidr]
  db_name                          = var.db_name
  username                         = var.db_username
  password                         = var.db_password
  db_allocated_storage             = var.db_allocated_storage
  subnet_ids                       = [module.fithealth_subnet_module[2].subnet_id, module.fithealth_subnet_module[3].subnet_id]
}
module "application_load_balancer" {
  source        = "../module/services/compute/elb"
  vpc_id        = module.fithealth_vpc_module.vpc_id
  subnet_id     = [module.fithealth_subnet_module[4].subnet_id, module.fithealth_subnet_module[5].subnet_id]
  instance1_id  = module.fithealthec2_instance_module[0].instance_id
  instance2_id  = module.fithealthec2_instance_module[1].instance_id
  instance_port = 8080
  nametg        = var.nametg
  lbrname       = var.lbrname
  depends_on = [   
    resource.null_resource.ansible_remote_exe,
    resource.null_resource.copy_ssh
    
  ]
}
