require 'yard'
require 'minitest'
require 'minitest/spec'

require 'yard/cli/doctest'
require 'yard/doctest/example'
require 'yard/doctest/version'

module YARD
  module Doctest
    extend self

    #
    # Configures YARD doctest.
    #
    # @yield [self]
    #
    def configure
      yield self
    end

    #
    # Passed block called before each example
    # or specific tests based on passed name.
    #
    # It is evaluated in the same context as example.
    #
    # @param [String] test
    # @param [Proc] blk
    #
    def before(test = nil, &blk)
      hooks[:before] << {test: test, block: blk}
    end

    #
    # Passed block called after each example
    # or specific tests based on passed name.
    #
    # It is evaluated in the same context as example.
    #
    # @param [String] test
    # @param [Proc] blk
    #
    def after(test = nil, &blk)
      hooks[:after] << {test: test, block: blk}
    end

    #
    # Passed block called after all examples and
    # evaluated in the different context from examples.
    #
    # It actually just sends block to `Minitest.after_run`.
    #
    # @param [Proc] blk
    #
    def after_run(&blk)
      Minitest.after_run &blk
    end

    #
    # Adds definition of test to be skipped.
    #
    # @param [Array<String>] test
    #
    def skip(test)
      skips << test
    end

    #
    # Array of tests to be skipped.
    # @api private
    #
    def skips
      @skips ||= []
    end

    #
    # Returns hash with arrays of before/after hooks.
    # @api private
    #
    def hooks
      @hooks ||= {}.tap do |hash|
        hash[:before], hash[:after] = [], []
      end
    end

  end # Doctest
end # YARD


YARD::CLI::CommandParser.commands[:doctest] = YARD::CLI::Doctest
