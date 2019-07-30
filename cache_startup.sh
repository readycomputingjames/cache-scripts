#!/bin/bash
#########################################################################
# James Hipp
# System Support Engineer
# Ready Computing
#
# Bash script to start Cache instances on boot
# Can add other startup tasks for Cache if needed
#
# Since this is a startup script, we will assume Cache is installed
#
# Cache instances do no start automatically on boot
#
# Our system OS use-case will be RHEL 7+ (or CentOS 7+)
#
# Usage = cache_startup.sh
# Ex: ./cache_startup.sh
#
#
### CHANGE LOG ###
#
# 20190725 = Changed log entry in main() from echo to logger
#
#########################################################################

start_instances()
{

   # Load Instances into an Array, in case we have Multiple
   instances=()
   while IFS= read -r line; do
      instances+=( "$line" )
   done < <( sudo ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

   for i in ${instances[@]};
   do
      sudo ccontrol start $i > /dev/null 2>&1
   done

}

is_up()
{

   # Return False if any Instances are Down
   if [ "`sudo ccontrol list |grep down,`" ]
   then
      return 1
   else
      return 0
   fi

}

main()
{

   # Start Instances
   start_instances
   
   # Verify
   if is_up;
   then
      sudo su - root -c "logger 'cache_startup.sh: Instances started successfully at boot time'"
      return 0   
   else
      sudo su - root -c "logger 'cache_startup.sh: There was an error starting up instances at boot time'"
      return 1
   fi

}

main

