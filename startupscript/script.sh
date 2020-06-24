#!/bin/bash
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>log.out 2>&1
# Everything below will go to the file 'log.out':
SUSEConnect -r EA18E064F5CBC3A3 -e heloiseboanerges@hotmail.com
SUSEConnect --status
zypper --quiet patch -y --updatestack-only
zypper --non-interactive --quiet patch -y --category security
zypper install -y socat
zypper install -y resource-agents