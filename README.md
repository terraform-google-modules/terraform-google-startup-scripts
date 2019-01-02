# Startup Script Library

This terraform module provides a mechanism to store a library of bash functions
intended for use in startup scripts.  The goal is to have a single place to add
functionality useful by all instances.

Use cases are:

 * Logging functions
 * Debugging functions
 * Functions to execute commands and provide a consistent output format for the
   end user and/or machine parsing via logs.

# Usage

The library is loaded as the startup script of an instance.  It initializes and
passes control to the metadata key startup-script-custom. Control is passed
using bash's `source` mechanism so that all functions provided by the library are
available.

Add the following to your Terraform module.  Update the tag as necessary.

```terraform
module "startup-script-lib" {
  source = "git::https://github.com/terraform-google-modules/terraform-google-startup-scripts.git?ref=v0.1.0"
}
```

When managing a compute instance, your module is responsible for passing the
library of functions as a string values of the startup-script metadata key. Your
module may also pass configuration via the startup-script-config metadata key.
Inject the library into the compute instance by reading the output content like
so:

```terraform
resource "google_compute_instance" "example" {
  # other attributes removed
  metadata {
    startup-script        = "${module.startup-script-lib.content}"
    startup-script-custom = "stdlib::info Hello World"
  }
}
```

## Updating vs Deleting instances

Note the use of of the `compute_instance` `metadata` attribute causes existing
instances to be updated in place when values change.  In contrast, the use of
the `metadata_startup_script` attribute causes Terraform to delete and re-create
the instance as per the [compute_instance
metadata_startup_script][metadata_startup_script] documentation.

## Re-run startup scripts

It can be helpful to re-run custom startup scripts by logging into the instance
and running.

```bash
sudo google_metadata_script_runner --script-type startup
```

To enable full debugging, both in the script runner and the startup script
library, set `DEBUG` to a non-zero length string.

```bash
sudo DEBUG=1 google_metadata_script_runner --script-type startup --debug
```

## Configuration

The behavior of the startup scripts library is governed by environment
variables.  Feature flags are enabled by setting the environment variable to a
non-zero length value.  Logs are sent to syslog and standard error by default.

| Variable              | Default          | Description                   |
| --------              | -------          | -----------                   |
| DEBUG                 | unset            | Log debug messages if set.    |
| QUIET                 | unset            | Silence log messages if set.  |
| COLOR                 | unset            | Colored logs if set.          |
| DATE_FMT              |                  | Log `date +<format>`.         |
| SYSLOG_DEBUG_PRIORITY | syslog.debug     | `logger -p <value>`           |
| SYSLOG_INFO_PRIORITY  | syslog.info      | `logger -p <value>`           |
| SYSLOG_ERROR_PRIORITY | syslog.error     | `logger -p <value>`           |
| VARDIR                | /var/lib/startup | Durable alternative to TMPDIR |

[^]: (autogen_docs_start)


## Outputs

| Name | Description |
|------|-------------|
| content | startup-script-stdlib.sh content as a string value. |

[^]: (autogen_docs_end)

[metadata_startup_script]: https://www.terraform.io/docs/providers/google/r/compute_instance.html#metadata_startup_script
