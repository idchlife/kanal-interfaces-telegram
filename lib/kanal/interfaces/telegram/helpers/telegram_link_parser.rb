# frozen_string_literal: true

module Kanal
  module Interfaces
    module Telegram
      module Helpers
        class TelegramLinkParser
          def get_file_link(file_id, bot, bot_token)
            file = bot.api.get_file(file_id: file_id)
            file_path = file.dig('result', 'file_path')
            "https://api.telegram.org/file/bot#{bot_token}/#{file_path}"
          end
        end
      end
    end
  end
end
