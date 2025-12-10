# frozen_string_literal: true

RSpec.describe "GVL release safety" do
  let(:encoding) { Tiktoken.get_encoding("cl100k_base") }
  let(:text) { "Hello world! " * 1000 }

  it "survives GC stress during encode_ordinary" do
    GC.stress = true
    begin
      result = encoding.encode_ordinary(text)
      expect(encoding.decode(result)).to eq(text)
    ensure
      GC.stress = false
    end
  end

  it "survives GC stress during encode" do
    GC.stress = true
    begin
      result = encoding.encode(text)
      expect(encoding.decode(result)).to eq(text)
    ensure
      GC.stress = false
    end
  end

  it "survives GC stress during decode" do
    tokens = encoding.encode(text)
    GC.stress = true
    begin
      result = encoding.decode(tokens)
      expect(result).to eq(text)
    ensure
      GC.stress = false
    end
  end

  it "survives concurrent GC stress with multiple threads" do
    GC.stress = true
    threads = 4.times.map do
      Thread.new do
        10.times do
          local_enc = Tiktoken.get_encoding("cl100k_base")
          tokens = local_enc.encode_ordinary(text)
          local_enc.decode(tokens)
        end
      end
    end
    begin
      threads.each(&:join)
    ensure
      GC.stress = false
    end
  end

  it "encoder survives after intermediate objects are GC'd" do
    tokens = nil
    10.times do
      encoding.encode_ordinary("temp string " * 100)
      tokens = encoding.encode_ordinary(text) if tokens.nil?
      GC.start(full_mark: true, immediate_sweep: true)
    end
    expect(encoding.decode(tokens)).to eq(text)
  end

  it "survives GC stress during encode_with_special_tokens" do
    GC.stress = true
    begin
      result = encoding.encode_with_special_tokens(text)
      expect(encoding.decode(result)).to eq(text)
    ensure
      GC.stress = false
    end
  end

  it "survives concurrent GC stress with shared encoder across threads" do
    GC.stress = true
    shared_enc = Tiktoken.get_encoding("cl100k_base")
    threads = 4.times.map do
      Thread.new do
        10.times do
          tokens = shared_enc.encode_ordinary(text)
          shared_enc.decode(tokens)
        end
      end
    end
    begin
      threads.each(&:join)
    ensure
      GC.stress = false
    end
  end
end
