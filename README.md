# docxgen

[![Build Status](https://travis-ci.org/4ndv/docxgen.svg?branch=master)](https://travis-ci.org/4ndv/docxgen)

Docxgen is a Ruby library for templating docx files based on [ruby-docx](https://github.com/ruby-docx/docx).

## Features

- Validates if there is any variables without provided values
- Supports arrays
- Preserves formatting
- Supports non-latin variable names (cyrillic, for example)

## Requirements

Ruby 2.4+

## Installation

Add this line to your application's Gemfile:

```ruby
gem "docxgen"
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install docxgen
```

## Usage

### Variables

Example of variables and corresponding hashes:

```ruby
# {{ hello }} => world

{ hello: "world" }

# {{ hello.world }} => wow

{ hello: { world: "wow" } }

# {{ array.0.name }} => Wow

{ array: [ { name: "Wow" } ]}

# {{ Привет.Мир }} => 123

{ "Привет": { "Мир": "123" } }
```

### Reading file

```ruby
generator = Docxgen::Generator.new("template.docx")
```

### Rendering

```ruby
generator.render({ variable: "Value" }, remove_missing: true)
```

Options:

`remove_missing` [default: true] - Replaces variables without provided values with empty string

### Checking render results

```ruby
generator.valid? # Returns true if there is no errors

puts generator.errors # Returns array of the errors
```

### Saving file

```ruby
generator.save("result.docx")
```

Alternatively you can use `stream` method if you want to get result as `StringIO` (for example, for saving it in ActiveStorage):

```ruby
io = generator.stream
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## TODO

- Add error objects

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/4ndv/docxgen](https://github.com/4ndv/docxgen).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
