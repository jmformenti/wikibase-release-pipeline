#/bin/sh

docker-php-ext-install mysqli

mkdir -p /data/project/nobody/
cat << EOF > /data/project/nobody/replica.my.cnf
[client]
user=$DB_USER
password=$DB_PASS
EOF

ln -s /usr/local/bin/php /usr/bin/php

# ensure right log permissions
touch /var/log/quickstatements/tool.log
chown www-data.www-data /var/log/quickstatements/tool.log

exec /entrypoint.sh
