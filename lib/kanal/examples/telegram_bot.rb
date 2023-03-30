# frozen_string_literal: true

require "kanal/core/core"
require "kanal/interfaces/telegram/telegram_interface"

module Kanal
  module Interfaces
    module Examples
      module TelegramBot
        core = Kanal::Core::Core.new

        bot = Kanal::Interfaces::Telegram::TelegramInterface.new core, "5896231552:AAHsA_6jRIsiW92IAS-3N_FYTYPVsNsnEFA"

        core.add_condition_pack :tg_text do
          add_condition :is do
            with_argument
            met? do |input, _core, argument| # 3 arguments provided to the block
              input.tg_text == argument
            end
          end
        end

        core.router.configure do
          on :tg_text, is: "foo" do
            respond do
              tg_text "bar"
            end
          end
        end

        core.router.default_response do
          tg_text "Default response"
        end

        bot.start
      end
    end
  end
end
