# frozen_string_literal: true

require_relative "tiktoken_ruby/version"
require_relative "tiktoken_ruby/encoding"

begin
  RUBY_VERSION =~ /(\d+\.\d+)/
  require_relative "tiktoken_ruby/#{$1}/tiktoken_ruby"
rescue LoadError
  require_relative "tiktoken_ruby/tiktoken_ruby"
end

module Tiktoken
  class << self
    # Returns an encoding by name. If the encoding is not already loaded it will be loaded, but otherwise
    # it will reuse the instance of that type that was previous loaded
    # @param name [Symbol|String] The name of the encoding to load
    # @return [Tiktoken::Encoding] The encoding instance
    # @example Encode and decode text
    #   enc = Tiktoken.get_encoding("cl100k_base")
    #   enc.decode(enc.encode("hello world")) #=> "hello world"
    def get_encoding(name)
      name = name.to_sym
      return nil unless SUPPORTED_ENCODINGS.include?(name)

      Tiktoken::Encoding.for_name_cached(name)
    end

    # Gets the encoding for an OpenAI model
    # @param model_name [Symbol|String] The name of the model to get the encoding for
    # @return [Tiktoken::Encoding] The encoding instance
    # @example Count tokens for text
    #   enc = Tiktoken.encoding_for_model("gpt-4")
    #   enc.encode("hello world").length #=> 2
    def encoding_for_model(model_name)
      PREFIX_MODELS.each do |prefix|
        if model_name.to_s.start_with?("#{prefix}-")
          model_name = prefix
          break
        end
      end

      encoding_name = MODEL_TO_ENCODING_NAME[model_name.to_sym]
      return nil unless encoding_name

      get_encoding(encoding_name)
    end

    # Lists all the encodings that are supported
    # @return [Array<Symbol>] The list of supported encodings
    def list_encoding_names
      SUPPORTED_ENCODINGS
    end

    # Lists all the models that are supported
    # @return [Array<Symbol>] The list of supported models
    def list_model_names
      MODEL_TO_ENCODING_NAME.keys
    end

    private

    SUPPORTED_ENCODINGS = [
      :r50k_base,
      :p50k_base,
      :p50k_edit,
      :cl100k_base
    ]

    # taken from the python library here https://github.com/openai/tiktoken/blob/main/tiktoken/model.py#L13-L53
    # that is also MIT licensed but by OpenAI
    MODEL_TO_ENCODING_NAME = {
      "gpt-4": "cl100k_base",
      "gpt-3.5-turbo": "cl100k_base",
      # text
      "text-davinci-003": "p50k_base",
      "text-davinci-002": "p50k_base",
      "text-davinci-001": "r50k_base",
      "text-curie-001": "r50k_base",
      "text-babbage-001": "r50k_base",
      "text-ada-001": "r50k_base",
      davinci: "r50k_base",
      curie: "r50k_base",
      babbage: "r50k_base",
      ada: "r50k_base",
      # code
      "code-davinci-002": "p50k_base",
      "code-davinci-001": "p50k_base",
      "code-cushman-002": "p50k_base",
      "code-cushman-001": "p50k_base",
      "davinci-codex": "p50k_base",
      "cushman-codex": "p50k_base",
      # edit
      "text-davinci-edit-001": "p50k_edit",
      "code-davinci-edit-001": "p50k_edit",
      # embeddings
      "text-embedding-ada-002": "cl100k_base",
      # old embeddings
      "text-similarity-davinci-001": "r50k_base",
      "text-similarity-curie-001": "r50k_base",
      "text-similarity-babbage-001": "r50k_base",
      "text-similarity-ada-001": "r50k_base",
      "text-search-davinci-doc-001": "r50k_base",
      "text-search-curie-doc-001": "r50k_base",
      "text-search-babbage-doc-001": "r50k_base",
      "text-search-ada-doc-001": "r50k_base",
      "code-search-babbage-code-001": "r50k_base",
      "code-search-ada-code-001": "r50k_base"
    }

    # these are models that have a versioned models that are otherwise identical
    PREFIX_MODELS = ["gpt-4", "gpt-3.5-turbo"]
  end
end
