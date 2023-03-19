# frozen_string_literal: true

require_relative "tiktoken_ruby/version"
require_relative "tiktoken_ruby/encoding.rb"

begin
  RUBY_VERSION =~ /(\d+\.\d+)/
  require_relative "tiktoken_ruby/#{$1}/tiktoken_ruby"
rescue LoadError
  require_relative "tiktoken_ruby/tiktoken_ruby"
end

module Tiktoken
  class Error < StandardError; end
end
