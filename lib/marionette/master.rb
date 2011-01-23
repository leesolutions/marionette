module HeadStartApp
  module Marionette

    require 'uri'
    require 'ffi-rzmq'
    
    # Master class is the ZMQ socket connection on the puppet master
    # Before calling the talk method set ZMQ::RECOVERY_IVL = 1 to force ZMQ to re-try every 1 second for failed send attempts. 
    class Master
      attr_accessor :socket, :reply
  
      def initialize(uri)
        
        # Set URI and connect to socket
        @uri = uri

      end
      
      def puppet!(poll_till_reply_available = false)
        
        msg = {:run=>[:puppet]}
        talk msg, poll_till_reply_available
        
      end
      
      def facter!(poll_till_reply_available = false)
        
        msg = {:run=>[:facter]}
        talk msg, poll_till_reply_available
        
      end
      
      def run!(cmd, poll_till_reply_available = false)
        
        msg = {:run=>[:system],:system=>{:command=>cmd}}
        talk msg, poll_till_reply_available
        
      end
      
      # Sends a msg to puppet node
      # and stands by for a reply
      # and processes reply
      def talk(msg, poll_till_reply_available = false)
        
        # Initiate send
        # ZMQ's send is asynchronous: send_string will queue the send job in the background
        # and keep trying until the node is available and accepts the message.  
        @socket = socket_connect
        @socket.send_string Marshal.dump(msg), ZMQ::NOBLOCK

        options = {:max => 10, :interval => 100}
        poller = Poller.new @socket, options

        if not poller.pull? and poll_till_reply_available
          
          # Repeat poll till reply receive-able
          while true do
            
            poller = Poller.new @socket, options
            break if poller.pull?

          end

        end

        if poller.pull?

          # Fetch reply
          @reply = process_message(@socket.recv_string)

        else

          # Polled but no reply
          @reply = "Polled #{options[:max]} times every #{options[:interval]} milliseconds but no reply."

        end

      end
      
      private
      
        # Re-connect master to puppet socket
        def close_open_socket
          
          begin
            @socket.close
          rescue
          end
          
        end
        
        def poll?
          @poll
        end
        
        # Connect master to puppet socket
        def socket_connect(uri = @uri)
          
          close_open_socket

          # Set ZMQ context
          context = ZMQ::Context.new(1)
    
          # Set socket to talk to puppet
          socket = context.socket(ZMQ::REQ)
          socket.connect(uri.to_s)
          
          socket
          
        end
        
        # Unserialize if necessary
        def process_message(response)
          
          begin
            
            msg = Marshal.load(response)
            
          rescue
            
            # Catch non-marshal-able response
            msg = response
  
          end
          
        end

        def send_successful

          while true do
  
            # Send the message and catch send failure
            begin
              
              @socket.send_string Marshal.dump(msg), ZMQ::NOBLOCK
    
            rescue
              
            end
          end
          
        end        
        
        class Poller < ZMQ::Poller
          attr_accessor :pull, :reconnect
          
          def initialize(socket, options)
            
            super()
            register_readable socket
            @max = options[:max] if options[:max]
            @interval = options[:interval] ? options[:interval] : 10
            @attempt = 0
            start
            
          end
          
          def pull?
            @pull
          end
          
          def run!

            @attempt+=1
            poll_reply = poll @interval
            key = poll_reply.keys.first # fetch the first and only hash key
            @pull = poll_reply[key][:revents] == 1 # true if revents==1
            @attempt <= @max # true if allowed attempt
            
          end
          
          def start
            
            while run! do
              break if @pull or @reconnect
            end
            
          end
          
        end
        
    end

  end

end