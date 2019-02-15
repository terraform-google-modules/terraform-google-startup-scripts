#! /bin/bash
#
# This is an example of how stdlib::get_from_bucket behaves.
#
# Check for crcmod
# https://cloud.google.com/storage/docs/gsutil/addlhelp/CRC32CandInstallingcrcmod
stdlib::info 'TEST UUID E62A3897-AAA0-4577-A564-F00B4B54869B'
stdlib::cmd gsutil version -l
# Check the message in the object is the expected content
tmpdir="$$(mktemp -d)"
# This should create a file named `${object}` in the target directory
stdlib::get_from_bucket -u "gs://${bucket}/${object}" -d "$${tmpdir}"
echo 'EXPECTED: ${content}'
echo -n 'ACTUAL: '
cat "$${tmpdir}/${object}"

echo "Finished with startup-script-custom example 3FF02EC9-BFFE-4B47-BEE7-C98A07818251"
