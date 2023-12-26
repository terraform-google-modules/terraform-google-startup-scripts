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
  project = var.project_id
  region  = var.region
  zone    = "${var.region}-a"
}

module "startup-scripts" {
  source  = "terraform-google-modules/startup-scripts/google"
  version = "~> 2.0"

  enable_get_from_bucket   = true
  enable_setup_init_script = true
}

data "google_compute_image" "os" {
  project = "centos-cloud"
  family  = "centos-7"
}

resource "random_id" "resource_name_suffix" {
  byte_length = 4
}

# Storage bucket used by startup-script-custom and stdlib::get_from_bucket
resource "google_storage_bucket" "example" {
  name          = "startup-scripts-${random_id.resource_name_suffix.hex}"
  location      = var.region
  storage_class = "REGIONAL"
}

resource "google_storage_bucket_object" "message" {
  name    = "message.txt"
  content = var.message
  bucket  = google_storage_bucket.example.name
}

resource "google_storage_bucket_object" "init_script_sample" {
  name    = "init_script_sample"
  content = file("${path.module}/init_scripts/init_script_sample")
  bucket  = google_storage_bucket.example.name
}

data "template_file" "startup-script-custom" {
  template = file("${path.module}/templates/startup-script-custom.tpl")

  vars = {
    bucket             = google_storage_bucket_object.message.bucket
    object             = google_storage_bucket_object.message.name
    content            = google_storage_bucket_object.message.content
    init_script_object = google_storage_bucket_object.init_script_sample.name
  }
}

resource "google_compute_instance" "example" {
  name           = "startup-scripts-gsutil1"
  description    = "Startup Scripts Example"
  machine_type   = "f1-micro"
  can_ip_forward = false

  metadata = {
    startup-script        = module.startup-scripts.content
    startup-script-custom = data.template_file.startup-script-custom.rendered
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  boot_disk {
    auto_delete = true

    initialize_params {
      image = data.google_compute_image.os.self_link
      type  = "pd-standard"
    }
  }

  network_interface {
    network = var.network

    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    email  = var.service_account_email
    scopes = ["storage-ro"]
  }
}

