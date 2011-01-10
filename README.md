Headstartapp::Marionette - ZMQ connection to puppet master
============================================================

Marionette connects a headstartapp server instance (puppet node) to its 
master and executes puppet runs on demand. Marionette uses fast and lightweight 
0MQ <http://zeromq.org> messaging system.



For more about Headstartapp see <http://headstartapp.com>.


Installation
------------

You must, of course, first install zeromq.  Run the following as root: 

    wget http://download.zeromq.org/zeromq-2.1.0.tar.gz
    tar zxvf zeromq-2.1.0.tar.gz
    cd zeromq-2.1.0
    ./configure
    make
    make install
    ldconfig


If you're using RVM, run this under the system context.
Be sure to have the appropriate port open (for the following example, port 5555) 
on the puppet node.
    
    gem install marionette



Example
-------

The following has been tested on Centos 5.5 running Ruby 1.8.7-p174 and p302.
In this example, puppet and master are on the same local network and the puppet's ip is 192.168.1.1.

Note: By default, Marionette connects to "tcp://127.0.0.1:5555"

Results:

1) on the pupet, /tmp/test.out contains "test #{Time.now}"

2) master.receive returns puppet's facts as a hash.

3) Note: this example does not execute a puppet run. 


    Ruby:

    require 'rubygems'
    require 'marionette'

    puppet = HeadStartApp::Marionette::Connect.new(:uri=>"192.168.1.1:5555) puppet
    master = HeadStartApp::Marionette::Connect.new(:uri=>"192.168.1.1:5555").master
    message = {:run=>{:system=>true,:facter=>true},:system=>{:command=>"echo 'test @ #{Time.now}' > /tmp/test.out"}}
    master.send message
    master.receive



    CLI:

    marionette start tcp://192.168.1.1:5555 # start marionette as a daemon



    MISC:
    # By default, the tcp location will be the connection on eth1 and port 5555
    # The service picks up the tcp location from /etc/marionette.tcp, update if necessary.

    # run as root
    chkconfig marionette on     # start marionette daemon at boot
    service marionette start    # start marionette as a service
    service marionette restart  # restart marionette service
    service marionette stop     # stop marionette service
    


To Do
----

1) Complete implementation for puppet runs.

2) Example of executing a run.

3) Instructions for setting up SSH Tunnel to secure marionette.



Meta
----

Created and Maintained by Dan Lee

Released under the [MIT license](http://www.opensource.org/licenses/mit-license.php).
<http://github.com/headstartapp/marionette>
