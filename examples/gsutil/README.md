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
 3. `stdlib::setup_init_script`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| message | The content to place in a bucket object message.txt. startup-script-custom fetches this object and validate this message against the content as an end-to-end example of stdlib::get_from_bucket(). | string | `"Hello World! uuid=0afce28a-057b-42cf-a90f-493de3c0666b"` | no |
| network | The network name to deploy to | string | `"default"` | no |
| project\_id | The project_id to deploy the example instance into.  (e.g. "simple-sample-project-1234") | string | n/a | yes |
| region | The region to deploy to | string | n/a | yes |
| service\_account\_email | The service acocunt email to associate with the example instance.  Should have storage.buckets.get to use stdlib::get_from_bucket | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| nat\_ip | Public IP address of the example compute instance. |
| project\_id | The project id used when managing resources. |
| region | The region used when managing resources. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
