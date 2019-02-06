# Startup Script gsutil functionality

While in this directory, run `terraform init` then `terraform plan` and
`terraform apply` to boot an instance which executes a custom startup script
within the context of the startup scripts library.

See the [Simple Example](/examples/simple_example/README.md) for detailed
general instructions.

This example demonstrates the use of the feature flags to include the following
functions:

 1. `stdlib::init_gsutil_crcmod_el`
 2. `stdlib::get_from_bucket`

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
