module HeadStartApp
  module Marionette

    require 'uri'
  
  
    # Master class is the ZMQ socket connection on the puppet master
    class Master
      attr_accessor :socket, :reply
  
      def initialize(uri)
  
        require 'ffi-rzmq'
        
        # Set URI and connect to socket
        @uri = uri

      end
      
      # Sends a msg to puppet node
      # and stands by for a reply
      # and processes reply
      def talk(msg)
        
        # Initial connection to socket 
        @socket = socket_connect

        # Repeat until talk succeeds.
        while true do

          # Send the message
          @socket.send_string Marshal.dump(msg)

          # Poll server until it is receive-able and re-poll if necessary
          poller = Poller.new
          break if poller.pull?
          @socket = socket_reconnect
          
        end
        
        @reply = process_message(@socket.recv_string)

      end
      
      private
      
        # Re-connect master to puppet socket
        def socket_reconnect(socket)
          socket.close
          socket_connect
        end
        
        # Connect master to puppet socket
        def socket_connect(uri = @uri)

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
        
        class Poller << ZMQ::Poller
          attr_accessor :pull, :reconnect
          
          def initialize(socket, options)
            
            super
            register_readable socket
            @max = options[:max] if options[:max]
            @attempt = 0
            
          end
          
          def pull?
            @pull
          end
          
          def run!

            @attempt+=1
            poll_reply = poll 500
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
