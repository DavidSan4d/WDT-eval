terraform {
  backend "s3" {
    bucket = "app3536567"
    key = "terraform.tfstate"
    region = "us-east-1"
    skip_credentials_validation = true
  }
  required_providers {
    cloudops = {
      source  = "fedex.com/5780/cloudops"
      version = "~> 0.1.07"
    }
  }
}

provider "cloudops" {
  client_id = var.client_id
  secret    = var.secret
  issuer    = var.issuer
  host      = var.mf_broker_host
}

resource "cloudops_deployment" "my-deployment" {
  name = var.name
  eai  = "3536567"
  runtime_classification {
    type      = var.type
    locations = var.locations
  }
  nodes {
    instances     = var.instances
    size          = var.size
    cname_pattern = var.cname_pattern
    total_swap_size_gb = var.swap
    os {
      name    = "RedHat Linux"
      version = "7"
      release = "20170801"
    }
    software {
      name    = "Oracle JDK"
      version = "1.8.0"
      release = "automatic"
    }
    software {
      name    = "Weblogic"
      version = "12.2.1.4"
      release = "automatic"
    }
    application_accounts {
      users {
        name         = "iaasascode"
        directory    = "/opt/fedex/iaasascode"
      }
      shell = "bash"
    }
  }
  load_balancing {
    enabled        = true
    route_prefixes = var.lb_route_prefixes
    service_port   = 8001
    probe_port     = 8001
    predictor      = "LeastConnections"
    protocol       = "http"
  }
}
