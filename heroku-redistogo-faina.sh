#!/bin/sh
# Monitor a RedisToGo instance on Heroku with redis-faina
#
# Usage: heroku-redistogo-faina.sh -n <LINES OF MONITORING> -a <HEROKU APPLICAION>
# Author: @ssaunier

# Default values: 1000 line of monitoring, and heroku app of current folder.
LINES=1000
APP=""

# Parse -a and -n options
while getopts "a:n:" opt; do
  case $opt in
    n)
      LINES=$OPTARG
      ;;
    a)
      APP=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

# Try to figure out if we are in an heroku application folder
INFO=""
if [ -z $APP ]; then
  INFO=`heroku info 2>&1`
  if [ $? -ne 0 ]; then
    echo 'Please provide an heroku app with the -a option';
    exit 1;
  else
    tokens=(`echo "$INFO" | awk '{print $2}'`)
    APP=${tokens[0]}
  fi
fi

# Retrieve info about the heroku app
if [ -z "$INFO" ]; then
  INFO=`heroku info --app $APP 2>&1`
fi

if [ "$INFO" == "${INFO/redistogo/}"  ]; then
  echo "The heroku app \033[0;31m$APP\033[0;0m does not seem to have a Redis To Go addon enabled.";
  echo "Here are the addons installed for this application:"
  heroku addons --app $APP
  exit 1;
fi

# Parse Redis To Go url
REDISTOGO_URL=`heroku config --app $APP | grep REDISTOGO_URL`
PASSWORD_HOST_PORT_RAW=`echo $REDISTOGO_URL | cut -d " " -f 2 | sed -e "s/redis:\/\/redistogo://"`
tokens=(`echo "$PASSWORD_HOST_PORT_RAW" | awk -F'@|:|/' '{print $1 " " $2 " " $3 }'`)
PASSWORD=${tokens[0]}
HOST=${tokens[1]}
PORT=${tokens[2]}

# Actually launch redis-faina command
echo "Parsing \033[0;32m$LINES\033[0;0m lines of redis MONITOR on \033[0;32m$HOST:$PORT\033[0;0m for heroku app \033[0;32m$APP\033[0;0m.\n"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
redis-cli -a $PASSWORD -h $HOST -p $PORT MONITOR | head -n $LINES | $DIR/redis-faina.py
