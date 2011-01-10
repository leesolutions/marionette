require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'

namespace :marionette do

  # task description
  desc 'Set up marionette as a service (run this as sudo/root)'
  
  # define task:
  # 1) write to init.d/marionette
  # 2) set permissions
  # 3) set ifconfig
  # 4) start service
  task :service do

    file '/etc/rc.d/init.d/marionette', <<-CODE
#!/bin/bash

### BEGIN INIT INFO
# Provides: marionette
# Default-Start:  2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: start and stop marionette
# Description: 0mq connection for puppet and master.
### END INIT INFO

# source function library
. /etc/rc.d/init.d/functions

RETVAL=0
prog="marionette"

set -e

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DESC="marionette daemon"
NAME=marionette
DAEMON=/usr/local/bin/$NAME
PIDFILE=/var/run/$NAME.pid
LOGFILE=/var/log/$NAME.log
SCRIPTNAME=/etc/init.d/$NAME
IP=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
TCP=tcp://$IP:5555

# Gracefully exit if the package has been removed.
# test -x $DAEMON || exit 0

d_start() {
  $DAEMON start $TCP || echo -en "\n already running"
}

d_stop() {
  kill -9 `cat $PIDFILE` || echo -en "\n not running"
}

case "$1" in
  start)
    echo -n "Starting $DESC: $NAME"
    d_start
        echo "."
  ;;
  stop)
    echo -n "Stopping $DESC: $NAME"
    d_stop
        echo "."
  ;;
  restart)
    echo -n "Restarting $DESC: $NAME"
    d_stop
    sleep 5
    d_start
    echo "."
  ;;
  *)
    echo "Usage: $SCRIPTNAME {start|stop|restart}" >&2
    exit 3
  ;;
esac

exit 0
CODE

    system "chmod 755 /etc/init.d/marionette"
    system "chkconfig marionette on"
    system "service marionette start"
  end
  
  # set "service" as the default task
  task :default => 'marionette:service'

end

