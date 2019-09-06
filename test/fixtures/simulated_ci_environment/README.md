# Integration Testing

Use this directory to create resources reflecting the same resource fixtures
created for use by the CI environment CI integration test pipelines.  The intent
of these resources is to run the integration tests locally as closely as
possible to how they will run in the CI system.

Once created, store the service account key content into the
`GOOGLE_CREDENTIALS` environment variable.  This reflects the same behavior as
used in CI.

For example:

```bash
terraform init
terraform apply
terraform output phoogle_sa > ~/.credentials/startup-scripts-sa.json
```

Then, configure the environment (suggest using direnv) like so:

```bash
export GOOGLE_CREDENTIALS_PATH="${HOME}/.credentials/startup-scripts-sa.json"
export GOOGLE_CREDENTIALS="$(<"${GOOGLE_CREDENTIALS_PATH}")"
export TF_VAR_project_id="startup-scripts"
export TF_VAR_region="us-west1"
```

With these variables set, the `make integration_test_run` task should work
locally and execute similar to how CI executes the integration test job.

For example:

[^]: (autogen_docs_start)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| billing\_account | The billing account id associated with the project, e.g. XXXXXX-YYYYYY-ZZZZZZ | string | n/a | yes |
| folder\_id | The numeric folder id to create resources | string | n/a | yes |
| organization\_id | The numeric organization id | string | n/a | yes |
| project\_id | The project_id to deploy the example instance into.  (e.g. "simple-sample-project-1234") | string | n/a | yes |
| region | The region to deploy to | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| service\_account\_private\_key | The SA KEY JSON content.  Store in GOOGLE_CREDENTIALS.  This is equivalent to the `phoogle_sa` output in the infra repository |

[^]: (autogen_docs_end)
