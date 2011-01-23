module HeadStartApp
  module Marionette

    require 'uri'
  
  
    # Puppet class is the active ZMQ connection on the puppet node
    class Puppet
      attr_accessor :socket, :thread, :message
  
      def initialize(socket)

        @socket = socket
        start
        
      end
      
      # Starts send and response thread
      def start
        
        # Continually pull down requests
        while true do
          pull
        end
        
      end
      
      # Pulls down message from the master and pushes up stats
      def pull
        
        # Stand by for a response msg
        @response = @socket.recv
        
        begin
          
          # Execute a puppet run and/or ad hoc system commands
          @response = Marshal.load(@response)
          puppet_run if @response[:run].include? :puppet
          system_run if @response[:run].include? :system
          facter_run if @response[:run].include? :facter
          
        rescue
          
          # Catch non-hash responses
          @message =  @response
          
        end

        # Sends a response if nil
        @message = "Response from node @ #{Time.now}." if @message.nil?

        # Send back system stats
        # @socket.send Marshal.dump(stats)
        @socket.send Marshal.dump(@message)

      end
      
      # Fetches thread status
      def status
  
        # Returns Thread status
        @thread.status
        
      end
      
      # Stop the pull-loop thread
      def disconnect
        
        # Exit returns the Thread
        # - Note: @thread was never joined
        @thread.exit
        
      end
  
      # Executes ad hoc system command msg'd from the master
      def system_run
  
        @message = `#{@response[:system][:command]}`
  
      end
      
      # Executes a puppet run
      def puppet_run
  
        if @response[:puppet].nil?
          @message = `puppet agent --server master.runrails.com --verbose --waitforcert 5 --no-daemonize --onetime --logdest /var/log/puppet.log`
        else
          @message = `puppet agent #{@response[:puppet][:args]}`
        end
  
      end
      
      # Fetches facts collection
      def facter_run
        
        # Load facts from cli to reduce ruby memory footprint
        facts = {}
        raw = `facter`
        raw.split("\n").each do |line|
          fact = line.split(" => ")
          facts[fact[0].strip.to_sym] = fact[1].strip
        end
        @message = facts

      end
  
    end
    
  end

end
