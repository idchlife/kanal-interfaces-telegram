# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in kanal-interfaces-telegram.gemspec
gemspec

gem "rake", "~> 13.0"

gem "rspec", "~> 3.0"

gem "kanal", git: "git@github.com:idchlife/kanal.git"

group :development do
  gem "rubocop", "~> 1.21"
  gem "ruby-debug-ide"
  gem "solargraph"
  gem "yard"
end

group :test do
  gem "simplecov", require: false
end
