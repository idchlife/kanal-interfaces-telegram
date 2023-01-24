# frozen_string_literal: true

require "kanal/core/interfaces/interface"
require "kanal/plugins/batteries/batteries_plugin"
require_relative "./plugins/telegram_integration_plugin"

require "telegram/bot"

module Kanal
  module Interfaces
    module Telegram
      # This interface helps working with telegram
      class TelegramInterface < Kanal::Core::Interfaces::Interface
        def initialize(core, bot_token)
          super(core)

          @bot_token = bot_token

          @core.register_plugin Kanal::Plugins::Batteries::BatteriesPlugin.new
          @core.register_plugin Kanal::Interfaces::Telegram::Plugins::TelegramIntegrationPlugin.new
        end

        def start
          ::Telegram::Bot::Client.run(@bot_token) do |bot|
            bot.listen do |message|
              input = @core.create_input

              input.tg_message = message

              output = router.create_output_for_input input

              bot.api.send_message(
                chat_id: message.chat.id,
                text: output.tg_text,
                reply_markup: output.tg_reply_markup
              )
            end
          end
        end
      end
    end
  end
end
