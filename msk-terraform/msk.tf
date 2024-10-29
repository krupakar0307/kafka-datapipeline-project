#cluster
#########
resource "aws_kms_key" "msk_kms_key" {
  description = "kafka key"
}

resource "aws_msk_configuration" "msk_config" {
  name              = "${var.msk_name}-config"
  server_properties = <<EOF
  auto.create.topics.enable = true
  delete.topic.enable = true
  EOF
}

resource "aws_msk_cluster" "msk" {
  cluster_name           = var.msk_name
  kafka_version          = "3.5.1"
  number_of_broker_nodes = length(module.vpc.aws_private_subnets_id)
  broker_node_group_info {
    instance_type = "kafka.t3.small"
    storage_info {
      ebs_storage_info {
        volume_size = 1000
      }
    }
    client_subnets = module.vpc.aws_private_subnets_id
    security_groups = [aws_security_group.msk.id]
  }
  encryption_info {
    encryption_in_transit {
      client_broker = "PLAINTEXT"
    }
    encryption_at_rest_kms_key_arn = aws_kms_key.msk_kms_key.arn
  }
  configuration_info {
    arn      = aws_msk_configuration.msk_config.arn
    revision = aws_msk_configuration.msk_config.latest_revision
  }
  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = false
      }
      node_exporter {
        enabled_in_broker = false
      }
    }
  }
  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.msk_log_group.name
      }
    }
  }
}

resource "aws_cloudwatch_log_group" "msk_log_group" {
  name = "msk_broker_logs"
}

#Security group for kafka
#########################

resource "aws_security_group" "msk" {
  name   = "${var.msk_name}-dev"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = 0
    to_port     = 9092
    protocol    = "TCP"
    cidr_blocks = module.vpc.aws_private_subnets
  }
  ingress {
    from_port   = 0
    to_port     = 9092
    protocol    = "TCP"
    cidr_blocks = module.vpc.aws_public_subnets
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#SG for bastion host
################################

resource "aws_security_group" "bastion_host" {
  name   = "${var.msk_name}-bastion-host"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}