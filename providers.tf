terraform {
  required_version = ">= 1.5.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.200"
    }
  }
}

provider "yandex" {
  cloud_id  = "b1gqk07fu7d7upt6b4dc"
  folder_id = "b1gf4hkj6jim41tarvvk"
  zone      = "ru-central1-a"
}
