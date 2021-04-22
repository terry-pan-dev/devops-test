provider "aws" {
  region = var.region
}

locals {
  container_name  = "devops-test"
  container_port  = 8080
  container_image = var.container_image
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name               = "ecs-alb-single-svc"
  cidr               = var.vpc_cidr
  azs                = var.availability_zone
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Name        = "ecs vpc"
    Owner       = "terry"
    Environment = "dev"
  }
}

module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws"

  name = "ecs_cluster"

  tags = {
    Name        = "ecs cluster"
    Owner       = "terry"
    Environment = "dev"
  }
}


resource "aws_security_group" "alb_public_sg" {
  name        = "alb-public-sg"
  description = "application load balancer public security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  egress {
    # allow all traffic to private SN
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "ecs cluster public security group"
    Owner       = "terry"
    Environment = "dev"
  }

}

resource "aws_alb" "ecs_load_balancer" {
  name            = "ecs-load-balancer"
  security_groups = [aws_security_group.alb_public_sg.id]
  subnets         = module.vpc.public_subnets

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "ecs cluster application load balancer"
    Owner       = "terry"
    Environment = "dev"
  }
}

resource "aws_alb_target_group" "ecs_target_group" {
  name        = "ecs-target-group"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
  }

  tags = {
    Name        = "ecs cluster target group"
    Owner       = "terry"
    Environment = "dev"
  }
}

resource "aws_alb_listener" "alb-listener" {
  load_balancer_arn = aws_alb.ecs_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  lifecycle {
    create_before_destroy = true
  }

  default_action {
    target_group_arn = aws_alb_target_group.ecs_target_group.arn
    type             = "forward"
  }
}


resource "aws_ecs_task_definition" "devops" {
  family                   = "devops"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 1024
  cpu                      = 512

  container_definitions = jsonencode(
    [
      {
        "name" : local.container_name,
        "image" : local.container_image,
        "portMappings" : [
          {
            "containerPort" : local.container_port
          }
        ]
      }
  ])

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "ecs cluster task definition devops"
    Owner       = "terry"
    Environment = "dev"
  }
}

resource "aws_ecs_service" "devops" {
  name            = "devops"
  cluster         = module.ecs_cluster.this_ecs_cluster_id
  task_definition = aws_ecs_task_definition.devops.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_alb_target_group.ecs_target_group.arn
    container_name   = local.container_name
    container_port   = local.container_port
  }

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.alb_public_sg.id]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "ecs cluster service devops"
    Owner       = "terry"
    Environment = "dev"
  }
}
