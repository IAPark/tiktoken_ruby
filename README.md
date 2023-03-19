# tiktoken_ruby

[Tiktoken](https://github.com/openai/tiktoken) is BPE tokenizer from OpenAI used with their GPT models.
This is a wrapper around it aimed primarily at enabling accurate counts of GPT model tokens used. 

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add tiktoken_ruby

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install tiktoken_ruby

## Usage

```ruby
encoding = Tiktoken::Encoding.r50k_base
tokens = encoding.encode("Hello world!")
puts encoding.decode(tokens)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/iapark/tiktoken_ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
