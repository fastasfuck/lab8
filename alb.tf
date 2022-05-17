module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "my-alb"

  load_balancer_type = "application"

  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.ecs_sg.id]

  tags = {
    Environment = "Test"
  }
}
resource "aws_alb_listener" "nginx-listeners" {
  load_balancer_arn = module.alb.lb_arn
  port              = "80"
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.example-production-tg2.arn
  }
}
