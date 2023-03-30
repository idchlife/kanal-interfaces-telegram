# Kanal::Interfaces::Telegram

Welcome to Telegram interface!

Integrate this interface into your Kanal app workflow and it will handle the incoming messages containing plain text or media (images, audio, videos, documents). You can attach media to your responses as well.

Upon receiving a message or callback from end-user, Telegram interface will transform incoming data into standard Kanal input and feed it to router. Router will form an output (or outputs), which will be sent to Telegram interface. Telegram interface will send a message (or messages) to end-user.

It is advised to use telegram interface with Telegram bridge which converts Telegram interface input/output properties to standard Kanal properties.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add kanal-interfaces-telegram

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install kanal-interfaces-telegram

## Usage

1. Create instance of Core:

```core = Kanal::Core::Core.new```
2. Create instance of Telegram interface

```bot = Kanal::Interfaces::Telegram::TelegramInterface.new core, "YOUR_TOKEN"```
3. (Add bridge here???)
4. Configure your Kanal router - add responses for certain conditions (specific cases will be described further)
```
core.router.configure do
    on :contains, text: "Hello" do
        respond do
            body "World!"
        end
    end
    
    #etc...
end
```
5. Start your bot

```bot.start```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/kanal-interfaces-telegram. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/kanal-interfaces-telegram/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Kanal::Interfaces::Telegram project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/kanal-interfaces-telegram/blob/main/CODE_OF_CONDUCT.md).
