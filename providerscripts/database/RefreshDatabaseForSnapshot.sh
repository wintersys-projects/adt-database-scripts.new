#set -x

if ( [ ! -f ${HOME}/runtime/SNAPSHOT_BUILT ] || [ -f ${HOME}/runtime/DATABASE_UPDATED_FOR_SNAPSHOT ] )
then
        exit
fi

${HOME}/providerscripts/utilities/UpdateInfrastructure.sh
        
if ( [ -f ${HOME}/runtime/CREDENTIALS_PRIMED ] )
then
        /bin/rm ${HOME}/runtime/CREDENTIALS_PRIMED
fi

${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh dbp.dat ${HOME}/runtime/dbp.dat
db_prefix="`/bin/cat ${HOME}/runtime/dbp.dat`"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
then
        command=""

        for table in `${HOME}/providerscripts/utilities/helperscripts/ConnectToLocalMySQL.sh 'show tables LIKE "'${db_prefix}'%";' 'raw'`
        do
                command="${command} drop table ${table};"
        done
        command="${command} drop table zzzz;"
        ${HOME}/providerscripts/utilities/helperscripts/ConnectToLocalMySQL.sh "${command}"
        ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "APPLICATION_INSTALLED"
        export BUILD_ARCHIVE_CHOICE="`/bin/ls ${HOME}/runtime/BUILDARCHIVECHOICE:* | /usr/bin/awk -F':' '{print $NF}'`"
        ${HOME}/applicationdb/InstallApplicationDB.sh
fi
/bin/touch ${HOME}/runtime/DATABASE_UPDATED_FOR_SNAPSHOT

