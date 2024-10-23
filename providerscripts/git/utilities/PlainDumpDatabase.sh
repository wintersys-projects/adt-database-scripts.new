#!/bin/sh
##############################################################################################################################
# Description: This script implements database specific dump procedures. If you want to support additional new types of
# database, then, you can add to this file, for example, mongodb or something like that
# Author: Peter Winter
# Date: 28/05/2017
##############################################################################################################################
# License Agreement:
# This file is part of The Agile Deployment Toolkit.
# The Agile Deployment Toolkit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# The Agile Deployment Toolkit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with The Agile Deployment Toolkit.  If not, see <http://www.gnu.org/licenses/>.
#######################################################################################################
#######################################################################################################
#set -x

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    HOST="`${HOME}/providerscripts/utilities/GetIP.sh`"
fi

#The standard troop of SQL databases
if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] )
then    
    /bin/echo "SET SESSION sql_require_primary_key = 0;" > applicationDB.sql
    tries="1"
    /usr/bin/mysqldump --lock-tables=false  --no-tablespaces -y  --port=${DB_PORT} --host=${HOST} -u ${DB_U} -p${DB_P} ${DB_N} >> applicationDB.sql
    while ( [ "$?" != "0"  ] && [ "${tries}" -lt "5" ] )
    do
        /bin/sleep 10
        tries="`/usr/bin/expr ${tries} + 1`"
        /usr/bin/mysqldump --lock-tables=false  --no-tablespaces -y  --port=${DB_PORT} --host=${HOST} -u ${DB_U} -p${DB_P} ${DB_N} >> applicationDB.sql
    done
    
    if ( [ "${tries}" = "5" ] )
    then
        /bin/echo "${0} `/bin/date`: Had trouble makng a backup of your database. Please investigate..." >> ${HOME}/logs/OPERATIONAL_MONITORING.log
        ${HOME}/providerscripts/email/SendEmail.sh "FAILED TO TAKE BACKUP" "I haven't been able to take a database backup, please investigate" "ERROR"
        exit
    fi
    /bin/sed -i '/SESSION.SQL_LOG_BIN/d' applicationDB.sql
    /bin/echo "DROP TABLE IF EXISTS \`zzzz\`;" >> applicationDB.sql
    /bin/echo "CREATE TABLE \`zzzz\` ( \`idxx\` int(10) unsigned NOT NULL, PRIMARY KEY (\`idxx\`) ) Engine=INNODB CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;" >> applicationDB.sql
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
then
    /bin/echo "SET SESSION sql_require_primary_key = 0;" > applicationDB.sql
    tries="1"
    /usr/bin/mysqldump --lock-tables=false --no-tablespaces -y --port=${DB_PORT} --host=${HOST} -u ${DB_U} -p${DB_P} ${DB_N} >> applicationDB.sql
    while ( [ "$?" != "0"  ] && [ "${tries}" -lt "5" ] )
    do
        /bin/sleep 10
        tries="`/usr/bin/expr ${tries} + 1`"
        /usr/bin/mysqldump --lock-tables=false --no-tablespaces -y --port=${DB_PORT} --host=${HOST} -u ${DB_U} -p${DB_P} ${DB_N} >> applicationDB.sql
    done
    
    if ( [ "${tries}" = "5" ] )
    then
        /bin/echo "${0} `/bin/date`: Had trouble makng a backup of your database. Please investigate..." >> ${HOME}/logs/OPERATIONAL_MONITORING.log
        ${HOME}/providerscripts/email/SendEmail.sh "FAILED TO TAKE BACKUP" "I haven't been able to take a database backup, please investigate" "ERROR"
        exit
    fi
    /bin/sed -i '/SESSION.SQL_LOG_BIN/d' applicationDB.sql
    /bin/echo "DROP TABLE IF EXISTS \`zzzz\`;" >> applicationDB.sql
    /bin/echo "CREATE TABLE \`zzzz\` ( \`idxx\` int(10) unsigned NOT NULL, PRIMARY KEY (\`idxx\`) ) Engine=INNODB CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;" >> applicationDB.sql
fi

#The Postgres SQL database
if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
then
    export PGPASSWORD="${DB_P}" && /usr/bin/pg_dump -U ${DB_U} -h ${HOST} -p ${DB_PORT} ${DB_N} > applicationDB.sql
    if ( [ "$?" != "0" ] )
    then
        /usr/bin/sudo -su postgres /usr/bin/pg_dump -h ${HOST} -p ${DB_PORT} -d ${DB_N} > applicationDB.sql
    fi
    /bin/echo "DROP TABLE IF EXISTS public.zzzz;" >> applicationDB.sql
    /bin/echo "CREATE TABLE public.zzzz ( idxx serial PRIMARY KEY );" >> applicationDB.sql
fi
