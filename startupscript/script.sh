SUSEConnect -r 632B0F54D50200 -e heloise.sanmiguel@myclouddoor.com
SUSEConnect --status
zypper --quiet patch -y --updatestack-only
zypper --non-interactive --quiet patch -y --category security