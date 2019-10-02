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

control 'get_from_bucket with crcmod compilation' do
  title "With enable_init_gsutil_crcmod_el=true and enable_get_from_bucket=true"

  describe 'console output of startup-scripts-gsutil1' do
    # Avoid racing against the instance boot sequence
    before :all do
      Retriable.retriable(tries: 20) do
        get_serial_port_output = "gcloud compute instances get-serial-port-output startup-scripts-gsutil1"
        @cmd = command("#{get_serial_port_output} --project #{attribute('project_id')} --zone #{attribute('region')}-a")
        if not %r{systemd: Startup finished}.match(@cmd.stdout)
          raise StandardError, "Not found: 'systemd: Startup finished' in console output, cannot proceed"
        end
      end
    end

    subject do
      @cmd
    end

    describe "Overall result of startup-script-custom" do
      its('exit_status') { should be 0 }
      its('stdout') { should match('INFO startup-script: Return code 0.') }
    end

    describe "UUID markers from startup-script-custom in the serial output" do
      its('stdout') { should match('TEST UUID E62A3897-AAA0-4577-A564-F00B4B54869B') }
      its('stdout') { should match('Finished with startup-script-custom example 3FF02EC9-BFFE-4B47-BEE7-C98A07818251') }
    end

    describe "gsutil version -l before calling stdlib::init_gsutil_crcmod_el" do
      its('stdout', focus: true) { should match('679EBF864666 compiled crcmod: False') }
    end

    describe "gsutil version -l after calling stdlib::init_gsutil_crcmod_el" do
      its('stdout') { should match('28BBEF21C095 compiled crcmod: True') }
    end

    ##
    # TODO: Move this to another example with no service account bound to the
    # instance.
    # context "when the instance does not have storage.objects.get access to the bucket" do
    #   describe "stdlib::get_from_bucket should retry up to 10 times" do
    #     9.times do |n|
    #       its('stdout') { should match(%r{reported non-zero exit code fetching gs://startup-scripts-\w+/message\.txt.*?Retrying \(#{n+1}/10\)}) }
    #     end
    #   end
    # end

    context "stdlib::get_from_bucket -u gs://<bucket>/message.txt -d /path/to/tmpdir" do
      describe "the content of message.txt fetched using stdlib::get_from_bucket" do
        its('stdout') { should match('EXPECTED: Hello World! uuid=0afce28a-057b-42cf-a90f-493de3c0666b') }
        its('stdout') { should match('ACTUAL: Hello World! uuid=0afce28a-057b-42cf-a90f-493de3c0666b') }
      end
    end

    context "stdlib::setup_init_script -u gs://<bucket>/<file_name> -f <file_name>" do
      describe "checking that the init script is enabled" do
         its('stdout') { should match('ACTUAL: Service enabled status is 1') }
         its('stdout') { should match('EXPECTED: Service enabled status is 1') }
      end
    end

  end
end
