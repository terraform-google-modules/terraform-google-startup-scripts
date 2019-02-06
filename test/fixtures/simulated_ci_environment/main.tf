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
  project = "${var.project_id}"
  region  = "${var.region}"
}

locals {
  # roles/storage.admin used by stdlib::get_from_bucket tests.
  required_service_account_project_roles = [
    "roles/compute.instanceAdmin",
    "roles/iam.serviceAccountUser",
    "roles/storage.admin",
  ]
  required_project_services = [
    "cloudresourcemanager.googleapis.com",
    "storage-api.googleapis.com",
    "compute.googleapis.com",
    "oslogin.googleapis.com",
  ]
}

resource "google_project" "startup_scripts" {
  name            = "${var.project_id}"
  project_id      = "${var.project_id}"
  folder_id       = "${var.folder_id}"
  billing_account = "${var.billing_account}"
}

resource "google_project_service" "startup_scripts" {
  project = "${google_project.startup_scripts.id}"
  count   = "${length(local.required_project_services)}"
  service = "${element(local.required_project_services, count.index)}"
}

resource "google_service_account" "startup_scripts" {
  project      = "${google_project.startup_scripts.id}"
  account_id   = "ci-startup-scripts"
  display_name = "ci-startup-scripts"
}

resource "google_project_iam_member" "startup_scripts" {
  depends_on = ["google_project_service.startup_scripts"]
  count      = "${length(local.required_service_account_project_roles)}"
  project    = "${google_project.startup_scripts.id}"
  role       = "${element(local.required_service_account_project_roles, count.index)}"
  member     = "serviceAccount:${google_service_account.startup_scripts.email}"
}

resource "google_service_account_key" "startup_scripts" {
  service_account_id = "${google_service_account.startup_scripts.id}"
}
