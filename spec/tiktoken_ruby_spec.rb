# frozen_string_literal: true

RSpec.describe Tiktoken do
  it "has a version number" do
    expect(Tiktoken::VERSION).not_to be nil
  end

  it "can load an encoding" do
    expect(Tiktoken.get_encoding("r50k_base")).to be_a(Tiktoken::Encoding)
  end

  it "can get an encoding for a model" do
    expect(Tiktoken.encoding_for_model("gpt-3.5-turbo")).to be_a(Tiktoken::Encoding)
  end

  it "can get an encoding for a fine-tuned model" do
    expect(Tiktoken.encoding_for_model("ft:gpt-3.5-turbo:org:suffix:abc123")).to be_a(Tiktoken::Encoding)
  end

  it "can get an encoding for a reasoning model" do
    expect(Tiktoken.encoding_for_model("o3")).to be_a(Tiktoken::Encoding)
  end

  it "fails gracefully when getting an encoding for an unknown model" do
    expect(Tiktoken.encoding_for_model("bad-model-name")).to be_nil
  end

  it "lists available encodings" do
    expect(Tiktoken.list_encoding_names).to be_a(Array)
  end

  Tiktoken.list_encoding_names.each do |encoding_name|
    describe "Encoding #{encoding_name}" do
      let(:encoding) { Tiktoken.get_encoding(encoding_name) }
      describe Tiktoken::Encoding do
        it "Can get the encoding" do
          expect(encoding).to be_a(Tiktoken::Encoding)
        end

        it "Tokenizes a string" do
          expect(encoding.encode("Hello world!").size).to be(3)
        end

        it "round trips a string" do
          tokens = encoding.encode("Hello world!")
          expect(encoding.decode(tokens)).to eq("Hello world!")
        end

        it "Encode ordinary tokenizes a string" do
          expect(encoding.encode_ordinary("Hello world!").size).to be(3)
        end

        it "Encode with special tokens tokenizes a string" do
          expect(encoding.encode_with_special_tokens("Hello world!").size).to be(3)
        end

        it "Encode with special tokens round trips a string" do
          tokens = encoding.encode_with_special_tokens("Hello world!")
          expect(encoding.decode(tokens)).to eq("Hello world!")
        end
      end
    end
  end

  describe "special token handling" do
    let(:encoding) { Tiktoken.get_encoding("cl100k_base") }
    let(:text_with_special) { "Hello<|endoftext|>World" }

    it "encode_ordinary treats special tokens as literal text" do
      tokens = encoding.encode_ordinary(text_with_special)
      # <|endoftext|> is tokenized character by character, resulting in more tokens
      expect(tokens.length).to be > 3
      expect(encoding.decode(tokens)).to eq(text_with_special)
    end

    it "encode treats special tokens as literal text by default" do
      tokens = encoding.encode(text_with_special)
      expect(tokens).to eq(encoding.encode_ordinary(text_with_special))
    end

    it "encode recognizes special tokens when in allowed_special" do
      tokens = encoding.encode(text_with_special, allowed_special: ["<|endoftext|>"])
      # <|endoftext|> becomes a single token, resulting in exactly 3 tokens
      expect(tokens.length).to eq(3)
      expect(encoding.decode(tokens)).to eq(text_with_special)
    end

    it "encode_with_special_tokens recognizes all special tokens" do
      tokens = encoding.encode_with_special_tokens(text_with_special)
      # <|endoftext|> becomes a single token, resulting in exactly 3 tokens
      expect(tokens.length).to eq(3)
      expect(tokens).to eq(encoding.encode(text_with_special, allowed_special: ["<|endoftext|>"]))
      expect(encoding.decode(tokens)).to eq(text_with_special)
    end
  end
end
