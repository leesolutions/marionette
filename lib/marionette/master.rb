module HeadStartApp
  module Marionette

    require 'uri'
    require 'ffi-rzmq'
  
    # Master class is the ZMQ socket connection on the puppet master
    class Master
      attr_accessor :socket, :reply
  
      def initialize(uri)
        
        # Set URI and connect to socket
        @uri = uri

      end
      
      # Sends a msg to puppet node
      # and stands by for a reply
      # and processes reply
      def talk(msg, send_guarantee = false, poll_guarantee = false)
        
        # @replies = []
        # 
        # # Fetch queued message first
        # begin
        #   
        #   @socket = socket_connect
        #   @replies << process_message(@socket.recv_string)
        #   
        # rescue
        # end

        # Initiate send
        begin
          
          # if send successful start polling
          @socket = socket_connect
          @socket.send_string Marshal.dump(msg), ZMQ::NOBLOCK
          @poll = true
          
        rescue
          
          puts "*****RESCUE******"
          
          if send_guarantee
            
            # Keep sending till successful
            while true do
              
              begin
              
                @socket = socket_connect
                @socket.send_string Marshal.dump(msg), ZMQ::NOBLOCK
                @poll = true
                break
              
              rescue
                
                puts "*****inner RESCUE******"
                
                # sleep half a second before next attempt
                sleep 500
              
              end

            end
  
          else
            
            # don't poll if send failed and no guarantee 
            @poll = false
            
          end
          
        end

        if poll?
          
          options = {:max => 10, :interval => 500}
          poller = Poller.new @socket, options

          if not poller.pull? and poll_guarantee
            
            # Repeat poll till reply receive-able
            while true do
              
              @socket = socket_reconnect(@socket)
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

        else
          
          # Send failed
          @reply = "Send failed!"

        end
        
      end
      
      private
      
        # Re-connect master to puppet socket
        def socket_reconnect(socket)
          
          socket.close
          socket_connect
          
        end
        
        def poll?
          @poll
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
