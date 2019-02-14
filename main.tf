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

locals {
  stdlib_head     = "${file("${path.module}/files/startup-script-stdlib-head.sh")}"
  gsutil_el       = "${var.enable_init_gsutil_crcmod_el ? file("${path.module}/files/init_gsutil_crcmod_el.sh") : ""}"
  get_from_bucket = "${var.enable_get_from_bucket ? file("${path.module}/files/get_from_bucket.sh") : ""}"
  stdlib_body     = "${file("${path.module}/files/startup-script-stdlib-body.sh")}"
  # List representing complete content, to be concatenated together.
  stdlib_list = [
    "${local.stdlib_head}",
    "${local.gsutil_el}",
    "${local.get_from_bucket}",
    "${local.stdlib_body}",
  ]
  # Final content output to the user
  stdlib = "${join("", local.stdlib_list)}"
}
