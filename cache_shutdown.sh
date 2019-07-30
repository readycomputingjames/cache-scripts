#!/bin/bash
#########################################################################
# James Hipp
# System Support Engineer
# Ready Computing
#
# Bash script to stop all Cache instances at runtime
# Can add other shutdown tasks for Cache if needed
#
# Since this is a shutdown script, we will assume Cache is installed
#
# Our system OS use-case will be RHEL 7+ (or CentOS 7+)
#
# Usage = cache_shutdown.sh
# Ex: ./cache_shutdown.sh
#
#
### CHANGE LOG ###
#
#
#########################################################################

stop_instances()
{

   # Load Instances into an Array, in case we have Multiple
   instances=()
   while IFS= read -r line; do
      instances+=( "$line" )
   done < <( sudo ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

   for i in ${instances[@]};
   do
      sudo ccontrol stop $i quietly > /dev/null 2>&1
   done

}

is_down()
{

   # Return False if any Instances show Running
   if [ "`sudo ccontrol list |grep running,`" ]
   then
      return 1
   else
      return 0
   fi

}

main()
{

   # Stop Instances
   stop_instances
   
   # Verify
   if is_down;
   then
      sudo su - root -c "logger 'cache_shutdown.sh: Instances stopped successfully at script runtime'"
      return 0   
   else
      sudo su - root -c "logger 'cache_shutdown.sh: There was an error stopping, not all instances are showing down'"
      return 1
   fi

}

main

