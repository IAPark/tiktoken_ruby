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
      end
    end
  end
end
