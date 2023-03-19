# frozen_string_literal: true

require_relative "tiktoken_ruby/version"
require_relative "tiktoken_ruby/encoding.rb"
require_relative "tiktoken_ruby/tiktoken_ruby"

module Tiktoken
  class Error < StandardError; end
end
