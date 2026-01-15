# ApplicationCable is the base module for all Action Cable channels and connections.
#
# This file provides the base classes that all your channels should inherit from.
# It allows for shared configuration and authentication logic across channels.
#
# Files needed:
# - app/channels/application_cable/connection.rb (base for WebSocket connections)
# - app/channels/application_cable/channel.rb (base for channel logic)
#

module ApplicationCable
  # Base class for Action Cable connections
  #
  # This class handles the initial WebSocket connection from a client.
  # You can override methods here to implement authentication, logging, etc.
  #
  # Example: Authenticate the connection using the session
  #   def connect
  #     self.current_user = find_verified_user
  #     reject_unauthorized_connection unless current_user
  #   end
  #
  class Connection < ActionCable::Connection::Base
    # Called when a client establishes a WebSocket connection
    #
    # Override this method to:
    # - Authenticate users
    # - Set up shared state
    # - Reject unauthorized connections
    #
    identified_by :current_user

    # Example authentication (uncomment to use):
    # protected
    #
    # def find_verified_user
    #   if session[:user_id]
    #     User.find_by(id: session[:user_id])
    #   else
    #     reject_unauthorized_connection
    #   end
    # end

    # def session
    #   # Access the Rails session from the WebSocket connection
    #   cookies.encrypted[Rails.application.config.session_options[:key]]
    # end
  end

  # Base class for all channels
  #
  # Channels are the logical containers for subscriptions.
  # When a client subscribes to a channel, they receive broadcasts from it.
  #
  # You can override this class to:
  # - Add authorization checks
  # - Set up shared helpers
  # - Handle common channel logic
  #
  class Channel < ActionCable::Channel::Base
    # Called when a client subscribes to this channel
    #
    # Override to:
    # - Verify the client can access this channel
    # - Set up channel-specific state
    # - Transmit initial data
    #
    # Example:
    #   def subscribed
    #     stream_from "some_channel_#{params[:id]}"
    #   end
  end
end
