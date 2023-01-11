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
            core.register_input_parameter :tg_message, readonly: true
            core.register_output_parameter :tg_text
            core.register_output_parameter :tg_reply_markup
          end

          def register_hooks(core)
            core.hooks.attach :input_just_created do |input|
              input.source = :telegram
            end

            core.hooks.attach :input_before_router do |input|
              input.body = input.tg_message.text
            end

            core.hooks.attach :output_before_returned do |input, output|
              output.tg_text = output.body
            end
          end
        end
      end
    end
  end
end
