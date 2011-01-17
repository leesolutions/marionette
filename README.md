Headstartapp::Marionette - ZMQ connection to puppet master
============================================================

Marionette connects a headstartapp server instance (puppet node) to its 
master and executes puppet runs on demand. Marionette uses fast and lightweight 
0MQ <http://zeromq.org> messaging system.

From version 0.0.8 onward, use puppet agent for puppet runs
From version 0.0.7 onward, talk replaces send and receive.
From version 0.0.7 onward, marionette reconnects after n-poll attempts (10 by default).
From version 0.0.6 onward, marionette polls before receives.


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



Ruby:

    require 'rubygems'
    require 'marionette'

    puppet = HeadStartApp::Marionette::Connect.new(:uri=>"192.168.1.1:5555) puppet
    master = HeadStartApp::Marionette::Connect.new(:uri=>"192.168.1.1:5555").master
    message = {:run=>[:system,:facter,:puppet],:system=>{:command=>"echo 'test @ #{Time.now}' > /tmp/test.out"}}
    master.talk messagee

    # Results:
    # 
    # 1) on the pupet, /tmp/test.out contains "test #{Time.now}"
    # 2) returns puppet's facts as a hash.
    # 3) completes a puppet run. 



CLI:

    # To start marionette as a daemon
    marionette start tcp://192.168.1.1:5555

    # To setup marionette as a service
    # pass the tcp address if you don't want to accept the default on eth1.
    marionette-setup
    marionette-setup tcp://192.168.1.1:5555



MISC:
    # By default, the tcp connection is on eth1 over port 5555.
    # Tcp location is read from /etc/marionette.tcp.  Update if necessary.

    # run as root
    chkconfig marionette on     # start marionette daemon at boot
    service marionette start    # start marionette as a service
    service marionette restart  # restart marionette service
    service marionette stop     # stop marionette service
    


To Do
----

1) Instructions for setting up SSH Tunnel to secure marionette.



Meta
----

Created and Maintained by Dan Lee

Released under the [MIT license](http://www.opensource.org/licenses/mit-license.php).
<http://github.com/headstartapp/marionette>
