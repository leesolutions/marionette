module HeadStartApp
  module Marionette

    require 'uri'
  
  
    # Master class is the ZMQ socket connection on the puppet master
    class Master
      attr_accessor :socket, :threads
  
      def initialize(socket)
  
        # Set socket
        @socket = socket
  
      end
  
      # Sends a msg to puppet node
      def send(msg)
  
        # Send and Receive
        @socket.send_string Marshal.dump(msg)

      end
      
      # Stands by for the next msg from puppet
      # Processes and returns response 
      def receive
        
        # Stand by for a response
        begin
          
          response = socket.recv_string
          @response = Marshal.load(response)
          
        rescue
          
          # Catch non-marshal-able response
          @response = response

        end
        
        @response
          
      end
      
    end

  end

end
