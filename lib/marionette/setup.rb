module HeadStartApp
  module Marionette

    # Setup method configures the server for running marionette as a service at boot up.
    def setup(options={})

      # Set default(s)
      ip = `sudo /sbin/ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
      options = { :uri => "tcp://#{ip}:5555" } if options.nil?

      # Set up marionette as a service to start at boot.
      # define task:
      # 1) write to init.d/marionette
      # 2) set permissions
      # 3) set ifconfig
      # 4) start service
    
    
      script = <<CODE
#!/bin/bash

### BEGIN INIT INFO
# Provides: marionette
# Default-Start:  2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: start and stop marionette
# Description: 0mq connection for puppet and master.
# chkconfig:   - 85 15 
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
TCPFILE=/etc/marionette.tcp
SCRIPTNAME=/etc/init.d/$NAME
TCP=`cat $TCPFILE`

# Gracefully exit if the package has been removed.
# test -x $DAEMON || exit 0
echo "connecting on $TCP..."

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
  
      file = File.open('/etc/marionette.tcp','w')
      file.write ip
      file.close
      
      file = File.open('/etc/init.d/marionette','w')
      file.write script
      file.close
      
      system "sudo chmod 755 /etc/init.d/marionette"

    end
  end

end
