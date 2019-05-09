# SlateSerializer

SlateSerializer de- and serializer text and html to Slate document values in Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'slate_serializer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install slate_serializer

## Usage

To convert between plain text and Slate document use:

    $ SlateSerializer::Plain.serializer({ document: {...}}) => text
    $ SlateSerializer::Plain.deserializer(text) => { document: {...}}

To convert between html and Slate document use:

    $ SlateSerializer::Html.deserializer(text) => { document: {...}}

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wesleystam/slate_serializer.
