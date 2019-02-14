#! /bin/bash
#
# This is an example of how stdlib::get_from_bucket behaves.
#
# Check for crcmod
# https://cloud.google.com/storage/docs/gsutil/addlhelp/CRC32CandInstallingcrcmod
stdlib::cmd gsutil version -l
# Check the message in the object is the expected content
tmpdir="$$(mktemp -d)"
# This should create a file named `${object}` in the target directory
stdlib::get_from_bucket -u "gs://${bucket}/${object}" -d "$${tmpdir}"
echo 'EXPECTED: ${content}'
echo -n 'ACTUAL: '
cat "$${tmpdir}/${object}"

echo "Finished with startup-script-custom example"
