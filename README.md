Headstartapp::Marionette - ZMQ connection to puppet master
============================================================

Marionette connects a headstartapp server instance (puppet node) to its 
master and executes puppet runs on demand. Marionette uses fast and lightweight 
0MQ <http://zeromq.org> messaging system.

For more about Headstartapp see <http://headstartapp.com>.


Installation
------------

    # If you're using RVM, run this under the system context.
    # Be sure to have the appropriate port open (for the following example, port 5555).
    
    gem install marionette



Example
-------

    # In this example, puppet and master are on the same local network 
    # and the puppet's ip is 192.168.1.1.
    #
    # Note: By default, Marionette connects to "tcp://127.0.0.1:5555"
    #
    # Results:
    # 1) on the pupet, /tmp/headstartapp-marionette-test.out contains "testing 1 2 3"
    # 2) master.receive returns puppet's facts as a hash.
    # 3) Note: this example does not execute a puppet run. 


    Ruby:

    require 'rubygems'
    require 'marionette'

    puppet = HeadStartApp::Marionette::Connect.new(:uri=>"192.168.1.1:5555) puppet
    master = HeadStartApp::Marionette::Connect.new(:uri=>"192.168.1.1:5555").master
    message = {:run=>{:system=>true,:puppet=>false,:facter=>true},:system=>{:command=>"echo 'testing 1 2 3' > /tmp/headstartapp-marionette-test.out"}}
    master.send message
    master.receive



    CLI (start marionette-puppet as a daemon):

    marionette-puppet start tcp://192.168.1.1:5555



Meta
----

Created and Maintained by Dan Lee

Released under the [MIT license](http://www.opensource.org/licenses/mit-license.php).
<http://github.com/headstartapp/marionette>
