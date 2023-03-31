# frozen_string_literal: true

require "kanal/core/core"
require "kanal/interfaces/telegram/telegram_interface"

core = Kanal::Core::Core.new

interface = Kanal::Interfaces::Telegram::TelegramInterface.new core, "replace-me-with-your-token"

core.add_condition_pack :tg_text do
  add_condition :is do
    with_argument
    met? do |input, _core, argument|
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

interface.start
