#!/bin/bash -ex

if ! [[ -v FSBUCKET_PROD_HOST  && -v FSBUCKET_PROD_USER && -v FSBUCKET_PROD_PASSWORD ]]; then
  echo "Missing FSBUCKET env vars"
  exit 2
fi

if ! [[ -v DB_PROD_HOST && -v DB_PROD_NAME && -v DB_PROD_USER && -v DB_PROD_PASSWORD && -v DB_PROD_PASSWORD ]]; then
  echo "Missing DB env vars"
  exit 2
fi


# On charge la base depuis celle de prod
mysqldump --column-statistics=0 --no-tablespaces --single-transaction -h $DB_PROD_HOST  -P $DB_PROD_PORT -u $DB_PROD_USER -p$DB_PROD_PASSWORD $DB_PROD_NAME | mysql -h $MYSQL_ADDON_HOST -P $MYSQL_ADDON_PORT -u $MYSQL_ADDON_USER -p$MYSQL_ADDON_PASSWORD $MYSQL_ADDON_DB

# On modifie les urls pour les adapter à la préprod
mysql -h $MYSQL_ADDON_HOST -P $MYSQL_ADDON_PORT -u $MYSQL_ADDON_USER -p$MYSQL_ADDON_PASSWORD $MYSQL_ADDON_DB -e "UPDATE wp_2021_options SET option_value = replace(option_value, 'https://event.afup.org', 'https://event-preprod.afup.org') WHERE option_name = 'home' OR option_name = 'siteurl';"

mysql -h $MYSQL_ADDON_HOST -P $MYSQL_ADDON_PORT -u $MYSQL_ADDON_USER -p$MYSQL_ADDON_PASSWORD $MYSQL_ADDON_DB -e "UPDATE wp_2021_posts SET guid = REPLACE (guid, 'https://event.afup.org', 'https://event-preprod.afup.org');"
mysql -h $MYSQL_ADDON_HOST -P $MYSQL_ADDON_PORT -u $MYSQL_ADDON_USER -p$MYSQL_ADDON_PASSWORD $MYSQL_ADDON_DB -e "UPDATE wp_2021_posts SET guid = REPLACE (guid, 'http://event.afup.org', 'https://event-preprod.afup.org');"

mysql -h $MYSQL_ADDON_HOST -P $MYSQL_ADDON_PORT -u $MYSQL_ADDON_USER -p$MYSQL_ADDON_PASSWORD $MYSQL_ADDON_DB -e "UPDATE wp_2021_postmeta SET meta_value = REPLACE (meta_value, 'https://event.afup.org', 'https://event-preprod.afup.org') WHERE meta_key = '_menu_item_url' ;"

# On copie le bucket de prod vers le dossier de prod
lftp ftp://$FSBUCKET_PROD_USER:$FSBUCKET_PROD_PASSWORD@$FSBUCKET_PROD_HOST -e "mirror / $APP_HOME/resources/uploads/ ; quit"
#  
