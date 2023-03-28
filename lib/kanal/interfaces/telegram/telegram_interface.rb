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

          @bot = ::Telegram::Bot::Client.new(bot_token)

          @core.register_plugin Kanal::Plugins::Batteries::BatteriesPlugin.new
          @core.register_plugin Kanal::Interfaces::Telegram::Plugins::TelegramIntegrationPlugin.new

        end

        def start
          ::Telegram::Bot::Client.run(@bot_token) do |bot|
            bot.listen do |message|
              puts "message class: #{message.class}"

              input = @core.create_input

              # Inline button pressed
              if message.instance_of?(::Telegram::Bot::Types::CallbackQuery)
                input.tg_button_pressed = message.data
                input.tg_chat_id = message.from.id
                input.tg_username = message.from.username
              else
                # Regular message received
                input.tg_text = message.text
                input.tg_chat_id = message.chat.id
                input.tg_username = message.chat.username || message.from.username

                if message.photo.count > 0
                  # Array of images contains thumbnails, we take 3rd element to get the high-res image
                  input.tg_image_link = get_file_link message.photo[2].file_id
                end

                if message.audio.instance_of?(::Telegram::Bot::Types::Audio)
                  input.tg_audio_link = get_file_link message.audio.file_id
                end

                if message.video.instance_of?(::Telegram::Bot::Types::Video)
                  input.tg_video_link = get_file_link message.video.file_id
                end

                if message.document.instance_of?(::Telegram::Bot::Types::Document)
                  input.tg_video_link = get_file_link message.document.file_id
                end
              end

              router.consume_input input
            end
          end
        end

        def consume_output(output)
          send_output @bot, output
        end

        private
        def get_file_link(file_id)
          file = bot.api.get_file(file_id: file_id)
          file_path = file.dig('result', 'file_path')
          "https://api.telegram.org/file/bot#{@bot_token}/#{file_path}"
        end

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
              audio: Faraday::UploadIO.new(output.tg_audio_path, guess_mimetype(output.tg_audio_path))
            )
          end

          video_path = output.tg_video_path

          if !output.tg_video_path.nil? && File.exist?(video_path)
            bot.api.send_video(
              chat_id: output.tg_chat_id,
              video: Faraday::UploadIO.new(output.tg_video_path, guess_mimetype(output.tg_video_path))
            )
          end

          document_path = output.tg_document_path

          if !output.tg_document_path.nil? && File.exist?(document_path)
            bot.api.send_document(
              chat_id: output.tg_chat_id,
              document: Faraday::UploadIO.new(output.tg_document_path, guess_mimetype(output.tg_document_path))
            )
          end
        end

        def guess_mimetype(filename)
          media_types = [
            images: {
              "image/jpeg" => %w[jpg jpeg],
              "image/png" => ["png"],
              "image/bmp" => ["bmp"]
            },
            audios: {
              "audio/mp3" => ["mp3"],
              "audio/ogg" => ["ogg"],
              "audio/vnd.wave" => ["wav"]
            },
            videos: {
              "video/mp4" => ["mp4"],
              "video/webm" => ["webm"]
            },
            documents: {
              "application/msword" => %w[doc docx],
              "application/pdf" => ["pdf"]
            }
          ]

          media_types.each do |media_type|
            media_type.each do |media_name, variant|
              variant.each do |mime, extensions|
                extensions.each do |extension|
                  return mime if filename.include? extension
                end
              end
            end
          end
        end
      end
    end
  end
end
