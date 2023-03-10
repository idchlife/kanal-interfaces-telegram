# frozen_string_literal: true

require_relative "telegram/version"

require "kanal/core/core"
require "kanal/interfaces/telegram/telegram_interface"

module Kanal
  module Interfaces
    module Telegram
      class Error < StandardError; end
      # Your code goes here...
    end
  end
end
