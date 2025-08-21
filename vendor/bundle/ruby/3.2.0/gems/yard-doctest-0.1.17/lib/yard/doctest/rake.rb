require 'rake'
require 'rake/tasklib'

module YARD
  module Doctest
    class RakeTask < ::Rake::TaskLib

      # @return [String] the name of the task
      attr_accessor :name

      # @return [Array<String>] options to pass to test runner
      attr_accessor :doctest_opts

      # @return [String] list of files/dirs separated with space or glob
      attr_accessor :pattern

      def initialize(name = 'yard:doctest')
        @name = name
        @doctest_opts = []
        @pattern = ''

        yield self if block_given?

        define
      end

      protected

      def define
        desc 'Run YARD doctests'
        task(name) do
          command = "yard doctest #{(doctest_opts << pattern).join(' ')}"
          exit system(command)
        end
      end

    end # RakeTask
  end # Doctest
end # YARD
