Headstartapp::Marionette - ZMQ connection to puppet master
============================================================

Marionette connects a headstartapp server instance (puppet node) to its 
master and executes puppet runs on demand. Marionette uses fast and lightweight 
0MQ <http://zeromq.org> messaging system.

For more about Headstartapp see <http://headstartapp.com>.

Installation
------------

    gem install marionette

Example
-------

    Ruby:

    require 'marionette'
    # By default, Marionette connects to "tcp://master.headstartapp.com:5555"
    Headstartapp::Marionette::Connect.new.master
    # Connect to a different master
    Headstartapp::Marionette::Connect.new("tcp://master.example.com:5555").master


    CLI (start as a daemon):

    marionette-master start tcp://master.example.com:5555
    marionette-puppet start tcp://master.example.com:5555


Meta
----

Created and Maintained by Dan Lee

Released under the [MIT license](http://www.opensource.org/licenses/mit-license.php).
<http://github.com/headstartapp/marionette>
