# ApplicationCable::Connection
#
# Base class for Action Cable WebSocket connections.
#
# This class handles the initial connection from a client.
# When a client connects, this class is instantiated to handle the connection.
#
# COMMON TASKS TO OVERRIDE:
# 1. Authentication - verify the user is who they claim to be
# 2. Authorization - verify the user can access this connection
# 3. Setup - initialize connection state
#
# USAGE:
#   class Connection < ApplicationCable::Connection
#     identified_by :current_user
#
#     def connect
#       self.current_user = User.find_by(id: session[:user_id])
#       reject_unauthorized_connection unless current_user
#     end
#   end
#
# IDENTIFIED BY:
#   The `identified_by` declaration marks attributes that uniquely identify
#   this connection. These attributes are available in all channel classes
#   via `connection.current_user`, etc.
#
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    # Mark these attributes as connection identifiers
    # These will be available in all channels via `connection.identifier`
    identified_by :connection_id

    # Called when the client initiates a WebSocket connection
    #
    # @example: Simple connection without authentication
    #   def connect
    #     # Assign a unique ID to this connection
    #     self.connection_id = SecureRandom.hex(10)
    #     logger.info "[ActionCable] New connection: #{connection_id}"
    #   end
    #
    # @example: Connection with session-based authentication
    #   def connect
    #     self.current_user = User.find_by(id: cookies.encrypted[:user_id])
    #     reject_unauthorized_connection unless current_user
    #   end
    #
    def connect
      # Simple implementation - just log the connection
      # Override this method to add authentication/authorization
      self.connection_id = SecureRandom.hex(10)
      logger.info "[ActionCable] New connection: #{connection_id}"
    end

    # Called when the connection is closed
    #
    # Use this to clean up resources, notify other systems, etc.
    #
    def disconnect
      logger.info "[ActionCable] Connection closed: #{connection_id}"
      # Clean up any resources here
    end
  end
end
