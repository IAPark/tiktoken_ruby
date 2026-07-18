[![Gem Version](https://badge.fury.io/rb/tiktoken_ruby.svg)](https://badge.fury.io/rb/tiktoken_ruby)

# tiktoken_ruby

[Tiktoken](https://github.com/openai/tiktoken) is BPE tokenizer from OpenAI used with their GPT models.
This is a wrapper around it aimed primarily at enabling accurate counts of GPT model tokens used.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add tiktoken_ruby

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install tiktoken_ruby

## Usage

Encode and decode text:

```ruby
require 'tiktoken_ruby'
enc = Tiktoken.get_encoding("cl100k_base")
enc.decode(enc.encode("hello world")) #=> "hello world"
```

Encoders can also be retrieved by model name:

```ruby
require 'tiktoken_ruby'

enc = Tiktoken.encoding_for_model("gpt-4")
enc.encode("hello world").length #=> 2
```

### Encoding methods

There are three methods for encoding text:

- `encode_ordinary(text)` - Encodes text, always treating special tokens as ordinary text
- `encode(text, allowed_special: [])` - Encodes text, treating special tokens as text unless listed in `allowed_special`
- `encode_with_special_tokens(text)` - Encodes text, recognizing and parsing all special tokens

**Special tokens** are control sequences used by OpenAI models, such as `<|endoftext|>`, `<|fim_prefix|>`, `<|fim_middle|>`, and `<|fim_suffix|>`. The encoding methods differ in how they handle these sequences:

```ruby
enc = Tiktoken.get_encoding("cl100k_base")
text = "Hello<|endoftext|>World"

# encode_ordinary: treats <|endoftext|> as literal characters (9 tokens)
enc.encode_ordinary(text)
#=> [9906, 27, 91, 8862, 728, 428, 91, 29, 10343]

# encode: same as encode_ordinary by default
enc.encode(text)
#=> [9906, 27, 91, 8862, 728, 428, 91, 29, 10343]

# encode with allowed_special: recognizes the specified special token (3 tokens)
enc.encode(text, allowed_special: ["<|endoftext|>"])
#=> [9906, 100257, 10343]

# encode_with_special_tokens: recognizes ALL special tokens (3 tokens)
enc.encode_with_special_tokens(text)
#=> [9906, 100257, 10343]
```

All methods round-trip correctly through `decode`.

### Decoding methods

- `decode(tokens, errors: :strict)` - Decodes tokens back into a UTF-8 string
- `decode_bytes(tokens)` - Decodes tokens into their raw bytes (an `ASCII-8BIT` string), without UTF-8 validation

Because BPE tokens are byte-level, a single character (an emoji, or non-Latin scripts) can span multiple tokens. Truncating a token array (like, "trim text to N tokens") can leave a prefix that is not valid UTF-8. The `errors:` option controls how those invalid sequences are handled.

```ruby
enc = Tiktoken.encoding_for_model("gpt-4o")
tokens = enc.encode("🦄") # the emoji spans multiple tokens

# :strict (default) - raise Tiktoken::UnicodeError on invalid UTF-8
enc.decode(tokens.first(2))                    #=> raises Tiktoken::UnicodeError

# :replace - substitute invalid sequences with "�" (matches Python tiktoken's default)
enc.decode(tokens.first(2), errors: :replace)  #=> "�"

# decode_bytes - get the raw bytes and handle them yourself
enc.decode_bytes(tokens.first(2))              #=> "\xF0\x9F\xA6" (ASCII-8BIT)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

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
