resource "aws_security_group" "fithealth_db_sg" {
  vpc_id = var.vpc_id
  ingress {
    cidr_blocks = var.fithealth_db_securtiy_cidr_block
    description = "db security group"
    from_port   = 3306
    protocol    = "tcp"
    to_port     = 3306
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = -1
  }
}
resource "aws_db_subnet_group" "subnetgroup" {

  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "fithealthdb" {
  allocated_storage      = var.db_allocated_storage
  db_name                = var.db_name
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  username               = var.username
  password               = var.password
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.subnetgroup.name
  vpc_security_group_ids = [aws_security_group.fithealth_db_sg.id]
}
