# frozen_string_literal: true

require "kanal/core/core"
require "kanal/interfaces/telegram/telegram_interface"

RSpec.describe Kanal::Interfaces::Telegram::TelegramInterface do
  it "successfully created without errors" do
    core = Kanal::Core::Core.new

    expect do
      Kanal::Interfaces::Telegram::TelegramInterface.new core, "SOME_BOT_TOKEN"
    end.not_to raise_error
  end
end
