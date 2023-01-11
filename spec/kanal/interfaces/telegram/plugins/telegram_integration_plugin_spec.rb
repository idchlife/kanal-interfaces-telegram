# frozen_string_literal: true

require "kanal/core/core"
require "kanal/plugins/batteries/batteries_plugin"
require "kanal/interfaces/telegram/plugins/telegram_integration_plugin"

class FakeTelegramMessage
  attr_reader :text,
              :chat_id

  def initialize(text: nil, chat_id: nil)
    @text = text
    @chat_id = chat_id
  end
end

RSpec.describe Kanal::Interfaces::Telegram::Plugins::TelegramIntegrationPlugin do
  it "plugin registered successfully" do
    core = Kanal::Core::Core.new

    expect do
      core.register_plugin Kanal::Interfaces::Telegram::Plugins::TelegramIntegrationPlugin.new
    end.not_to raise_error
  end

  it "receives telegram-like input and responds with proper output" do
    core = Kanal::Core::Core.new

    core.register_plugin Kanal::Plugins::Batteries::BatteriesPlugin.new
    core.register_plugin Kanal::Interfaces::Telegram::Plugins::TelegramIntegrationPlugin.new

    core.router.default_response do
      respond do
        body "Default response"
      end
    end

    core.router.configure do
      on :body, starts_with: "First" do
        respond do
          body "Got to first one"
        end
      end
    end

    input = core.create_input
    input.tg_message = FakeTelegramMessage.new text: "First one goes...", chat_id: 34567

    output = core.router.create_output_for_input input

    expect(output.body).to include "Got to first one"
  end
end
