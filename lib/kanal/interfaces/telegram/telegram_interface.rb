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
              input.tg_text = message.text
              input.tg_chat_id = message.chat.id
              input.tg_username = message.try(:chat).try(:username) || input.tg_message.try(:from).try(:username)

              output = router.create_output_for_input input

              bot.api.send_message(
                chat_id: output.tg_chat_id,
                text: output.tg_text,
                reply_markup: output.tg_reply_markup
              )

              image_path = output.tg_image_path

              if image_path && File.exist?(image_path)
                bot.api.send_photo(
                  chat_id: message.chat.id,
                  photo: Faraday::UploadIO.new(image_path, guess_mimetype(image_path))
                )
              end
            end
          end
        end

        private

        def guess_mimetype(filename)
          images = {
            "image/jpeg" => %w[jpg jpeg],
            "image/png" => ["png"],
            "image/bmp" => ["bmp"]
          }

          # TODO: rewrite with .find or .each
          for mime, types in [images] do
            for type in types do
              return mime if filename.include? type
            end
          end

          "application/octet-stream"
        end
      end
    end
  end
end
