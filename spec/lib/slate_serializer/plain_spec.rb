require 'spec_helper'

RSpec.describe SlateSerializer::Plain do
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
                  leaves: [
                    { text: 'Some text' },
                    { text: 'and lalala' }
                  ]
                ]
              },
              {
                object: 'block',
                type: 'paragraph',
                nodes: [
                  leaves: [
                    { text: 'Next line' }
                  ]
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
