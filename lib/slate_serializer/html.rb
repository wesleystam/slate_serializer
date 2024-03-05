require 'nokogiri'

module SlateSerializer
  # Html de- and serializer
  class Html
    # Default lookup list to convert html tags to object types
    ELEMENTS = {
      'a': 'link',
      'img': 'image',
      'li': 'list-item',
      'p': 'paragraph',
      'div': 'paragraph',
      'ol1': 'ordered-list',
      'ola': 'alpha-ordered-list',
      'ol': 'ordered-list',
      'ul': 'unordered-list',
      'table': 'table',
      'tbody': 'tbody',
      'tr': 'tr',
      'td': 'td',
      'text': 'text',
      'hr': 'hr',
      'figure': 'figure',
      'figcaption': 'figcaption'
    }.freeze
    # Default block types list
    BLOCK_ELEMENTS = %w[figure figcaption hr img li p ol ul table tbody tr td].freeze
    # Default inline types list
    INLINE_ELEMENTS = %w[a].freeze
    # Default mark types list
    MARK_ELEMENTS = {
      'em': 'italic',
      'strong': 'bold',
      'u': 'underline'
    }.freeze

    class << self
      # Convert html to a Slate document
      #
      # @param html format [String] the HTML
      # @param options [Hash]
      # @option options [Array] :elements Lookup list to convert html tags to object types
      # @option options [Array] :block_elemnts List of block types
      # @option options [Array] :inline_elemnts List of inline types
      # @option options [Array] :mark_elemnts List of mark types
      def deserializer(html, options = {})
        return empty_state if html.nil? || html == ''

        self.elements = options[:elements] || ELEMENTS
        self.block_elements = options[:block_elements] || BLOCK_ELEMENTS
        self.inline_elements = options[:inline_elements] || INLINE_ELEMENTS
        self.mark_elements = options[:mark_elements] || MARK_ELEMENTS

        html = html.gsub('<br>', "\n")
        nodes = Nokogiri::HTML.fragment(html).elements.map do |element|
          element_to_node(element)
        end

        {
          document: {
            object: 'document',
            nodes: nodes
          }
        }
      end

      # Convert html to a Slate document
      #
      # @param value format [Hash] the Slate document
      # @return [String] plain text version of the Slate documnent
      def serializer(value)
        return '' unless value.key?(:document)

        self.mark_elements = MARK_ELEMENTS.invert

        serialize_node(value[:document])
      end

      private

      attr_accessor :elements, :block_elements, :inline_elements, :mark_elements

      def element_to_node(element)
        type = convert_name_to_type(element)

        nodes = element.children.flat_map do |child|
          if block?(child)
            element_to_node(child)
          elsif inline?(child)
            element_to_inline(child)
          else
            next if child.text.strip == ''

            element_to_texts(child)
          end
        end.compact

        nodes << { marks: [], object: 'text', text: '' } if nodes.empty? && type != 'image'

        {
          data: element.attributes.each_with_object({}) { |a, h| h[a[1].name] = a[1].value },
          object: 'block',
          nodes: nodes,
          type: type
        }
      end

      def element_to_inline(element)
        type = convert_name_to_type(element)
        nodes = element.children.flat_map do |child|
          element_to_texts(child)
        end

        {
          data: element.attributes.each_with_object({}) { |a, h| h[a[1].name] = a[1].value },
          object: 'inline',
          nodes: nodes,
          type: type
        }
      end

      def element_to_texts(element)
        nodes = []
        mark = convert_name_to_mark(element.name)

        if element.instance_of?(Nokogiri::XML::Element)
          element.children.each do |child|
            nodes << element_to_text(child, mark)
          end
        else
          nodes << element_to_text(element)
        end

        nodes
      end

      def element_to_text(element, mark = nil)
        marks = [mark, convert_name_to_mark(element.name)].compact
        {
          marks: marks,
          object: 'text',
          text: element.text
        }
      end

      def convert_name_to_type(element)
        type = [element.name, element.attributes['type']&.value].compact.join
        elements[type.to_sym] || elements[:p]
      end

      def convert_name_to_mark(name)
        type = mark_elements[name.to_sym]

        return nil unless type

        {
          data: [],
          object: 'mark',
          type: type
        }
      end

      def block?(element)
        block_elements.include?(element.name)
      end

      def inline?(element)
        inline_elements.include?(element.name)
      end

      def empty_state
        {
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
        }
      end

      def serialize_node(node)
        case node[:object]
        when 'document'
          node[:nodes].map { |n| serialize_node(n) }.join
        when 'block'
          children = node[:nodes].map { |n| serialize_node(n) }.join

          element = ELEMENTS.find { |_, v| v == node[:type] }[0]
          data = node[:data].map { |k, v| "#{k}=\"#{v}\"" }

          if %i[ol1 ola].include?(element)
            data << ["type=\"#{element.to_s[-1]}\""]
            element = :ol
          end

          "<#{element}#{!data.empty? ? " #{data.join(' ')}" : ''}>#{children}</#{element}>"
        else
          if node[:marks].nil? || node[:marks].empty?
            node[:text]
          else
            elements = node[:marks].map { |m| mark_elements[m[:type]] }
            marks = elements.map { |m| "<#{m}>" }.join
            "#{marks}#{node[:text]}#{elements.map { |m| "</#{m}>" }.join}"
          end
        end
      end
    end
  end
end
