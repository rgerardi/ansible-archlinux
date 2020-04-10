# ansible-archlinux
Automate ArchLinux install using Ansible

Opinionated ArchLinux installer automation using Ansible and an `install.sh` file.

Use at your own risk.

**Warning**: Careful when running this playbook as it destroy partitions and filesystem if you have permission to do so.

**Warning**: This playbook is intended to be used in a NEW ArchLinux install only.

I created it to automate building VM's with ArchLinux so it may not work on Bare Metal without modification. It will not work on EFI systems as is.

Basic usage:

After booting up ArchLinux install ISO and connecting to the Internet, download the `install.sh` script.

```bash
curl -sO https://raw.githubusercontent.com/rgerardi/ansible-archlinux/master/install.sh
chmod +x install.sh
```

Run the script to install with default options and set the hostname to `newhost01`:

```bash
./install.sh -s newhost01
```

Usage:
```
Usage: install.sh [Options]

Options:
  -s SYSTEM_HOSTNAME    Set new system hostname (default=localhost)
  -c                    Opens an editor allowing variables customization prior to install
  -d                    Do not save configuration files into new system /root directory
  -u REPO_URL           Set repository URL to download playbook and vars file

  -e EXTRA_VARS         Set additional ansible variables as key=value or YAML/JSON
                        i.e. -e enable_swap=no will disable creation of swap partition
                        For a complete list of variables used, check vars.yaml

  -h                    Show this help message and exit
```

## Customizing Options
You can customize options interactively during the install by providing the `-c` flag:
```bash
./install.sh -s newhost01 -c
```

The install script opens the default editor allowing you to customize any variables in the `vars.yaml` file prior to executing the playbook.

You can also override specific variables directly using the `-e` flag. For example, to install with the default options but using the LTS Linux kernel, use:
```bash
./install.sh -s newhost01 -e kernel=linux-lts
```

You can use `-e` as many time as you want. To disable swap in addition to using the LTS kernel, use:
```bash
./install.sh -s newhost01 -e kernel=linux-lts -e enable_swap=no
```
