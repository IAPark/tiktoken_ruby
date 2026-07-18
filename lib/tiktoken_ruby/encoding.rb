# frozen_string_literal: true

class Tiktoken::Encoding
  CACHE_MUTEX = Mutex.new

  attr_reader :name

  # This returns a new Tiktoken::Encoding instance for the requested encoding
  # @param encoding [Symbol] The name of the encoding to load
  # @return [Tiktoken::Encoding] The encoding instance
  def self.for_name(encoding)
    Tiktoken::Encoding.new(Tiktoken::BpeFactory.send(encoding.to_sym), encoding.to_sym)
  end

  # This returns a Tiktoken::Encoding instance for the requested encoding
  # It will reuse an existing encoding if it's already been loaded
  # @param encoding [Symbol] The name of the encoding to load
  # @return [Tiktoken::Encoding] The encoding instance
  def self.for_name_cached(encoding)
    CACHE_MUTEX.synchronize do
      @encodings ||= {}
      @encodings[encoding.to_sym] ||= Tiktoken::Encoding.for_name(encoding)
    end
  end

  # Encodes the text as a list of integer tokens. This encoding will encode special non text tokens
  # basically it's unescaped
  # @param text [String] The text to encode
  # @return [Array<Integer>] The encoded tokens
  def encode_ordinary(text)
    @ext_base_bpe.encode_ordinary(text)
  end

  # Encodes the text as a list of integer tokens. This encoding will treat special non text tokens
  # as text unless they're in the allowed_special array. It's basically like the text was escaped
  # @param text [String] The text to encode
  # @param allowed_special [Array<String>] An array of special tokens to allow
  # @return [Array<Integer>] The encoded tokens
  def encode(text, allowed_special: [])
    @ext_base_bpe.encode(text, allowed_special)
  end

  # Encodes the text as a list of integer tokens, including special tokens.
  # @param text [String] The text to encode
  # @return [Array<Integer>] The encoded tokens
  def encode_with_special_tokens(text)
    @ext_base_bpe.encode_with_special_tokens(text)
  end

  # Decodes the tokens back into text.
  #
  # BPE tokens are byte-level, so a single character (an emoji, non-Latin
  # scripts) can span multiple tokens. Truncating a token array to a limit can
  # therefore leave a prefix that is not valid UTF-8. The +errors+ option
  # controls how those invalid byte sequences are handled:
  #
  # * +:strict+ (default) - raise Tiktoken::UnicodeError on invalid UTF-8.
  # * +:replace+ - substitute each invalid sequence with the Unicode replacement
  #   character (U+FFFD, +�+), matching Python tiktoken's default behavior.
  #
  # @param tokens [Array<Integer>] The tokens to decode
  # @param errors [Symbol] How to handle invalid UTF-8 (:strict or :replace)
  # @return [String] The decoded text (UTF-8)
  def decode(tokens, errors: :strict)
    case errors
    when :strict
      @ext_base_bpe.decode(tokens)
    when :replace
      decode_bytes(tokens).force_encoding(Encoding::UTF_8).scrub("\u{FFFD}")
    else
      raise ArgumentError, "errors must be :strict or :replace, got #{errors.inspect}"
    end
  end

  # Decodes the tokens back into their raw bytes, without any UTF-8 validation.
  #
  # The returned string has ASCII-8BIT (binary) encoding and is not guaranteed
  # to be valid UTF-8 — useful when you want to handle invalid sequences
  # yourself. Matches Python tiktoken's +decode_bytes+.
  #
  # @param tokens [Array<Integer>] The tokens to decode
  # @return [String] The decoded bytes (ASCII-8BIT)
  def decode_bytes(tokens)
    @ext_base_bpe.decode_bytes(tokens)
  end

  private

  def initialize(ext_base_bpe, name)
    @ext_base_bpe = ext_base_bpe
    @name = name
  end
end
