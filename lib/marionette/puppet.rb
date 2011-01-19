module HeadStartApp
  module Marionette

    require 'uri'
  
  
    # Puppet class is the active ZMQ connection on the puppet node
    class Puppet
      attr_accessor :socket, :thread, :message
  
      def initialize(socket)

        @socket = socket
        @messages = []
        start
        
      end
      
      # Starts send and response thread
      def start
        
        # Continually pull down requests
        while true do
          pull
        end
        
      end
      
      # Pulls down messages from the master and pushes up stats
      def pull
        
        # Stand by for a response msg
        @response = @socket.recv
        
        # Sets default message to current time
        @message << "Response from node @ #{Time.now}."
        
        begin
          
          # Execute a puppet run and/or ad hoc system commands
          @response = Marshal.load(@response)
          puppet_run if @response[:run].include? :puppet
          system_run if @response[:run].include? :system
          facter_run if @response[:run].include? :facter
          
        rescue
          
          # Catch non-hash responses
          puts @response
          
        end

        # Send back system stats
        # @socket.send Marshal.dump(stats)
        @socket.send Marshal.dump(@messages)

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
  
        @message << `#{@response[:system][:command]}`
  
      end
      
      # Executes a puppet run
      def puppet_run
  
        if @response[:puppet].nil?
          @message << `puppet agent --server master.runrails.com --verbose --waitforcert 5 --no-daemonize --onetime --logdest /var/log/puppet.log`
        else
          @message << `puppet agent #{@response[:puppet][:args]}`
        end
  
      end
      
      # Fetches facts collection
      def facter_run
        
        # Load facts from cli to reduce ruby memory footprint
        facts = `facter`
        facts = facts.split "\n"
        facts.collect! {|f| ff=f.split("=>"); {ff[0].strip.to_sym => ff[1]}}.compact
        @message << facts

      end
  
    end
    
  end

end
