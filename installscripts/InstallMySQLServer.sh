apt update
apt install -y curl
curl -O https://repo.percona.com/apt/percona-release_latest.generic_all.deb
apt install -y gnupg2 lsb-release ./percona-release_latest.generic_all.deb
apt update
percona-release setup ps80
percona-release enable ps-80 release
apt update
apt install -y -qq percona-server-server
