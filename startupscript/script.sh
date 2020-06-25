SUSEConnect -r EA18E064F5CBC3A3 -e heloiseboanerges@hotmail.com
SUSEConnect --status
zypper --quiet patch -y --updatestack-only
zypper --non-interactive --quiet patch -y --category security

sh ./script-config.sh