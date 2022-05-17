module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  name = "my-ecs"

  container_insights = true

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy = [
    {
      base              = 1
      capacity_provider = "FARGATE"
      weight            = 5
    }
  ]

  tags = {
    Environment = "Development"
  }
}


resource "aws_alb_target_group" "example-production-tg2" {
  name     = "example-production-tg2"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = module.vpc.vpc_id
}



resource "aws_ecs_service" "worker" {
  name            = "worker"
  cluster         = module.ecs.ecs_cluster_id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 2
  network_configuration {
      subnets          = module.vpc.public_subnets
      assign_public_ip = true
      security_groups = [aws_security_group.ecs_sg.id]
    }
    load_balancer {
    target_group_arn     = aws_alb_target_group.example-production-tg2.arn
    container_name   =  aws_ecs_task_definition.task_definition.family
    container_port   = 80
  }

}


resource "aws_ecs_task_definition" "task_definition" {
  family                = "worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([
    {
      "name": "worker"
      "image": "nginx:latest",
      "environment": [],
      "entryPoint": [],
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
          loadBalancerName: "my-alb"
        }
      ],
      "networkMode": "awsvpc"
    }
  ])
}
