# Startup Script Configuration Example

While in this directory, run `terraform init` then `terraform plan` and
`terraform apply` to boot an instance which executes a custom startup script
within the context of the startup scripts library:

# Usage

## Initialize terraform modules

```bash
terraform init
```

## Target a project.

The Project Factory [Simple Project][simple-project] is sufficient to get
started.

```bash
PROJECT="simple-sample-project-1234"
```

## Terraform plan

Run a plan and save it to a local file.

```bash
terraform plan \
  -var project_id="$PROJECT" \
  -var region=us-west1 \
  -out simple.tfplan
```

Expected output:

```txt
...
Plan: 1 to add, 0 to change, 0 to destroy.
------------------------------------------------------------------------
This plan was saved to: simple.tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "simple.tfplan"
```

## Terraform apply

```bash
terraform apply simple.tfplan
```

Expected output:

```txt
...
google_compute_instance.example: Creation complete after 14s (ID:
startup-scripts-example1)

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

nat_ip = 35.203.161.30
project_id = simple-sample-project-3337
region = us-west1
```

## Startup script output

The results can be seen in the console output of the instance.

```bash
gcloud compute instances get-serial-port-output startup-scripts-example1 \
  | grep 'INFO startup-script'
```

Expected output:

```txt
Dec 19 17:15:14 startup-scripts-example1 startup-script: INFO startup-script: Wed Dec 19 17:15:14 +0000 2018 Info [3102]: Fetching http://ifconfig.co/json
Dec 19 17:15:15 startup-scripts-example1 startup-script: INFO startup-script: {"ip":"35.203.161.30","ip_decimal":600547614,"country":"United States","country_eu":false,"country_iso":"US","city":"Mountain View","hostname":"30.161.203.35.bc.googleusercontent.com","latitude":37.4056,"longitude":-122.0775}
Dec 19 17:15:15 startup-scripts-example1 startup-script: INFO startup-script: Return code 0.
```

## Terraform destroy

The example may be destroyed using:

```bash
terraform destroy -var project_id=$PROJECT -var region=us-west1
```

Expected output:

```txt
...
Destroy complete! Resources: 1 destroyed.
```

## Debug output

Debug output is accessible by running with `DEBUG=1`.  For example:

```txt
[jmccune@startup-scripts-example1 ~]$ sudo DEBUG=1 google_metadata_script_runner --script-type startup --debug
startup-script: INFO Starting startup scripts.
startup-script: INFO Found startup-script in metadata.
startup-script: INFO startup-script: Wed Dec 19 17:24:51 +0000 2018 Debug [3261]: init_startup_stdlib(): startup-script-stdlib.sh initialized and ready
startup-script: INFO startup-script: Wed Dec 19 17:24:51 +0000 2018 Debug [3261]: Loaded startup-script-stdlib as an executable.
startup-script: INFO startup-script: Wed Dec 19 17:24:51 +0000 2018 Debug [3261]: Getting metadata resource url=http://metadata.google.internal/computeMetadata/v1/instance/attributes/startup-script-custom
startup-script: INFO startup-script: Wed Dec 19 17:24:51 +0000 2018 Debug [3261]: BEGIN: stdlib::cmd() command=[curl --location --silent --connect-timeout 1 --fail --output /tmp/tmp.RXaYMWqc4J/tmp.z8YQ4lvsW3 -H Metadata-Flavor: Google http://metadata.google.internal/computeMetadata/v1/instance/attributes/startup-script-custom]
startup-script: INFO startup-script: Wed Dec 19 17:24:51 +0000 2018 Debug [3261]: END: stdlib::cmd() command=[curl --location --silent --connect-timeout 1 --fail --output /tmp/tmp.RXaYMWqc4J/tmp.z8YQ4lvsW3 -H Metadata-Flavor: Google http://metadata.google.internal/computeMetadata/v1/instance/attributes/startup-script-custom] exit_code=0
startup-script: INFO startup-script: Wed Dec 19 17:24:51 +0000 2018 Debug [3261]: === BEGIN instance/attributes/startup-script-custom ===
startup-script: INFO startup-script: Wed Dec 19 17:24:51 +0000 2018 Info [3261]: Fetching http://ifconfig.co/json
startup-script: INFO startup-script: Wed Dec 19 17:24:51 +0000 2018 Debug [3261]: BEGIN: stdlib::cmd() command=[curl --silent http://ifconfig.co/json]
startup-script: INFO startup-script: {"ip":"35.203.161.30","ip_decimal":600547614,"country":"United States","country_eu":false,"country_iso":"US","city":"Mountain View","hostname":"30.161.203.35.bc.googleusercontent.com","latitude":37.4056,"longitude":-122.0775}Wed Dec 19 17:24:51 +0000 2018 Debug [3261]: END: stdlib::cmd() command=[curl --silent http://ifconfig.co/json] exit_code=0
startup-script: INFO startup-script: Wed Dec 19 17:24:51 +0000 2018 Debug [3261]: === END instance/attributes/startup-script-custom ===
startup-script: INFO startup-script: Return code 0.
startup-script: INFO Finished running startup scripts.
```

## Direct Execution

The startup script library may be directly executed outside the context of the
metadata script runner:

```txt
$ curl -H Metadata-Flavor:Google http://metadata.google.internal/computeMetadata/v1/instance/attributes/startup-script \
  > startup.sh
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7268  100  7268    0     0   958k      0 --:--:-- --:--:-- --:--:-- 1013k
```

[^]: (autogen_docs_start)


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| project_id | The project_id to deploy the example instance into.  (e.g. "simple-sample-project-1234") | string | - | yes |
| region | The region to deploy to | string | - | yes |
| url | The url to fetch in the startup script.  This URL is passed via instance metadata to the startup script.  (e.g. ifconfig.co/city) | string | `http://ifconfig.co/json` | no |

## Outputs

| Name | Description |
|------|-------------|
| nat_ip | Public IP address of the example compute instance. |
| project_id |  |
| region |  |

[^]: (autogen_docs_end)

[simple-project]: https://github.com/terraform-google-modules/terraform-google-project-factory/tree/master/examples/simple_project
