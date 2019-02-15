# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

project_id = attribute('project_id')
region = attribute('region')
zone = "#{region}-a"

control 'enable_init_gsutil_crcmod_el' do
  title "With enable_init_gsutil_crcmod_el=true"

  describe command("gcloud compute instances get-serial-port-output startup-scripts-gsutil1 --project #{project_id} --zone #{zone}") do
    its('exit_status') { should be 0 }
    its('stdout') { should match('TEST UUID E62A3897-AAA0-4577-A564-F00B4B54869B') }
    its('stdout') { should match('compiled crcmod: True') }
    its('stdout') { should match('Finished with startup-script-custom example 3FF02EC9-BFFE-4B47-BEE7-C98A07818251') }
    its('stdout') { should match('INFO startup-script: Return code 0.') }
  end
end
