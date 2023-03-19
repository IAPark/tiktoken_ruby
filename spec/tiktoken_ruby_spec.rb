# frozen_string_literal: true

RSpec.describe Tiktoken do
  it "has a version number" do
    expect(Tiktoken::VERSION).not_to be nil
  end

  describe Tiktoken::Encoding do
    it "Returns a core BPE instance" do
      expect(described_class.r50k_base).to be_a(Tiktoken::Encoding)
    end

    it "Tokenizes a string" do
      expect(described_class.r50k_base.encode("Hello world!").size).to be(3)
    end

    it "round trips a string" do
      tokens = described_class.r50k_base.encode("Hello world!")
      expect(described_class.r50k_base.decode(tokens)).to eq("Hello world!")
    end

    it "Encode ordinary tokenizes a string" do
      expect(described_class.r50k_base.encode_ordinary("Hello world!").size).to be(3)
    end
  end
end
