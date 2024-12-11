if ( [ -f ${HOME}/runtime/DATABASE_UPDATED_FOR_SNAPSHOT ] && [ ! -f ${HOME}/runtime/SOFTWARE_UPDATED_FOR_SNAPSHOT ] )
then
  /bin/touch ${HOME}/runtime/SOFTWARE_UPDATED_FOR_SNAPSHOT


fi
  
