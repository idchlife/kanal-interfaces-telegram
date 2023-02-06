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
              puts "message class: #{message.class}"

              if message.instance_of?(::Telegram::Bot::Types::CallbackQuery)
                input = @core.create_input

                input.tg_callback = message
                input.tg_callback_text = message.data
                input.tg_chat_id = message.from.id
                input.tg_username = message.from.username

                puts input.tg_username
                puts input.tg_chat_id

                output = router.create_output_for_input input

                send_output bot, output
              else
                input = @core.create_input

                if message.text.nil?
                  message.text = "EMPTY TEXT"
                end

                input.tg_message = message
                input.tg_text = message.text
                input.tg_chat_id = message.chat.id
                input.tg_username = message.chat.username || input.tg_message.from.username

                puts input.tg_username
                puts input.tg_chat_id

                if message.photo.count > 0
                  puts message.photo[0].file_id
                  file = bot.api.get_file(file_id: message.photo[2].file_id)
                  file_path = file.dig('result', 'file_path')
                  photo_url = "https://api.telegram.org/file/bot#{@bot_token}/#{file_path}"
                  puts photo_url
                  input.tg_image_link = photo_url
                end

                if message.audio.instance_of?(::Telegram::Bot::Types::Audio)
                  file = bot.api.get_file(file_id: message.audio.file_id)
                  file_path = file.dig('result', 'file_path')
                  audio_url = "https://api.telegram.org/file/bot#{@bot_token}/#{file_path}"
                  puts audio_url
                  input.tg_audio_link = audio_url
                end

                output = router.create_output_for_input input

                send_output bot, output
              end
            end
          end
        end

        private
        def send_output(bot, output)
          bot.api.send_message(
            chat_id: output.tg_chat_id,
            text: output.tg_text,
            reply_markup: output.tg_reply_markup
          )

          image_path = output.tg_image_path

          if !image_path.nil? && File.exist?(image_path)
            bot.api.send_photo(
              chat_id: output.tg_chat_id,
              photo: Faraday::UploadIO.new(output.tg_image_path, guess_mimetype(output.tg_image_path))
            )
          end

          audio_path = output.tg_audio_path

          if !output.tg_audio_path.nil? && File.exist?(audio_path)
            bot.api.send_audio(
              chat_id: output.tg_chat_id,
              audio: Faraday::UploadIO.new(output.tg_audio_path, "audio/mpeg3")
            )
          end
        end

        def guess_mimetype(filename)
          images = {
            "image/jpeg" => %w[jpg jpeg],
            "image/png" => ["png"],
            "image/bmp" => ["bmp"]
          }

          # TODO: rewrite with .find or .each
          for pack in [images] do
            for mime, types in pack do
              for type in types do
                return mime if filename.include? type
              end
            end
          end
        end
      end
    end
  end
end
