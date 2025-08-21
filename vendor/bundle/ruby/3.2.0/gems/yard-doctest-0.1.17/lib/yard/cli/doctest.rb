module YARD
  module CLI
    class Doctest < Command

      def description
        'Doctests from @example tags'
      end

      #
      # Runs the command line, parsing arguments
      # and generating tests.
      #
      # @param [Array<String>] args Switches are passed to minitest,
      #   everything else is treated as the list of directories/files or glob
      #
      def run(*args)
        files = args.select { |arg| arg !~ /^-/ }

        files = parse_files(files)
        examples = parse_examples(files)

        add_pwd_to_path

        generate_tests(examples)
      end

      private

      def parse_files(globs)
        globs = %w(app lib) if globs.empty?

        files = globs.map do |glob|
          if glob !~ /.rb$/
            glob = "#{glob}/**/*.rb"
          end

          Dir[glob]
        end

        files.flatten
      end

      def parse_examples(files)
        YARD.parse(files, excluded_files)
        registry = Registry.load_all
        registry.all.map { |object| object.tags(:example) }.flatten
      end

      def excluded_files
        excluded = []
        args = YARD::Config.with_yardopts { YARD::Config.arguments.dup }
        args.each_with_index do |arg, i|
          next unless arg == '--exclude'
          excluded << args[i + 1]
        end

        excluded
      end

      def generate_tests(examples)
        examples.each do |example|
          text = example.text

          text = text.gsub('# =>', '#=>')
          text = text.gsub('#=>', "\n#=>")
          lines = text.split("\n").map(&:strip).reject(&:empty?)

          asserts = [].tap do |arr|
            until lines.empty?
              actual = lines.take_while { |l| l !~ /^#=>/ }
              expected = lines[actual.size] || ''
              lines.slice! 0..actual.size

              arr << {
                expected: expected.sub('#=>', '').strip,
                actual: actual.join("\n"),
              }
            end
          end

          spec = YARD::Doctest::Example.new(example.name)
          spec.definition = example.object.path
          spec.filepath = "#{Dir.pwd}/#{example.object.files.first.join(':')}"
          spec.asserts = asserts
          spec.generate
        end
      end

      def add_pwd_to_path
        $LOAD_PATH.unshift(Dir.pwd) unless $LOAD_PATH.include?(Dir.pwd)
      end

    end # Doctest
  end # CLI
end # YARD
