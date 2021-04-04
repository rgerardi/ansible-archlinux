#!/bin/bash

# --------------
# Usage
# --------------

function usage() {
    cat << EOF
Usage: $0 [Options]

Options:
  -s SYSTEM_HOSTNAME    Set new system hostname (default=localhost)
  -c                    Opens an editor allowing variables customization prior to install
  -d                    Do not save configuration files into new system /root directory
  -u REPO_URL           Set repository URL to download playbook and vars file

  -e EXTRA_VARS         Set additional ansible variables as key=value or YAML/JSON
                        i.e. -e enable_swap=no will disable creation of swap partition
                        For a complete list of variables used, check vars.yaml

  -h                    Show this help message and exit
EOF
    exit 2
}

## Configure default values
customize=0
system_hostname=localhost
OPTIONS=""
playbook=site.yaml
varsfile=vars.yaml
repo_url=https://raw.githubusercontent.com/rgerardi/ansible-archlinux/master

## Parse options
while getopts ":s:e:u:cd" opt; do
  case ${opt} in
    c )
      customize=1
      ;;
    d )
      OPTIONS="$OPTIONS -e save_config=no"
      ;;
    s )
      system_hostname=$OPTARG
      ;;
    u )
      repo_url=$OPTARG
      ;;
    e )
      OPTIONS="$OPTIONS -e $OPTARG"
      ;;
    * )
      usage
      ;;
  esac
done

mount -o remount,size=768M /run/archiso/cowspace

/usr/bin/pacman -Sy ansible --noconfirm

if [ ! -f ${playbook} ]; then
  /usr/bin/curl -sO ${repo_url}/${playbook}
fi

if [ ! -f ${varsfile} ]; then
  /usr/bin/curl -sO ${repo_url}/${varsfile}
fi

# Add ansible.cfg
cat > ansible.cfg << EOF
[defaults]
inventory=hosts
log_path=./ansible.log
callback_whitelist=timer,profile_tasks,yaml
forks=10
timeout=60
retry_files_enabled=false
stdout_callback=yaml
EOF

# Add inventory files
echo "localhost ansible_connection=local" > ./hosts

if [ "${customize}" -eq 1 ]; then
  ${EDITOR} ${varsfile}
fi

/usr/bin/ansible-playbook ${playbook} -v -e "system_hostname=${system_hostname}" ${OPTIONS}

echo "Rebooting system in 15 sec. Press Ctrl+C to cancel"
sleep 15

/usr/bin/reboot
