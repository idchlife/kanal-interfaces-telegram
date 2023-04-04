# frozen_string_literal: true

require "kanal/core/core"
require "kanal/interfaces/telegram/telegram_interface"

class FromOrChat
  attr_reader :id, :username

  def initialize
    @id = "some_id"
    @username = "some_username"
  end
end

class DummyAttachment
  attr_reader :file_id

  def initialize(id)
    @file_id = id
  end
end

class DummyMessage

  attr_reader :chat, :from, :photo, :audio, :video, :document, :attributes

  def initialize
    @from = FromOrChat.new
    @chat = FromOrChat.new
    @photo = [DummyAttachment.new("photo1"), DummyAttachment.new("photo2"), DummyAttachment.new("photo3")]
    @audio = DummyAttachment.new("audio")
    @video = DummyAttachment.new("video")
    @document = DummyAttachment.new("document")
    @attributes = {}
  end
end

class DummyTextMessage < DummyMessage
  def initialize
    super
    @attributes[:text] = "message_text"
  end

  def text
    @attributes[:text]
  end
end

class DummyButtonMessage < DummyMessage
  def initialize
    super
    @attributes[:data] = "button_text"
  end

  def data
    @attributes[:data]
  end
end

class DummyLinkParser
  def get_file_link(file_id, bot, bot_token)
    "https://somelink.with/file/id/#{file_id}"
  end
end

class InterfaceWithDummyParser < Kanal::Interfaces::Telegram::TelegramInterface
  def initialize(core, bot_token)
    super
    @link_parser = DummyLinkParser.new
  end
end

RSpec.describe Kanal::Interfaces::Telegram::TelegramInterface do
  it "successfully created without errors" do
    core = Kanal::Core::Core.new

    expect do
      Kanal::Interfaces::Telegram::TelegramInterface.new core, "SOME_BOT_TOKEN"
    end.not_to raise_error
  end

  it "creates input from message" do
    core = Kanal::Core::Core.new

    interface = InterfaceWithDummyParser.new core, "SOME_BOT_TOKEN"

    text_message = DummyTextMessage.new
    text_input = interface.create_input text_message
    expect(text_input.tg_text).to eq "message_text"
    expect(text_input.tg_chat_id).to eq "some_id"
    expect(text_input.tg_username).to eq "some_username"
    expect(text_input.tg_image_link).to eq "https://somelink.with/file/id/photo3"
    expect(text_input.tg_audio_link).to eq "https://somelink.with/file/id/audio"
    expect(text_input.tg_video_link).to eq "https://somelink.with/file/id/video"
    expect(text_input.tg_document_link).to eq "https://somelink.with/file/id/document"

    button_pressed = DummyButtonMessage.new
    button_input = interface.create_input button_pressed
    expect(button_input.tg_button_pressed).to eq "button_text"
    expect(button_input.tg_chat_id).to eq "some_id"
    expect(button_input.tg_username).to eq "some_username"
  end
end
