# frozen_string_literal: true

class Tiktoken::Encoding 
    def self.method_missing(method)
        Tiktoken::Encoding.new(Tiktoken::BpeFactory.send(method))
    end

    def initialize(ext_base_bpe)
        @ext_base_bpe = ext_base_bpe
    end

    def encode_ordinary(text)
        @ext_base_bpe.encode_ordinary(text)
    end

    def encode(text, allowed_special: [])
        @ext_base_bpe.encode(text, allowed_special)
    end

    def decode(tokens)
        @ext_base_bpe.decode(tokens)
    end
end
