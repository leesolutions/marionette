module HeadStartApp
  module Marionette

    require 'uri'
    require 'marionette/setup'
    require 'marionette/master'
    require 'marionette/puppet'
  
  
    # PuppetString class establishes a zmq messaging system connection with the puppet master
    # and sends back stats and receives instructions to execute puppet runs or ad hoc system commands.
    class Connect
      attr_accessor :uri, :connection      
  
      def initialize(options = nil)
        
        # Set default(s)
        options = { :uri => `cat /etc/marionette.tcp` } if options.nil?
        
        # Set URI
        @uri = URI(options[:uri])
  
      end
      
      # Connect puppet
      # require 'zmq'
      def puppet
        require 'zmq'

        # Set ZMQ context
        context = ZMQ::Context.new(1)
  
        # Set socket to talk to master
        socket = context.socket(ZMQ::REP)
        socket.bind(@uri.to_s)
        @connection = HeadStartApp::Marionette::Puppet.new(socket)
  
      end
      
      # Connect master
      # require 'ffi-rzmq'
      def master
        require 'ffi-rzmq'

        # Set ZMQ context
        context = ZMQ::Context.new(1)
  
        # Set socket to talk to puppet
        socket = context.socket(ZMQ::REQ)
        socket.connect(@uri.to_s)
        @connection = HeadStartApp::Marionette::Master.new(socket)
  
      end
      
    end
    
  end
        
end
