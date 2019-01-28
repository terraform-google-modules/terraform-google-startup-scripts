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

# Features

## Configuration of startup-script

This module provides a mechanism to automatically load configuration values for
use by `startup-script-custom`.  Configuration values are automatically sourced
from the metadata key `instance/attributes/startup-script-config`.  This module
follows the `/etc/sysconfig/defaults` model of loading configuration keys and
values.

Set the startup-script-config metadata key to a rendered template:

```bash
# IPIP peer address configuration.
PEER_OUTER_IPADDR='${peer_outer_ipaddr}'
PEER_INNER_IPADDR='${peer_inner_ipaddr}'
MY_INNER_IPADDR='${my_inner_ipaddr}'
# Subnets to route through the IPIP Tunnel to the peer
IPIP_SUBNETS='${ipip_subnets}'
```

Fill in this template in Terraform:

```terraform
data "template_file" "startup_script_config" {
  template = "${file("${path.module}/templates/startup-script-config.tpl")}"
  vars {
    peer_outer_ipaddr = "${var.peer_outer_ipaddr}"
    peer_inner_ipaddr = "${var.peer_inner_ipaddr}"
    my_inner_ipaddr   = "${var.my_inner_ipaddr}"
    ipip_subnets      = "${var.ipip_subnets}"
  }
}
```

These configuration values will be automatically loaded into the environment
when `startup-script-custom` script executes.

# Behavior

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

# Automated Tests

Automated tests are run inside of a docker image.  The initial tests are modeled
as specification tests validating expected behavior.  [bats][bats] is the test
framework run inside the container.

## Spec Tests

### Build the bats container image

Build the image used to validate specification tests.  This command builds an
image with bats installed, suitable for running the tests.

```sh
make docker_build_bats
```

### Validate Behavior Specifications

Validate the expected behavior using the image containing the bats tools.  This
command runs the container and executes bats against each of the test suite
files in `test/spec/`

```sh
make docker_bats
```

Example output:

```txt
1..4
ok 1 STARTUP_SCRIPT_STDLIB_INITIALIZED is initialized to 0
ok 2 E_RUN_OR_DIE error code is 5
ok 3 E_MISSING_MANDATORY_ARG error code is 9
ok 4 E_UNKNOWN_ARG error code is 10
```

[^]: (autogen_docs_start)


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| enable_init_gsutil_crcmod_el | If not false, include stdlib::init_gsutil_crcmod_el() prior to executing startup-script-custom.  Call this function from startup-script-custom to initialize gsutil as per https://cloud.google.com/storage/docs/gsutil/addlhelp/CRC32CandInstallingcrcmod#centos-rhel-and-fedora Intended for CentOS, RHEL and Fedora systems. | string | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| content | startup-script-stdlib.sh content as a string value. |

[^]: (autogen_docs_end)

[metadata_startup_script]: https://www.terraform.io/docs/providers/google/r/compute_instance.html#metadata_startup_script
[bats]: https://github.com/sstephenson/bats
