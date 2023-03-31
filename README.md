# Kanal::Interfaces::Telegram

Welcome to Telegram interface!

Integrate this interface into your Kanal app workflow and it will handle the incoming messages containing plain text or media (images, audio, videos, documents). You can attach media to your responses as well.

This interface relies on telegram-bot-ruby wrapper (https://github.com/atipugin/telegram-bot-ruby) to handle the actual communication with Telegram API.

Upon receiving a message or callback from end-user through telegram-bot-ruby, Telegram interface will transform incoming data into Kanal input with specific Telegram properties and feed it to router. Router will form an output (or outputs), which will be sent to Telegram interface. Telegram interface will send a message (or messages) through telegram-bot-ruby wrapper to end-user.

It is advised to use Telegram interface with Telegram bridge which converts specific input/output properties to standard Kanal properties.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add kanal-interfaces-telegram

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install kanal-interfaces-telegram

## Usage

1. Create instance of Core:

```core = Kanal::Core::Core.new```

2. Create instance of Telegram interface

```interface = Kanal::Interfaces::Telegram::TelegramInterface.new core, "YOUR_TOKEN"```

3. You can use https://github.com/idchlife/kanal-plugins-batteries_bridge to convert Telegram interface specific properties to Kanal Batteries plugin properties. Batteries plugin properties are using generally known keywords such as :body, :image, :audio etc. More info you can get inside batteries bridge plugin repository

```core.register_plugin Kanal::Plugins::Batteries::BatteriesPlugin.new```

4. Add your condition packs (or use conditions provided by Batteries plugin)

```
# Conditions need to be coded for usage in routing
core.add_condition_pack :tg_text do
    add_condition :is do
        with_argument
        met? do |input, _core, argument| # 3 arguments provided to the block
            input.tg_text == argument
        end
    end
end

core.router.configure do
    # Response for condition created above
    on :tg_text, is: "foo" do
        respond do
            tg_text "bar"
        end
    end
end

core.router.default_response do
    tg_text "Default response"
end
```

5. Start your bot

```interface.start```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/kanal-interfaces-telegram. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/kanal-interfaces-telegram/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Kanal::Interfaces::Telegram project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/kanal-interfaces-telegram/blob/main/CODE_OF_CONDUCT.md).
