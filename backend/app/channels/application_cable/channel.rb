# ApplicationCable::Channel
#
# Base class for all Action Cable channels.
#
# A channel is a logical container for subscriptions. When a client
# subscribes to a channel, they can receive broadcasts sent to that channel.
#
# COMMON TASKS TO OVERRIDE:
# 1. subscribed() - Called when a client subscribes. Stream from a channel.
# 2. unsubscribed() - Called when a client unsubscribes. Clean up.
# 3. receive(data) - Called when a client sends data to the channel.
#
# USAGE:
#   class MyChannel < ApplicationCable::Channel
#     def subscribed
#       stream_from "my_channel_#{params[:id]}"
#     end
#   end
#
# BROADCASTING:
#   To broadcast to all subscribers of a channel:
#   - From a job: MyChannel.broadcast_to(channel, data)
#   - From a channel: ActionCable.server.broadcast(channel, data)
#
# RECEIVING DATA FROM CLIENTS:
#   Clients can send data via cable.send('channel_name', data)
#   This data is received in the `receive` method
#
module ApplicationCable
  class Channel < ActionCable::Channel::Base
    # Called when a client subscribes to this channel
    #
    # Override this method to:
    # 1. Stream from a specific channel identifier
    # 2. Verify the user can access this channel
    # 3. Transmit initial data to the subscriber
    #
    # @example: Stream from a channel based on an ID
    #   def subscribed
    #     stream_from "chat_room_#{params[:room_id]}"
    #   end
    #
    # @example: Stream from a model
    #   def subscribed
    #     stream_for current_user
    #   end
    #
    def subscribed
      # Override in your specific channel class
      # Example: stream_from "some_channel"
    end

    # Called when a client unsubscribes from this channel
    #
    # Override this method to:
    # 1. Stop streaming
    # 2. Clean up resources
    # 3. Notify other subscribers
    #
    # Note: Rails automatically stops streaming when this is called
    #
    def unsubscribed
      # Override to clean up
      # Any streams started in `subscribed` are automatically stopped
    end

    # Called when a client sends data to this channel
    #
    # @param [Hash] data - The data sent by the client
    #
    # @example: Handle a chat message
    #   def receive(data)
    #     ChatMessage.create!(content: data['message'], user: current_user)
    #   end
    #
    def receive(data)
      # Override to handle data from clients
    end

    # Helper method to reject the subscription
    # Use this when authorization fails
    #
    # @example: Reject if user can't access this resource
    #   def subscribed
    #     unless current_user.can_access?(params[:resource_id])
    #       reject
    #       return
    #     end
    #     stream_from "resource_#{params[:resource_id]}"
    #   end
    #
    def reject
      # Rejects the subscription request
      # The connection will receive a reject_subscription message
    end
  end
end
