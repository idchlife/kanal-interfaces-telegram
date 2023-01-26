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

              puts "message: #{message}"

              if message.instance_of?(::Telegram::Bot::Types::CallbackQuery)
                input = @core.create_input

                input.tg_message = message

                output = router.create_output_for_input input

                bot.api.send_message(
                  chat_id: message.from.id,
                  text: output.tg_text
                )

                # if message.data == 'touch'
                #   bot.api.send_message(chat_id: message.from.id, text: "Don't touch me!")
                # end
              else
                input = @core.create_input

                if message.text.nil?
                  message.text = "EMPTY TEXT"
                end

                input.tg_message = message

                if message.photo.count > 0
                  puts message.photo[0].file_id
                  file = bot.api.get_file(file_id: message.photo[2].file_id)
                  file_path = file.dig('result', 'file_path')
                  photo_url = "https://api.telegram.org/file/bot#{@bot_token}/#{file_path}"
                  puts photo_url
                  input.file_link = photo_url
                end

                if message.audio.instance_of?(::Telegram::Bot::Types::Audio)
                  file = bot.api.get_file(file_id: message.audio.file_id)
                  file_path = file.dig('result', 'file_path')
                  audio_url = "https://api.telegram.org/file/bot#{@bot_token}/#{file_path}"
                  puts audio_url
                  input.file_link = audio_url
                end

                output = router.create_output_for_input input

                bot.api.send_message(
                  chat_id: message.chat.id,
                  text: output.tg_text,
                  reply_markup: output.tg_reply_markup
                )

                unless output.tg_image_path.nil? or output.tg_image_path.empty?
                  bot.api.send_photo(
                    chat_id: message.chat.id,
                    photo: Faraday::UploadIO.new(output.tg_image_path, "image/jpeg")
                  )
                end

                unless output.tg_audio_path.nil? or output.tg_audio_path.empty?
                  bot.api.send_audio(
                    chat_id: message.chat.id,
                    audio: Faraday::UploadIO.new(output.tg_audio_path, "audio/mpeg3")
                  )
                end
              end              
            end
          end
        end
      end
    end
  end
end
