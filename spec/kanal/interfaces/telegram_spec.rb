# frozen_string_literal: true

RSpec.describe Kanal::Interfaces::Telegram do
  it "has a version number" do
    expect(Kanal::Interfaces::Telegram::VERSION).not_to be nil
  end
end
