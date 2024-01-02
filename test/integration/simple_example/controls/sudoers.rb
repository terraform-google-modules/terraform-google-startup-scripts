# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'retriable'

control 'simple startup-script-custom' do
  title "With the simple example of startup-script-custom calling stdlib::info and stdlib::cmd"

  describe "gcloud ... get-serial-port-output startup-scripts-example1" do
    # Avoid racing against the instance boot sequence
    before :all do
      Retriable.retriable(tries: 20) do
        get_serial_port_output = "gcloud compute instances get-serial-port-output startup-scripts-example1"
        @cmd = command("#{get_serial_port_output} --project #{attribute('project_id')} --zone #{attribute('region')}-a")
        if not %r{systemd: Startup finished}.match(@cmd.stdout)
          raise StandardError, "Not found: 'systemd: Startup finished' in console output, cannot proceed"
        end
      end
    end

    subject do
      @cmd
    end

    its('exit_status') { should be 0 }
    its('stdout') { should match(%r{Info \[\d+\]: Adding example_user1 to /etc/sudoers}) }
    its('stdout') { should match(%r{Info \[\d+\]: sudoers config valid!}) }
    its('stdout') { should match('startup-script exit status 0') }
  end
end
