terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.52.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }
}

data "terraform_remote_state" "gke" {
  backend = "local"

  config = {
    path = "../learn-terraform-provision-gke-cluster-master/terraform.tfstate"
  }
}

# Retrieve GKE cluster information
provider "google" {
  project = data.terraform_remote_state.gke.outputs.project_id
  region  = data.terraform_remote_state.gke.outputs.region
}

# Configure kubernetes provider with Oauth2 access token.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config
# This fetches a new token, which will expire in 1 hour.
data "google_client_config" "default" {}

data "google_container_cluster" "my_cluster" {
  name     = data.terraform_remote_state.gke.outputs.kubernetes_cluster_name
  location = data.terraform_remote_state.gke.outputs.region
}

provider "kubernetes" {
  host = data.terraform_remote_state.gke.outputs.kubernetes_cluster_host

  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate)
}

resource "kubernetes_config_map" "default" {
  metadata {
    name      = "grafana-config"

    labels = {
      app     = "ScalableGrafanaExample"
      version = "1.0.0"
    }

  } 

}
resource "kubernetes_service" "default" {
  metadata {
    name      = "grafana-example"

    labels = {
      app = "ScalableGrafanaExample"
    }
  }

  spec {
    port {
      name        = "3000-tcp"
      port        = "3000"
      target_port = "3000"
      protocol    = "TCP"
    }

    selector = {
      deploymentconfig = "grafana"
    }

    session_affinity = "None"
    type             = "ClusterIP"
  }
}
resource "kubernetes_deployment" "default" {
  metadata {
    name      = "scalable-grafana-example"

    labels = {
      app              = "ScalableGrafanaExample"
    }
  }

  spec {
    selector {
      match_labels = {
        app              = "ScalableGrafanaExample"
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          app              = "ScalableGrafanaExample"
        }
      }

      spec {
        container {
          image = "grafana/grafana:latest"
          name  = "grafana"

          port {
            container_port = "3000"
            protocol       = "TCP"
          }

          resources {
            limits = {
              cpu    = "300m"
              memory = "256Mi"
            }

            requests = {
              cpu    = "150m"
              memory = "256Mi"
            }
          }

          volume_mount {
            mount_path = "/var/lib/grafana"
            name       = "volume-xdtzh"
          }

          volume_mount {
            mount_path = "/etc/grafana/grafana.ini"
            name       = "volume-et7q2"
            sub_path   = "grafana.ini"
          }
        }

        volume {
          name = "volume-xdtzh"

          persistent_volume_claim {
            claim_name = "grafana-persistence-volume"
          }
        }

        volume {
          name = "volume-et7q2"

          config_map {
            default_mode = "0420"

            items {
              key  = "grafana.ini"
              path = "grafana.ini"
            }

            name = "grafana-config"
          }
        }
      }
    }
  }
}
