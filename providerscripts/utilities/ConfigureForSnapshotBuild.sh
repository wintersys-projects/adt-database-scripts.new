#!/bin/sh

db_prefix="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh DBPREFIX:* | /usr/bin/awk -F':' '{print $NF}'`"

command=""

for table in `${HOME}/providerscripts/utilities/helperscripts/ConnectToLocalMySQL.sh 'show tables LIKE "'${db_prefix}'%";' 'raw'`
do
        command="${command} drop table ${table};"
done

command="${command} drop table zzzz;"

${HOME}/providerscripts/utilities/helperscripts/ConnectToLocalMySQL.sh "${command}"
