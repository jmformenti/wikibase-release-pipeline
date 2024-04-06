#/bin/sh

printconf() {
cat <<-EOF
    [client]
    user=root
    password=$MYSQL_ROOT_PASSWORD
EOF
}

DB_NAME=${DB_USER}__quickstatements_auth

mysql --defaults-extra-file=<(printconf) <<EOF
  CREATE DATABASE ${DB_NAME};
  CREATE USER ${DB_USER}@'%' IDENTIFIED BY '${DB_PASS}';
  GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO ${DB_USER}@'%';
  FLUSH PRIVILEGES;

  USE ${DB_NAME};

  CREATE TABLE user (
    id int(11) unsigned NOT NULL AUTO_INCREMENT,
    name varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
    api_hash varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
    PRIMARY KEY (id),
    KEY name (name(191))
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

  CREATE TABLE batch_oauth (
    id int(11) unsigned NOT NULL AUTO_INCREMENT,
    batch_id int(11) NOT NULL,
    serialized mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
    serialized_json mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
    PRIMARY KEY (id),
    KEY batch_id (batch_id)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

EOF

echo "done."
