module "vpc" {
  source = "./modules/vpc"

  project_name             = var.project_name
  vpc_cidr                 = var.vpc_cidr
  public_subnet_cidr       = var.public_subnet_cidr
  private_db_subnet_a_cidr = var.private_db_subnet_a_cidr
  private_db_subnet_b_cidr = var.private_db_subnet_b_cidr
  availability_zone_a      = var.availability_zone_a
  availability_zone_b      = var.availability_zone_b
}
