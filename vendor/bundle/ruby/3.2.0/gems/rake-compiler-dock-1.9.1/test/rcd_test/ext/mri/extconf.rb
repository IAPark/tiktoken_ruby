if RUBY_ENGINE == "jruby"
  File.open("Makefile", "w") do |mf|
    mf.puts "# Dummy makefile for JRuby"
    mf.puts "all install::\n"
  end
else
  require "mkmf"

  include RbConfig

  puts "-"*70
  puts "CONFIG['arch']: #{CONFIG['arch'].inspect}"
  puts "CONFIG['sitearch']: #{CONFIG['sitearch'].inspect}"
  puts "CONFIG['host']: #{CONFIG['host'].inspect}"
  puts "CONFIG['RUBY_SO_NAME']: #{CONFIG['RUBY_SO_NAME'].inspect}"
  puts "RUBY_PLATFORM: #{RUBY_PLATFORM.inspect}"
  puts "Gem::Platform.local.to_s: #{Gem::Platform.local.to_s.inspect}"
  puts "cc --version: #{ %x[#{CONFIG['CC']} --version].lines.first}"
  puts "-"*70

  have_func('rb_thread_call_without_gvl', 'ruby/thread.h') ||
      raise("rb_thread_call_without_gvl() not found")

  if arg_config("--link-static", false)
    # https://github.com/rake-compiler/rake-compiler-dock/issues/69
    puts "Linking with '-static' flag"
    $LDFLAGS << ' -static'
  else
    if RbConfig::CONFIG["target_os"].include?("darwin")
      ## In ruby 3.2, symbol resolution changed on Darwin, to introduce the `-bundle_loader` flag.
      ##
      ## See https://github.com/rake-compiler/rake-compiler-dock/issues/87 for a lot of context, but
      ## I'll try to summarize here.
      ##
      ## > -bundle_loader executable
      ## >   This specifies the executable that will be loading the bundle output file being linked.
      ## >   Undefined symbols from the bundle are checked against the specified executable like it
      ## >   was one of the dynamic libraries the bundle was linked with.
      ##
      ## There are good reasons to do this, including faster initialiation/loading as the Darwin
      ## toolchain gets improved over time.
      ##
      ## Unfortunately, this flag prevents us from building a shared object that works with both a
      ## Ruby compiled with `--enable-shared` and one compiled with `--disabled-shared`. The result
      ## is usually an "Symbol not found" error about `_rb_cObject`, or a "dyld: missing symbol
      ## called" error.
      ##
      ## There are two workarounds that I know of (there may be others I don't know of), and
      ## they are ...

      ## ----------------------------------------
      ## SOLUTION 1, the `-flat_namespace` flag
      ##
      ## > Two-level namespace
      ## >   By default all references resolved to a dynamic library record the library to which
      ## >   they were resolved. At runtime, dyld uses that information to directly resolve symbols.
      ## >   The alternative is to use the -flat_namespace option.  With flat namespace, the library
      ## >   is not recorded.  At runtime, dyld will search each dynamic library in load order when
      ## >   resolving symbols. This is slower, but more like how other operating systems resolve
      ## >   symbols.
      ##
      #
      # puts "Adding '-flat_namespace'"
      # $LDFLAGS << ' -flat_namespace'
      #
      ## This solution unfortunately introduces new behavior that any symbols statically linked into
      ## the shared object (e.g., libxml2 in nokogiri.bundle) may not be resolved locally from the
      ## shared object, but instead resolved from a shared object loaded in the main process.
      ##
      ## This solution might be good for you if:
      ## - you don't statically link things into your bundle,
      ## - or you don't export those symbols,
      ## - or you can avoid exporting those symbols (e.g., by using `-load_hidden`, or
      ##   `-exported_symbols_list` or some other mechanism)
      ##

      ## ----------------------------------------
      ## BUT ... if that is a problem, try SOLUTION 2, remove the `-bundle-loader` flag
      ##
      ## This returns us to the symbol resolution we had in previous Rubies. It feels gross but may
      ## be a workaround for gem maintainers until we all figure out a better way to deal with this.
      #
      # extdldflags = RbConfig::MAKEFILE_CONFIG["EXTDLDFLAGS"].split
      # if found = extdldflags.index("-bundle_loader")
      #   removed_1 = extdldflags.delete_at(found) # flag
      #   removed_2 = extdldflags.delete_at(found) # and its argument
      #   puts "Removing '#{removed_1} #{removed_2}' from EXTDLDFLAGS"
      # end
      # RbConfig::MAKEFILE_CONFIG["EXTDLDFLAGS"] = extdldflags.join(" ")
      #
    end
  end

  create_makefile("rcd_test/rcd_test_ext")

  # exercise the strip command - this approach borrowed from grpc
  strip_tool = RbConfig::CONFIG['STRIP']
  strip_tool += ' -x' if RUBY_PLATFORM =~ /darwin/
  File.open('Makefile.new', 'w') do |o|
    o.puts 'hijack: all strip'
    o.puts
    o.write(File.read('Makefile'))
    o.puts
    o.puts 'strip: $(DLLIB)'
    o.puts "\t$(ECHO) Stripping $(DLLIB)"
    o.puts "\t$(Q) #{strip_tool} $(DLLIB)"
  end
  File.rename('Makefile.new', 'Makefile')
end
