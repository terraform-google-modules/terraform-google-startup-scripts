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

  describe command("gcloud compute instances list --project #{project_id}") do
    its('exit_status') { should be 0 }
    its('stderr') { should eq '' }
    its('stdout') { should match(/startup-scripts-example.*RUNNING/) }
  end

  describe command("gcloud compute instances get-serial-port-output startup-scripts-example1 --project #{project_id} --zone #{zone}") do
    its('exit_status') { should be 0 }
    its('stderr') { should match(%r{Specify --start=\d+ in the next get-serial-port-output invocation to get only the new output starting from here})}
    its('stdout') { should match(%r{Info \[\d+\]: Fetching http://ifconfig\.co/json}) }
    its('stdout') { should match('INFO startup-script: Return code 0.') }
  end
end
