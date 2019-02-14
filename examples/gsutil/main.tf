/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

provider "google" {
  version = "~> 1.20"
  project = "${var.project_id}"
  region  = "${var.region}"
  zone    = "${var.region}-a"
}

module "startup-scripts" {
  source                       = "../../"
  enable_init_gsutil_crcmod_el = true
  enable_get_from_bucket       = true
}

data "google_compute_image" "os" {
  project = "centos-cloud"
  family  = "centos-7"
}

resource "random_id" "resource_name_suffix" {
  byte_length = 4
}

#    webhook_token = "${random_id.startup_scripts_github_webhook_token.hex}"

# Storage bucket used by startup-script-custom and stdlib::get_from_bucket
resource "google_storage_bucket" "example" {
  name          = "startup-scripts-${random_id.resource_name_suffix.hex}"
  location      = "${var.region}"
  storage_class = "REGIONAL"
}

resource "google_storage_bucket_object" "message" {
  name    = "message.txt"
  content = "${var.message}"
  bucket  = "${google_storage_bucket.example.name}"
}

data "template_file" "startup-script-custom" {
  template = "${file("${path.module}/templates/startup-script-custom.tpl")}"
  vars = {
    bucket  = "${google_storage_bucket_object.message.bucket}"
    object  = "${google_storage_bucket_object.message.name}"
    content = "${google_storage_bucket_object.message.content}"
  }
}

resource "google_compute_instance" "example" {
  name           = "startup-scripts-gsutil1"
  description    = "Startup Scripts Example"
  machine_type   = "f1-micro"
  can_ip_forward = false

  metadata {
    startup-script        = "${module.startup-scripts.content}"
    startup-script-custom = "${data.template_file.startup-script-custom.rendered}"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  boot_disk {
    auto_delete = true
    initialize_params {
      image = "${data.google_compute_image.os.self_link}"
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }
}
