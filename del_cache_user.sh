#!/bin/bash
#########################################################################
# James Hipp
# System Support Engineer
# Ready Computing
#
# Bash script to delete a user account from Cache
# Check if user already exists, then delete if needed
#
# For our use case, OS authentication in Cache is enabled
# This script needs to be modified if that is not the case
#
# Usage = del_cache_user.sh <user_id>
# Ex: ./del_cache_user.sh <user_id>
#
#
### CHANGE LOG ###
#
#
#########################################################################

USER_ID=$1

is_cache()
{

   ### Check if Cache is Installed ###

   if [ "`sudo ccontrol list`" ]
   then
      return 0
   else
      echo "Cache is not Installed, exiting..."
      echo ""
      return 1
   fi

}

is_up()
{

   ### Check if Cache Instances are Up ###

   if [ "`sudo ccontrol list |grep down`" ]
   then
      echo "One or More Instances is Down, exiting..."
      echo ""
      return 1
   else
      return 0
   fi

}


cache_user_exists()
{

   ### Check if User Exists in Cache ###

   # Returns True is Cache User DOES NOT Exist

   if is_cache && is_up;
   then

      # Load Instances into an Array, in case we have Multiple
      instances=()
      while IFS= read -r line; do
         instances+=( "$line" )
      done < <( sudo ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

      for i in ${instances[@]};
      do
         output=`sudo su - root -c "echo -e 'w ##class(Security.Users).Exists(\"$USER_ID\")\nh' |csession $i -U %SYS |awk NR==5"`
         if [ $output -eq 1 ]
         then
            echo "User Exists in Cache"
            echo ""
            return 1
         else
            return 0
         fi
      done

   else
      echo "Cache is Not Installed, exiting..."
      echo ""
      return 1
   fi

}

del_user()
{

   if ! cache_user_exists;
   then

      # Load Instances into an Array, in case we have Multiple
      instances=()
      while IFS= read -r line; do
         instances+=( "$line" )
      done < <( sudo ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

      for i in ${instances[@]};
      do
         sudo su - root -c "echo -e 's x=##Class(Security.Users).Delete(\"$USER_ID\")\nh' |csession $i -U %SYS > /dev/null 2>&1"
      done

      echo "Checking if Delete was Successful..."
      echo ""

      if cache_user_exists;
         then
            echo "User Deleted Successfully"
            echo ""
         else
            echo "User was not Deleted Successfully, please check manually"
            echo ""
            return 1
      fi

   else
      echo "User does not exist in Cache, nothing to do..."
      echo ""
   fi

}

main()
{

   ### Main Function for Overall Script ###

   if [ -z "$USER_ID" ]
   then
      echo ""
      echo "No User Role Input - Please run again with a Username Specified"
      echo ""

   else
      echo ""
      echo "Running Delete Cache User Script for Host = `hostname` and Username = $USER_ID"
      echo ""

      del_user

   echo "------"
   echo ""

   fi

}

main

