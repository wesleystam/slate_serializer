module SlateSerializer
  # From to plain text converter
  class Plain
    class << self
      # Convert an Slate Document to plain text
      #
      # @param value format [Hash] the Slate document
      # @param options format [Hash] options for the serializer, delimitter defaults to "\n"
      # @return [String] plain text version of the Slate documnent
      def serializer(value, options = {})
        return '' unless value.key?(:document)

        options[:delimiter] = "\n" unless options.key?(:delimiter)
        serialize_node(value[:document], options)
      end

      private

      def serialize_node(node, options)
        if node[:object] == 'document' || node[:object] == 'block'
          node[:nodes].map { |n| serialize_node(n, options) }.join(options[:delimiter])
        else
          node[:leaves].map { |l| l[:text] }.join(' ')
        end
      end
    end
  end
end
