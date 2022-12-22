# Startup Script Library

This terraform module provides a mechanism to store a library of bash functions
intended for use in startup scripts.  The goal is to have a single place to add
functionality useful by all instances.

Use cases are:

 * Logging functions
 * Debugging functions
 * Functions to execute commands and provide a consistent output format for the
   end user and/or machine parsing via logs.

## Compatibility

This module is meant for use with Terraform 0.13+ and tested using Terraform 1.0+.
If you find incompatibilities using Terraform `>=0.13`, please open an issue.

If you haven't [upgraded][terraform-0.13-upgrade] and need a Terraform
0.12.x-compatible version of this module, the last released version
intended for Terraform 0.12.x is [1.0.0].

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
sudo google_metadata_script_runner startup
```

To enable full debugging, both in the script runner and the startup script
library, set `DEBUG` to a non-zero length string.

```bash
sudo DEBUG=1 google_metadata_script_runner startup --debug
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

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable\_get\_from\_bucket | If not false, include stdlib::get\_from\_bucket() prior to executing startup-script-custom.  Requires gsutil in the PATH.  See also enable\_init\_gsutil\_crcmod\_el feature flag. | `bool` | `false` | no |
| enable\_init\_gsutil\_crcmod\_el | If not false, include stdlib::init\_gsutil\_crcmod\_el() prior to executing startup-script-custom.  Call this function from startup-script-custom to initialize gsutil as per https://cloud.google.com/storage/docs/gsutil/addlhelp/CRC32CandInstallingcrcmod#centos-rhel-and-fedora Intended for CentOS, RHEL and Fedora systems. | `bool` | `false` | no |
| enable\_setup\_init\_script | If not false, include stdlib::setup\_init\_script() prior to executing startup-script-custom.   Call this function to load an init script from GCS into /etc/init.d and initialize it with chkconfig. This function depends on stdlib::get\_from\_bucket, so this function won't be enabled if enable\_get\_from\_bucket is false. | `bool` | `false` | no |
| enable\_setup\_sudoers | If true, include stdlib::setup\_sudoers() prior to executing startup-script-custom. Call this function from startup-script-custom to setup unix usernames in sudoers Comma separated values must be posted to the project metadata key project/attributes/sudoers | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| content | startup-script-stdlib.sh content as a string value. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

[metadata_startup_script]: https://www.terraform.io/docs/providers/google/r/compute_instance.html#metadata_startup_script
[bats]: https://github.com/sstephenson/bats
