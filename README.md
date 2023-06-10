# keypea-infra

Infrastructure management for Keypea.

## Requirements

- Python 3.7 or later with `pip`.
- Make

## Quick Start

1. Install all Python and Ansible dependencies on your system run:
   ```
   make bootstrap
   ```
2. Check SSH connectivity to all machines:
   ```
   make ping INVENTORY=production ANSIBLE_USER=<your-username>
   ```
3. Provision/deploy against all machines:
   ```
   make provision INVENTORY=production ANSIBLE_USER=<your-username>
   ```

## Make Targets

### `bootstrap`

The `bootstrap` make target basically runs the following two commands to install
required Python packages and Ansible dependencies:

- `pip install -r requirements.txt`
- `ansible-galaxy install -f -r requirements.yml`

### `ping`

Checks connectivity too all machines that would be provisioned via the
`provision` target. Hence `ping` uses the same exact options as `provision`. It
effectively performs `ansible -m ping all`.

### `provision`

The `provision` make target runs ansible-playbook against the specified
inventory. It also passes in some extra command line flags which are most likely
needed. They are each configured with the following environment variables:

- `INVENTORY` — Used to specify the inventory name to use. Effectively adds
  `-i inventories/$INVENTORY` to the list of Ansible arguments. When this is set
  to `production` the `--ask-become-pass` flag is also passed making Ansible
  prompt for the sudo password on the target machines.
- `ANSIBLE_USER` — The user Ansible will use to establish a SSH connection to
  the target machines. This overrides any `ansible_user` vars specified in
  inventory files directly. This is mostly needed for the `production` inventory
  where each person have their own unique username.
- `TAGS` — When set to a non-empty string `--tag=$TAGS` will be added to the
  list of Ansible arguments.
- `ANSIBLE_ARGS` — Allows specifying additional arguments passed to
  `ansible-playbook`.
- `APT_UPGRADE` — Upgrade packages with `apt-get upgrade` when set to a
  non-empty string.
- `APT_DIST_UPGRADE` — Upgrade packages with `apt-get dist-upgrade` when set to
  a non-empty string.

### Post provisioning

On first run against a specific system, it is generally a good idea to upgrade
system packages.

### `deploy`

The `deploy` make target runs the deploy playbook located to trigger a deployment against
the specified inventory and host group.

- `INVENTORY` - the inventory
- `GROUP` - the group against we run the deployment, for example if we want to deploy only
  the gateway we would run `make deploy INVENTORY=production GROUP=gateway`
