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
      'ola': 'alpha-ordered-list',
      'ol': 'ordered-list',
      'ul': 'unordered-list',
      'table': 'table',
      'tbody': 'tbody',
      'tr': 'tr',
      'td': 'td',
      'text': 'text'
    }.freeze
    # Default block types list
    BLOCK_ELEMENTS = %w[img li p ol ul table tbody tr td].freeze
    # Default inline types list
    INLINE_ELEMENTS = %w[a].freeze
    # Default mark types list
    MARK_ELEMENTS = {
      'em': 'italic',
      'strong': 'bold',
      'u': 'underline'
    }.freeze

    class << self
      # Convert html to a Slare document
      #
      # @param html format [String] the HTML
      # @param options [Hash]
      # @option options [Array] :elements Lookup list to convert html tags to object types
      # @option options [Array] :block_elemnts List of block types
      # @option options [Array] :inline_elemnts List of inline types
      # @option options [Array] :mark_elemnts List of mark types
      def deserializer(html, options = {})
        return empty_state if html.nil?

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

      private

      attr_accessor :elements, :block_elements, :inline_elements, :mark_elements

      def element_to_node(element)
        type = convert_name_to_type(element)

        nodes = element.children.flat_map do |child|
          next if child.text.strip == '' && child.type == 'img'

          if block?(child)
            element_to_node(child)
          elsif inline?(child)
            element_to_inline(child)
          else
            next if child.text.strip == ''

            element_to_texts(child)
          end
        end.compact

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

        if element.class == Nokogiri::XML::Element
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
        elements[type.to_sym]
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
    end
  end
end
