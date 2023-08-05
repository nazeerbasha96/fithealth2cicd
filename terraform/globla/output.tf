output "vpc_id" {
  value = module.fithealth_vpc_module.vpc_id

}
output "subnet_id" {
  value = module.fithealth_subnet_module[*].subnet_id
}

output "public_ip" {
  value = module.jumpboxec2_module.jumpboxec2_public_ip
}
output "private_ip" {
  value = module.fithealthec2_instance_module[*].fithealthec2_private_ip
  
}
output "rds_endpoint" {
  value = module.rds_module.db_instance_endpoint
 }
output "instance_id" {
  value = module.fithealthec2_instance_module[*].instance_id
  
}

output "lbr_dns_name" {
  value = module.application_load_balancer.lbr_dns_name
  
}
