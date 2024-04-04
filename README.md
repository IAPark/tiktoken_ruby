[![Gem Version](https://badge.fury.io/rb/tiktoken_ruby.svg)](https://badge.fury.io/rb/tiktoken_ruby)

# tiktoken_ruby

[Tiktoken](https://github.com/openai/tiktoken) is BPE tokenizer from OpenAI used with their GPT models.
This is a wrapper around it aimed primarily at enabling accurate counts of GPT model tokens used.

## Request for maintainers

I can't really put substantial time into maintaining this. Probably nothing more than a couple hours every few months. If you have experience maintaining ruby gems and would like to
lend a hand please send me an email or reply to this [issue](https://github.com/IAPark/tiktoken_ruby/issues/26)

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add tiktoken_ruby

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install tiktoken_ruby

## Usage

Usage should be very similar to the python library. Here's a simple example

Encode and decode text

```ruby
require 'tiktoken_ruby'
enc = Tiktoken.get_encoding("cl100k_base")
enc.decode(enc.encode("hello world")) #=> "hello world"
```

Encoders can also be retrieved by model name

```ruby
require 'tiktoken_ruby'

enc = Tiktoken.encoding_for_model("gpt-4")
enc.encode("hello world").length #=> 2
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/iapark/tiktoken_ruby.

To get started with development:

```sh
git clone https://github.com/IAPark/tiktoken_ruby.git
cd tiktoken_ruby
bundle install
bundle exec rake compile
bundle exec rake spec
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
