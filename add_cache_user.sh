#!/bin/bash
#########################################################################
# James Hipp
# System Support Engineer
# Ready Computing
#
# Bash script to add a user OS account to Cache
# Check if user already exists, then add if needed
#
# For our use case, OS authentication in Cache is enabled
# This script needs to be modified if that is not the case
#
# Usage = add_cache_user.sh <user_id>
# Ex: ./add_cache_user.sh <user_id>
#
#
### CHANGE LOG ###
#
#
#########################################################################

USER_ID=$1

os_user_exists()
{

   ### Check if User Exists on the OS ###

   if [ "`getent passwd $USER_ID`" ]
   then
      return 0
   else
      echo "User does not exist in the OS, exiting..."
      echo ""
      return 1
   fi

}

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
         if [ $output -eq  1 ]
         then
            echo "User Exists in Cache"
            echo ""
            return 1
         else
            return 0
         fi
      done

   else
      return 1
   fi

}

add_user()
{

   if os_user_exists && cache_user_exists;
   then

      # Load Instances into an Array, in case we have Multiple
      instances=()
      while IFS= read -r line; do
         instances+=( "$line" )
      done < <( sudo ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

      for i in ${instances[@]};
      do
         sudo su - root -c "echo -e 's x=##Class(Security.Users).Create(\"$USER_ID\",\"%All\",\"CHANGEPASSWORDHERE\",\"$USER_ID\",\"%SYS\")\nh' |csession $i -U %SYS > /dev/null 2>&1"
      done

      echo "Checking if Add was Successful..."
      echo ""

      if ! cache_user_exists;
         then
            echo "User added Successfully"
            echo ""
         else
            echo "User was not added Successfully, please check manually"
            echo ""
            return 1
      fi

   else
      echo "Requirements are not met to add new User, nothing to do..."
      echo ""
   fi

}

main()
{

   ### Main Function for Overall Script ###

   echo ""
   echo "Running Add Cache User Script for Host = `hostname`"
   echo ""
   echo "UserID Provided = $USER_ID"
   echo ""

   #os_user_exists
   #is_cache
   #cache_user_exists
   add_user

   echo "------"
   echo ""

}

main

