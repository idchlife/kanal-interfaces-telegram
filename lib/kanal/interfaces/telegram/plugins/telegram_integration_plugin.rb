# frozen_string_literal: true

module Kanal
  module Interfaces
    module Telegram
      module Plugins
        # This class registers properties and hooks for telegram bot library integration
        class TelegramIntegrationPlugin < Kanal::Core::Plugins::Plugin
          def name
            :telegram_properties
          end

          def setup(core)
            register_parameters core
            register_hooks core
          end

          def register_parameters(core)
            core.register_input_parameter :tg_chat_id, readonly: true
            core.register_input_parameter :tg_username, readonly: true
            core.register_input_parameter :tg_text, readonly: true
            core.register_input_parameter :tg_button_pressed, readonly: true
            core.register_input_parameter :tg_image_link, readonly: true
            core.register_input_parameter :tg_audio_link, readonly: true
            core.register_input_parameter :tg_video_link, readonly: true
            core.register_input_parameter :tg_document_link, readonly: true

            core.register_output_parameter :tg_chat_id
            core.register_output_parameter :tg_text
            core.register_output_parameter :tg_image_path
            core.register_output_parameter :tg_audio_path
            core.register_output_parameter :tg_video_path
            core.register_output_parameter :tg_document_path
            core.register_output_parameter :tg_reply_markup
          end

          def register_hooks(core)
            core.hooks.attach :input_just_created do |input|
              input.source = :telegram
            end

            core.hooks.attach :output_before_returned do |input, output|
              output.tg_chat_id = input.tg_chat_id if output.tg_chat_id.nil?
            end
          end
        end
      end
    end
  end
end
