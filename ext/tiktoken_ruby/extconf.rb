# frozen_string_literal: true

require 'mkmf'
require 'rb_sys/mkmf'

# Detect the operating system
os = RbConfig::CONFIG['host_os']

# Custom configurations for OpenBSD and FreeBSD
if os.include?('openbsd') || os.include?('freebsd')
  $CFLAGS << ' -I/usr/local/include'  # Include path for headers
  ENV['RUSTFLAGS'] = '-C link-arg=-lpthread'  # Link with pthread
end

# Custom configurations for Linux
if os.include?('linux')
  $CFLAGS << ' -O2 -Wall'  # Optimization and warnings
  ENV['RUSTFLAGS'] = '-C target-cpu=native'  # CPU-specific optimizations
end

# Custom configurations for macOS (Darwin)
if os.include?('darwin')
  $CFLAGS << ' -O2 -Wall'  # Example C flags
end

# Generate the Makefile
create_rust_makefile('tiktoken_ruby/tiktoken_ruby')
