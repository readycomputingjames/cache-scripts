#!/bin/bash
#########################################################################
# James Hipp
# System Support Engineer
# Ready Computing
#
# Bash script to restart all Cache instances at runtime
# Can add other shutdown/startup tasks for Cache if needed
#
# Since this is a restart script, we will assume Cache is installed
#
# Our system OS use-case will be RHEL 7+ (or CentOS 7+)
#
# Usage = cache_restart.sh
# Ex: ./cache_restart.sh
#
#
### CHANGE LOG ###
#
#
#########################################################################

restart_instances()
{

   # Load Instances into an Array, in case we have Multiple
   instances=()
   while IFS= read -r line; do
      instances+=( "$line" )
   done < <( sudo ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

   for i in ${instances[@]};
   do
      sudo ccontrol stop $i quietly restart > /dev/null 2>&1
   done

}

is_up()
{

   # Return False if any Instances show down
   if [ "`sudo ccontrol list |grep down,`" ]
   then
      return 1
   else
      return 0
   fi

}

main()
{

   # Restart Instances
   restart_instances
   
   # Verify
   if is_up;
   then
      sudo su - root -c "logger 'cache_restart.sh: Instances restarted successfully at script runtime'"
      return 0   
   else
      sudo su - root -c "logger 'cache_restart.sh: There was an error restarting, not all instances are showing up'"
      return 1
   fi

}

main

