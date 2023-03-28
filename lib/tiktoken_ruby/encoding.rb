# frozen_string_literal: true

class Tiktoken::Encoding
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
    @encodings ||= {}
    @encodings[encoding.to_sym] ||= Tiktoken::Encoding.for_name(encoding)
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

  # Decodes the tokens back into text
  # @param tokens [Array<Integer>] The tokens to decode
  # @return [String] The decoded text
  def decode(tokens)
    @ext_base_bpe.decode(tokens)
  end

  private

  def initialize(ext_base_bpe, name)
    @ext_base_bpe = ext_base_bpe
    @name = name
  end
end
