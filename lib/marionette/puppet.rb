module HeadStartApp
  module Marionette

    require 'uri'
    require 'facter'
  
  
    # Puppet class is the active ZMQ connection on the puppet node
    class Puppet
      attr_accessor :socket, :thread, :message
  
      def initialize(socket)

        @socket = socket
        start
        
      end
      
      # Starts send and response thread
      def start
        
        # Kill existing and create new pull-loop thread
        @thread.kill unless @thread.nil?
        Thread.abort_on_exception = true
        @thread = Thread.new do 
          while true do
            pull
          end
        end
        
      end
      
      # Pulls down messages from the master and pushes up stats
      def pull
        
        # Stand by for a response msg
        @response = @socket.recv
        
        # Sets default message to current time
        @message = "Response from node @ #{Time.now}."
        
        begin
          
          # Execute a puppet run and/or ad hoc system commands
          @response = Marshal.load(@response)
          puppet_run if @response[:run][:puppet]
          system_run if @response[:run][:system]
          facter_run if @response[:run][:facter]
          
        rescue
          
          # Catch non-hash responses
          puts @response
          
        end

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
  
        system "#{@response[:system][:command]}"
  
      end
      
      # Executes a puppet run
      def puppet_run
  
        if @response[:puppet].nil?
          system "puppetd --onetime --no-daemonize"
        else
          system "puppetd #{@response[:puppet][:args]}"
        end
  
      end
      
      # Fetches facts collection
      def facter_run
        
        @message = Facter.collection.to_hash
        
      end
  
      # Some stats
      # - to be set up as a fact(s) later
      def stats
  
        stats = {}
        stats[:disk] = `df -h -P` rescue nil
        stats[:network] = `vnstat` rescue nil
        stats[:memory] = `vmstat -a` rescue nil
        stats[:process] = `monit status` rescue nil
        stats[:cpu] = `mpstat -P ALL | awk 'NR>2' | cut -c14-` rescue nil
        stats
  
      end
        
    end
    
  end

end
