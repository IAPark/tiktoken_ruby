# yard-doctest [![Gem Version](https://badge.fury.io/rb/yard-doctest.svg)](http://badge.fury.io/rb/yard-doctest) [![Build Status](https://travis-ci.org/p0deje/yard-doctest.svg?branch=master)](https://travis-ci.org/p0deje/yard-doctest)

Have you ever wanted to turn your amazing code examples into something that really make sense, is always up-to-date and bullet-proof? Were looking at an amazing [Python doctest](https://docs.python.org/3/library/doctest.html)? Well, look no longer!

Meet `YARD::Doctest` - simple and magical gem, which automatically parses your `@example` tags and turn them into tests!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yard-doctest'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install yard-doctest
```

## Basic usage

Let's imagine you have the following library:

```
lib/
  cat.rb
  dog.rb
```

Each file contains some class and methods:

```ruby
# cat.rb
class Cat
  # @example
  #   Cat.word #=> 'meow'
  def self.word
    'meow'
  end

  def initialize(can_hunt_dogs = false)
    @can_hunt_dogs = can_hunt_dogs
  end

  # @example Usual cat cannot hunt dogs
  #   cat = Cat.new
  #   cat.can_hunt_dogs? #=> false
  #
  # @example Lion can hunt dogs
  #   cat = Cat.new(true)
  #   cat.can_hunt_dogs? #=> true
  #
  # @example Mutated cat can hunt dogs too
  #   cat = Cat.new
  #   cat.instance_variable_set(:@can_hunt_dogs, true) # not part of public API
  #   cat.can_hunt_dogs? #=> true
  def can_hunt_dogs?
    @can_hunt_dogs
  end
end
```

```ruby
# dog.rb
class Dog
  # @example
  #   Dog.word #=> 'meow'
  def self.word
    'woof'
  end

  # @example Dogs never hunt dogs
  #   dog = Dog.new
  #   dog.can_hunt_dogs? #=> false
  def can_hunt_dogs?
    false
  end
end
```

You can run tests for all the examples you've documented.

First of all, you need to tell YARD to automatically load `yard-doctest` (as well as other plugins).
To do so, add yard-doctest as an automatically loaded plugin in your `.yardops`:

```bash
# .yardopts
--plugin yard-doctest
```

Next, you'll need to create test helper, which will be required before each of your test. Think about it as `spec_helper.rb` in RSpec or `env.rb` in Cucumber. You should require everything necessary for your examples to run there.

```bash
$ touch doctest_helper.rb
# or move it into either the `support` or `spec` directory
```

```ruby
# doctest_helper.rb
require 'lib/cat'
require 'lib/dog'
```

That's pretty much it, you can now run your examples:

```bash
$ bundle exec yard doctest
Run options: --seed 5974

# Running:

..F...

Finished in 0.015488s, 387.3967 runs/s, 387.3967 assertions/s.

  1) Failure:
Dog.word#test_0001_ [lib/dog.rb:5]:
Expected: "meow"
  Actual: "woof"

6 runs, 6 assertions, 1 failures, 0 errors, 0 skips
```

Oops, let's go back and fix the example by change "meow" to "woof" in `Dog.word` and re-run the examples:

```bash
$ sed -i.bak s/meow/woof/g lib/dog.rb
$ bundle exec yard doctest
Run options: --seed 51966

# Running:

......

Finished in 0.002712s, 2212.3894 runs/s, 2212.3894 assertions/s.

6 runs, 6 assertions, 0 failures, 0 errors, 0 skips
```

Pretty simple, ain't it? Need more details about the way it parses examples?

Think about `#=>` as equality assertion: everything before is actual result, everything after is expected result and they are asserted using `#==`.

You can use as many assertions as you want in a single example:

```ruby
class Cat
  # @example
  #   cat = Cat.new
  #   cat.can_hunt_dogs? #=> false
  #   cat = Cat.new(true)
  #   cat.can_hunt_dogs? #=> true
  def can_hunt_dogs?
    @can_hunt_dogs
  end
end
```

In this case, example will be run as a single test but with multiple assertions:

```bash
$ bundle exec yard doctest lib/cat.rb
# ...
1 runs, 2 assertions, 0 failures, 0 errors, 0 skips
```

If your example has no assertions, it will still be evaluated to ensure nothing is raised at least:

```ruby
class Cat
  # @example
  #   cat = Cat.new
  #   cat.can_hunt_dogs?
  def can_hunt_dogs?
    @can_hunt_dogs
  end
end
```

```bash
$ bundle exec yard doctest lib/cat.rb
# ...
1 runs, 0 assertions, 0 failures, 0 errors, 0 skips
```

Pretty simple, ain't it? Need more details about the way it runs the tests?

It is actually delegated to amazing [minitest](https://github.com/seattlerb/minitest) and each example is an instance of `Minitest::Spec`.

## Advanced usage

### Exceptions

If you want to use example that raises exception, this can be achieved by specifying the correct expected value:

```ruby
class Calculator
  # @example
  #   divide(1, 0) #=> raise ZeroDivisionError, "divided by 0"
  def divide(one, two)
    one / two
  end
end
```

The comparison of raised exceptions is being done by string containing the class and message of exceptions. With that said, you have to use the same message in expected value as the one that is used in actual.

### Test helper

You can define any methods and instance variables in test helper and they will be available in examples.

For example, if we change the examples for `Cat#can_hunt_dogs?` like that:

```ruby
# cat.rb
class Cat
  # @example Usual cat cannot hunt dogs
  #   cat.can_hunt_dogs? #=> false
  def can_hunt_dogs?
    @can_hunt_dogs
  end
end
```

And run the examples - it will fail because `cat is undefined`:

```bash
$ bundle exec yard doctest
  # ...
  1) Error:
Cat#can_hunt_dogs?#test_0001_Usual cat cannot hunt dogs:
NameError: undefined local variable or method `cat' for Object:Class
  # ...
```

If you don't want to create new instance of class each time (or include module if you're testing it), you can fix this by defining a method in test helper:

```ruby
# doctest_helper.rb
require 'lib/cat'
require 'lib/dog'

def cat
  @cat ||= Cat.new
end
```

### Hooks

In case you need to do some preparations/cleanup between tests, hooks are at your service to be defined in test helper:

```ruby
YARD::Doctest.configure do |doctest|
  doctest.before do
    # this is called before each example and
    # evaluated in the same context as example
    # (i.e. has access to the same instance variables)
  end

  doctest.after do
    # same as `before`, but runs after each example
  end

  doctest.after_run do
    # runs after all the examples and
    # has different context
    # (i.e. no access to instance variables)
  end
end
```

There is also a way to limit hooks to specific tests based on class/method name:

```ruby
YARD::Doctest.configure do |doctest|
  doctest.before('MyClass') do
    # this will only be called for doctests of `MyClass` class
    # and all its methods (i.e. `MyClass.foo`, `MyClass#bar`)
  end

  doctest.after('MyClass#foo') do
    # this will only be called for doctests of `MyClass#foo`
  end

  doctest.before('MyClass#foo@Example one') do
    # this will only be called for example `Example one` of `MyClass#foo`
  end
end
```

### Skip

You can skip running some of the tests:

```ruby
YARD::Doctest.configure do |doctest|
  doctest.skip 'MyClass' # will skip doctests for `MyClass` and all its methods
  doctest.skip 'MyClass#foo' # will skip doctests for `MyClass#foo`
end
```

### Rake

There is also a Rake task for you:

```ruby
# Rakefile
require 'yard/doctest/rake'

YARD::Doctest::RakeTask.new do |task|
  task.doctest_opts = %w[-v]
  task.pattern = 'lib/**/*.rb'
end
```

```bash
$ bundle exec rake yard:doctest
```

## Is it really used?

Well, yeah. A great example of using yard-doctest is [watir-webdriver](https://github.com/watir/watir-webdriver).

## Testing

There are some system tests implemented with [Aruba](https://github.com/cucumber/aruba):

```bash
$ bundle install
$ bundle exec rake cucumber
```

## Contributing

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with Rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.
