variable "repositoryName" {
  type    = string
}
variable "repositoryTag" {
  type    = string
  default = "1.0"
}
variable "registryName" {
  type    = string
}
variable "registryUsername" {
  type    = string
}
variable "registryPassword" {
  type    = string
}

packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "ubuntu" {
  image  = "ubuntu:22.04"
  commit = true
    changes = [
      "WORKDIR /azp",
      "ENV TARGETARCH=linux-x64",
      "ENTRYPOINT ./start.sh $AZP_STARTUP"
    ]
}

build {
  name    = "devopsagent"
  sources = ["source.docker.ubuntu"]

  provisioner "shell" {
    inline          = ["apt-get update", "apt-get upgrade -y"]
  }

  provisioner "shell" {
    scripts          = ["${path.root}/scripts/install-base-packages.sh"]
  }

  provisioner "shell" {
    inline          = ["curl -sL https://aka.ms/InstallAzureCLIDeb | bash"]
  }

  provisioner "file" {
    destination = "/azp"
    source      = "${path.root}/files"
  }
  post-processors {
    post-processor "docker-tag" {
        repository =  "${var.registryName}/${var.repositoryName}"
        tags = ["${var.repositoryTag}"]
      }
    post-processor "docker-push" {
      login = true
      login_server = "${var.registryName}"
      login_username = "${var.registryUsername}"
      login_password = "${var.registryPassword}"
    }
  }
}