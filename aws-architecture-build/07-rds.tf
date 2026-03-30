resource "aws_db_subnet_group" "db_subnets" {
  name       = "production-db-subnet"
  subnet_ids = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]

  tags = {
    Name = "Production DB Subnet Group"
  }
}

resource "aws_db_instance" "backend_db" {
  identifier        = "production-backend-db"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  # Credential
  username = "admin"
  password = "Secret123"

  # Network and Security
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  publicly_accessible    = false # Strict security: No internet access

  # Lab & Cost-saving setting
  multi_az            = false # We keep this false for the lab to save money
  skip_final_snapshot = true  # Allows us to delete the lab easily without AWS forcing a backup

  tags = {
    Name = "Production-MySQL"
  }

}