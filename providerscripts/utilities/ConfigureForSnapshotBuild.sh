#!/bin/sh

if ( [ -f ${HOME}/runtime/DATABASE_READY ] && [ ! -f ${HOME}/runtime/SNAPSHOT_PRIMED ] )
then
        if ( [ -f ${HOME}/runtime/CREDENTIALS_PRIMED ] )
        then
                /bin/rm ${HOME}/runtime/CREDENTIALS_PRIMED
        fi
        if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
        then
                db_prefix="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh DBPREFIX:* | /usr/bin/awk -F':' '{print $NF}'`"
                command=""

                for table in `${HOME}/providerscripts/utilities/helperscripts/ConnectToLocalMySQL.sh 'show tables LIKE "'${db_prefix}'%";' 'raw'`
                do
                        command="${command} drop table ${table};"
                done

                command="${command} drop table zzzz;"
                ${HOME}/providerscripts/utilities/helperscripts/ConnectToLocalMySQL.sh "${command}"
                ${HOME}/applicationdb/InstallApplicationDB.sh
        fi
fi
