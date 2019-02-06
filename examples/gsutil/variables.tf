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

variable "project_id" {
  description = "The project_id to deploy the example instance into.  (e.g. \"simple-sample-project-1234\")"
}

variable "region" {
  description = "The region to deploy to"
}

variable "url" {
  description = "The url to fetch in the startup script.  This URL is passed via instance metadata to the startup script.  (e.g. ifconfig.co/city)"
  default     = "http://ifconfig.co/json"
}

variable "message" {
  description = "The content to place in a bucket object message.txt. startup-script-custom fetches this object and validate this message against the content as an end-to-end example of stdlib::get_from_bucket()."
  default     = "Hello World! uuid=0afce28a-057b-42cf-a90f-493de3c0666b"
}
