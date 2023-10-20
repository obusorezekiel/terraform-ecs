resource "aws_ecs_cluster" "my_ecs_cluster" {
  name = "my_ecs_cluster"
}

resource "aws_ecs_task_definition" "my_sample_task" {
  family                   = "my_task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "my_task",
      "image": "${aws_ecr_repository.my-sample-app.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 5000,
          "hostPort": 5000
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]

DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

}

# main.tf
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "app_service" {
  name            = "my_ecs_cluster_service"                   # Name the service
  cluster         = aws_ecs_cluster.my_ecs_cluster.id          # Reference the created Cluster
  task_definition = aws_ecs_task_definition.my_sample_task.arn # Reference the task that the service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3 # Set up the number of containers to 3

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn # Reference the target group
    container_name   = aws_ecs_task_definition.my_sample_task.family
    container_port   = 5000 # Specify the container port
  }

  network_configuration {
    subnets = [aws_subnet.private_subnet-1.id, aws_subnet.private_subnet-2.id]
    // assign_public_ip = true     # Provide the containers with public IPs
    security_groups = ["${aws_security_group.service_security_group.id}"] # Set up the security group
  }
}


