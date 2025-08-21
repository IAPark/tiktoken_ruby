begin
  RUBY_VERSION =~ /(\d+\.\d+)/
  require "rcd_test/#{$1}/rcd_test_ext"
rescue LoadError
  require 'rcd_test/rcd_test_ext'
end
