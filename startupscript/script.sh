SUSEConnect -r 172906EDC081D889 -e heloiseboanerges@hotmail.com
SUSEConnect --status
zypper --quiet patch -y --updatestack-only
zypper --non-interactive --quiet patch -y --category security
