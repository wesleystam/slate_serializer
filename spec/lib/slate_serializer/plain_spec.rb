require 'spec_helper'

RSpec.describe SlateSerializer::Plain do
  describe '.deserializer' do
    text = %(
      1. Number one
      Some text on the next line

      2. Number two
      Some text on the next line

      3. Number three
      Some text on the next line

      4. Number four
      Some text on the next line
    )

    context 'when the text is nil' do
      it 'return a empty state' do
        expect(described_class.deserializer(nil)).to eq(
          document: {
            object: 'document',
            nodes: [
              {
                data: {},
                object: 'block',
                type: 'paragraph',
                nodes: [
                  {
                    marks: [],
                    object: 'text',
                    text: ''
                  }
                ]
              }
            ]
          }
        )
      end
    end

    context 'when the text holds a string' do
      it 'convert the text to Slatejs raw' do
        raw = described_class.deserializer(text)

        expect(raw[:document][:object]).to eq 'document'
        expect(raw[:document][:nodes].length).to be 4
        expect(raw[:document][:nodes][2][:type]).to eq 'paragraph'
        expect(raw[:document][:nodes][2][:nodes][0][:text]).to eq "3. Number three\nSome text on the next line"
      end
    end
  end

  describe '.serializer' do
    context 'when the value does not have a document key' do
      it 'return an empty string' do
        expect(described_class.serializer({})).to eq ''
      end
    end

    context 'when the value holds an Slate Value' do
      it 'converts the Slate value to plain text' do
        value = {
          document: {
            object: 'document',
            nodes: [
              {
                object: 'block',
                type: 'paragraph',
                nodes: [
                  { text: 'Some text and lalala' }
                ]
              },
              {
                object: 'block',
                type: 'paragraph',
                nodes: [
                  { text: 'Next line' }
                ]
              }
            ]
          }
        }

        plain_text = described_class.serializer(value)
        expect(plain_text).to eq "Some text and lalala\nNext line"
      end
    end
  end
end
